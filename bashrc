set -u

cachecmd() {
	if test -z "$2"; then
		cachecmd_usage
	fi
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
}
