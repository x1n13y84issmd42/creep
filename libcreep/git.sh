#!/bin/bash

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
