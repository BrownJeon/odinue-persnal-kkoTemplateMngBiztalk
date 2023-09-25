#!/bin/bash
M1PNM=TKM_FILES
M1PID=A1501135_${M1PNM}_10A0A5500C6
PIDS=""

. ./env.sh
M1LOGF=$M1_LOG/$M1PNM.log
. ./m1func.sh


runutil $M1PID $1 "$2"

nohup $M1_JAVA $M1_JVMOPT -Dm1.pid=$M1PID -Dm1.config.file=$M1_CONFIG -server -Xms16m -Xmx512m $PKGBIZ.frwx.process.TaskManager $M1PNM &>> $M1LOGF &

aftercheck $M1PID $!