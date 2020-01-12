case $1 in
	# Attempts to completely remove a Git submodule without a trace.
	purge)
		shift
		for P in ${@}; do
			git.submodule.purge $P;
		done
	;;

	*)
		git.log "${lcErr}Unknown command ${lcCmd}${1}${lcX}."
	;;
esac