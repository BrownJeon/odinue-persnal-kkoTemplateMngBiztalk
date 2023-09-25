#!/bin/bash
. ./env.sh
$M1_JAVA $M1_JVMOPT -Dm1.pid=$M1PID -Xmx1024m $PKGBIZ.ipc.SmsqmJ $@