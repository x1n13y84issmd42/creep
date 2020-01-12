case $1 in
	# Attempts to completely remove a Git submodule without a trace.
	-|purge)
		shift
		for P in ${@}; do
			git.logg "Purging the ${lcFile}$P${lcX} git submodule."
			git.submodule.purge $P;
			git.logg ""
		done
		
		git.log "\o/"
	;;

	*)
		git.log "${lcErr}Unknown command ${lcCmd}${1}${lcX}."
	;;
esac