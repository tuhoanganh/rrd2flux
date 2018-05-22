#!/bin/bash
#set -e

export HOST=$(echo '10.51.16.43')
export PORT=$(echo '8086')
export DB=$(echo 'mobi_nms')
export USER=$(echo 'juniper')
export PASSWORD=$(echo 'juniper@123')
export DIR=$(echo '/opt/perfdata_20180517')
export device
export FIRST_TIME=$(echo '-90days')
# 2-2-2018 -> 2-5-2018
#export FIRST_TIME=$(echo '1517734800')
#export LAST_TIME=$(echo '1525219200')
#export RRD_MIN_RES=$(echo '1800')

# 15-08-2017 -> 02-02-2018
#export FIRST_TIME=$(echo '1502755200')
#export LAST_TIME=$(echo '1517616000')
#export RRD_MIN_RES=$(echo '21600')

# 30-04-2018 -> 09-05-2018
#export FIRST_TIME=$(echo '1525046400')
#export LAST_TIME=$(echo '1525885200')
#export RRD_MIN_RES=$(echo '1800')

export FIRST_TIME=$(echo '1525737600')
export LAST_TIME=$(echo '1525777200')
export RRD_MIN_RES=$(echo '300')

export routers=$(ls /usr/share/pnp4nagios/var/perfdata/)
export routers=$(ls $DIR  |grep -v "ICINGA01-MonitorFromICINGA02" | grep -v "icinga-mobifone")
export routers=$(echo "ME-AGG-HNI-1.1---HN_TXN_HV_KHONG_QUAN")

in_bits(){
echo "############### in_bits ###############"
for i in $routers
do
  export HOSTNAME=$(echo $i)
  echo $i
  for j in `find $DIR/$i/IfCheck*.rrd -printf "%f\n"`
  do
    echo $j
    export COUNT=$(rrdtool fetch $DIR/$i/$j  MAX -e $LAST_TIME -s $FIRST_TIME | grep -v 'nan'| sed -e 's/://g'| sed '1d' |grep -Ev '^$' | wc -l)
    if [[ $COUNT == 0 ]]; then
      echo $j "has not entry!"
    else
      export BEGIN_DATA_TIME=$(rrdtool fetch $DIR/$i/$j  MAX -e $LAST_TIME -s $FIRST_TIME | grep -v 'nan'| sed -e 's/://g'| sed '1d' |grep -Ev '^$' | head -n 1| awk '{print $1}')
      ./both/rrdflux_ifcheck_inbits.py -f $DIR/$i/$j -D $HOSTNAME -H $HOST -p $PORT -d $DB -U $USER -P $PASSWORD --service $j -F $BEGIN_DATA_TIME -L $LAST_TIME -R $RRD_MIN_RES
    fi
  done
done
}

out_bits(){
echo "############### out_bits ###############"
for i in $routers
do
  export HOSTNAME=$(echo $i)
  echo $i
  for j in `find $DIR/$i/IfCheck*.rrd -printf "%f\n"`
  do
    echo $j
    export COUNT=$(rrdtool fetch $DIR/$i/$j  MAX -e $LAST_TIME -s $FIRST_TIME | grep -v 'nan'| sed -e 's/://g'| sed '1d' |grep -Ev '^$' | wc -l)
    if [[ $COUNT == 0 ]]; then
      echo $j "has not entry!"
    else
      export BEGIN_DATA_TIME=$(rrdtool fetch $DIR/$i/$j  MAX -e $LAST_TIME -s $FIRST_TIME | grep -v 'nan'| sed -e 's/://g'| sed '1d' |grep -Ev '^$' | head -n 1| awk '{print $1}')
      ./both/rrdflux_ifcheck_outbits.py -f $DIR/$i/$j -D $HOSTNAME -H $HOST -p $PORT -d $DB -U $USER -P $PASSWORD --service $j -F $FIRST_TIME -L $LAST_TIME -R $RRD_MIN_RES
    fi
  done
done
}

in_bits
out_bits
