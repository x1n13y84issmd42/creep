#!/bin/bash

source creep/creep.sh
source creep/runes/runes.sh

BITS=${1:-4096}

runes.log "Generating a pair of keys ($BITS bits long) to encrypt your files with."
runes.log "You will be prompted for a passphrase - ${lcHint}don't care about remembering it${lcX}, it will be stripped from the key later."

# Generating the key files
PUB=.creep/runes.public.key
PRIV=.creep/runes.private.key

openssl genrsa -aes256 -out $PRIV $BITS\
&&\
openssl rsa -in $PRIV -out $PRIV\
&&\
openssl rsa -in $PRIV -pubout -out $PUB

SSLRES=$?

if [[ $SSLRES == 0 ]]; then
	# Gitignoring the private key file
	runes.log ".gitignoring the $PRIV file..."
	git.ignore $PRIV 

	runes.log "${lcAttention}Remember to keep the ${lcCmd}${PRIV}${lcAttention} file secure and backup it up in multiple different storages."
	runes.log "${lcAttention}Your teammates will need it in order to access the secured files."
	runes.log "Done \o/"
else
	runes.log "Failed to generate keys."
fi
