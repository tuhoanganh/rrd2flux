#!/bin/bash

export HOST=$(echo '10.51.16.43')
export PORT=$(echo '8086')
export DB=$(echo 'mobi_nms')
export USER=$(echo 'juniper')
export PASSWORD=$(echo 'juniper@123')
export DIR=$(echo '/opt/perfdata')
export DIR=$(echo '/tmp')
export device
export FIRST_TIME=$(echo '-90days')
# 2-2-2018 -> 2-5-2018
export FIRST_TIME=$(echo '1517734800')
export LAST_TIME=$(echo '1525219200')
export RRD_MIN_RES=$(echo '1800')

# 15-08-2017 -> 02-02-2018
#export FIRST_TIME=$(echo '1502755200')
#export LAST_TIME=$(echo '1517616000')
#export RRD_MIN_RES=$(echo '21600')

export routers=$(ls /usr/share/pnp4nagios/var/perfdata/)
export routers=$(ls $DIR)
export routers=$(echo "icinga-mobifone-1 icinga-mobifone-2")

rta(){
echo "############### RTA ###############"
for i in $routers
do
  export HOSTNAME=$(echo $i)
  export COUNT=$(rrdtool fetch $DIR/$i/ping4.rrd  MAX -e $LAST_TIME -s $FIRST_TIME | grep -v 'nan'| sed -e 's/://g'| sed '1d' |grep -Ev '^$' | wc -l)
  if [[ $COUNT == 0 ]]; then
    echo $i "has no entry!"
  else
    echo $i
    export BEGIN_DATA_TIME=$(rrdtool fetch $DIR/$i/ping4.rrd  MAX -e $LAST_TIME -s $FIRST_TIME | grep -v 'nan'| sed -e 's/://g'| sed '1d' |grep -Ev '^$' | head -n 1| awk '{print $1}')
    ./both/rrdflux_ping4_rta.py -f $DIR/$i/ping4.rrd -D $HOSTNAME -H $HOST -p $PORT -d $DB -U $USER -P $PASSWORD  -F $FIRST_TIME -L $LAST_TIME -R $RRD_MIN_RES
  fi
done
}

pl(){
echo "############### PL ###############"
for i in $routers
do
  export HOSTNAME=$(echo $i)
  export COUNT=$(rrdtool fetch $DIR/$i/ping4.rrd  MAX -e $LAST_TIME -s $FIRST_TIME | grep -v 'nan'| sed -e 's/://g'| sed '1d' |grep -Ev '^$' | wc -l)
  if [[ $COUNT == 0 ]]; then
    echo $i "has no entry!"   
  else
    echo $i
    export BEGIN_DATA_TIME=$(rrdtool fetch $DIR/$i/ping4.rrd  MAX -e $LAST_TIME -s $FIRST_TIME | grep -v 'nan'| sed -e 's/://g'| sed '1d' |grep -Ev '^$' | head -n 1| awk '{print $1}')
    ./both/rrdflux_ping4_pl.py -f $DIR/$i/ping4.rrd -D $HOSTNAME -H $HOST -p $PORT -d $DB -U $USER -P $PASSWORD  -F $FIRST_TIME -L $LAST_TIME -R $RRD_MIN_RES
  fi
done
}

rta
pl
