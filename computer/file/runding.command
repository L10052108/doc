#!/bin/sh
 
cd `dirname $0`
echo `pwd`
echo "start dingding"
./ding -config=./ding.cfg -subdomain=liu 4001
