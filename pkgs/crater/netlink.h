#ifndef CRATER_NETLINK_H
#define CRATER_NETLINK_H

#include <stdint.h>

/*
 * Minimal rtnetlink client. Every function returns 0 (or an fd / ifindex where
 * noted) on success and -errno on failure, so callers see the kernel's real
 * error (EEXIST, ENODEV, EPERM, ...) instead of an exit status.
 */

/* Netlink socket bound to the network namespace `nsfd` (or the current one if
 * nsfd < 0). The process is back in its own namespace when this returns. */
int nl_open(int nsfd);

int nl_dellink(int sock, const char *name);
/* Create veth `name` in the socket's namespace; the peer `peer` is created in
 * the namespace referred to by `peer_nsfd`. */
int nl_veth_create(int sock, const char *name, const char *peer, int peer_nsfd);
int nl_link_up(int sock, const char *name);
int nl_addr_add4(int sock, const char *name, uint32_t addr_host_order, unsigned prefix);
int nl_route_default4(int sock, uint32_t gw_host_order);

#endif
