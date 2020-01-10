//
//  Function.h
//  autoTest
//
//  Created by May on 4/30/13.
//  Copyright (c) 2013 TOM. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <IACFactoryFramework/PlistIO.h>
#import <IACFactoryFramework/item.h>
#import <IACFactoryFramework/CBdelegate.h>
#import <IACFactoryFramework/libControlBits.h>
#import <IACFactoryFramework/ControlBits.h>
#import <IACFactoryFramework/Pudding.h>
#import "Device.h"
#import "RegxFunc.h"
#import "ValidatorPW.h"
#import "Utility.h"
#import "ShellCmd.h"
#import "ThreadSync.h"

#define DefectCBIndex @"-1"

enum ARGS_INDEX
{
    MethodName,Command,ValidForm,Min,Max,Unit,
    SN,MLB_SN,MPN,Region,
    pudding,controlbits,validatorPW,
    SNs=6,Other
};


#define init_before_test \
[testValue setString:@"0"];\
[testMessage setString:DEFAULT_MESSAGE];\
[testDisplayMessage setString:NA_STR];\
isPass=FALSE;\
isTimeout=FALSE;\
if (skipBelowTest)\
{\
[testDisplayMessage setString:@"skiped"];\
isPass=true;\
return;\
}\
if (isStartPudding)\
{\
skipBelowTest=![self Pudding_checkAMIOK:args];\
}\
if (skipBelowTest)\
{\
[testDisplayMessage setString:[[self catchObj:args name:pudding] amiokay_msg]];\
isPass=false;\
return;\
}\


#define init_before_test_wo_skip \
[testValue setString:@"0"];\
[testMessage setString:DEFAULT_MESSAGE];\
[testDisplayMessage setString:NA_STR];\
isPass=FALSE;\
isTimeout=FALSE;\

@interface IAC_Function : NSObject<CBdelegate>
{
    NSMutableString *testValue;
    NSMutableString *testMessage;
    NSMutableString *testDisplayMessage;
    Boolean isPass;
    Boolean isTimeout;
    Boolean isAllowPudding;
    NSUInteger testCount;
    Boolean skipBelowTest;
    Boolean isStartPudding;
    NSMutableDictionary *SecretKeyTable;
    PlistIO *plist;
    Pudding *puddings;
    ThreadSync *threadSyncStatus;
    BOOL confirm;
    int my_thread_index;//1~4
    
    ShellCmd *shellcmd;
    Device *dev;
}
@property(readonly)NSMutableString *testValue;
@property(readonly)NSMutableString *testMessage;
@property(readonly)NSMutableString *testDisplayMessage;
@property(readonly)Boolean isPass;
@property(readonly)Boolean isTimeout;
@property(readonly)Boolean skipBelowTest;
@property(readonly)Boolean isStartPudding;

-(id)initWithDutNum:(const int)dutNum withThreadsync:(ThreadSync*)threadSync;
@end
