#include <stdio.h>   /* printf */
#include <stdlib.h>  /* exit */
#include <unistd.h>

int main(int argc, char *argv[])
{
	int nflag, tflag;
	int opt;
	int nsecs;

	nsecs = 0;
	nflag = 0;
	tflag = 0;
	while ((opt = getopt(argc, argv, "nt:")) != -1) {
		switch (opt) {
		case 'n':
			nflag = 1;
			break;
		case 't':
			nsecs = atoi(optarg);
			tflag = 1;
			break;
		default: /* '?' */
			fprintf(stderr, "Usage: %s [-t nsecs] [-n] name\n",
				argv[0]);
			exit(EXIT_FAILURE);
		}
	}

	printf("nflag=%d; tflag=%d; optind=%d\n", nflag, tflag, optind);
	if (tflag) {
		printf("nsecs=%d\n", nsecs);
	}

	if (optind > argc) {
		fprintf(stderr, "Expected argument after options\n");
		exit(EXIT_FAILURE);
	}

	printf("name argument = %s\n", argv[optind]);

	/* Other code omitted */

	exit(EXIT_SUCCESS);
}

