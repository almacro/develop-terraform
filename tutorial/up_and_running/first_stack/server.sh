#!/bin/bash
sudo yum install nmap-ncat
echo "Hello, World" > index.html
echo <<EOF >> server.sh
while true; do
  printf 'HTTP/1.1 200 OK\n\n%s' $(cat index.html) | nc -l 8999
done
EOF
nohup server.sh &
