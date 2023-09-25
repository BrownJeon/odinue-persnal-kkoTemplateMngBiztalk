<#assign m1_home = m1.sysenv["M1_HOME"] />

<#assign edit_file_conf={
	"실시간": {
		"편집설정": { "file": m1_home + "/webapp/edit_file_conf.ftl"},
                "sql설정": { "file": m1_home + "/webapp/recover_conf.ftl"},
                "실행설정": { "file": m1_home + "/webapp/run_shell_conf.ftl"}

      },
      "엔진설정": {
		"마스터": { "file": m1_home + "/lib/m1_unix.properties"}
      }

}/>
