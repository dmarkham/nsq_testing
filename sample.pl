use AnyEvent;
use AnyEvent::Handle;
use JSON::XS;
use Time::HiRes qw(time);
use bytes;
no bytes;

use strict;

my $jcode = JSON::XS->new();

my $host = $ARGV[0];
my $port = "4150";
use constant {FrameTypeResponse => 0,
              FrameTypeError    => 1,
              FrameTypeMessage  => 2,};

my $cv = AnyEvent->condvar;

my $hdl;
$hdl = new AnyEvent::Handle
  no_delay => 1,
  connect  => [$host, $port],
  on_error => sub {
  my ($hdl, $fatal, $msg) = @_;
  warn $msg;
  $hdl->destroy;
  $cv->send;
  };

$hdl->push_write("  V2");
$hdl->push_write("IDENTIFY\n");
push_data($jcode->encode({short_id => "Mytest", long_id =>"myTest.example.com"})  );


## My avg msg is about 400 bytes long
my $message = "X" x 400;


my $count;
my $time = time;
$hdl->on_read(
  sub {
        
    # some data is here, now queue the length-type (8 octets)
    shift->unshift_read(
      chunk => 8,
      sub {

        # header arrived, decode
        my ($len,$type) = unpack "NN", $_[1];
        # now read the payload
        shift->unshift_read(
          chunk => $len - 4,
          sub {
            my $data = $_[1];
            
            if($type == FrameTypeResponse && $data eq '_heartbeat_'){
              $hdl->push_write("NOP\n");
            }
            elsif($type == FrameTypeResponse && $data eq 'OK'){
             publish("test", $message);
             $count++;
             if($count % 100000 == 0){
               my $diff = time - $time;
               $time = time;
               printf("Time: %.7f seconds to add 100000 items\n",$diff);
               printf("Rate: %.7f/sec\n",$diff / 100000);
               exit;
             }
           }
            else{
              print "LEN:$len\tTYPE:$type\n";
              print "DATA:($data)\n";
            
            }
          });
      });
  });

$cv->recv;


## protocal helpers
sub publish{
  my $topic  = shift;
  my $data = shift;
  $hdl->push_write("PUB $topic\n");
  push_data($data );
}

sub mpublish{
  my $topic  = shift;
  my $data = shift;
  $hdl->push_write("PUB $topic\n");
  push_data($data );
}

sub push_data{
  my $data = shift;
  my $packed_len = pack("N",bytes::length($data));
  $hdl->push_write($packed_len . $data);

}



