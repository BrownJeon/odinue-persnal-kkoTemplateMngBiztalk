<#assign m1_home = m1.sysenv["M1_HOME"] />

<#assign edit_file_conf={
	"�ǽð�": {
		"��������": { "file": m1_home + "/webapp/edit_file_conf.ftl"},
                "sql����": { "file": m1_home + "/webapp/recover_conf.ftl"},
                "���༳��": { "file": m1_home + "/webapp/run_shell_conf.ftl"}

      },
      "��������": {
		"������": { "file": m1_home + "/lib/m1_unix.properties"}
      }

}/>
