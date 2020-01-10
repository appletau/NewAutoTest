//
//  Pudding.h
//  autoTest
//
//  Created by May on 13/8/23.
//  Copyright (c) 2013年 Li Richard. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "InstantPudding_Additional.h"
//#import "InstantPudding_API.h"
#import "IPSFCPost_API.h"
#import "PlistIO.h"
#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <string.h>
#include <stdbool.h> //C99 support boolean

#define ERRORMESSAGE_BUFFER         1024
#define SUBTEST_NAMELENGTH          30

// lib instant pudding
#define API_REPLY_MSGLENGTH   255

//#define DEVICE_SN                   12
#define UUTATTRIBUTE_STRINGLENGTH   60
#define STATIONID_LENGTH            60
#define FUNCTIONTYPE_LENGTH         30

//additional common error strings
#define IP_FAIL_COMMON              "Test Fail"

/// UUT Attributes definitions
enum UUT_ADDATTRIBUTE
{
    UUT_ADDATTRIBUTE_SERIALNUMBER           = 1,
    UUT_ADDATTRIBUTE_STATIONSOFTWAREVERSION = 2,
    UUT_ADDATTRIBUTE_STATIONSOFTWARENAME    = 3,
    UUT_ADDATTRIBUTE_STATIONLIMITSVERSION   = 4,
    UUT_ADDATTRIBUTE_STATIONIDENTIFIER      = 5,
    UUT_ADDATTRIBUTE_SPECIAL_BUILD          = 6,
};

enum UUT_FUNCTIONTYPE
{
    UUT_FUNCTIONTYPE_NORMAL         =   0,
    UUT_FUNCTIONTYPE_START          =   1,
    UUT_FUNCTIONTYPE_ADDATTRIBUTE   =   2,
    UUT_FUNCTIONTYPE_ADDRESULT      =   3,
    UUT_FUNCTIONTYPE_AMIOKAY        =   4,
    UUT_FUNCTIONTYPE_DONE           =   5,
    UUT_FUNCTIONTYPE_COMMIT         =   6,
    UUT_FUNCTIONTYPE_BLOB           =   7,
};

/// Test Results should be same as IP_PASSFAILRESULT
enum TEST_PASSFAILRESULT
{
    
    /// test failed
    TEST_FAIL = 0,
    
    /// test passed
    TEST_PASS,
    
    /// test was not run or was skipped
    TEST_SKIP
    
};

///Each flag is set if that piece is reporting back OK
enum IP_CHECK_FLAGS
{
    IP_CHECK_PUDDING	= 1<<0, //Pudding (runs on test station)
    IP_CHECK_DCS		= 1<<1,	//Jello / DCS
    IP_CHECK_PDCA		= 1<<2,	//PDCA
    IP_CHECK_GH			= 1<<3,	//groundhog
    IP_CHECK_ALLFLAGS	//MUST BE LAST -- when using this, do (1<<IP_CHECK_ALLFLAGS)-1
};


@interface Pudding : NSObject
{
    char unitSerialNumber[UUTATTRIBUTE_STRINGLENGTH];
    char replyError[ERRORMESSAGE_BUFFER];
    char amIOK_Error[ERRORMESSAGE_BUFFER];
    BOOL replyResult;
    
    NSMutableString *amiokay_msg;
    BOOL amiokay_flag;
    
    IP_UUTHandle UID;
    IP_TestSpecHandle testSpec;
    IP_TestResultHandle testResult;
    char* stationMacAddr;

}
@property (readonly)BOOL amiokay_flag;
@property (readonly)NSMutableString *amiokay_msg;

