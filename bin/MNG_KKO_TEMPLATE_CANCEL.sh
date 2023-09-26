#!/bin/bash
M1PNM=MNG_KKO_TEMPLATE_CANCEL
PIDS=""

. ./env.sh

export TEMPLATE_ID=$1

M1LOGF=$M1_LOG/$M1PNM.`date +%Y-%m-%d`.log

$M1_JAVA -server -Xms128m -Xmx128m -Dm1.ftl.home=$M1_HOME -Dlog=$M1PNM.`date +%Y-%m-%d` com.odinues.m1vela.ftl.Vela config/vela/TMPL_KKO_EXT/include/biz/ftls/mng/kkoTemplateCancelAndDelete.ftl >> $M1LOGF 2>&1 & 