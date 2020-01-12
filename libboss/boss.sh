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
		echo ""
		boss.log "Executing in ${lcFile}$PROJ"
		local OUT=$(eval "$@")
		[[ ! -z $OUT ]] && echo ${OUT[@]}
		cd $WD
	done

	# And lastly, executing it in the root folder.
	echo ""
	boss.log "Executing in ${lcFile}[the project root]"
	local OUT=$(eval "$@")
	[[ ! -z $OUT ]] && echo ${OUT[@]}
}

# Adds a folder or a repository under namagement.
# Arguments:
#	$1 Either a directory name or a repository URL.
#	$2 Repository management mode. Valid values are 'clone' and 'submodule'.
function boss.add {
	local dirName="$1"
	local mode="$2"
	local dogit=0

	if str.isURL $1; then
		dirName=${dirName##*\/}
		dirName=${dirName%%\.*}
		dogit=1
	fi

	if flist.contains $BOSS_FILE $dirName; then
		boss.log "The ${lcFile}${dirName}${lcX} project is already under management."
		return 0
	fi

	if [[ $dogit == 1 ]]; then
		case $2 in
			sub|submodule)
				boss.logg "Adding a Git submodule ${lcFile}$1"
				git submodule add --quiet --force $1
			;;

			clone)
				if [[ -d $dirName ]]; then
					boss.logg "The ${lcFile}$dirName${lcX} directory already exists. Trying to clone anyway."
					boss.logg "${lcAlert}TODO:${lcX} Check for files."
					git clone $1 $dirName
				else
					boss.logg "Cloing the ${lcFile}${1}${lcX}repository."
					git clone $1
				fi
			;;

			*)
				boss.log "${lcError}Unknown mode ${lcHint}$mode${lcX}."
				exit 0
			;;
		esac
	else
		boss.logg "Adding a directory ${lcFile}${dirName}."

		if [[ ! -d $dirName ]]; then
			boss.logg "The directory is not there, making it."
			mkdir $dirName
		fi
	fi

	echo $dirName >> $BOSS_FILE

	boss.log "Managing the ${lcFile}${dirName}${lcX} project from now on."
}

# Removes a project under the Boss' management.
#  Arguments:
#	$1 A project's directory name to remove.
function boss.remove {
	if flist.contains $BOSS_FILE $1; then
		flist.without $BOSS_FILE $1
		boss.log "Not managing the ${lcFile}${1}${lcX} project anymore."
	else
		boss.log "The ${lcFile}${1}${lcX} project has never been managed."
	fi
}