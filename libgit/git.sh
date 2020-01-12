#!/bin/bash

# A logging functions.
function git.log {
	[[ ${CREEP_GIT_LOG:-2} -ge 1 ]] && creep.echo "git" $lcYellow $@
}

function git.logg {
	[[ ${CREEP_GIT_LOG:-2} -ge 2 ]] && creep.echo "git" $lcYellow $@
}

function git.loggg {
	[[ ${CREEP_GIT_LOG:-2} -ge 3 ]] && creep.echo "git" $lcYellow $@
}

# A script-friendly git status output.
function git.status {
	IFS=$'\n'
	git status --porcelain
}

# A list of files that have been changed in last commit.
function git.changes {
	git diff --name-only HEAD HEAD~1
}

function git.add {
	git add -f $1
}

# Properly (i.e. only once) .gitignores the given file
# Arguments:
#	$1 A file path to .gitignore.
function git.ignore {
	IFS=$'\n'
	readarray -t IGNORED < .gitignore

	if [[ " ${IGNORED[@]} " =~ " $1 " ]]; then
		:
	else
		echo $1 >> .gitignore
	fi
}

function git.diff {
	local output=$(git diff $1)

	[[ -z $output ]] && return 255

	return 0
}

# Checks if the given folder is a Git a repository.
# Arguments:
# 	$1 A directory path.
function git.isRepo {
	local wd=$(pwd)
	cd $1
	$(git status)
	local xc=$?
	cd $wd
	return $xc
}

function git.submodule.purge {
	F_1=${lcFile}${1}${lcX}
	gitModule=.git/modules/$1
	F_gitModule=${lcFile}${gitModule}${lcX}

	# Deinitializing the submodule.
	out=$(sys.exec git submodule deinit $1)
	if [[ $? = 0 ]]; then
		git.logg "Deinitialized the $F_1 submodule."
	else
		git.log "${lcErr}Failed to deinitialize the Git module."
		git.log "${lcErr}${out}"
	fi

	# Removing the working copy folder.
	if [[ -d  $1 ]]; then
		if rm -rf $1; then
			git.logg "Removed the $F_1 folder."
		else
			git.logg "${lcErr}Failed to remove the $F_1 folder."
		fi
	else
		git.log "The $F_1 folder wasn't there."
	fi

	# Clearing Git cache.
	out=$(sys.exec git rm -r --cached $1)
	if [[ $? = 0 ]]; then
		git.logg "Cleared the Git cache."
	else
		git.log "${lcErr}Failed to clear the Git cache."
		git.log "${lcErr}${out}"
	fi

	# Removing the Git cached module folder.
	if [[ -d $gitModule ]]; then
		if rm -rf $gitModule; then
			git.log "Removed the $F_gitModule folder."
		else
			git.log "${lcErr}Failed to remove the $F_gitModule folder."
		fi
	else
		git.log "The Git module folder $F_gitModule is not there."
	fi

	git.log ""
	git.log "${lcAlert}Manually delete the ${F_1}${lcAlert} entries from these files:"
	git.log "${lcFile}./.gitmodules"
	git.log "${lcFile}./.git/config"
	git.log ""
	git.log "\o/"
}
