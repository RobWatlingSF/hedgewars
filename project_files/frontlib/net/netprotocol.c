/*
 * Hedgewars, a free turn based strategy game
 * Copyright (C) 2012 Simeon Maxein <smaxein@googlemail.com>
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License
 * as published by the Free Software Foundation; either version 2
 * of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */

#include "netprotocol.h"

#include "../util/util.h"
#include "../util/logging.h"

#include "../base64/base64.h"

#include <zlib.h>

#include <string.h>
#include <stdio.h>
#include <errno.h>
#include <stdlib.h>

static int fillTeamFromMsg(flib_team *team, char **parts) {
	team->name = flib_strdupnull(parts[0]);
	team->grave = flib_strdupnull(parts[1]);
	team->fort = flib_strdupnull(parts[2]);
	team->voicepack = flib_strdupnull(parts[3]);
	team->flag = flib_strdupnull(parts[4]);
	team->ownerName = flib_strdupnull(parts[5]);
	if(!team->name || !team->grave || !team->fort || !team->voicepack || !team->flag || !team->ownerName) {
		return -1;
	}

	errno = 0;
	long difficulty = strtol(parts[6], NULL, 10);
	if(errno) {
		return -1;
	}

	for(int i=0; i<HEDGEHOGS_PER_TEAM; i++) {
		flib_hog *hog = &team->hogs[i];
		hog->difficulty = difficulty;
		hog->name = flib_strdupnull(parts[7+2*i]);
		hog->hat = flib_strdupnull(parts[8+2*i]);
		if(!hog->name || !hog->hat) {
			return -1;
		}
	}
	return 0;
}

flib_team *flib_team_from_netmsg(char **parts) {
	flib_team *result = NULL;
	flib_team *tmpTeam = flib_calloc(1, sizeof(flib_team));
	if(tmpTeam) {
		if(!fillTeamFromMsg(tmpTeam, parts)) {
			result = tmpTeam;
			tmpTeam = NULL;
		} else {
			flib_log_e("Error parsing team from net.");
		}
	}
	flib_team_destroy(tmpTeam);
	return result;
}

flib_scheme *flib_netmsg_to_cfg(flib_metascheme *meta, char **parts) {
	flib_scheme *result = flib_scheme_create(meta, parts[0]);
	if(result) {
		for(int i=0; i<meta->modCount; i++) {
			result->mods[i] = !strcmp(parts[i+1], "true");
		}
		for(int i=0; i<meta->settingCount; i++) {
			result->settings[i] = atoi(parts[i+meta->modCount+1]);
		}
	}
	return result;
}

flib_map *flib_netmsg_to_map(char **parts) {
	flib_map *result = flib_map_create_named(parts[3], parts[0]);
	if(result) {
		result->mapgen = atoi(parts[1]);
		result->mazeSize = atoi(parts[2]);
		result->templateFilter = atoi(parts[4]);
	}
	return result;
}

int flib_netmsg_to_drawnmapdata(char *netmsg, uint8_t** outbuf, size_t *outlen) {
	int result = -1;

	// First step: base64 decoding
	char *base64decout = NULL;
	size_t base64declen;
	bool ok = base64_decode_alloc(netmsg, strlen(netmsg), &base64decout, &base64declen);
	if(ok && base64declen>3) {
		// Second step: unzip with the QCompress header. That header is just a big-endian
		// uint32 indicating the length of the uncompressed data.
		uint8_t *ubyteBuf = (uint8_t*)base64decout;
		uint32_t unzipLen =
				(((uint32_t)ubyteBuf[0])<<24)
				+ (((uint32_t)ubyteBuf[1])<<16)
				+ (((uint32_t)ubyteBuf[2])<<8)
				+ ubyteBuf[3];
		if(unzipLen==0) {
			*outbuf = NULL;
			*outlen = 0;
			result = 0;
		} else {
			uint8_t *out = flib_malloc(unzipLen);
			if(out) {
				uLongf actualUnzipLen = unzipLen;
				int resultcode = uncompress(out, &actualUnzipLen, (Bytef*)(base64decout+4), base64declen-4);
				if(resultcode == Z_OK) {
					*outbuf = out;
					*outlen = actualUnzipLen;
					out = NULL;
					result = 0;
				} else {
					flib_log_e("Uncompressing drawn map failed. Code: %i", resultcode);
				}
			}
			free(out);
		}
	} else {
		flib_log_e("base64 decoding of drawn map failed.");
	}
	free(base64decout);
	return result;
}
