#!/bin/bash
set -e

export HOST=$(echo '10.51.16.43')
export PORT=$(echo '8086')
export DB=$(echo 'mobi_nms')
export USER=$(echo 'juniper')
export PASSWORD=$(echo 'juniper@123')
export DIR=$(echo '/opt/perfdata')
export device
export FIRST_TIME=$(echo '-90days')
# 2-2-2018 -> 2-5-2018
#export FIRST_TIME=$(echo '1517734800')
#export LAST_TIME=$(echo '1525219200')
#export RRD_MIN_RES=$(echo '1800')

# 15-08-2017 -> 02-02-2018
export FIRST_TIME=$(echo '1502755200')
export LAST_TIME=$(echo '1517616000')
export RRD_MIN_RES=$(echo '21600')

export routers=$(ls /usr/share/pnp4nagios/var/perfdata/)
export routers=$(ls $DIR  |grep -v "ICINGA01-MonitorFromICINGA02" | grep -v "icinga-mobifone")

for i in $routers
do
  export HOSTNAME=$(echo $i)
  echo $i
  for j in `find $DIR/$i/Jitter*.rrd -printf "%f\n"`
  do
    export COUNT=$(rrdtool fetch $DIR/$i/$j  MAX -e $LAST_TIME -s $FIRST_TIME | grep -v 'nan'| sed -e 's/://g'| sed '1d' |grep -Ev '^$' | wc -l)
    if [[ $COUNT == 0 ]]; then
      echo $j "has not entry!"
    else
      echo $j
      export BEGIN_DATA_TIME=$(rrdtool fetch $DIR/$i/$j  MAX -e $LAST_TIME -s $FIRST_TIME | grep -v 'nan'| sed -e 's/://g'| sed '1d' |grep -Ev '^$' | head -n 1| awk '{print $1}')
      ./both/rrdflux_jitter.py -f$DIR/$i/$j -D $HOSTNAME -H $HOST -p $PORT -d $DB -U $USER -P $PASSWORD --service $j -F $BEGIN_DATA_TIME -L $LAST_TIME -R $RRD_MIN_RES
    fi
  done
done

