#!/usr/bin/python
#
# author: yin-jianhong@163.com
#
# ref: https://docs.python.org/3/library/argparse.html
#
# coding=utf-8

import sys
import string
import argparse

parser = argparse.ArgumentParser(description="some information here")

parser.add_argument("echo", help="echo the string you use here")

# type=
parser.add_argument("square", help="display a square of a given number",
                type=int)

# action=
parser.add_argument("-e", "--enable", help="enable xxx",
                action="store_true")

# type & choices
parser.add_argument("-V", "--Verbosity", type=int, choices=[0, 1, 2],
                help="increase output verbosity")

# action='count' default=0
parser.add_argument("-v", "--verbosity", action="count", default=0,
                help="increase output verbosity")

# nargs=
parser.add_argument('--foo', type=int, nargs='?', action='append',
                help='an integer for the accumulator')
parser.add_argument('--bar', type=int, nargs='+', action='append',
                help='an integer for the accumulator')
parser.add_argument('--boo', type=list, nargs='*', action='append',
                help='an integer for the accumulator')

args = parser.parse_args()

parser.print_help()

if args.enable:
    print "enable = %s" % args.enable
if args.Verbosity:
    print "Verbosity = %d" % args.Verbosity
if args.verbosity:
    print "verbosity = %d" % args.verbosity
if args.foo:
    print "foo = ", args.foo
if args.bar:
    print "bar = ", args.bar
if args.boo:
    print "boo = ", args.boo
