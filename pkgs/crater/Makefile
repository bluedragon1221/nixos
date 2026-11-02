CC      ?= cc
WARN    := -Wall -Wextra -Wpedantic -Wshadow -Wconversion -Wformat=2 -Werror
HARDEN  := -O2 -D_FORTIFY_SOURCE=3 -fstack-protector-strong -fPIE -pie -Wl,-z,relro,-z,now

SRCS := main.c parse.c sys.c netlink.c

crater: $(SRCS) crater.h sys.h netlink.h
	$(CC) -std=c11 $(WARN) $(HARDEN) $(SRCS) -o $@

clean:
	rm crater
