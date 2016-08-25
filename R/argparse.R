#!/usr/bin/env Rscript

# maybe u need call install.package("argparse") first
suppressPackageStartupMessages(library("argparse"))

# create parser object
parser <- ArgumentParser(description='*Process some info/description*')

parser$add_argument("-v", "--verbose", action="store_true", default=FALSE,
    help="output verbose detail info")
parser$add_argument("-q", "--quietly", action="store_false",
    dest="quiet", help="suppress detail output")
parser$add_argument("-c", "--count", type="integer", default=5,
    help="Number of random normals to generate [default %(default)s]",
    metavar="number")
parser$add_argument("--sd", default=1, type="double",
    metavar="standard deviation",
    help="abcde [default %(default)s]")
parser$add_argument('--sum', dest='accumulate', action='store_const',
    const='sum', default='max', help='sum the integers (default: find the max)')

parser$add_argument('start', metavar='N', type="integer", nargs='+',
    help='an integer for the accumulator')
parser$add_argument('end', metavar='N', type="integer", nargs='+',
    help='an integer for the accumulator')

# don't need add -h/--help option, will generate
args <- parser$parse_args()

# print some progress messages to stderr if "quietly" wasn't requested
if ( args$verbose ) {
    write("writing some verbose output to standard error...\n", stderr())
}

# do some operations based on user input
cat(args$start:args$end)
cat("\n")
