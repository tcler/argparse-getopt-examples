#!/bin/sh

wget https://github.com/tcler/getopt.tcl/archive/v3.0.tar.gz
tar zxf v3.0.tar.gz
#cp -r getopt.tcl-3.0/getOpt-3.0 /usr/local/lib/.
cp -r getopt.tcl-3.0/getOpt-3.0 .
rm -rf getopt.tcl-3.0 v3.0.tar.gz
