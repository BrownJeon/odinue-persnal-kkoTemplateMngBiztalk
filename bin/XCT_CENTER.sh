#!/bin/bash
M1PNM=XCENTER
M1PID=2017Y01M01D_${M1PNM}_00H00M00S_ODI
PIDS=""

.  ./env.sh
M1LOGF=$M1_LOG/$M1PNM.log
.  ./m1func.sh


runutil $M1PID $1 "$2"

nohup $M1_JAVA $M1_JVMOPT -Dm1.pid=$M1PID -Dm1.config.file=$M1_CONFIG -server -Xms64m -Xmx128m com.odinues.m1vela.m1.VelaXCenter $M1PNM 24049 >> $M1LOGF &

aftercheck $M1PID $!