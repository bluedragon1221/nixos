#define _GNU_SOURCE
#include "netlink.h"

#include <arpa/inet.h>
#include <errno.h>
#include <fcntl.h>
#include <net/if.h>
#include <sched.h>
#include <string.h>
#include <sys/socket.h>
#include <sys/time.h>
#include <unistd.h>

#include <linux/netlink.h>
#include <linux/rtnetlink.h>
#include <linux/if_link.h>
#include <linux/veth.h>

/* ---- message builder: fixed buffer, bounds-checked, sticky error ---- */

#define NLBUF 1024

struct nlb {
	_Alignas(8) char buf[NLBUF];
	size_t len;
	int err;
};

static void nlb_init(struct nlb *b, uint16_t type, unsigned flags)
{
	struct nlmsghdr *h;

	memset(b, 0, sizeof(*b));
	h = (struct nlmsghdr *)(void *)b->buf;
	h->nlmsg_type = type;
	h->nlmsg_flags = (uint16_t)(flags | NLM_F_REQUEST | NLM_F_ACK);
	h->nlmsg_seq = 1;
	b->len = NLMSG_HDRLEN;
}

/* Zeroed (the buffer starts zeroed, so padding is too), 4-byte aligned. */
static void *nlb_alloc(struct nlb *b, size_t n)
{
	size_t need = NLMSG_ALIGN(n);
	void *p;

	if (b->err || b->len + need > sizeof(b->buf)) {
		b->err = -E2BIG;
		return NULL;
	}
	p = b->buf + b->len;
	b->len += need;
	return p;
}

static void nlb_attr(struct nlb *b, uint16_t type, const void *data, size_t len)
{
	struct rtattr *a = nlb_alloc(b, RTA_LENGTH(len));

	if (!a)
		return;
	a->rta_type = type;
	a->rta_len = (unsigned short)RTA_LENGTH(len);
	if (len)
		memcpy(RTA_DATA(a), data, len);
}

static size_t nlb_nest_start(struct nlb *b, uint16_t type)
{
	size_t off = b->len;

	nlb_attr(b, type, NULL, 0);
	return off;
}

static void nlb_nest_end(struct nlb *b, size_t off)
{
	struct rtattr *a;

	if (b->err)
		return;
	a = (struct rtattr *)(void *)(b->buf + off);
	a->rta_len = (unsigned short)(b->len - off);
}

/* ---- send one request, wait for its ACK (or error) ---- */

static int nl_talk(int sock, struct nlb *b, int *ifindex_out)
{
	struct sockaddr_nl sa = { .nl_family = AF_NETLINK };
	struct nlmsghdr *h = (struct nlmsghdr *)(void *)b->buf;
	_Alignas(8) char rbuf[8192];

	if (b->err)
		return b->err;
	h->nlmsg_len = (uint32_t)b->len;

	if (sendto(sock, b->buf, b->len, 0, (struct sockaddr *)&sa, sizeof(sa)) < 0)
		return -errno;

	for (;;) {
		ssize_t n = recv(sock, rbuf, sizeof(rbuf), 0);
		size_t off = 0;

		if (n < 0) {
			if (errno == EINTR)
				continue;
			return -errno;       /* includes EAGAIN from the receive timeout */
		}
		while (off + NLMSG_HDRLEN <= (size_t)n) {
			const struct nlmsghdr *r = (const struct nlmsghdr *)(const void *)(rbuf + off);

			if (r->nlmsg_len < NLMSG_HDRLEN || off + r->nlmsg_len > (size_t)n)
				return -EBADMSG;
			if (r->nlmsg_type == NLMSG_ERROR) {
				const struct nlmsgerr *e = NLMSG_DATA(r);

				if (r->nlmsg_len < NLMSG_LENGTH(sizeof(*e)))
					return -EBADMSG;
				return e->error;           /* 0 = ACK, else -errno */
			}
			if (r->nlmsg_type == RTM_NEWLINK && ifindex_out &&
			    r->nlmsg_len >= NLMSG_LENGTH(sizeof(struct ifinfomsg))) {
				const struct ifinfomsg *i = NLMSG_DATA(r);
				*ifindex_out = i->ifi_index;
			}
			off += NLMSG_ALIGN(r->nlmsg_len);
		}
	}
}

static int nl_ifindex(int s, const char *name)
{
	struct nlb b;
	int idx = 0, rc;

	nlb_init(&b, RTM_GETLINK, 0);
	(void)nlb_alloc(&b, sizeof(struct ifinfomsg));
	nlb_attr(&b, IFLA_IFNAME, name, strlen(name) + 1);
	rc = nl_talk(s, &b, &idx);
	if (rc < 0)
		return rc;
	return idx > 0 ? idx : -ENODEV;
}

/* ---- public API ---- */

