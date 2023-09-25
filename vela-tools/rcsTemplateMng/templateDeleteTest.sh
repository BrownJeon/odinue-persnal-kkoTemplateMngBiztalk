#!/bin/bash
M1PNM=RCS_TMPL_DELETE
PIDS=""

cd ../../bin/

. ./env.sh

M1LOGF=$M1_LOG/$M1PNM.`date +%Y-%m-%d`.log

$M1_JAVA -server -Xms128m -Xmx128m -Dm1.ftl.home=$M1_HOME com.odinues.m1vela.ftl.Vela vela-tools/rcsTemplateMng/templateDeleteTest.ftl