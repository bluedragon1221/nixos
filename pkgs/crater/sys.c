#define _GNU_SOURCE
#include "sys.h"
#include "netlink.h"

#include <arpa/inet.h>
#include <errno.h>
#include <fcntl.h>
#include <ifaddrs.h>
#include <limits.h>
#include <net/if.h>
#include <netinet/in.h>
#include <sched.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/mount.h>
#include <sys/stat.h>
#include <sys/wait.h>
#include <time.h>
#include <unistd.h>

#define RUN_DIR     "/run/crater"
#define NETWORK_DIR "/run/systemd/network"

/* Run argv[0] with an empty environment and no shell. Returns 0 only on exit 0. */
static int run_cmd(int quiet, char *const argv[])
{
	static char *const envp[] = { NULL };
	pid_t p = fork();
	int st;

	if (p < 0)
		return -1;
	if (p == 0) {
		if (quiet) {
			int n = open("/dev/null", O_WRONLY | O_CLOEXEC);
			if (n >= 0)
				(void)dup2(n, 2);
		}
		execve(argv[0], argv, envp);
		_exit(127);
	}
	while (waitpid(p, &st, 0) < 0)
		if (errno != EINTR)
			return -1;
	return (WIFEXITED(st) && WEXITSTATUS(st) == 0) ? 0 : -1;
}

/*
 * Locate a tool via $PATH. Only absolute entries are considered (a relative or
 * empty entry would mean "current directory", unsafe for a root tool), and the
 * file must be a regular file owned by root and not writable by group/others.
 * Children still run with an empty environment.
 */
static int find_bin(const char *name, char *out, size_t outn)
{
	const char *path = getenv("PATH");
	char copy[4096], *save = NULL, *dir;

	if (!path || strlen(path) >= sizeof(copy)) {
		fputs("crater: PATH is unset or too long\n", stderr);
		return -1;
	}
	memcpy(copy, path, strlen(path) + 1);

	for (dir = strtok_r(copy, ":", &save); dir; dir = strtok_r(NULL, ":", &save)) {
		struct stat st;

		if (dir[0] != '/')
			continue;
		if (snprintf(out, outn, "%s/%s", dir, name) >= (int)outn)
			continue;
		if (stat(out, &st) == 0 && S_ISREG(st.st_mode) && st.st_uid == 0 &&
		    !(st.st_mode & (S_IWGRP | S_IWOTH)) && access(out, X_OK) == 0)
			return 0;
	}
	out[0] = '\0';
	fprintf(stderr, "crater: no trusted '%s' found in PATH\n", name);
	return -1;
}

static char g_nctl[PATH_MAX];

static int find_tools(void)
{
	return find_bin("networkctl", g_nctl, sizeof(g_nctl));
}

#define NCTL(quiet, ...) \
	run_cmd((quiet), (char *const[]){ g_nctl, __VA_ARGS__, NULL })

static void fmt_addr(char *buf, size_t n, uint32_t a, const char *suffix)
{
	snprintf(buf, n, "%u.%u.%u.%u%s", (a >> 24) & 255u, (a >> 16) & 255u,
		 (a >> 8) & 255u, a & 255u, suffix);
}

static int wait_pid_ok(pid_t p)
{
	int st;

	while (waitpid(p, &st, 0) < 0)
		if (errno != EINTR)
			return -1;
	return (WIFEXITED(st) && WEXITSTATUS(st) == 0) ? 0 : -1;
}

/* /run/crater must be a real directory, root-owned, not group/world writable. */
static int ensure_run_dir(void)
{
	struct stat st;

	if (mkdir(RUN_DIR, 0755) < 0 && errno != EEXIST)
		return -1;
	if (lstat(RUN_DIR, &st) < 0)
		return -1;
	if (!S_ISDIR(st.st_mode) || st.st_uid != 0 || (st.st_mode & (S_IWGRP | S_IWOTH)))
		return -1;
	return 0;
}

/*
 * Persistent network namespace at `path`: create an empty file, then in a
 * short-lived child unshare(CLONE_NEWNET) and bind-mount the child's namespace
 * onto it. The parent never leaves its own namespace.
 */
static int create_ns(const char *path)
{
	int fd = open(path, O_RDONLY | O_CREAT | O_EXCL | O_CLOEXEC | O_NOFOLLOW, 0444);
	pid_t p;

	if (fd < 0)
		return -1;
	close(fd);

	p = fork();
	if (p < 0)
		return -1;
	if (p == 0) {
		if (unshare(CLONE_NEWNET) < 0)
			_exit(1);
		if (mount("/proc/self/ns/net", path, NULL, MS_BIND, NULL) < 0)
			_exit(2);
		_exit(0);
	}
	return wait_pid_ok(p);
}

