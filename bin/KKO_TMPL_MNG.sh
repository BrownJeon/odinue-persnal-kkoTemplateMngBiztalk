#!/bin/bash
M1PNM=KKO_TMPL_MNG
M1PID=2023Y01M01D_${M1PNM}_00H00M00S_ODI
PIDS=""

. ./env.sh
M1LOGF=$M1_LOG/$M1PNM.log
. ./m1func.sh


runutil $M1PID $1 "$2"

nohup $M1_JAVA $M1_JVMOPT -Dm1.pid=$M1PID -Dm1.config.file=$M1_CONFIG -server -Xms128m -Xmx256m  $PKGBIZ.frwx.process.TaskManager $M1PNM  >> $M1LOGF &

aftercheck $M1PID $!