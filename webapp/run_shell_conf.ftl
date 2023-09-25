<#assign m1_home = m1.sysenv["M1_HOME"] />
<#assign lg_home = "/iwork/sms008/LGU_M1_SECU" />

<#assign run_shell_conf={
	"전체기동": {
		"ALL Start": { "shell": m1_home + "/bin/allstart.sh"},
		"ALL Stop": { "shell": m1_home + "/bin/allstop.sh"},
		"ALL M1": { "shell": m1_home + "/bin/M1_ALL.sh"},
		"ALL KT": { "shell": m1_home + "/bin/KT_ALL.sh"},
		"ALL LG": { "shell": lg_home + "/bin/lgall.sh"}
	},
	"M1엔진": {
		"BKSM01_TSKM": { "shell": m1_home + "/bin/BKSM01_TSKM.sh"}
	},
	"실시간": {
		"BKSM01_LSNR": { "shell": m1_home + "/bin/BKSM01_LSNR.sh"},
		"BKSM01_XCNN": { "shell": m1_home + "/bin/BKSM01_XCNN.sh"},
		"BKSM01_RREQ": { "shell": m1_home + "/bin/BKSM01_RREQ.sh"},
		"KTSM000001_1": { "shell": m1_home + "/bin/KTSM000001_1.sh"},
		"KTSM000001_S1": { "shell": m1_home + "/bin/KTSM000001_S1.sh"},
		"LDSM000001_1": { "shell": lg_home + "/bin/LDSM000001_1.sh"},
		"LDSM000001_S1": { "shell": lg_home + "/bin/LDSM000001_S1.sh"},
		"LDMM000001_1": { "shell": lg_home + "/bin/LDMM000001_1.sh"}
	},
	"DB발송": {
		"BKSMB1_SCHD": { "shell": m1_home + "/bin/BKSMB1_SCHD.sh"},
		"BKSMB1_XCNN": { "shell": m1_home + "/bin/BKSMB1_XCNN.sh"},
		"KTSM000001_2": { "shell": m1_home + "/bin/KTSM000001_2.sh"},
		"KTSM000001_4": { "shell": m1_home + "/bin/KTSM000001_4.sh"},
		"KTSM000001_5": { "shell": m1_home + "/bin/KTSM000001_5.sh"},
		"KTSM000001_S2": { "shell": m1_home + "/bin/KTSM000001_S2.sh"},
		"LDSM000001_2": { "shell": lg_home + "/bin/LDSM000001_2.sh"},
		"LDSM000001_3": { "shell": lg_home + "/bin/LDSM000001_3.sh"},
		"LDSM000001_4": { "shell": lg_home + "/bin/LDSM000001_4.sh"},
		"LDSM000001_S2": { "shell": lg_home + "/bin/LDSM000001_S2.sh"},
		"LDMM000001_2": { "shell": lg_home + "/bin/LDMM000001_2.sh"},
		"LDMM000001_3": { "shell": lg_home + "/bin/LDMM000001_3.sh"}
	},
      "CRONTAB": {
		"M1_CRONTAB": { "shell": m1_home + "/bin/M1_CRONTAB.sh"}
	}
}/>

