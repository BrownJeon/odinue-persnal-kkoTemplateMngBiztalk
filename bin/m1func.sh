#!/bin/bash
##############################################################################
#	
#	m1func.sh
#	
#	This script define common M1 functions.
#	
#	
#	M1 is Trade Mark of Unified Messaging Service
#	Odinue Co.,Ltd. All rights reserved.
#	
##############################################################################

function  findproc  {
	#�Ķ���Ͱ�  1������  ���,  �ɼ�  ���
	if  ((  $#  ==  1  ))
	then
		echo    " = search PID by "  $1
	fi
	
		PIDS=""
		#PID ��ġ�� OS���� �ٸ��� ������, ���̽����� ����� ó����.
		if [ "$M1_OS" = "OSX" ]
		then
	               	ps  $M1_PS_OPT   |  grep  "$1"  |  grep  -v  grep  |  awk  '{print  $1}{print  $0}' |  while  read  aPID  &&  read  aCmd
			do
                		#�ڱ��ڽ���  ����.
                		if  [[  "$aPID"  !=  "$$"  ]]
	                	then
		                	PIDS="$PIDS  $aPID"
	        	        	if    ((  $#  <=  1    ))
					then
		                		#�Ķ���Ͱ�  1������  ���,  ���  ���
		                		if  ((  $#  ==  1  ))
						then
							echo  "        #  "$aPID  $aCmd
						fi
		                	fi
	                	fi
                	done 
                
	
		else
#	               	ps  $M1_PS_OPT   |  grep  "$1"  |  grep  -v  grep  |  awk  '{print  $2}{print  $0}' |  while  read  aPID  &&  read  aCmd
#			do
#                		#�ڱ��ڽ���  ����.
#                		if  [[  "$aPID"  !=  "$$"  ]]
#	                	then
#
#		                	PIDS="$PIDS  $aPID"
#
#                   echo PIDS=$PIDS in m1func 
#
#	        	        	if    ((  $#  <=  1    ))
#					then
#		                		#�Ķ���Ͱ�  1������  ���,  ���  ���
#		                		if  ((  $#  ==  1  ))
#						then
#							echo  " = command #  "$aPID  $aCmd
#						fi
#		                	fi
#	                	fi
#                	done 
 
		    PIDS=`ps  $M1_PS_OPT   |  grep  "$1"  |  grep  -v  grep  |  awk  '{print  $2}'`
	
		fi
}

function  aftercheck  
{
	sleep  1
	PIDS=""
	findproc  $1  s
	if  [[  "$PIDS"  =  ""  ]]
	then
		echo  "���α׷���  ������  ����Ǿ����ϴ�.  �α׸�  Ȯ���ϼ���.(pid=  $2  )"
		echo ""
	else
		echo  "���α׷���  ����������  ���۵Ǿ����ϴ�.(pid=  $2  )"
		echo ""

	fi

	if  [  "$SHOWLOG"  =  "on"  ]  
	then
			tail -fn400 $M1LOGF
	fi
	
	
}

function  killproc  {                        #  kill  the  named  process(es)

	PIDS=""
	findproc  $1

	if  [  "$PIDS"  !=  ""  ]  
	then
		
		if    ((  $#  >  1    ))
		then
			if  [  "$2"  =  "-9"  ]
			then
				echo  kill  -9  $PIDS
				[  "$PIDS"  !=  ""  ]  &&  kill  -9  $PIDS
			else
				echo  kill    $PIDS
				[  "$PIDS"  !=  ""  ]  &&  kill    $PIDS
			fi

			((s=0))
			
			while  ((  s  <  60  ))
			do
				
				findproc  $1  s
				((s=s+1))
				if  [  "$PIDS"  !=  ""  ]
				then
					if  (( s > 1)) 
					then
						echo $M1_ECHO_OPT  '\033'[2A
					fi
					echo  $s"��  ���..."
					sleep  1
				else
					if  (( s > 1)) 
					then
						echo $M1_ECHO_OPT  '\033'[2A
					fi
					echo  $s"��  ��  ���  ����  Ȯ��."
					PIDS=""
					break
				fi
				
			done

			if  [  "$PIDS"  !=  ""  ]
			then
				echo  "����  �����մϴ�.(kill  -9)."
				[  "$PIDS"  !=  ""  ]  &&  kill  -9  $PIDS
				
			fi			
	
		else
			echo  "kill  $PIDS  ?(y|n)"
			read  yn
			if  [    $yn  =  "y"  ]
			then
				[  "$PIDS"  !=  ""  ]  &&  kill  $PIDS
				
				findproc  $1  s
				((s=0))
				
				while  ((  s  <  10  ))
				do
					
					findproc  $1  s
					((s=s+1))
					if  [  "$PIDS"  !=  ""  ]
					then
						echo  $s"��  ���..."
						sleep  1
					else
						echo  $s"��  ��  ���  ����  Ȯ��."
						PIDS=""
						break
					fi
					
				done

				if  [  "$PIDS"  !=  ""  ]
				then
					echo  "����  �����մϴ�.(kill  -9)."
					[  "$PIDS"  !=  ""  ]  &&  kill  -9  $PIDS
					
				fi
	
			else
				exit  0;
				
			fi
		fi

	else
		echo  "���μ�����  �����ϴ�."
	fi	
}


function  runutil  {
	
	PIDS=""
	if  [  "$3"  =  "log"  ]  
	then
		SHOWLOG="on" ;
	else
		SHOWLOG="off" ;
	fi
	
	findproc  $1  s
	

	echo  " = log file  "  $M1LOGF
	
	if  [  "$2"  =  "conf"  ]  
	then
	  echo "$M1PNM ���ü��� Ȯ��."
		grep ".*\[$M1PNM\].*" $M1_HOME/lib/m1_unix.properties
	  exit ;
	fi
		
	if  [  "$2"  =  "log"  ]  
	then
		if  [  "$3"  !=  ""  ]
		then
			tail -fn$3 $M1LOGF
			exit ;
		else
			tail -f $M1LOGF
			exit ;
		fi
	fi
	
	
	if  [  "$2"  =  "stop"  ]  
	then
		if  [  "$PIDS"  !=  ""  ]
		then
			killproc  $1  $3
			exit  
		else
			echo  "��������  $M1PNM ���α׷���  �����ϴ�. $0"
			exit
		fi
	fi
	
	
	if  [  "$2"  =  "restart"  ]  
	then
		if  [  "$PIDS"  !=  ""  ]
		then
			killproc  $1  $3  
			return ;
		else
			return ;
  
		fi
	fi
	
	if  [  "$2"  =  "kill"  ]  
	then
		if  [  "$PIDS"  !=  ""  ]
		then
			killproc  $1  f
			exit  
		else
			echo  "��������  $M1PNM ���α׷���  �����ϴ�. $0"
			exit
		fi
	else
	
		if  [  "$PIDS"  !=  ""  ]
		then
#	      		echo  "$M1PNM ���α׷���  �̹�  �������Դϴ�.PIDS="  $PIDS  $0
	      		echo  "$M1PNM ���α׷���  �̹�  �������Դϴ�.PIDS="  $PIDS

	      		echo ""
	            		exit
	            	fi
	fi

    if  [  "$2"  =  "chkproc"  ]
    then
            if  [  "$PIDS"  !=  ""  ]
            then
                    echo  "$M1PNM�� �������Դϴ�.  $0"
                    echo ""
                    exit
            else
                    echo  "��������  $M1PNM ���α׷���  �����ϴ�.  $0"
                    if  [  "$3"  ==  ""  ]
                    then
                            echo ""
                            m1alert.sh M1ALT CHKPROC  "��������  $M1PNM ���α׷���  �����ϴ�."
                            exit 1
                    else
                            echo ""
                            $3
                            exit 1
                    fi
            fi
    fi
	
	if  [  "$2"  !=  "start"  ]  
	then
		if  [  "$PIDS"  !=  ""  ]
		then
			echo  "$M1PNM�� �������Դϴ�.  $0"
			echo ""
			exit  
		else
			echo  "��������  $M1PNM ���α׷���  �����ϴ�.  $0"
			echo ""
			exit
		fi
		
# start the program
	else
		echo "" >> $M1LOGF
		echo ">>>>>>>>>>>>>>>>>>>> START >>>>>>>>>>>>>>>>>>>>>" >> $M1LOGF
		
	fi




}




