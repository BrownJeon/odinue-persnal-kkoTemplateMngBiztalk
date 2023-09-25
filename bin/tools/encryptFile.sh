#!/bin/bash
cd ..
.  env.sh

cd tools
$M1_JAVA $M1_JVMOPT -Dm1.pid=$M1PID  -server -Xms16m -Xmx16m  $PKGBIZ.util.CryptoFile $@
