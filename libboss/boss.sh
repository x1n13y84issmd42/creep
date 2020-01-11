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

BOSS_FILE=.creep/.boss

function boss.load {
	if [[ -f $BOSS_FILE ]]; then
		readarray -t PROJECTS < $BOSS_FILE
	else
		runes.log "You don't have a .BOSS file. ${lcHint}Create a one with the ${lcCmd}creep/boss add PROJECT${lcHint} command to start managing."
	fi
}

# Executes arbitrary commands within each project directory.
function boss.execute {
	IFS=''
	local WD=$(pwd)
	for PROJ in ${PROJECTS[@]}; do
		PROJ=${PROJ##*\/}
		cd $PROJ
		boss.log "Doing in ${lcFile}$PROJ"
		local OUT=$(eval "$@")
		[[ ! -z $OUT ]] && echo ${OUT[@]}
		cd $WD
	done
}
