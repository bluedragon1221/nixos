#include "crater.h"
#include "sys.h"

#include <stdio.h>
#include <unistd.h>

static void usage(FILE *f)
{
	fputs("usage: crater up   --name=NAME --subnet=A.B.C.D/30 [--masquerade=yes|no]\n"
	      "       crater down --name=NAME\n", f);
}

int main(int argc, char **argv)
{
	struct opts o;
	const char *err;
	int r = parse_args(argc, argv, &o, &err);

	if (r) {
		fprintf(stderr, "crater: %s\n", err);
		return r;
	}
	if (o.cmd == CMD_HELP)    { usage(stdout); return EXIT_CR_OK; }

	if (geteuid() != 0) {
		fputs("crater: must run as root\n", stderr);
		return EXIT_CR_SYSTEM;
	}

	return o.cmd == CMD_UP ? crater_up(&o) : crater_down(&o);
}
