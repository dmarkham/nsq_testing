use Time::HiRes qw(time);
use LWP::UserAgent;
use LWP::ConnCache;
use strict;

my $host = $ARGV[0];
my $port = "4150";

my $ua = LWP::UserAgent->new(agent => "");
$ua->conn_cache(LWP::ConnCache->new());

## My avg msg is about 400 bytes long
my $message = "X" x 400;

my $time = time;
for (my $i = 0 ; $i < 100000 ; $i++) {
  my $res = $ua->post("http://$host:4151/put?topic=test", Content => $message);
  if ($res->code != 200) {
    die $res->content;
  } else {
    my $content = $res->content;
    #print "$content\n";
  }
}

my $diff = time - $time;
$time = time;
printf("Time: %.7f seconds to add 100000 items\n", $diff);
printf("Rate: %.7f/sec\n",                         $diff / 100000);
exit;

