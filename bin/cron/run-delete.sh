#!/bin/bash

. env.sh 
. m1func.sh

cd $M1_HOME/bin/cron

find $M1_HOME/logs/* -mtime +$1 -exec rm {} \;