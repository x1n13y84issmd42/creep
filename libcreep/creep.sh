#!/bin/bash

source creep/libgit/git.sh

# Log colors & styles
lc0="\e[0m"

lc1="\e[1m"
lc2="\e[2m"
lc4="\e[4m"
lc5="\e[5m"
lc7="\e[7m"
lc8="\e[8m"

lcB=$lc1
lcD=$lc2
lcU=$lc4
lcL=$lc5
lcR=$lc7	# Inverse
lcH=$lc8

lcBlack="\e[30m"
lcRed="\e[31m"
lcGreen="\e[32m"
lcYellow="\e[33m"
lcBlue="\e[34m"
lcMagenta="\e[35m"
lcCyan="\e[36m"
lcLGray="\e[37m"

lcDGray="\e[90m"
lcLRed="\e[91m"
lcLGreen="\e[92m"
lcLYellow="\e[93m"
lcLBlue="\e[94m"
lcLMagenta="\e[95m"
lcLCyan="\e[96m"
lcWhite="\e[97m"

lcbgBlack="\e[40m"
lcbgRed="\e[41m"
lcbgGreen="\e[42m"
lcbgYellow="\e[43m"
lcbgBlue="\e[44m"
lcbgMagenta="\e[45m"
lcbgCyan="\e[46m"
lcbgLGray="\e[47m"

lcbgDGray="\e[100m"
lcbgLRed="\e[101m"
lcbgLGreen="\e[102m"
lcbgLYellow="\e[103m"
lcbgLBlue="\e[104m"
lcbgLMagenta="\e[105m"
lcbgLCyan="\e[106m"
lcbgWhite="\e[107m"

lcX="$lc0$lcDGray"

# Styles
lcErr="$lcbgRed$lcWhite"
# lcHint="${lcbgLGray}$lcBlack"
lcHint="${lcWhite}"
lcFile="$lcU$lcLBlue"
lcCmd="$lcbgLGray$lcBlue"
# lcCmd="$lcU$lcLBlue"
lcAlert="$lcbgYellow$lcBlack"

lcRune="\e[35m\e[7m"

# A printing function.
# Arguments:
#	$1 A module/topic name.
#	$2 A color/style.
#	$@ Arguments to print.
function creep.echo {
	local t=$1
	local s=$2
	shift 2
	_IFS=$IFS && IFS='' && echo -en "${s}${t}${lcX}" $@ >&2 && echo -en "$lcX\n" >&2 && IFS=$_IFS
}

# Logging functions.
function creep.log {
	[[ ${CREEP_LOG:-2} -ge 1 ]] && creep.echo "creep" $lcLGray $@
}

function creep.logg {
	[[ ${CREEP_LOG:-2} -ge 2 ]] && creep.echo "creep" $lcLGray $@
}

function creep.loggg {
	[[ ${CREEP_LOG:-2} -ge 3 ]] && creep.echo "creep" $lcLGray $@
}