#ifndef CHINADNS_NG_MAPUTILS_H
#define CHINADNS_NG_MAPUTILS_H

#define _GNU_SOURCE
#include "uthash.h"
#include "netutils.h"
#undef _GNU_SOURCE

/* hash table structure typedef */
typedef struct {
    uint16_t       unique_msgid;  /* [key]   globally unique msgid */
    uint16_t       origin_msgid;  /* [value] associated original msgid */
    int            query_timerfd; /* [value] dns query timeout timerfd */
    inet6_skaddr_t source_addr;   /* [value] associated client sockaddr */
    UT_hash_handle hh;            /* metadata, used internally by uthash */
} hashmap_t, hashentry_t;

/* put key and value to hashmap */
hashentry_t* hashmap_put(hashmap_t **hashmap, uint16_t unique_msgid, uint16_t origin_msgid, int query_timerfd, const inet6_skaddr_t *source_addr);

/* get entry_ptr by unique_msgid */
hashentry_t* hashmap_get(hashmap_t *hashmap, uint16_t unique_msgid);

/* delete and free the entry from hashmap */
void hashmap_del(hashmap_t **hashmap, hashentry_t *hashentry);

#endif