/*
 * Write /run/systemd/network/50-crater-NAME.network from a fixed template.
 * Temp file + rename through a directory fd so networkd never sees a partial
 * file and nothing is followed through symlinks.
 */
static int write_network_file(const struct opts *o, const char *ifn, const char *host_cidr)
{
	char body[512], final[96], tmp[96];
	int dfd, fd, n, rc = -1;
	size_t off = 0;

	n = snprintf(body, sizeof(body),
		     "[Match]\n"
		     "Name=%s\n"
		     "\n"
		     "[Network]\n"
		     "Address=%s\n"
		     "%s"
		     "LinkLocalAddressing=no\n"
		     "IPv6AcceptRA=no\n"
		     "ConfigureWithoutCarrier=yes\n",
		     ifn, host_cidr,
		     /* no NAT: also pin forwarding off on this link, so packets are not
		      * routed out un-NATed when forwarding is enabled globally */
		     o->masquerade ? "IPMasquerade=ipv4\n" : "IPv4Forwarding=no\n");
	if (n < 0 || (size_t)n >= sizeof(body))
		return -1;
	snprintf(final, sizeof(final), "50-crater-%s.network", o->name);
	snprintf(tmp, sizeof(tmp), ".50-crater-%s.network.tmp", o->name);

	if (mkdir(NETWORK_DIR, 0755) < 0 && errno != EEXIST)
		return -1;
	dfd = open(NETWORK_DIR, O_RDONLY | O_DIRECTORY | O_CLOEXEC | O_NOFOLLOW);
	if (dfd < 0)
		return -1;

	(void)unlinkat(dfd, tmp, 0);       /* leftover from a crash */
	fd = openat(dfd, tmp, O_WRONLY | O_CREAT | O_EXCL | O_CLOEXEC | O_NOFOLLOW, 0644);
	if (fd < 0)
		goto out;
	while (off < (size_t)n) {
		ssize_t w = write(fd, body + off, (size_t)n - off);
		if (w < 0 && errno == EINTR)
			continue;
		if (w <= 0)
			break;
		off += (size_t)w;
	}
	if (close(fd) == 0 && off == (size_t)n && renameat(dfd, tmp, dfd, final) == 0)
		rc = 0;
out:
	if (rc != 0)
		(void)unlinkat(dfd, tmp, 0);
	close(dfd);
	return rc;
}

/* Poll (via libc getifaddrs, nothing to parse) until networkd has put the
 * address on the host end and the link is up. ~5 s total. */
static int wait_host_addr(const char *ifn, uint32_t host)
{
	const struct timespec ts = { 0, 50 * 1000 * 1000 };

	for (int i = 0; i < 100; i++) {
		struct ifaddrs *all, *p;
		int ok = 0;

		if (getifaddrs(&all) == 0) {
			for (p = all; p; p = p->ifa_next) {
				const struct sockaddr_in *sin;

				if (!p->ifa_addr || p->ifa_addr->sa_family != AF_INET ||
				    strcmp(p->ifa_name, ifn) != 0)
					continue;
				sin = (const struct sockaddr_in *)(const void *)p->ifa_addr;
				if (ntohl(sin->sin_addr.s_addr) == host && (p->ifa_flags & IFF_UP))
					ok = 1;
			}
			freeifaddrs(all);
		}
		if (ok)
			return 0;
		nanosleep(&ts, NULL);
	}
	return -1;
}

static void paths(const struct opts *o, char *ns, size_t nsn, char *ifn, size_t ifnn)
{
	snprintf(ns, nsn, RUN_DIR "/%s", o->name);
	snprintf(ifn, ifnn, "cr-%s", o->name);
}

