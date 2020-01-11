#!/bin/bash

source creep/libcreep/creep.sh

# A logging functions.
function boss.log {
	[[ ${CREEP_BOSS_LOG:-2} -ge 1 ]] && creep.echo "boss" $lcRed $@
}

function boss.logg {
	[[ ${CREEP_BOSS_LOG:-2} -ge 2 ]] && creep.echo "boss" $lcRed $@
}

function boss.loggg {
	[[ ${CREEP_BOSS_LOG:-2} -ge 3 ]] && creep.echo "boss" $lcRed $@
}
