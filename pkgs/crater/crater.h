#ifndef CRATER_H
#define CRATER_H

#include <stdint.h>

#define CRATER_NAME_MAX 11   /* "cr-" + 11 = 14 chars, under IFNAMSIZ (16) */
#define CRATER_ARG_MAX  64   /* any single argv entry longer than this is rejected */

enum cmd { CMD_UP = 1, CMD_DOWN, CMD_HELP };

/* Everything parse_args() produces. Fixed size, no heap. */
struct opts {
	enum cmd cmd;
	char     name[CRATER_NAME_MAX + 1];
	uint32_t subnet;   /* host byte order, network address of the /30 */
	int      masquerade; /* 1 (default): NAT + forwarding; 0: host end only */
};

/* Exit codes, also used as parse_args() return values. */
enum { EXIT_CR_OK = 0, EXIT_CR_USAGE = 2, EXIT_CR_INVALID = 3, EXIT_CR_SYSTEM = 4 };

/*
 * Pure function: no I/O, no allocation, no environment. Returns 0 or an exit
 * code; on failure *err points at a static string safe to print (it never
 * echoes user input).
 */
int parse_args(int argc, char **argv, struct opts *out, const char **err);

int valid_name(const char *s);
int parse_subnet(const char *s, uint32_t *base_out);

#endif
