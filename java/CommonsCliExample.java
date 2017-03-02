//ref: https://commons.apache.org/proper/commons-cli/usage.html
//
//usage: 
//1. download commons-cli-${ver} package .zip or .tgz and unzip
//2. javac -classpath commons-cli-${ver}/commons-cli-$ver.jar CommonsCliExample.java
//3. java -classpath commons-cli-${ver}/commons-cli-$ver.jar CommonsCliExample
//BTW: if download src package, -classpath is commons-cli-${ver}/src/main/java

import java.util.*;
import org.apache.commons.cli.*;

public class CommonsCliExample { // clase start


public static void main(String[] argv)
{
	// create the command line parser
	CommandLineParser parser = new DefaultParser();

	// create the Options
	Options options = new Options();
	options.addOption("h", "help", false, "print this usage info");
	options.addOption("a", "all", false, "do not hide entries starting with .");
	options.addOption("A", "almost-all", false, "do not list implied . and ..");
	options.addOption("b", "escape", false, "print octal escapes for nongraphic "
						 + "characters" );
	options.addOption(OptionBuilder.withLongOpt( "block-size")
					.withDescription( "use SIZE-byte blocks")
					.hasArg()
					.withArgName("SIZE")
					.create());
	options.addOption("B", "ignore-backups", false, "do not list implied entried "
							 + "ending with ~");
	options.addOption("c", false, "with -lt: sort by, and show, ctime (time of last " 
				       + "modification of file status information) with "
				       + "-l:show ctime and sort by name otherwise: sort "
				       + "by ctime");
	options.addOption("C", false, "list entries by columns");


	String[] args = new String[]{ "--block-size=10" };

	try {
	    // parse the command line arguments
	    // CommandLine line = parser.parse(options, args);
	    CommandLine line = parser.parse(options, argv);

	    if (line.hasOption("help") || argv.length == 0) {
		// automatically generate the help statement
		HelpFormatter formatter = new HelpFormatter();
		formatter.printHelp("ls", options); 
	    }

	    // validate that block-size has been set
	    if (line.hasOption("block-size")) {
		// print the value of block-size
		System.out.println(line.getOptionValue("block-size"));
	    }
	}
	catch (ParseException exp) {
	    System.out.println("Unexpected exception:" + exp.getMessage());
	}
}


} //class end
