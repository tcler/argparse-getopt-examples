#include <stdio.h>   /* printf */
#include <stdlib.h>  /* exit */
#include <getopt.h>
#include <errno.h>
#include <string.h>

void usage(char *prog, FILE *fp)
{
	fprintf(fp, "Usage: %s [options] arg\n", prog);
	fprintf(fp, "Options: \n"
		"  -a       a option\n"
		"  -b       a option\n"
		"  --add    add option\n"
		"  ...\n"
	);
}

long long int countlines(char *filename);

int main(int argc, char **argv)
{
	int c;
	int digit_optind = 0;

	while (1) {
		int this_option_optind = optind ? optind : 1;
		int option_index = 0;
		static struct option long_options[] = {
			{"add",     required_argument, 0,  0 },
			{"append",  no_argument,       0,  0 },
			{"delete",  required_argument, 0,  0 },
			{"verbose", no_argument,       0,  0 },
			{"create",  required_argument, 0, 'c'},
			{"file",    required_argument, 0,  0 },
			{0,         0,                 0,  0 }
		};

		c = getopt_long(argc, argv, "habc:d:012",
				long_options, &option_index);
		if (c == -1)
			break;

		switch (c) {
		case 0:
			printf("option %s", long_options[option_index].name);
			if (optarg)
				printf(" with arg %s", optarg);
			printf("\n");
			break;

		case 'h':
			usage(argv[0], stdout);
			exit(EXIT_SUCCESS);
			break;

		case '0':
		case '1':
		case '2':
			if (digit_optind != 0 && digit_optind != this_option_optind)
				printf("digits occur in two different argv-elements.\n");
			digit_optind = this_option_optind;
			printf("option %c\n", c);
			break;

		case 'a':
			printf("option a\n");
			break;

		case 'b':
			printf("option b\n");
			break;

		case 'c':
			printf("option c with value '%s'\n", optarg);
			break;

		case 'd':
			printf("option d with value '%s'\n", optarg);
			break;

		case '?':
			break;

		default:
			printf("?? getopt returned character code 0%o ??\n", c);
		}
	}

	int argind = optind;
	if (optind < argc) {
		printf("non-option ARGV-elements: ");
		while (optind < argc)
			printf("%s ", argv[optind++]);
		printf("\n");
	}

	optind = argind;

	printf("\n");
	while (optind < argc) {
		char *filename = argv[optind++];
		long long int nlines = countlines(filename);
		if (nlines >= 0) {
			printf("%s: %lld\n", filename, countlines(filename));
		} else {
			fprintf(stderr, "%s: %s\n", filename, strerror(errno));
		}
	}

	exit(EXIT_SUCCESS);
}

long long int countlines(char *filename)
{
	long long int nlines = 0;
	char ch = '\0';
	FILE *fp = fopen(filename, "r");
	if (fp == NULL) {
		return -1;
	}

	do {
		ch = fgetc(fp);
		if (ch == '\n')
			nlines++;
	} while (ch != EOF);
	return nlines;
}
