import java.io.*;
import java.util.ArrayList;
import java.util.List;

/*
 * compile and run:
    javac Shell.java
    java Shell
 */
public class Shell {
	public static class CommandHistory {
		private List<String> history = new ArrayList<String>();
	}

	public static void main(String[] args) throws java.io.IOException {
		String prompt;
		String commandLine;
		BufferedReader console = new BufferedReader(new InputStreamReader(System.in));
		ProcessBuilder pb = new ProcessBuilder();
		File startDir = new File(System.getProperty("user.dir"));
		pb.directory(startDir);

		CommandHistory cmdHistory = new CommandHistory();
		Integer indexOfHistory = 1;

		while (true) {
			// read what the user entered
			prompt = System.getProperty("user.name") + " " + System.getProperty("user.dir") + "> ";
			System.out.print(prompt);

			commandLine = console.readLine();
			String[] mycommands = commandLine.split(" +");

			// if the user entered a return, just loop again
			if (commandLine.equals("")) {
				continue;
			}

			try {
				if (commandLine.matches("!!")) {
					if (cmdHistory.history.size() == 1) {
						System.out.println("Error: No previous command found");
						continue;
					} else {
						String newcmds = cmdHistory.history.get(cmdHistory.history.size()-1).substring(indexOfHistory.toString().length()+1);
						mycommands = newcmds.split(" +");
						commandLine = newcmds;
					}
				}

				if (commandLine.matches("\\d+")) {
					if (Integer.parseInt(commandLine) > indexOfHistory) {
						System.out.println("Error: Invalid number in command history");
						continue;
					}
					Integer index = Integer.parseInt(commandLine);
					String newcmds = cmdHistory.history.get(index-1).substring(indexOfHistory.toString().length()+1);
					mycommands = newcmds.split(" +");
					commandLine = newcmds;
				}

				if (commandLine.matches("history")) {
					for (String s: cmdHistory.history) {
						System.out.println(s);
					}
					continue;
				}

				if (commandLine.trim().matches("exit")) {
					break;
				}

				if (commandLine.contains("cd")) {
					if (commandLine.trim().matches("cd") == true) {
						File home = new File(System.getProperty("user.home"));
						//System.out.println(home);
						pb.directory(home);
						System.setProperty("user.dir", home.getAbsolutePath());
						continue;
					} else if (commandLine.trim().matches("cd +\\.\\.")) {
						File parentDir = new File(pb.directory().getParent());
						//System.out.println(parentDir);
						pb.directory(parentDir);
						System.setProperty("user.dir", parentDir.getAbsolutePath());
						continue;
					} else {
						String dir = mycommands[1].trim();
						File newDir = new File(pb.directory() + File.separator + dir);
						if (dir.matches("^/.*") == true) {
							newDir = new File(dir);
						}
						if (newDir.isDirectory()) {
							//System.out.println(newDir);
							pb.directory(newDir);
							System.setProperty("user.dir", newDir.getAbsolutePath());
							continue;
						} else {
							System.out.println(dir + ": No such file or directory");
							continue;
						}
					}
				}

				pb.command(mycommands);
				Process p = pb.start();
				BufferedReader br = new BufferedReader(new InputStreamReader(p.getInputStream()));

				String s;
				while ((s = br.readLine()) != null) {
					System.out.println(s);
				}
				br.close();
			}
			catch(Exception e) {
				System.out.println(e.getMessage());
			}

			cmdHistory.history.add(indexOfHistory.toString() + " " + commandLine);
			indexOfHistory++;
		}
	}
}
