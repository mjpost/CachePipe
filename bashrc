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
		name=$1
		cmd=$2

		shift
		shift

		args=""
		for arg in $@; do
			if test -z "$args"; then
				args="'$arg'"
			else
				args="$args, '$arg'"
			fi
		done

		perl -MCachePipe -e "cache('$name','$cmd',$args)"
	fi
}
