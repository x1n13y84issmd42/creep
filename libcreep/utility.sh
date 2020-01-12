
# Checks if a file, which is a list of strings, contains some string value.
# Arguments:
#	$1 The file location.
#	$2 The value to check for.
function flist.contains {
	if [[ -f $1 ]]; then
		IFS=$'\n'
		readarray -t LINES < $1

		if [[ " ${LINES[@]} " =~ " $2 " ]]; then
			return 0
		fi
	fi

	return 255
}

# Removes a line from the string list file.
# Arguments:
#	$1 The file location.
#	$2 The value to remove from the list.
function flist.without {
	if [[ -f $1 ]]; then
		IFS=$'\n'
		local tmp="$1.tmp"
		[[ -f $tmp ]] && rm $tmp
		touch $tmp

		readarray -t LINES < $1

		for L in ${LINES[@]}; do
			if [[ "$L" = "$2" ]]; then
				:
			else
				echo "$L" >> $tmp
			fi
		done

		mv $tmp $1
	fi
}

# Installs a Git hook file.
# Arguments:
#	$1 A Creep (source) hook file location.
#	$2 A Git (destination) hook file location.
#	$3 An optional f|force flag to overwrite existing files.
function hook.install {
	local runesHook=$1
	local gitHook=$2

	if [[ -f $gitHook ]]; then
		if diff $runesHook $gitHook > /dev/null; then
			creep.log "The correct ${lcFile}${gitHook}${lcX} file is already installed."
			return 0
		else
			:
		fi

		case $3 in
			-f|--force)
				cp -f $runesHook $gitHook
				creep.log "Overwrited the ${lcFile}${gitHook}${lcX}."
			;;

			*)
				creep.log "There is already a different ${lcFile}${gitHook}${lcX} file."
				creep.log "${lcHint}You can add a ${lcCmd}\"-f|--force\"${lcX}${lcHint} flag to the command to forcefully overwrite it:"
				creep.log "${lcCmd}creep/runes install-hooks --force"
			;;
		esac
	else
		cp $runesHook $gitHook
		creep.log "Installed the ${lcFile}${runesHook}${lcX}."
	fi
}

# Checks if the given string is a URL.
# Arguments:
#	$1 A strring to check.
function str.isURL {
	if [[ $1 =~ ^http|https|git:\/\/ ]]; then
		return 0
	fi

	return 255
}

# Nicely enumerates the passed arguments, so a call
# str.enum Alice Bob Jane Tom
# outputs
# Alice, Bob, Jane & Tom
function str.enum {
	echo -n $1
	shift

	while [[ ${#} > 1 ]]; do
		echo -n ", $1"
		shift
	done

	echo -n " and $1"
}

function sys.exec {
	eval "$@ 2>&1"
}
