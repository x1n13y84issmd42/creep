case $1 in
	# Attempts to completely remove a Git submodule without a trace.
	purge)
		shift
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
			# Then deleting it.
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
	;;
esac