// ref: https://picocli.info/#_groovy

//'info.picocli.picocli' has been rename to 'info.picocli:picocli-groovy' since 4.*
@Grab('info.picocli:picocli-groovy:4.6.1')
@GrabConfig(systemClassLoader=true)
//Annotation PicocliScript Deprecated, use PicocliScript2 instead
@picocli.groovy.PicocliScript2

import groovy.transform.Field
import java.security.MessageDigest
import static picocli.CommandLine.*

@Parameters(arity="1", paramLabel="FILE", description="The file(s) whose checksum to calculate.")
@Field File[] files

@Option(names = ["-a", "--algorithm"], description = [
        "MD2, MD5, SHA-1, SHA-256, SHA-384, SHA-512,",
        "  or any other MessageDigest algorithm."])
@Field String algorithm = "MD5"

@Option(names= ["-h", "--help"], usageHelp= true, description= "Show this help message and exit.")
@Field boolean helpRequested

files.each {
  println MessageDigest.getInstance(algorithm).digest(it.bytes).encodeHex().toString() + "\t" + it
}

