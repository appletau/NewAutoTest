//
//  Function.h
//  autoTest
//
//  Created by May on 4/30/13.
//  Copyright (c) 2013 TOM. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PlistIO.h"
#import "Item.h"
#import "CBdelegate.h"
#import "libControlBits.h"
#import "ControlBits.h"
#import "Pudding.h"
#import "Device.h"
#import "RelayBox.h"
#import "Fixture.h"
#import "Meter34401A.h"
#import "Meter34465A_USB.h"
#import "Meter34465A_Client.h"
#import "Counter53131A.h"
#import "I2CMaster.h"
#import "Socket_Client.h"
#import "Socket_Server.h"
#import "UDP_Client.h"
#import "UDP_Server.h"
#import "DFU.h"
#import "UDID.h"
#import "PWR3615GW.h"
#import "PWR3631.h"
#import "Eload_PEL_3021.h"
#import "Eload_PEL_3021_USB.h"
#import "Tektronix_DPO4104BL_USB.h"
#import "SC18IM700.h"
#import "USB_HID.h"
#import "RegxFunc.h"
#import "Bobcat.h"
#import "SeggerFlasher.h"
#import "Stream.h"
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
    Bobcat *bobcat;
    Fixture *currentFixture;
    SeggerFlasher *segger;
    RelayBox *relayBox ;
    Meter34401A *meter;
    Meter34465A_Client *meter_clent;
    Meter34465A_USB *meter_usb;
    Counter53131A *counter;
    X1_Aardvark *aark;
    Socket_Client *tcp_client;
    Socket_Server *tcp_server;
    UDP_Client *udp_client;
    UDP_Server *udp_server;
    DFU *dfu;
    UDID *udid;
    PWR3615GW *pwr3615;
    PWR3631 *pwr3631;
    Eload_PEL_3021 *eload_gpib;
    Eload_PEL_3021_USB *eload_usb;
    Tektronix_DPO4104BL_USB *scope_usb;
    SC18IM700 *scim;
    USB_HID *hid;
    Stream *stream;
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
