#ifndef CRATER_SYS_H
#define CRATER_SYS_H

#include "crater.h"

/* Both return 0 or an EXIT_CR_* code. Inputs must come from parse_args(). */
int crater_up(const struct opts *o);
int crater_down(const struct opts *o);

#endif
