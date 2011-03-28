# This allows you to cache commands from the command line.
# Usage:

cachecmd_usage() {
	cat <<EOF
Usage: cachecmd ID command [dep1 [dep2 ...]]
where
  ID is the command ID (unique within the directory)
  command is the command to run (remember to quote multiword commands)
  dep1 .. depN are file and environment dependencies
EOF
}

cachecmd() {
	if [ -z "$2" ]; then
		cachecmd_usage
	else
		local name=$1
		local cmd=$2

		shift
		shift

		local tmpfile=.cachepipe.$$.$(date +%s)
		echo $name > $tmpfile		
		echo $cmd >> $tmpfile
 		local arg
		for arg in $@; do
			echo $arg >> $tmpfile
		done

		# echo $tmpfile
		perl -MCachePipe -e "cache_from_file('$tmpfile')"
		rm -f $tmpfile
	fi
}
