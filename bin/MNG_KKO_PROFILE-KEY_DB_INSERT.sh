#!/bin/bash
M1PNM=MNG_KKO_PROFILE-KEY_DB_INSERT
PIDS=""

. ./env.sh

# 카카오톡 채널: @odinue1116
export CHANNEL_ID=@odinue1116
# 발신프로필키: 채널의 발신프로필키
export PROFILE_KEY=d556109269a3158ee278ca371662efeffb081b93
# 카테고리코드: 채널의 발신프로필키
export CATEGORY_CODE=00400030001
# 결과수신채널: (Polling) 메시지 전송 결과 수신 채널
export CHANNEL_KEY=

M1LOGF=$M1_LOG/$M1PNM.`date +%Y-%m-%d`.log

$M1_JAVA -server -Xms128m -Xmx128m -Dm1.ftl.home=$M1_HOME -Dlog=$M1PNM.`date +%Y-%m-%d` com.odinues.m1vela.ftl.Vela config/vela/TMPL_KKO_EXT/include/biz/ftls/mng/kkoProfileKeyDatabaseInsert.ftl >> $M1LOGF 2>&1 & 