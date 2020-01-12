#!/bin/bash

source creep/libcreep/creep.sh
source creep/libgit/git.sh

# A printing function.
function runes.echo {
	_IFS=$IFS && IFS='' && echo -en "\e[35mrunes${lcX}" $@ >&2 && echo -en "$lcX\n" >&2 && IFS=$_IFS
}

# A logging functions.
function runes.log {
	[[ ${CREEP_RUNES_LOG:-2} -ge 1 ]] && runes.echo $@
}

function runes.logg {
	[[ ${CREEP_RUNES_LOG:-2} -ge 2 ]] && runes.echo $@
}

function runes.loggg {
	[[ ${CREEP_RUNES_LOG:-2} -ge 3 ]] && runes.echo $@
}

RUNES_FILE=.creep/.runes
PUB_KEY_FILE=.creep/runes.public.key
PRIV_KEY_FILE=.creep/runes.private.key
PASS_KEY_FILE=.creep/runes.pass.key

# Initalizes the thing by checking for presence of needed files,
# giving some hints on where to obtain them on case they're missing,
# and, if everything is in place, reading the .runes file.
function runes.load {

	if [[ $CREEP_RUNES_OFF == 1 ]]; then
		runes.logg "Disabled by CREEP_RUNES_OFF=1 environment variable; exiting."
		exit 0
	fi

	runes.load.args $@;

	# Checking for the .runes file
	if [[ -f $RUNES_FILE ]]; then
		# Reading it
		readarray RUNES < $RUNES_FILE

		if [[ ! -f $PUB_KEY_FILE ]]; then
			runes.log "${lcErr}You don't have a public key to encrypt your content with, so you won't be able to commit to this repository."
		fi

		if [[ ! -f $PRIV_KEY_FILE ]]; then
			runes.log "${lcErr}You don't have a private key to decrypt your content with, so you won't be able to access contents of some files from this repository."
		fi

		if [[ (! -f $PUB_KEY_FILE) && (! -f $PRIV_KEY_FILE) ]]; then
			runes.log "${lcHint}Create a pair of keys by running ${lcCmd}creep/runes keygen${lcX}."
		elif [[ (-f $PUB_KEY_FILE) && (! -f $PRIV_KEY_FILE) ]]; then
			runes.log "You have the ${lcCmd}${PUB_KEY_FILE}${lcX}, so there must be it's private counterpart somewhere."
			runes.log "${lcHint}Ask around your team for the ${lcCmd}${PRIV_KEY_FILE}${lcHint} file for this project."
		fi
	else
		runes.log "You don't have a runes file. ${lcHint}Create a ${lcCmd}${RUNES_FILE}${lcHint} file in your project root to start using the encryption."
	fi
}

# Parses command line args and configures the app.
function runes.load.args {
	while getopts ":l:" opt; do
		case $opt in
			l)
				CREEP_RUNES_LOG=$OPTARG
				runes.loggg "Setting CREEP_RUNES_LOG to $OPTARG"
			;;
		esac
	done
}

# Generates a new passkey file.
# The passkey is needed to encrypt large files, which is impossible with smaller key sizes,
# so a random key is used to encrypt the files, then in turn it's enrypted with the public key
# and added to the repo.
# Usually it's used once per commit.
function runes.new.passKey {
	runes.logg "Generating a new passkey file."
	openssl rand -hex 128 > $PASS_KEY_FILE
}

# Checks if the given path belongs to the runes file.
# Arguments:
#	$1	A file path to check.
function runes.isRune {
	for RUNE in ${RUNES[@]}; do
		if [[ $RUNE == $1 ]]; then
			return 0
		fi
	done

	return 255
}

# Outputs a path to the public key file.
function runes.publicKey {
	if [[ -f $PUB_KEY_FILE ]]; then
		echo $PUB_KEY_FILE
	fi
}

# Outputs a path to the private key file.
function runes.privateKey {
	if [[ -f $PRIV_KEY_FILE ]]; then
		echo $PRIV_KEY_FILE
	fi
}

