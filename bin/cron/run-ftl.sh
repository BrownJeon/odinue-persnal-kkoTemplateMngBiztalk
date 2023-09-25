#!/bin/bash

. env.sh 
. m1func.sh

cd $M1_HOME/bin/cron

$M1_JAVA $M1_JVMOPT -Dlog=$1 -Dm1.ftl.home=$M1_HOME/bin/cron -Dm1.config.file=$M1_CONFIG -server com.odinues.m1vela.ftl.Vela $1 $2 $3 $4 $5 $6 &>> $M1_HOME/logs/$1.log