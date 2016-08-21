#!/bin/bash
#
# author: yin-jianhong@163.com
#
# ref: /usr/share/doc/util-linux/getopt-parse.bash

Prog=${0##*/}

Usage() {
cat <<END
Usage: $Prog [other options] <casedir>
	<casedir>               #path/dir
	-m [ServNum,ClntNum]    #multihost machines number
	-l <0|1|2|...>          #Tier/level specify(default 1)
	-t <type1[,type2,...]>  #type: function/regression/stress
	--time <time>           #max run time(default 30m)
	--desc <desc>           #a description of the case
	-h|--help               #get this help info
END
}

# __main__
# argument process
_at=`getopt -o d:m::l:t:h \
	--long time: \
	--long desc: \
	--long help \
    -n "$Prog" -- "$@"`
eval set -- "$_at"

while true; do
	case "$1" in
	-m)             multihost=${2:-1,1}; shift 2;;
	-l)		level=$2; shift 2;;
	-t)		type="${2//,/ }"; shift 2;;
	--time)		time="$2"; shift 2;;
	--desc)		desc="$2"; shift 2;;
	-h|--help)      Usage; shift 1; exit 0;;
	--) shift; break;;
	esac
done