# Outputs a path to a passkey file.
function runes.passKey {
	echo $PASS_KEY_FILE
}

# Initializes the encryption process by generating a new passkey file.
function runes.encrypt.start {
	if runes.encrypt.precondition "start the encryption"; then
		runes.new.passKey;
	fi
}

# Encrypts a single file with a passkey which is generated once per commit.
# Arguments:
#	$1 A path to a file to encrypt.
#	$2 A silence flag.
function runes.encrypt {
	if runes.encrypt.precondition "encrypt" $1; then
		#TODO: tunes.diff $1
		local passKey=$(runes.passKey)
		local tmpFN="$1.enc"

		[[ ! $2 ]] && runes.log "Encrypting ${lcRune}${1}${lcX}."
		openssl enc -aes-256-cbc -pass file:$passKey -nosalt -in $1 -out $tmpFN
		mv $tmpFN $1
	fi
}

# Finalizes the encryption by encrypting the passkey file and adding it to the repository.
function runes.encrypt.finish {
	if runes.encrypt.precondition "finish the encryption"; then
		local pubKey=$(runes.publicKey)
		local privKey=$(runes.privateKey)
		local passKey=$(runes.passKey)
		local tmpFN="$passKey.enc"

		runes.log "Encrypting the ${lcRune}$passKey${lcX} file and adding it to the repository."
		openssl rsautl -encrypt -pubin -inkey $pubKey -in $passKey -out $tmpFN
		mv $tmpFN $passKey
		git.add $passKey

		# Decrypting it back for consistency
		#TODO: move openssl ops, get rid of that mv
		openssl rsautl -decrypt -inkey $privKey -in $passKey -out $tmpFN
		mv $tmpFN $passKey

		runes.logg "\o/"
	fi;
}

# Initializes the decryption process by decrypting the passkey file first.
function runes.decrypt.start {
	if runes.decrypt.precondition "start the decryption"; then
		local privKey=$(runes.privateKey)
		local passKey=$(runes.passKey)
		local tmpFN="$passKey.dec"

		if git.diff $passKey; then
			runes.logg "The ${lcRune}$passKey${lcX} file has changed, skipping decryption."
		else
			runes.logg "Decrypting the ${lcRune}$passKey${lcX} file."
			openssl rsautl -decrypt -inkey $privKey -in $passKey -out $tmpFN
			mv $tmpFN $passKey
		fi
	fi
}

# Decrypts a single file with a passkey which is generated once per commit.
# Arguments:
#	$1 A path to a file to decrypt.
#	$2 A silence flag.
function runes.decrypt {
	if runes.decrypt.precondition "decrypt" $1; then
		local passKey=$(runes.passKey)
		local tmpFN="$1.dec"

		[[ ! $2 ]] && runes.log "Decrypting ${lcRune}${1}${lcX}."
		openssl enc -d -aes-256-cbc -pass file:$passKey -nosalt -in $1 -out $tmpFN

		if [[ $? == 0 ]]; then
			mv $tmpFN $1
		else
			runes.log "${lcErr}Could not decrypt ${lcRune}${1}${lcX}."
			[[ -f $tmpFN ]] && rm $tmpFN
		fi
	fi
}

# Checks if it's generally makes sense to try to decrypt something by ensuring
# there is a private key file in place.
# Arguments:
#	$1 A name of operation the precondition is checked for.
#	$2 A file name being decrypted.
function runes.decrypt.precondition {
	local privKey=$(runes.privateKey)
	if [[ ! -f $privKey ]]; then
		runes.log "${lcErr}Cannot $1 $2 because private key is missing."

		return 255
	fi

	return 0
}

# Checks if it's makes sense to try to encrypt something by ensuring
# there is a public key file in place.
# Arguments:
#	$1 A name of operation the precondition is checked for.
#	$2 A file name being decrypted.
function runes.encrypt.precondition {
	local privKey=$(runes.publicKey)
	if [[ ! -f $privKey ]]; then
		runes.log "${lcErr}Cannot $1 $2 because public key is missing."

		return 255
	fi

	return 0
}