int nl_open(int nsfd)
{
	struct timeval tv = { 5, 0 };
	int home = -1, s, err = 0;

	if (nsfd >= 0) {
		home = open("/proc/self/ns/net", O_RDONLY | O_CLOEXEC);
		if (home < 0)
			return -errno;
		if (setns(nsfd, CLONE_NEWNET) < 0) {
			err = errno;
			close(home);
			return -err;
		}
	}
	/* A socket belongs to the namespace it was created in. */
	s = socket(AF_NETLINK, SOCK_RAW | SOCK_CLOEXEC, NETLINK_ROUTE);
	if (s < 0)
		err = errno;
	if (home >= 0) {
		if (setns(home, CLONE_NEWNET) < 0) {
			/* Stranded in the wrong namespace: stop before doing damage. */
			static const char m[] = "crater: cannot return to host namespace\n";
			ssize_t r = write(2, m, sizeof(m) - 1);
			(void)r;
			_exit(4);
		}
		close(home);
	}
	if (s < 0)
		return -err;
	(void)setsockopt(s, SOL_SOCKET, SO_RCVTIMEO, &tv, sizeof(tv));
	return s;
}

int nl_dellink(int s, const char *name)
{
	struct nlb b;

	nlb_init(&b, RTM_DELLINK, 0);
	(void)nlb_alloc(&b, sizeof(struct ifinfomsg));
	nlb_attr(&b, IFLA_IFNAME, name, strlen(name) + 1);
	return nl_talk(s, &b, NULL);
}

int nl_veth_create(int s, const char *name, const char *peer, int peer_nsfd)
{
	struct nlb b;
	int32_t nsfd = peer_nsfd;
	size_t linkinfo, data, peerattr;

	nlb_init(&b, RTM_NEWLINK, NLM_F_CREATE | NLM_F_EXCL);
	(void)nlb_alloc(&b, sizeof(struct ifinfomsg));
	nlb_attr(&b, IFLA_IFNAME, name, strlen(name) + 1);

	linkinfo = nlb_nest_start(&b, IFLA_LINKINFO);
	nlb_attr(&b, IFLA_INFO_KIND, "veth", sizeof("veth"));
	data = nlb_nest_start(&b, IFLA_INFO_DATA);
	peerattr = nlb_nest_start(&b, VETH_INFO_PEER);
	(void)nlb_alloc(&b, sizeof(struct ifinfomsg));   /* the peer's ifinfomsg */
	nlb_attr(&b, IFLA_IFNAME, peer, strlen(peer) + 1);
	nlb_attr(&b, IFLA_NET_NS_FD, &nsfd, sizeof(nsfd));
	nlb_nest_end(&b, peerattr);
	nlb_nest_end(&b, data);
	nlb_nest_end(&b, linkinfo);

	return nl_talk(s, &b, NULL);
}

int nl_link_up(int s, const char *name)
{
	struct nlb b;
	struct ifinfomsg *i;
	int idx = nl_ifindex(s, name);

	if (idx < 0)
		return idx;
	nlb_init(&b, RTM_NEWLINK, 0);
	i = nlb_alloc(&b, sizeof(*i));
	if (i) {
		i->ifi_index = idx;
		i->ifi_flags = IFF_UP;
		i->ifi_change = IFF_UP;
	}
	return nl_talk(s, &b, NULL);
}

int nl_addr_add4(int s, const char *name, uint32_t addr, unsigned prefix)
{
	struct nlb b;
	struct ifaddrmsg *a;
	uint32_t be = htonl(addr);
	int idx = nl_ifindex(s, name);

	if (idx < 0)
		return idx;
	nlb_init(&b, RTM_NEWADDR, NLM_F_CREATE | NLM_F_EXCL);
	a = nlb_alloc(&b, sizeof(*a));
	if (a) {
		a->ifa_family = AF_INET;
		a->ifa_prefixlen = (uint8_t)prefix;
		a->ifa_scope = RT_SCOPE_UNIVERSE;
		a->ifa_index = (uint32_t)idx;
	}
	nlb_attr(&b, IFA_LOCAL, &be, sizeof(be));
	nlb_attr(&b, IFA_ADDRESS, &be, sizeof(be));
	return nl_talk(s, &b, NULL);
}

int nl_route_default4(int s, uint32_t gw)
{
	struct nlb b;
	struct rtmsg *r;
	uint32_t be = htonl(gw);

	nlb_init(&b, RTM_NEWROUTE, NLM_F_CREATE | NLM_F_EXCL);
	r = nlb_alloc(&b, sizeof(*r));
	if (r) {
		r->rtm_family = AF_INET;
		r->rtm_table = RT_TABLE_MAIN;
		r->rtm_protocol = RTPROT_BOOT;
		r->rtm_scope = RT_SCOPE_UNIVERSE;
		r->rtm_type = RTN_UNICAST;
	}
	nlb_attr(&b, RTA_GATEWAY, &be, sizeof(be));
	return nl_talk(s, &b, NULL);
}
