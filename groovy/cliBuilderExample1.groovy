#!/usr/bin/env groovy

def cli = new CliBuilder(
  usage : 'program [options] <arguments>',
  header : 'Options:',
)
 
cli.with {
  s 'simplest boolean option'
 
  b longOpt: 'both', 'boolean option with both longop and shortop'
 
  _ longOpt: 'no-shortop-1', 'boolean option without short version 1'
  _ longOpt: 'no-shortop-2', 'boolean option without short version 2'
 
  n args:1, argName:'thing', 'simple argument option'
  r args:1, argName:'thing', 'required argument option', required: true
 
  u args:2, 'key value argument option, no clue'
  v args:2, argName:'property=value', valueSeparator:'=', 'key=value argument option'
}

def args = [ '-b', '--no-shortop-1', '-r', 'req', '-u', "vvv www", '-v', 'xxx=yyy', 'qwer', 'asdf', "1234 5678", 'zxcv', 'cvbn' ]
def opts = cli.parse(args) ?: System.exit(1)
//def opts = cli.parse(args)
 
println "${args.join(' ')}"
println 'Arguments: ' << opts.arguments()
println '-s: ' << opts.s
println '-b: ' << opts.b
println '--no-shortop-1: ' << opts.'no-shortop-1'
println '--no-shortop-2: ' << opts.'no-shortop-2'
println '-n: ' << opts.n
println '-r: ' << opts.r
println '-u: ' << opts.u
println '-us: ' << opts.us
println '-v: ' << opts.v
println '-vs: ' << opts.vs

println ""
cli.usage()
