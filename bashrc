# This allows you to cache commands from the command line.
# Usage:

cachecmd_usage() {
	cat <<EOF
Usage: cachecmd ID "command arg1 arg2" [dep1 [dep2 ...]]
       cachecmd ID --rerun
       cachecmd ID --cache-only
       cachecmd ID --cache-only "command arg1 arg2" [dep1 [dep2 ...]]
where
  ID is the command ID (unique within the directory)
  command is the command to run (remember to quote multiword commands)
  dep1 .. depN are file and environment dependencies
  --cache-only builds the cache files without actually running the command
EOF
}

cachecmd() {
	if [ -z "$2" ]; then
		cachecmd_usage
	else
		local tmpfile=.cachepipe.$$.$(date +%s)
		rm -f $tmpfile
		# $@ must be in quotes, or quoted args get split up
		# see VonC's answer at http://stackoverflow.com/questions/255898/how-to-iterate-over-arguments-in-bash-script
		for arg in "$@"; do
			echo $arg >> $tmpfile
		done

		perl -MCachePipe -e "cache_from_file('$tmpfile')"
		rm -f $tmpfile
	fi
}
