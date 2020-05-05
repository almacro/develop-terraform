#!/usr/bin/env bash
#
# jump thru outside host and login to inside host
# tested on debian-buster

USAGE="$0 <outside_ip> <inside_IP>"

if [ $# -ne 2 ]; then
    echo "error: wrong number of args"
    echo $USAGE
    exit 1
fi

OUTSIDE_IP=$1
INSIDE_IP=$2
ssh \
    -i terraform-demo \
    -o ProxyCommand="ssh -i terraform-demo -W %h:%p ec2-user@${OUTSIDE_IP}" \
    ec2-user@${INSIDE_IP}
