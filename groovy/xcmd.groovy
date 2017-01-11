//http://docs.groovy-lang.org/next/html/gapi/groovy/util/CliBuilder.html

def cli = new CliBuilder(usage:'xcmd [options] arguments', header: 'options:')
cli.a('display all files')
cli.l('use a long listing format')
cli.t('sort by modification time')
cli.help('print this message')
cli.f(longOpt:'logfile', args:1, argName:'file', 'use given file for log')
cli.D(args:3, valueSeparator:',', argName:'property,value',
       'use value for given property')

def args = ' -tt -l -l  -D a,b,c,d,e  -logfile abc -f xyz --help'.split() // normally from commandline itself
def options = cli.parse(args)

println "args = ${args.join(' ')}"
println "\$options = $options"
println "\$options.a = $options.a"
println "\$options.l = $options.l"
println "\$options.t = $options.t"
println "\${options.t} = ${options.t}"
println "\${options.arguments()} = ${options.arguments()}"
println "\$options.arguments() = $options.arguments()" //wrong usage

println "\$options.D = $options.D"
println "\$options.Ds = $options.Ds"
println "\$options.logfile = $options.logfile"

if (options.help) {
	cli.usage()
}

