#!/bin/bash
M1PNM=STAT_DAYS
PIDS=""

. ./env.sh
M1LOGF=$M1_LOG/$M1PNM.`date +%Y%m%d%H%M%S`.log
. ./m1func.sh

nohup $M1_JAVA -server -Xms128m -Xmx128m -Dm1.ftl.home=$M1_HOME com.odinues.m1vela.ftl.Vela bin/cron/stat/stat_days_scanner.ftl  >>  $M1LOGF  & 