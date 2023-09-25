#!/bin/bash
CURRENT_PWD=$PWD
cd ../bin

. ./env.sh
cd $CURRENT_PWD

java com.odinues.m1vela.ftl.Vela $@