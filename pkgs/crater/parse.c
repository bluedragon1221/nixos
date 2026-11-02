#define _GNU_SOURCE
#include "crater.h"

#include <arpa/inet.h>
#include <getopt.h>
#include <string.h>

/* ^[a-z][a-z0-9-]{0,10}$ and no trailing '-'. Locale-independent on purpose. */
int valid_name(const char *s)
{
	size_t n = strnlen(s, CRATER_NAME_MAX + 1);

	if (n == 0 || n > CRATER_NAME_MAX)
		return 0;
	if (s[0] < 'a' || s[0] > 'z')
		return 0;
	for (size_t i = 1; i < n; i++) {
		char c = s[i];
		if (!((c >= 'a' && c <= 'z') || (c >= '0' && c <= '9') || c == '-'))
			return 0;
	}
	return s[n - 1] != '-';
}

static int in_net(uint32_t a, uint32_t net, int bits)
{
	uint32_t mask = ~UINT32_C(0) << (32 - bits);
	return (a & mask) == net;
}

/* "A.B.C.D/30", aligned, inside RFC 1918 space. */
int parse_subnet(const char *s, uint32_t *base_out)
{
	const char *slash = strchr(s, '/');
	char buf[16];
	struct in_addr a;
	uint32_t h;
	size_t n;

	if (!slash || strcmp(slash, "/30") != 0)
		return 0;
	n = (size_t)(slash - s);
	if (n < 7 || n > 15)           /* "1.2.3.4" .. "255.255.255.255" */
		return 0;
	memcpy(buf, s, n);
	buf[n] = '\0';
	if (inet_pton(AF_INET, buf, &a) != 1)
		return 0;

	h = ntohl(a.s_addr);
	if (h & 3)                      /* not aligned to a /30 */
		return 0;
	if (!(in_net(h, UINT32_C(0x0A000000), 8)  ||   /* 10.0.0.0/8     */
	      in_net(h, UINT32_C(0xAC100000), 12) ||   /* 172.16.0.0/12  */
	      in_net(h, UINT32_C(0xC0A80000), 16)))    /* 192.168.0.0/16 */
		return 0;

	*base_out = h;
	return 1;
}

/* Exactly "yes" or "no". */
static int parse_bool(const char *s, int *out)
{
	if (!strcmp(s, "yes")) { *out = 1; return 1; }
	if (!strcmp(s, "no"))  { *out = 0; return 1; }
	return 0;
}

int parse_args(int argc, char **argv, struct opts *out, const char **err)
{
	/* getopt_long accepts unambiguous prefixes (--na=x); that is documented
	 * behavior and deliberately allowed. */
	static const struct option longopts[] = {
		{ "name",   required_argument, NULL, 'n' },
		{ "subnet", required_argument, NULL, 's' },
		{ "masquerade", required_argument, NULL, 'm' },
		{ NULL, 0, NULL, 0 }
	};
	int have_name = 0, have_subnet = 0, have_masq = 0, opt, sargc;
	char **sargv;

	memset(out, 0, sizeof(*out));
	out->masquerade = 1;
	*err = NULL;

	if (argc < 2 || !argv) {
		*err = "missing command (try --help)";
		return EXIT_CR_USAGE;
	}
	/* argv[0] is skipped: it is the invoking path (a long /nix/store/... path
	 * under systemd) and is never used. Only user-supplied arguments are capped. */
	for (int i = 1; i < argc; i++) {
		if (!argv[i] || strnlen(argv[i], CRATER_ARG_MAX + 1) > CRATER_ARG_MAX) {
			*err = "argument too long";
			return EXIT_CR_USAGE;
		}
	}

	if (!strcmp(argv[1], "up"))             out->cmd = CMD_UP;
	else if (!strcmp(argv[1], "down"))      out->cmd = CMD_DOWN;
	else if (!strcmp(argv[1], "--help"))    out->cmd = CMD_HELP;
	else {
		*err = "unknown command (try --help)";
		return EXIT_CR_USAGE;
	}

	if (out->cmd == CMD_HELP) {
		if (argc != 2) {
			*err = "unexpected arguments";
			return EXIT_CR_USAGE;
		}
		return EXIT_CR_OK;
	}

	/* Parse everything after the subcommand. getopt treats sargv[0] as the
	 * program name, so the subcommand itself is skipped. */
	sargc = argc - 1;
	sargv = argv + 1;
	optind = 0;     /* glibc: full reinitialisation (needed for fuzzing) */
	opterr = 0;     /* we print our own one-line errors */

	/* leading '+': stop at first non-option, ignore POSIXLY_CORRECT */
	while ((opt = getopt_long(sargc, sargv, "+", longopts, NULL)) != -1) {
		switch (opt) {
		case 'n':
			if (have_name) {
				*err = "--name given twice";
				return EXIT_CR_USAGE;
			}
			if (!valid_name(optarg)) {
				*err = "invalid --name (want [a-z][a-z0-9-]{0,10}, no trailing '-')";
				return EXIT_CR_INVALID;
			}
			memcpy(out->name, optarg, strlen(optarg) + 1);
			have_name = 1;
			break;
		case 's':
			if (have_subnet) {
				*err = "--subnet given twice";
				return EXIT_CR_USAGE;
			}
			if (!parse_subnet(optarg, &out->subnet)) {
				*err = "invalid --subnet (want aligned private A.B.C.D/30)";
				return EXIT_CR_INVALID;
			}
			have_subnet = 1;
			break;
		case 'm':
			if (have_masq) {
				*err = "--masquerade given twice";
				return EXIT_CR_USAGE;
			}
			if (!parse_bool(optarg, &out->masquerade)) {
				*err = "invalid --masquerade (want yes or no)";
				return EXIT_CR_INVALID;
			}
			have_masq = 1;
			break;
		default:
			*err = "unknown option or missing value";
			return EXIT_CR_USAGE;
		}
	}

	if (optind != sargc) {
		*err = "unexpected positional argument";
		return EXIT_CR_USAGE;
	}
	if (!have_name) {
		*err = "--name is required";
		return EXIT_CR_USAGE;
	}
	if (out->cmd == CMD_UP && !have_subnet) {
		*err = "--subnet is required for 'up'";
		return EXIT_CR_USAGE;
	}
	if (out->cmd == CMD_DOWN && (have_subnet || have_masq)) {
		*err = "--subnet and --masquerade are not accepted by 'down'";
		return EXIT_CR_USAGE;
	}
	return EXIT_CR_OK;
}
