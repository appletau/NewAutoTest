//
//  ControlBits.h
//  autoTest
//
//  Created by Li Richard on 13-8-28.
//  Copyright (c) 2013年 TOM. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CBAuth_API.h"
#import "CBdelegate.h"
#define CB_INCOMPLETE @"INCOMPLETE"
#define CB_PASS @"PASS"
#define CB_FAIL @"FAIL"
#define CB_UNTESTED @"UNTESTED"

@interface ControlBits : NSObject
{
    Boolean CBenable;
    id<CBdelegate> delegate;
    NSMutableString *testMessage;
    size_t CBsToCheckSize;
    BOOL CBsToCheckOn;
}

@property(readonly)Boolean CBenable;
@property (nonatomic, assign) id<CBdelegate> delegate;
@property(readonly)size_t CBsToCheckSize;
@property(readonly)BOOL CBsToCheckOn;
- (id)init;
- (void)dealloc;
- (NSString *) testMessage;
- (BOOL)startHandler:(NSString*)myCBindex;
- (BOOL)CBsToClearOnFail;
- (BOOL)CBsToClearOnPass;
- (BOOL)CBsToCheck;
- (BOOL)SetCBsEnable;
- (int)StationFailCountAllowed;
+ (const char *)getVersion;
+ (unsigned char*)getSHA1ByKey:(unsigned char*)secretKey andNonce:(unsigned char*)nonce;
@end
