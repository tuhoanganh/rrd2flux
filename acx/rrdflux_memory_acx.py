#!/usr/bin/python
# -*- coding: utf-8 -*-

import sys,getopt
import re
import os
import subprocess
import rrdtool
import xml.etree.ElementTree as ET
import pprint
from influxdb import InfluxDBClient


def main(argv):

   RRD_MIN_RES=""

   update=False
   dump=True
   fname=""
   host=""
   port="8086"
   db=""
   user=""
   password=""
   hostname=""
   first_time=""
   last_time=""

   tag1="hostname"
   tag2="metric"
   tag3="service"
   tag4="service_type"

   value1="value"
   value2_metric1="MEM_RE0"
   service="Juniper_Memory_ACX"
   value4="MEM"

   def help():
      print('Usage: rddflux.py [-u|-m] -f <RRD FILE> [-H <INFLUXDB HOST>] [-p <INFLUXDB PORT>] -d DATABASE [-U user] [-P password] [-k KEY] -S service [-h] ')
      print('Updates or dumps passed RRD File to selected InfluxDB database')
      print('	-h, --help		Display help and exit')
      print('	-u, --update		Only update database with last value')
      print('	-m, --dump		Dump full RRD to database')
      print('	-f, --file		RRD file to dump')
      print('	-H, --host		Optional. Name or IP of InfluxDB server. Default localhost.')
      print('	-p, --port		Optional. InfluxDB server port. Default 8086.')
      print('	-d, --database		Database name where to store data.')
      print('	-U, --user		Optional. Database user.')
      print('	-P, --password		Optional. Database password.')
      print('	-k1, --tag1		Optional. Key used to store data values. Taken from RRD file\'s name if not specified.')
      print('	-k2, --tag2		Optional. Key used to store data values. Taken from RRD file\'s name if not specified.')
      print('	-k3, --tag3		Optional. Key used to store data values. Taken from RRD file\'s name if not specified.')
      print('	-S, --service		Device the RRD metrics are related with.')
      print('	-D, --hostname		Device name to store in the hostname value.')
      print('	-M1, --value2_metric1		Metric name 1.')
      print('	-M2, --value2_metric2		Metric name 2.')
   try:
      opts, args = getopt.getopt(argv,"humf:H:p:d:U:P:k:D:F:L:R:",["help=","update=","dump=","file=","host=","port=","database=","user=","password=","value=","service=","hostname=","first_time=","last_time=","RRD_MIN_RES="])
   except getopt.GetoptError:
      help()
      sys.exit(2)

   for opt, arg in opts:
      if opt == '-h':
         help()
         sys.exit()
      elif opt in ("-u", "--update"):
         update = True
      elif opt in ("-m", "--dump"):
         dump = True
      elif opt in ("-f", "--file"):
         fname = arg
      elif opt in ("-H", "--host"):
         host = arg
      elif opt in ("-p", "--port"):
         port = arg
      elif opt in ("-d", "--database"):
         db = arg
      elif opt in ("-U", "--user"):
         user = arg
      elif opt in ("-P", "--password"):
         password = arg
      elif opt in ("-k", "--tag"):
         tag = arg
      elif opt in ("-D", "--hostname"):
         hostname = arg
      elif opt in ("-S", "--service"):
         service = arg
      elif opt in ("-F", "--first_time"):
         first_time = arg
      elif opt in ("-L", "--last_time"):
         last_time = arg
      elif opt in ("-R", "--RRD_MIN_RES"):
         RRD_MIN_RES = arg

   if service == "" or fname == "" or db == "" or (update == False and dump == False) or (update == True and dump == True):
      print("ERROR: Missing or duplicated parameters.")
      help()
      sys.exit(2)

   client = InfluxDBClient(host, port, user, password, db)
   client.query("create database "+db+";") # Create database if it not exists
   
   if dump == True:
      allvalues = rrdtool.fetch(
         fname,
         "MAX",
         '-e', str(last_time),
         '-s', str(first_time))
#         '-r', str(RRD_MIN_RES))
      json_body1 = []
      i=0
      unixts1=int(first_time)
      while i < len(allvalues[2]):
         val1=allvalues[2][i][0]

         if val1 is None:
           i=i+1
         else:
           json_body1.append({
                 "measurement": "snmp",
                 "time": (unixts1*1000000000),
                 "tags": {
                     tag1: hostname,
                     tag2: value2_metric1,
                     tag3: service,
                    tag4: value4,
                 },
                 "fields": {
                     value1: val1,
                 }
              }
           )
           i=i+1
           unixts1=(unixts1+int(RRD_MIN_RES))
      client.write_points(json_body1)

if __name__ == "__main__":
   main(sys.argv[1:])


