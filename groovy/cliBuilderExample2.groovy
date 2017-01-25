import org.apache.commons.cli.Option

def cli = new CliBuilder(
  usage : 'program [options] <arguments>',
  header : 'Options:',
  //posix: false,
)
 
cli.with {
  s 'simplest boolean option'
  b longOpt: 'both', 'boolean option with both longop and shortop'
 
  //_ longOpt: 'no-shortop-1', 'boolean option without short version 1'
 
  _ longOpt: 'multi', args:Option.UNLIMITED_VALUES, valueSeparator: ',', 'multiple args example'
}

if (args.length == 0)
	args = [ '-b', '--no-shortop-1', '-r', 'req', '-u', "vvv www", '-v', 'xxx=yyy', '--multi', 'ab,cd,ef,g', 'qwer', 'asdf', "1234 5678", 'zxcv', 'cvbn' ]
def opts = cli.parse(args) ?: System.exit(1)

println "${args.join(' ')}"

println 'Arguments: ' << opts.arguments()
println '-multi: ' << opts.multi
println '-multis: ' << opts.multis

println ""
cli.usage()
