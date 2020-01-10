//
//  libInstantPudding.h
//  autoTest
//
//  Created by Li Richard on 13-8-28.
//  Copyright (c) 2013年 Li Richard. All rights reserved.
//

#ifndef autoTest_libInstantPudding_h
#define autoTest_libInstantPudding_h

//API_Reply Error Message Length
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


char unitSerialNumber[UUTATTRIBUTE_STRINGLENGTH];

bool UUTStart(const char* serialNumber,unsigned int snLength, char* replyMessage);
bool UUTDestroy(void);
bool UUTamIOkay(char* replyMessage);
bool UUTDone(char* replyMessage);

bool UUTSetStartTime(void);
bool UUTSetStopTime(void);
bool UUTAddAttribute(enum UUT_ADDATTRIBUTE addAttribute,char* value,char* replyMessage);
bool UUTAddAttributeByName(char *name,char* value,char* replyMessage);
bool UUTAddBlob(const char* inBlobName, const char* inPathToBlobFile, char* replyMessage);
bool UUTCreateTest(char* replyMessage);
bool UUTCleanTest(void);
bool UUTTestSpecSetTestName(const char* name);
bool UUTTestSpecSetSubTestName(const char* name);
bool UUTTestSpecSetSubSubTestName(const char* name);
bool UUTTestSpecSetValue(const char* value);
bool UUTTestSpecSetMessage(const char* message);
bool UUTTestSpecSetLimits(const char* lowerLimit,const char* upperLimit);
bool UUTTestSpecSetUnits(const char* units);
bool UUTAddResult(char* replyMessage);

const char* getIPVersion(void);
bool getGHStationInfo(int stationID,char * strStationID);
char* getSFC_URL();
#endif
