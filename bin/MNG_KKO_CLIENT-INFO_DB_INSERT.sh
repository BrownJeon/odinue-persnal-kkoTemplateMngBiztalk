#!/bin/bash
M1PNM=MNG_KKO_CLIENT-INFO_DB_INSERT
PIDS=""

. ./env.sh

# �߽�������Ű: ä���� �߽�������Ű
export CHANNEL_ID=d556109269a3158ee278ca371662efeffb081b93
# ��������
export CLIENT_ID=shLife1
# ���� ����Ű
export CLIENT_SECRET=N2IzZTljNmUwMGFjMzk0NzFjMzU4ZTJmYmY1N2RjZmMwOWM2ZTM4NzIzYzYxOGY3OTMxNzllMDU2Zjc2ZjIwMQ==

M1LOGF=$M1_LOG/$M1PNM.`date +%Y-%m-%d`.log

$M1_JAVA -server -Xms128m -Xmx128m -Dm1.ftl.home=$M1_HOME -Dlog=$M1PNM.`date +%Y-%m-%d` com.odinues.m1vela.ftl.Vela config/vela/TMPL_KKO_EXT/include/biz/ftls/mng/kkoClientInfoInsertDatabase.ftl >> $M1LOGF 2>&1 & 