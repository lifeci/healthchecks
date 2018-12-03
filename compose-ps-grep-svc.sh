#!/bin/bash
SvcName=$1
Delay=$2;
if [ -z $SvcName ]; then echo 'USAGE: compose-ps-grep-svc.sh $SvcName $Delay' && exit -2; fi
if [ -z $Delay ]; then Delay=1; fi

#unset COUNTER; unset health; unset healthy;

while [[ "$COUNTER" -lt 10 ]] || [ "$healthy" == 'true' ]; do
  health=$(docker-compose  ps | grep $SvcName);
  let COUNTER=COUNTER+1; sleep $Delay;
  if [[ "$health" == *"Up (healthy)"* ]]; then
    printf "$COUNTER | $health\n";
    healthy=true
  else
    printf "$COUNTER | $health\n";
  fi;
done

if [ "$healthy" == 'true' ]; then
  echo "ALL RIGHT!";
  exit 0
else
  echo "ALL BAD :(";
  exit -1
fi
