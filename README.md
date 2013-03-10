nsq_testing
===========

nsq_testing


    Notes:
    
    Ok as we all know doing benchmarks are hard and loaded with caveats and mistakes.
     
    My take away: 
    Both were using 1 persistant connection.
    HTTP: had to move ~ 30% more data
    HTTP:  was about 4 times slower
    I'm convenced some of the slowdown is the byte size difference between the two. 
    The rest is the overhead of building and parsing HTTP.
     
     
     
    Few Notes:
    CentOS 5 on a 2  older 4core Xeon
    nsqd v0.2.18-alpha @ sha: 2555d091de
    go version go1.0.3
    perl v5.10.0
    LWP::UserAgent @ 5.835
    AnyEvent @ 5.31 using EV @ 4.03
     
    Here is how the nsqd is being run for these tests.
    ./nsqd  -lookupd-tcp-address=192.168.1.39:4160  -sync-every=10000 -mem-queue-size=1000
     
     
     
     
    The byte numbers:
    Publishing a 400byte message over http:
    write  573 bytes
    read  118 bytes
     
    Publishing over TCP:
    write: 413 bytes
    read:  10 bytes
     
     
    These results  are within the avg time after running it 5 times each. 
    The topic was droped between each run. 
    No channels were being created or consumed just pure queueing.
    The times:
     
  
    dmarkham@www01:~/dev/nsq (master) $ time perl_ev  sample.pl  db05.dev.myhost.com
    Time: 25.9672000 seconds to add 100000 items
    Rate: 0.0002597/sec
     
    real  0m26.018s
    user  0m7.949s
    sys	0m2.722s
     
     
    dmarkham@www01:~/dev/nsq (master) $ time perl_ev  http_sample.pl  db05.dev.myhost.com
    Time: 105.9750021 seconds to add 100000 items
    Rate: 0.0010598/sec
     
    real	1m46.029s
    user	1m7.270s
    sys	0m3.943s
     
  
     
    Sample  read/writes from each from my test script:
     
    HTTP Write:
    write : "POST /put?topic=test HTTP/1.1\r\nTE: deflate,gzip;q=0.3\r\nConnection: TE\r\nHost: my.host.com:4151\r\nContent-Length: 400\r\nContent-Type: application/x-www-form-urlencoded\r\n\r\nXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX" , 573)
     
    read:  "HTTP/1.1 200 OK\r\nContent-Length: 2\r\nDate: Sat, 09 Mar 2013 23:19:07 GMT\r\nContent-Type: text/plain; charset=utf-8\r\n\r\nOK", 1024) = 118
     
     
     
     
    TCP Write:
    write(8, "PUB test\n", 9)               = 9
    write(8, "\0\0\1\220XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX", 404) = 404
     
    read(8, "\0\0\0\6\0\0\0\0OK", 2048)     = 10