+ (const char *)getStationName;
+ (const char *)getVersion;
- (BOOL)startHandler:(NSString*)snText;
- (BOOL) UUT_setDUTPos:(NSString *)fixture Header:(NSString*)header;
- (BOOL) UUT_CreateTest;
- (BOOL) UUT_TestSpecSetSubTestName:(const char *)name;
- (BOOL) UUT_TestSpecSetTestName:(const char*) name;
- (BOOL) UUT_TestSpecSetValue:(const char*) value;
- (BOOL) UUT_TestSpecSetLimits:(const char*) lowerLimit Upper_Limits:(const char*) upperLimit;
- (BOOL) UUT_TestSpecSetUnits:(const char*) units;
- (BOOL) UUT_TestSpecSetPriority:(enum IP_PDCA_PRIORITY) priority;
- (BOOL) UUT_TestSpecSetResult:(enum TEST_PASSFAILRESULT1) result;
- (BOOL) UUT_TestSpecSetMessage:(const char*) message;
- (BOOL) UUT_AddAttribute:(NSString *)name Value:(NSString*)val;
- (BOOL) UUT_AddBlob:(NSString *)blobName PathToBlobFile:(NSString *)pathToBlobFile;
- (BOOL) UUT_AddResult;
- (BOOL) UUT_CleanTest;
- (BOOL) UUT_SetStopTime;
- (BOOL) UUT_amIOkay;
- (BOOL) UUT_Done;
- (BOOL) UUT_Commit:(enum TEST_PASSFAILRESULT1)result;
- (BOOL) UUT_Destroy;

- (char *) replyError;


// lib start handle
- (BOOL) handleReply:(IP_API_Reply)reply uutFunctionType:(enum UUT_FUNCTIONTYPE)funcType replyMessage:(char*)msg;
- (BOOL) UUTStart:(const char*)serialNumber snLength:(unsigned int)len replyMessage:(char*)msg;
- (BOOL) UUTDestroy;
- (BOOL) UUTamIOkay:(char*) replyMessage;
- (BOOL) UUTDone:(char*)replyMessage;
- (BOOL) UUTSetStartTime;
- (BOOL) UUTSetStopTime;
- (BOOL) UUTAddAttribute:(enum UUT_ADDATTRIBUTE)addAttribute value:(char*)val replyMessage:(char*)msg;
- (BOOL) UUTAddAttributeByName:(char *)name value:(char*)val replyMessage:(char*)msg;
- (BOOL) UUTAddBlob:(const char*)inBlobName inPathToBlobFile:(const char*)filePath replyMessage:(char*)msg;
- (BOOL) UUTCreateTest:(char*)replyMessage;
- (BOOL) UUTCleanTest;
- (BOOL) UUTTestSpecSetTestName:(const char*)name;
- (BOOL) UUTTestSpecSetSubTestName:(const char*)name;
- (BOOL) UUTTestSpecSetSubSubTestName:(const char*)name;
- (BOOL) UUTTestSpecSetValue:(const char*)value;
- (BOOL) UUTTestSpecSetMessage:(const char*)message;
- (BOOL) UUTTestSpecSetLimits:(const char*)lowerLimit upperLimit:(const char*)upLimit;
- (BOOL) UUTTestSpecSetUnits:(const char*)units;
- (BOOL) UUTAddResult:(char*)replyMessage;
- (BOOL) UUTCommit:(enum TEST_PASSFAILRESULT)result replyMessage:(char*)msg;
- (BOOL) UUTTestSpecSetPriority:(enum IP_PDCA_PRIORITY)priority;
- (BOOL) UUTTestSpecSetResult:(enum TEST_PASSFAILRESULT)result;

- (BOOL) getGHStationInfo:(int)key outputData:(char *)data;
- (char*) getSFC_URL;
+ (const char *) getIPVersion;

// SFC
- (char*)SFC_getURL;
- (const char*)SFC_getLibVersion;
- (const char*)SFC_getServerVersion;
- (const char*)SFC_getHistoryBySN:(NSString *)acpSerialNumber;
- (int)SFC_AddRecord:(NSString *)acpSerialNumber withDictionary:(NSDictionary *)dic;
- (int)SFC_AddAttr:(NSString *)acpSerialNumber withDictionary:(NSDictionary *)dic;
- (NSDictionary *)SFC_QueryRecordBySn:(NSString *)acpSerialNumber withKeyArray:(NSArray *)keyArr;

@end