/* Every step runs even if an earlier one fails; the result is the worst. */
static int teardown(const struct opts *o, int reload)
{
	char ns[64], ifn[32], file[96];
	int rc = EXIT_CR_OK, nl;

	paths(o, ns, sizeof(ns), ifn, sizeof(ifn));
	snprintf(file, sizeof(file), NETWORK_DIR "/50-crater-%s.network", o->name);

	/* Deleting the host end of a veth destroys the peer too. A missing device
	 * (ENODEV) is fine; anything else is a real problem worth reporting. */
	nl = nl_open(-1);
	if (nl < 0) {
		fprintf(stderr, "crater: netlink: %s\n", strerror(-nl));
		rc = EXIT_CR_SYSTEM;
	} else {
		int e = nl_dellink(nl, ifn);

		if (e < 0 && e != -ENODEV) {
			fprintf(stderr, "crater: could not delete %s: %s\n", ifn, strerror(-e));
			rc = EXIT_CR_SYSTEM;
		}
		close(nl);
	}

	if (unlink(file) < 0 && errno != ENOENT) {
		fputs("crater: could not remove networkd file\n", stderr);
		rc = EXIT_CR_SYSTEM;
	}
	if (umount2(ns, MNT_DETACH) < 0 && errno != ENOENT && errno != EINVAL) {
		fputs("crater: umount failed\n", stderr);
		rc = EXIT_CR_SYSTEM;
	}
	if (unlink(ns) < 0 && errno != ENOENT) {
		fputs("crater: unlink failed\n", stderr);
		rc = EXIT_CR_SYSTEM;
	}
	if (reload && NCTL(0, "reload") != 0) {
		fputs("crater: networkctl reload failed\n", stderr);
		rc = EXIT_CR_SYSTEM;
	}
	return rc;
}

int crater_down(const struct opts *o)
{
	if (find_tools() != 0)
		return EXIT_CR_SYSTEM;
	return teardown(o, 1);
}

#define STEP(expr, msg) \
	do { if ((expr) != 0) { fputs("crater: failed: " msg "\n", stderr); goto fail; } } while (0)

/* For the netlink helpers: they return -errno, and we want to show it. */
#define NLSTEP(expr, msg) \
	do { \
		int e_ = (expr); \
		if (e_ < 0) { \
			fprintf(stderr, "crater: failed: " msg ": %s\n", strerror(-e_)); \
			goto fail; \
		} \
	} while (0)

int crater_up(const struct opts *o)
{
	char ns[64], ifn[32], host_cidr[24];
	int nsfd = -1, hostns = -1, nl = -1;

	paths(o, ns, sizeof(ns), ifn, sizeof(ifn));
	fmt_addr(host_cidr, sizeof(host_cidr), o->subnet + 1, "/30");

	if (find_tools() != 0)
		return EXIT_CR_SYSTEM;
	if (ensure_run_dir() != 0) {
		fputs("crater: " RUN_DIR " is missing or unsafe\n", stderr);
		return EXIT_CR_SYSTEM;
	}

	/* Idempotent: clear leftovers (no reload yet, we reload once below). */
	if (teardown(o, 0) != EXIT_CR_OK)
		return EXIT_CR_SYSTEM;

	/* A handle on our own (host) namespace: the veth peer is created there. */
	hostns = open("/proc/self/ns/net", O_RDONLY | O_CLOEXEC);
	STEP(hostns < 0, "open host namespace");

	/* networkd file first, so the host end is configured the moment it appears. */
	STEP(write_network_file(o, ifn, host_cidr), "write networkd file");
	STEP(NCTL(0, "reload"), "networkctl reload");

	STEP(create_ns(ns), "create namespace");
	nsfd = open(ns, O_RDONLY | O_CLOEXEC);
	STEP(nsfd < 0, "open namespace");

	/* Everything inside the namespace goes through one netlink socket that
	 * lives in it, while this process stays in the host namespace. */
	nl = nl_open(nsfd);
	if (nl < 0) {
		fprintf(stderr, "crater: failed: netlink in namespace: %s\n", strerror(-nl));
		nl = -1;
		goto fail;
	}
	NLSTEP(nl_veth_create(nl, "eth0", ifn, hostns), "create veth");
	NLSTEP(nl_link_up(nl, "lo"), "bring up lo");
	NLSTEP(nl_addr_add4(nl, "eth0", o->subnet + 2, 30), "address eth0");
	NLSTEP(nl_link_up(nl, "eth0"), "bring up eth0");
	NLSTEP(nl_route_default4(nl, o->subnet + 1), "default route");

	/* networkd owns the host end; wait until it has configured it. */
	STEP(wait_host_addr(ifn, o->subnet + 1), "wait for networkd to configure host end");

	close(nl);
	close(nsfd);
	close(hostns);
	return EXIT_CR_OK;
fail:
	if (nl >= 0)
		close(nl);
	if (nsfd >= 0)
		close(nsfd);
	if (hostns >= 0)
		close(hostns);
	(void)teardown(o, 1);
	return EXIT_CR_SYSTEM;
}
