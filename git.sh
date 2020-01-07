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
	git add $1
}
