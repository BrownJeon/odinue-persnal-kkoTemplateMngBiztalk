#!/bin/bash

function exec {
    for item in `ls | grep "$1_.*.sh"`
    do
            ./$item $2 f
    done
}

# M1 module
exec "XCN" $1;
exec "SCH" $1;
exec "DBX" $1;
exec "TKM" $1;
exec "TSK" $1;

#./XCN_SMS41.sh $1 f
#./TKM_SMS41.sh $1 f

# M1 XCENTER
./XCT_CENTER.sh $1 f

# KT module
cd ../M1kt/bin
./KTALL.sh $1 f