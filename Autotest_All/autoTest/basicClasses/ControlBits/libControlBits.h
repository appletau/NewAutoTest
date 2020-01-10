//
//  libControlBits.h
//  autoTest
//
//  Created by Li Richard on 13-8-29.
//  Copyright (c) 2013年 TOM. All rights reserved.
//

#ifndef autoTest_libControlBits_h
#define autoTest_libControlBits_h

#define ARRAYSIZE               256
#define DefectFailCount         -1
#define STAIONALWAYSALLOWTEST   -1


bool IP_CBsToClearOnFail(void);
bool IP_CBsToClearOnPass(void);
bool IP_CBsToCheck(int *dstArray,size_t *arrayLength,char stationNameArray[ARRAYSIZE][ARRAYSIZE]);
int IP_StationFailCountAllowed(void);
const char * getAuthVersion();
unsigned char * IP_CBToCreateSHA1(unsigned char* secretKey, unsigned char* nonce);
bool IP_CBsToClearOnFail2(int *dstArray,size_t *arrayLength);
bool IP_CBsToClearOnPass2(int *dstArray,size_t *arrayLength);
bool setCb();

#endif
