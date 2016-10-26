//package no package

import java.util.*;

public class Hello { // clase start

public static void test(String[] options, int flag)
{
	System.out.print("Args: ");
	for (String opt : options) {
		System.out.print(opt + " ");
	}
	System.out.println("");
}

public static void main(String[] argv)
{
	//test({"hello", "world", "hello", "programmer"}, 0); #wrong
	//test(["hello", "world", "hello", "programmer"], 0); #wrong
	test(new String[]{"hello", "world", "hello", "programmer"}, 0);

	String[] strlist = {"hello", "world2", "hello", "programmer2"};
	test(strlist, 0);

	test(argv, 0);
}

} //class end
