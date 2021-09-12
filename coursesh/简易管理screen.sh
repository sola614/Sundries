#!/bin/bash

SCNAME='gbf'
SERVICE='gbf-proxy'

start() {
   ps_out=`ps -ef | grep $SERVICE | grep -v 'grep' | grep -v $0`
   result=$(echo $ps_out | grep "$1")
   if [[ "$result" != "" ]] ; then
       echo "$SERVICE is already running!"
       exit
   else
       echo "Starting $SERVICE..."
       screen -S $SCNAME -dm /home/centos/gbf-proxy local --host 0.0.0.0 --port 12345
       sleep 10
       screen -S $SCNAME -X stuff 'gbf-proxy starting'
           exit
   fi
   exit
}

stop() {
   ps_out=`ps -ef | grep $SERVICE | grep -v 'grep' | grep -v $0`
   result=$(echo $ps_out | grep "$1")
   if [[ "$result" != "" ]] ; then
       echo "Stopping $SERVICE "
       screen -S $SCNAME -X quit
           exit
   else
       echo "$SERVICE is not running!"
       exit
   fi
   exit
}

status() {
   ps_out=`ps -ef | grep $SERVICE | grep -v 'grep' | grep -v $0`
   result=$(echo $ps_out | grep "$1")
   if [[ "$result" != "" ]] ; then
       echo "$SERVICE is already running!"
       exit
   else
       echo "$SERVICE is not running!"
       exit
   fi
}

case "$1" in
   start)
       start
       ;;
   stop)
       stop
       ;;
   status)
       status
       ;;
   *)
       echo  $"Usage: $0 {start|stop|status}"
esac
