/*
 * Written by Solar Designer <solar at openwall.com> in 2000-2011.
 * No copyright is claimed, and the software is hereby placed in the public
 * domain.  In case this attempt to disclaim copyright and place the software
 * in the public domain is deemed null and void, then the software is
 * Copyright (c) 2000-2011 Solar Designer and it is hereby released to the
 * general public under the following terms:
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted.
 *
 * There's ABSOLUTELY NO WARRANTY, express or implied.
 *
 * See crypt_blowfish.c for more information.
 */
#ifndef __OW_CRYPT_H
#define __OW_CRYPT_H

#ifdef __cplusplus
extern "C" {
#endif

#ifndef __GNUC__
#undef __const
#define __const const
#endif

#ifndef __SKIP_GNU
// Si crypt_r est déjà défini dans <crypt.h>, vous pouvez le commenter ici
// ou entourer avec #ifndef HAVE_CRYPT_R
// #ifndef HAVE_CRYPT_R
extern char *crypt_r(__const char *key, __const char *setting, void *data);
// #endif
extern char *crypt(__const char *key, __const char *setting);
#endif

/* Reste du code... */

#ifdef __cplusplus
}
#endif

#endif
