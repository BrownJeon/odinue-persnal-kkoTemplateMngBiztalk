#!/bin/bash
PPP=$PWD
cd ../bin

. env.sh
cd $PPP
export CLASSPATH=$M1_HOME/lib/m1core1.0.jar:$M1_HOME/lib/m1vela1.0.jar:$CLASSPATH:$M1_HOME/lib/jai_core.jar:$M1_HOME/lib/jai_codec.jar  
java -agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=5005 -Dm1.ftl.home=. com.odinues.m1vela.ftl.Vela $@


