#!/bin/bash
M1PNM=MNG_RCS_MSGBASE_FORM_SYNC
PIDS=""

. ./env.sh

M1LOGF=$M1_LOG/$M1PNM.`date +%Y-%m-%d`.log

$M1_JAVA -server -Xms128m -Xmx128m -Dm1.ftl.home=$M1_HOME -Dlog=$M1PNM.`date +%Y-%m-%d` com.odinues.m1vela.ftl.Vela config/vela/TMPL_RCS_EXT/include/biz/ftls/mng/rcsMsgbaseFormRBC2DatabaseSync.ftl >> $M1LOGF 2>&1 & 
# $M1_JAVA -server -Xms128m -Xmx128m -Dm1.ftl.home=$M1_HOME -Dlog=$M1PNM.`date +%Y-%m-%d` com.odinues.m1vela.ftl.Vela config/vela/TMPL_MNG/rcsMsgbaseFormRBC2DatabaseSync.ftl