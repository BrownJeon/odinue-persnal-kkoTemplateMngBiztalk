#!/bin/bash
##############################################################################
#	
#	env.sh
#	
#	This script set information such as Option, Path etc.
#	
#	
#	M1 is Trade Mark of Unified Messaging Service
#	Odinue Co.,Ltd. All rights reserved.
#	
##############################################################################
function findFile
{
        for item in `ls $1/*.jar`
        do
          sum=$sum:${item}
        done
        echo $sum
};

function findDir
{
        for item in `find $1 * | grep ".jar$"`
        do
          sum=$sum:${item}
        done
        echo $sum
};

#=================================================================
#	INCLUDE
#							
#=================================================================
. ./host.env


#=================================================================
#	JNI LIB PATH
#							
#=================================================================
export M1_ECHO_OPT=
if [ "$M1_OS" = "HPUX" ]
then
#----- HPUX
	export SHLIB_PATH=$M1_HOME/lib:/opt/java1.5/jre/lib/PA_RISC2.0/server:$SHLIB_PATH
	export JAVA_PRELOAD_ONCE=$M1_HOME/lib/libmsgipc.sl
	export M1_JVMOPT="-XX:+UseGetTimeOfDay -XX:+UseHighResolutionTimer -Xeprof:off"
	export M1_PS_OPT="-efx"   
elif [ "$M1_OS" = "AIX" ]
then
#----- AIX
	#export EXTSHM=ON
	export PATH=/usr/vacpp/bin:$PATH
	export LIBPATH=$M1_HOME/lib:$LIBPATH
	export M1_PS_OPT=-ef
	export M1_JVMOPT=
elif [ "$M1_OS" = "LINUX" ]
then
#----- LINUX
        SO_LIB_PATH=`find $JAVA_HOME -name "libjsig.so" |grep "/server/"`
        #echo "SO_LIB_PATH="$SO_LIB_PATH
        SO_LIB_PATH=${SO_LIB_PATH/\/libjsig.so/}
        #echo "SO_LIB_PATH="$SO_LIB_PATH

	JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64
	SO_LIB_PATH=$JAVA_HOME/jre/lib/amd64/server

        #export LD_LIBRARY_PATH=$M1_HOME/lib:/opt/java1.5/jre/lib/i386/server:$LD_LIBRARY_PATH
        export LD_LIBRARY_PATH=$M1_HOME/lib:$SO_LIB_PATH:$LD_LIBRARY_PATH
        export M1_PS_OPT=-ef

	#export M1_JVMOPT=-DM1_HOME=$M1_HOME -Dfile.encoding=euckr
elif [ "$M1_OS" = "OSX" ]
then
#----- OSX
	export LD_LIBRARY_PATH=$M1_HOME/lib
	export M1JVM_OPT='-Dfile.encoding=KSC5601 -Djava.library.path=$M1_HOME/lib'
	export M1JVM_OPT=-Djava.library.path=$M1_HOME/lib
	export M1_PS_OPT=-ex
	export M1_ECHO_OPT=" -e"
fi


#=================================================================
#	CLASS PATH
#							
#=================================================================
export CLASSPATH=$M1_HOME/lib:$KT_HOME/lib:$M1_JAR:$CLASSPATH
export PATH=.:$PATH


#=================================================================
#	DISPLAY INFORMATION
#							
#=================================================================
echo ============== $M1PNM  =================
echo " = configured on " $M1_OS

if [ "$1" = "show" ]
then
	echo M1_HOME=$M1_HOME
	echo M1_LOG=$M1_LOG
	echo M1_DATA=$M1_DATA
	echo SMSIPC_KEY2=$SMSIPC_KEY2
	echo PKGBIZ=$PKGBIZ
	echo M1_JAR=$M1_JAR
	echo M1_JAVA=$M1_JAVA
	echo PATH=$PATH
	echo LD_LIBRARY_PATH=$LD_LIBRARY_PATH
	echo LIB_PATH=$LIB_PATH
	echo LIBPATH=$LIBPATH
	echo SHLIB_PATH=$SHLIB_PATH
	echo CLASSPATH=$CLASSPATH
fi
