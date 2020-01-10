//
//  Pudding.m
//  autoTest
//
//  Created by May on 13/8/23.
//  Copyright (c) 2013年 Li Richard. All rights reserved.
//

#import "Pudding.h"

#define STATION_SOFTWARE_LIMITS "1"
#define StationName [[[PlistIO sharedPlistIO] getObjForKey:@"STATION_NAME"]UTF8String]
#define SoftwareVersion [[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"] UTF8String]

char softwareVersion[UUTATTRIBUTE_STRINGLENGTH];
char softwareName[UUTATTRIBUTE_STRINGLENGTH];
char softwareBuild[UUTATTRIBUTE_STRINGLENGTH];
char softwareIdentifier[UUTATTRIBUTE_STRINGLENGTH];

extern IP_TestSpecHandle IP_testSpec_create( void );
extern IP_TestResultHandle IP_testResult_create( void );
extern bool IP_testSpec_setSubTestName( IP_TestSpecHandle testSpecHandle, const char* name, size_t nameLength );
extern bool IP_testSpec_setSubSubTestName( IP_TestSpecHandle testSpecHandle, const char* name, size_t nameLength );
extern bool IP_testSpec_setTestName( IP_TestSpecHandle testSpecHandle, const char* name, size_t nameLength );
extern bool IP_testResult_setValue( void* testResultHandle, const char* value, size_t valueLength );
extern bool IP_testSpec_setLimits( IP_TestSpecHandle testSpecHandle,	const char* lowerLimit, size_t lowerLimitLength,
                                  const char* upperLimit, size_t upperLimitLength );
extern bool IP_testSpec_setUnits( IP_TestSpecHandle testSpecHandle, const char* units, size_t unitsLength );
extern bool IP_testSpec_setPriority( IP_TestSpecHandle testSpecHandle, enum IP_PDCA_PRIORITY priority );
extern bool IP_testResult_setResult( );
extern bool IP_testResult_setMessage( void* testResultHandle, const char* message, size_t messageLength );
extern IP_API_Reply IP_addResult( IP_UUTHandle inHandle, IP_TestSpecHandle testSpec, IP_TestResultHandle testResult );
extern void IP_testResult_destroy( IP_TestResultHandle testResultHandle );
extern void IP_testSpec_destroy( IP_TestSpecHandle testSpecHandle );
extern IP_API_Reply IP_setStopTime( IP_UUTHandle handleStopTime, time_t rawTimeToUse );
extern IP_API_Reply IP_amIOkay( IP_UUTHandle inHandle, const char* inUUTSerialNumber );
extern IP_API_Reply IP_UUTDone( IP_UUTHandle inHandle );
extern IP_API_Reply IP_UUTCommit( );
extern void IP_UID_destroy( IP_UUTHandle UUTHandle );

@implementation Pudding
@synthesize amiokay_flag,amiokay_msg;

-(id)init
{
    if (self = [super init])
    {
        amiokay_flag = YES;
        amiokay_msg = [[NSMutableString alloc] initWithString:@"NA"];
        stationMacAddr = (char*)malloc(30*sizeof(char));
    }
    return self;
}

-(void)dealloc
{
    [amiokay_msg release];
    [super dealloc];
}

- (BOOL)startHandler: (NSString*)snText
{
    memset(replyError, 0, ERRORMESSAGE_BUFFER);
    replyResult = [self UUTStart:[snText UTF8String] snLength:(unsigned int)[snText length] replyMessage:replyError];
    
    if (replyResult)
        replyResult &= [self UUTAddAttribute:UUT_ADDATTRIBUTE_SERIALNUMBER value:(char*)[snText UTF8String] replyMessage:replyError];
    if (replyResult)
        replyResult &= [self UUTAddAttribute:UUT_ADDATTRIBUTE_STATIONSOFTWAREVERSION value:(char*)SoftwareVersion replyMessage:replyError];
    if (replyResult)
        replyResult &= [self UUTAddAttribute:UUT_ADDATTRIBUTE_STATIONSOFTWARENAME value:(char*)StationName replyMessage:replyError];
    if (replyResult)
        replyResult &= [self UUTAddAttribute:UUT_ADDATTRIBUTE_STATIONLIMITSVERSION value:STATION_SOFTWARE_LIMITS replyMessage:replyError];
    if (replyResult)
        replyResult &= [self UUTAddAttribute:UUT_ADDATTRIBUTE_STATIONIDENTIFIER value:NULL replyMessage:replyError];
    if (replyResult)
        replyResult &= [self UUTSetStartTime];
    
    [self UUT_amIOkay];
    [self getGHStationInfo:IP_MAC outputData:stationMacAddr];
    
    return replyResult;
}

- (BOOL) UUT_AddAttribute:(NSString *)name Value:(NSString*)val
{
    if (![val respondsToSelector:@selector(UTF8String)])
    {
        sprintf(replyError, "UTF8String call error\t");
        return NO;
    }

    replyResult = [self UUTAddAttributeByName:(char*)[name UTF8String] value:(char*)[val UTF8String] replyMessage:replyError];
    
    if ( !replyResult)
        NSLog(@"%s",replyError);
    
    return replyResult;
}

- (BOOL) UUT_setDUTPos:(NSString *)fixture Header:(NSString*)header
{

    replyResult = [self UUTSetDUTPos:(char*)[fixture UTF8String] headerID:(char*)[header UTF8String] replyMessage:replyError];
    
    if ( !replyResult)
        NSLog(@"%s",replyError);
    return replyResult;
}





- (BOOL) UUT_AddBlob:(NSString *)blobName PathToBlobFile:(NSString *)pathToBlobFile
{
    replyResult = [self UUTAddBlob:(char*)[blobName UTF8String] inPathToBlobFile:(char*)[pathToBlobFile UTF8String] replyMessage:replyError];
    
    if ( !replyResult)
        NSLog(@"%s",replyError);
    
    return replyResult;
}

- (BOOL) UUT_CreateTest
{
    // create a test specification for our test
	testSpec = IP_testSpec_create(); // a new testSpec is needed for every test result
	
	// now determine whether we pass or fail
	testResult = IP_testResult_create();
	
	if (( NULL == testResult ) || ( NULL == testSpec )) {
        NSLog(@"ERROR with IP_addResult:%s",replyError);
        //sprintf(replyError,"ERROR with IP_addResult.\n");
        
        [self UUTCleanTest];
        return NO;
	}
    
    return YES;
}

- (BOOL) UUT_TestSpecSetSubTestName:(const char*)name
{
    size_t nameLength = strlen(name);
    
    IP_testSpec_setSubTestName( testSpec, name, nameLength);
    
    return true;
}

- (BOOL) UUT_TestSpecSetTestName:(const char*) name
{
    size_t nameLength = strlen(name);
    
    IP_testSpec_setTestName( testSpec, name, nameLength);
    
    return true;
}

- (BOOL) UUT_TestSpecSetValue:(const char*) value
{
    size_t valueLength = strlen(value);
    
    IP_testResult_setValue( testResult,value,valueLength );
    
    return true;
}

- (BOOL) UUT_TestSpecSetLimits:(const char*) lowerLimit
                 Upper_Limits:(const char*) upperLimit
{
    return IP_testSpec_setLimits( testSpec, lowerLimit, strlen(lowerLimit),
                                 upperLimit, strlen(upperLimit) );
}

- (BOOL) UUT_TestSpecSetUnits:(const char*) units
{
    return IP_testSpec_setUnits( testSpec, units, strlen(units));
}

- (BOOL) UUT_TestSpecSetPriority:(enum IP_PDCA_PRIORITY) priority
{
    IP_testSpec_setPriority( testSpec, priority );
    
    return true;
}

- (BOOL) UUT_TestSpecSetResult:(enum TEST_PASSFAILRESULT1) result
{
    enum IP_PASSFAILRESULT IPResult;
    
    switch (result) {
        case TEST_FAIL1:
            IPResult = IP_FAIL;
            break;
        case TEST_PASS1:
            IPResult = IP_PASS;
            break;
        case TEST_SKIP1:
            IPResult = IP_NA;
            break;
        default:
            IPResult = IP_NA;
            break;
    }
    IP_testResult_setResult( testResult, IPResult);
    
    return true;
}

- (BOOL) UUT_TestSpecSetMessage:(const char*) message
{
    size_t messageLength = strlen(message);
    
    return IP_testResult_setMessage( testResult, message, messageLength);;
}

- (BOOL) UUT_AddResult
{
    //## required step #3:  IP_addResult()
    IP_API_Reply reply = IP_addResult(UID, testSpec, testResult );
    
    return [self handleReply:reply uutFunctionType:UUT_FUNCTIONTYPE_ADDRESULT replyMessage:replyError];
}

- (BOOL) UUT_CleanTest
{
	IP_testResult_destroy(testResult);
	IP_testSpec_destroy(testSpec);
    
    return true;
}

- (BOOL) UUT_SetStopTime
{
    time_t rawtime;
    time( &rawtime );
    
    IP_setStopTime(UID, rawtime);
    
    return true;
}

- (BOOL) UUT_Done
{
    //## required step #4:  IP_UUTDone()
    //printf("Testing finished, calling 'UUTDone' for handle %s\n",UID);
	IP_API_Reply reply = IP_UUTDone(UID);
    
    return [self handleReply:reply uutFunctionType:UUT_FUNCTIONTYPE_DONE replyMessage:replyError];
}

- (BOOL) UUT_Commit:(enum TEST_PASSFAILRESULT1)result
{
    //## required step #5:  IP_UUTCommit().
    enum IP_PASSFAILRESULT IPResult;
    
    switch (result) {
        case TEST_FAIL1:
            IPResult = IP_FAIL;
            break;
        case TEST_PASS1:
            IPResult = IP_PASS;
            break;
        case TEST_SKIP1:
            IPResult = IP_NA;
            break;
        default:
            IPResult = IP_NA;
            break;
    }
    
    
    IP_API_Reply reply = IP_UUTCommit(UID, IPResult);
    
    return [self handleReply:reply uutFunctionType:UUT_FUNCTIONTYPE_COMMIT replyMessage:replyError];
}


- (BOOL) UUT_amIOkay
{
    memset(amIOK_Error, 0, ERRORMESSAGE_BUFFER);
    IP_API_Reply reply = IP_amIOkay(UID,unitSerialNumber);
    
    amiokay_flag = [self handleReply:reply uutFunctionType:UUT_FUNCTIONTYPE_AMIOKAY replyMessage:amIOK_Error];

    [amiokay_msg setString:[NSString stringWithFormat:@"%s",amIOK_Error]];
    return amiokay_flag;
}

- (BOOL) UUT_Destroy
{
    amiokay_flag = YES;
    [amiokay_msg setString:@"NA"];
    
    IP_UID_destroy(UID);
    
    return true;
}

-(char *)replyError
{
    return replyError;
}

+ (const char *)getStationName
{
    return softwareName;
}

+ (const char *)getVersion
{
    return [self getIPVersion];
}

#pragma mark lib instant pudding

- (BOOL) handleReply:(IP_API_Reply)reply uutFunctionType:(enum UUT_FUNCTIONTYPE)funcType replyMessage:(char*)msg
{
    char functionType[FUNCTIONTYPE_LENGTH];
    char temp_msg[1024] ;
    memset(temp_msg, 0, 1024);
    
    switch (funcType) {
        case UUT_FUNCTIONTYPE_START:
            strcpy(functionType,"UUTStart()");
            break;
        case UUT_FUNCTIONTYPE_ADDATTRIBUTE:
            strcpy(functionType,"UUTAddAttribute()");
            break;
        case UUT_FUNCTIONTYPE_ADDRESULT:
            strcpy(functionType,"UUTAddResult()");
            break;
        case UUT_FUNCTIONTYPE_DONE:
            strcpy(functionType,"UUTDone()");
            break;
        case UUT_FUNCTIONTYPE_COMMIT:
            strcpy(functionType,"UUTCommit()");
            break;
        case UUT_FUNCTIONTYPE_BLOB:
            strcpy(functionType, "UUTAddBlob()");
            break;
        case UUT_FUNCTIONTYPE_AMIOKAY:
            strcpy(functionType,"amIOkay()");
            break;
        default:
            strcpy(functionType,"");
            break;
    }
    
    
    if ( !IP_success( reply ) )
    {
        unsigned int doneMessageID = IP_reply_getMessageID( reply );
        
        if ( IP_reply_isOfClass( reply, IP_MSG_CLASS_PROCESS_CONTROL) )
        {
            // this type of error should be considered a unit failure
            sprintf(temp_msg, "%s ERROR[%d] : %s\t",functionType,doneMessageID,IP_reply_getError(reply));
        }
        else if(IP_reply_isOfClass( reply, IP_MSG_CLASS_UNCLASSIFIED))
        {
            sprintf(temp_msg, "%s ERROR[%d] : %s\t",functionType,doneMessageID,IP_reply_getError(reply));
        }
        else if ( IP_reply_isOfClass( reply, IP_MSG_CLASS_API_ERROR ) )
        {
            // these are non-fatal errors; one or more support systems were not available
            // to reply to the request.  You should continue testing like nothing happened.
            
            if ( IP_MSG_ERROR_FERRET_NOT_RUNNING == doneMessageID )
            {
                // if this happens, you are allowed to continue with the UUTCommit without
                // counting this as a test failure
            }
            else if ( IP_MSG_ERROR_API_NO_ATTRIBUTE == doneMessageID )
            {
                //printf("attribute does not exist\n");
                sprintf(temp_msg, "Attribute does not exist.\tnon-fatal errors from %s[%d] : %s\t",functionType,doneMessageID,IP_reply_getError(reply));
                strncat(msg, temp_msg,API_REPLY_MSGLENGTH);
                IP_reply_destroy(reply);
                return false;
            }
            else
            {
                // other server errors ... right now this back-end isn't implemented
                if ( !(doneMessageID & IP_CHECK_PUDDING) ) {printf("Pudding failed to report\n");} // "Pudding failed to report"
                if ( !(doneMessageID & IP_CHECK_DCS) ) {printf("DCS failed to report\n");} // "DCS failed to report"
                if ( !(doneMessageID & IP_CHECK_PDCA) ) {printf("PDCA failed to report\n");} // "PDCA failed to report"
            }
            sprintf(temp_msg, "non-fatal errors from %s[%d] : %s\t",functionType,doneMessageID,IP_reply_getError(reply));
        }
        else if (IP_reply_isOfClass( reply, IP_MSG_CLASS_COMM_ERR))
        {
            sprintf(temp_msg, "%s ERROR[%d] : %s\t",functionType,doneMessageID,IP_reply_getError(reply));
        }
        else if (IP_reply_isOfClass( reply, IP_MSG_CLASS_QUERY))
        {
            sprintf(temp_msg, "%s ERROR[%d] : %s\t",functionType,doneMessageID,IP_reply_getError(reply));
        }
        else if (IP_reply_isOfClass( reply, IP_MSG_CLASS_QUERY_RESPONSE))
        {
            sprintf(temp_msg, "%s ERROR[%d] : %s\t",functionType,doneMessageID,IP_reply_getError(reply));
        }
        else if(IP_reply_isOfClass( reply, IP_MSG_CLASS_QUERY_DELAYED_RESPONSE))
        {
            sprintf(temp_msg, "%s ERROR[%d] : %s\t",functionType,doneMessageID,IP_reply_getError(reply));
        }
        else
        {
            sprintf(temp_msg, "%s OTHER ERROR[%d]\t",functionType,doneMessageID);
        }
        
        //IP_UUTCancel(UID); //MUST CALL HERE TO CLEAN THE BRICKS
        strncat(msg, temp_msg, API_REPLY_MSGLENGTH);
        IP_reply_destroy(reply);
        return false;
    }
    
    IP_reply_destroy(reply);
    return true;
}

- (BOOL) UUTStart:(const char*)serialNumber snLength:(unsigned int)len replyMessage:(char*)msg
{
    IP_API_Reply reply = IP_UUTStart(&UID);
    
    int i = 0;
    
    for (i = 0;i < len;i++)
        unitSerialNumber[i] = serialNumber[i];
    
    unitSerialNumber[i] = '\0';
    
    return [self handleReply:reply uutFunctionType:UUT_FUNCTIONTYPE_START replyMessage:msg];
}

- (BOOL) UUTDestroy
{
    IP_UID_destroy(UID);
    
    return true;
}

- (BOOL) UUTamIOkay:(char*) replyMessage
{
    IP_API_Reply reply = IP_amIOkay(UID,unitSerialNumber);
    
    return [self handleReply:reply uutFunctionType:UUT_FUNCTIONTYPE_AMIOKAY replyMessage:replyMessage];
}

- (BOOL) UUTDone:(char*)replyMessage
{
    //## required step #4:  IP_UUTDone()
    //printf("Testing finished, calling 'UUTDone' for handle %s\n",UID);
    IP_API_Reply reply = IP_UUTDone(UID);
    
    return [self handleReply:reply uutFunctionType:UUT_FUNCTIONTYPE_DONE replyMessage:replyMessage];
}

- (BOOL) UUTSetStartTime
{
    time_t rawtime;
    time( &rawtime );
    
    IP_setStartTime(UID, rawtime);
    
    return true;
}

- (BOOL) UUTSetStopTime
{
    time_t rawtime;
    time( &rawtime );
    
    IP_setStopTime(UID, rawtime);
    
    return true;
}

- (BOOL) UUTAddAttribute:(enum UUT_ADDATTRIBUTE)addAttribute value:(char*)val replyMessage:(char*)msg
{
    char name[UUTATTRIBUTE_STRINGLENGTH];
    char stationValue[STATIONID_LENGTH];
    
    switch (addAttribute) {
        case UUT_ADDATTRIBUTE_SERIALNUMBER:
            strcpy(name,IP_ATTRIBUTE_SERIALNUMBER);
            break;
        case UUT_ADDATTRIBUTE_STATIONSOFTWAREVERSION:
            strcpy(name,IP_ATTRIBUTE_STATIONSOFTWAREVERSION);
            break;
        case UUT_ADDATTRIBUTE_STATIONSOFTWARENAME:
            strcpy(name,IP_ATTRIBUTE_STATIONSOFTWARENAME);
            break;
        case UUT_ADDATTRIBUTE_STATIONLIMITSVERSION:
            strcpy(name,IP_ATTRIBUTE_STATIONLIMITSVERSION);
            break;
        case UUT_ADDATTRIBUTE_SPECIAL_BUILD:
            strcpy(name,IP_ATTRIBUTE_SPECIAL_BUILD);
            break;
        case UUT_ADDATTRIBUTE_STATIONIDENTIFIER: {
            
            char *stationID = (char *)malloc(STATIONID_LENGTH*sizeof(char));
            
            [self getGHStationInfo:IP_STATION_ID outputData:stationID];

            printf("station id:%s, length:%ld\n",stationID,strlen(stationID));
            
            strcpy(name,IP_ATTRIBUTE_STATIONIDENTIFIER);
            strcpy(stationValue,stationID);
            
            free(stationID);
        }
            break;
        default:
            break;
    }
    
    IP_API_Reply reply;
    
    if (UUT_ADDATTRIBUTE_STATIONIDENTIFIER == addAttribute)
        reply = IP_addAttribute( UID, name, stationValue);
    else
        reply = IP_addAttribute( UID, name, val);
    
    return [self handleReply:reply uutFunctionType:UUT_FUNCTIONTYPE_ADDATTRIBUTE replyMessage:msg];

}
- (BOOL) UUTSetDUTPos:(char *)fixture headerID:(char*)header replyMessage:(char*)msg
{
    IP_API_Reply reply;
    reply = IP_setDUTPos(UID,fixture,header);
    
    return [self handleReply:reply uutFunctionType:UUT_FUNCTIONTYPE_ADDATTRIBUTE replyMessage:msg];
}

- (BOOL) UUTAddAttributeByName:(char *)name value:(char*)val replyMessage:(char*)msg
{
    IP_API_Reply reply;
    char stationValue[STATIONID_LENGTH];
    
    if (!strcmp(name,"STATION_IDENTIFIER")) {
        
        char *stationID = (char *)malloc(STATIONID_LENGTH*sizeof(char));
        
        [self getGHStationInfo:IP_STATION_ID outputData:stationID];

        printf("station id:%s, length:%ld\n",stationID,strlen(stationID));
        
        strcpy(name,IP_ATTRIBUTE_STATIONIDENTIFIER);
        strcpy(stationValue,stationID);
        
        free(stationID);
        
        reply = IP_addAttribute( UID, name, stationValue);
        
    }
    else {
        reply = IP_addAttribute( UID, name, val);
    }
    
    return [self handleReply:reply uutFunctionType:UUT_FUNCTIONTYPE_ADDATTRIBUTE replyMessage:msg];
}

- (BOOL) UUTAddBlob:(const char*)inBlobName inPathToBlobFile:(const char*)filePath replyMessage:(char*)msg
{
    IP_API_Reply reply;
    
    reply = IP_addBlob(UID, inBlobName, filePath);
    
    return [self handleReply:reply uutFunctionType:UUT_FUNCTIONTYPE_BLOB replyMessage:msg];
}

- (BOOL) UUTCreateTest:(char*)replyMessage
{
    // create a test specification for our test
    testSpec = IP_testSpec_create(); // a new testSpec is needed for every test result
    
    // now determine whether we pass or fail
    testResult = IP_testResult_create();
    
    if (( NULL == testResult ) || ( NULL == testSpec )) {
        sprintf(replyMessage,"ERROR with IP_addResult.\n");
        
        [self UUTCleanTest];
        return false;
    }
    
    return true;
}

- (BOOL) UUTCleanTest
{
    IP_testResult_destroy(testResult);
    IP_testSpec_destroy(testSpec);
    
    return true;
}

- (BOOL) UUTTestSpecSetTestName:(const char*)name
{
    size_t nameLength = strlen(name);
    
    IP_testSpec_setTestName( testSpec, name, nameLength);
    
    return true;
}

- (BOOL) UUTTestSpecSetSubTestName:(const char*)name
{
    size_t nameLength = strlen(name);
    
    IP_testSpec_setSubTestName( testSpec, name, nameLength);
    
    return true;
}

- (BOOL) UUTTestSpecSetSubSubTestName:(const char*)name
{
    size_t nameLength = strlen(name);
    
    IP_testSpec_setSubSubTestName( testSpec, name, nameLength );
    return true;
}

- (BOOL) UUTTestSpecSetValue:(const char*)value
{
    size_t valueLength = strlen(value);
    
    IP_testResult_setValue( testResult,value,valueLength );
    
    return true;
}

- (BOOL) UUTTestSpecSetMessage:(const char*)message
{
    size_t messageLength = strlen(message);
    
    IP_testResult_setMessage( testResult, message, messageLength);
    
    return true;
}

- (BOOL) UUTTestSpecSetLimits:(const char*)lowerLimit upperLimit:(const char*)upLimit
{
    return IP_testSpec_setLimits( testSpec, lowerLimit, strlen(lowerLimit),
                                 upLimit, strlen(upLimit) );
}

- (BOOL) UUTTestSpecSetUnits:(const char*)units
{
    return IP_testSpec_setUnits( testSpec, units, strlen(units));
}

- (BOOL) UUTAddResult:(char*)replyMessage
{
    IP_API_Reply reply = IP_addResult(UID, testSpec, testResult );
    
    return [self handleReply:reply uutFunctionType:UUT_FUNCTIONTYPE_ADDRESULT replyMessage:replyMessage];
//    return handleReply(reply,UUT_FUNCTIONTYPE_ADDRESULT,replyMessage);
}

+(const char *)getIPVersion
{
    return IP_getVersion();
}

- (BOOL) getGHStationInfo:(int)key outputData:(char *)data
{
    size_t length = 0;
    
    IP_API_Reply reply = IP_getGHStationInfo(UID,key,NULL,&length);
    IP_reply_destroy(reply);
    
    reply=IP_getGHStationInfo(UID,key,&data,&length);
    IP_reply_destroy(reply);
    //printf("%ld:",length);
    
    if (data == NULL)
        return false;
    
    return true;
}

-(char*) getSFC_URL
{
    char *sfc_url = (char *)malloc(STATIONID_LENGTH*sizeof(char));
    [self getGHStationInfo:IP_SFC_URL outputData:sfc_url];

    return sfc_url;
}

- (BOOL) UUTCommit:(enum TEST_PASSFAILRESULT)result replyMessage:(char*)msg
{
    //## required step #5:  IP_UUTCommit().
    enum IP_PASSFAILRESULT IPResult;
    
    switch (result) {
        case TEST_FAIL:
            IPResult = IP_FAIL;
            break;
        case TEST_PASS:
            IPResult = IP_PASS;
            break;
        case TEST_SKIP:
            IPResult = IP_NA;
            break;
        default:
            IPResult = IP_NA;
            break;
    }
    
    IP_API_Reply reply = IP_UUTCommit(UID, IPResult);
    
    return [self handleReply:reply uutFunctionType:UUT_FUNCTIONTYPE_COMMIT replyMessage:msg];
}

- (BOOL) UUTTestSpecSetPriority:(enum IP_PDCA_PRIORITY)priority
{
    IP_testSpec_setPriority( testSpec, priority );
    
    return true;
}

- (BOOL) UUTTestSpecSetResult:(enum TEST_PASSFAILRESULT)result
{
    enum IP_PASSFAILRESULT IPResult;
    
    switch (result) {
        case TEST_FAIL:
            IPResult = IP_FAIL;
            break;
        case TEST_PASS:
            IPResult = IP_PASS;
            break;
        case TEST_SKIP:
            IPResult = IP_NA;
            break;
        default:
            IPResult = IP_NA;
            break;
    }
    IP_testResult_setResult( testResult, IPResult);
    
    return true;
}


#pragma mark SFC QueryRecord

// Bobcat URL
- (char*)SFC_getURL
{
    return [self getSFC_URL];
}

- (const char *)SFC_getLibVersion
{
    return SFCLibVersion();
}

- (const char *)SFC_getServerVersion
{
    return SFCServerVersion();
}

- (const char*)SFC_getHistoryBySN:(NSString *)acpSerialNumber
{
    return SFCQueryHistory([acpSerialNumber UTF8String]);
}

- (int)SFC_AddRecord:(NSString *)acpSerialNumber withDictionary:(NSDictionary *)dic
{
    int dicCount = (int)[dic count];
    struct QRStruct *  apQRStruct[dicCount];
    NSArray * keyArray = [dic allKeys];
    
    for (int i=0; i<dicCount; i++)
    {
        apQRStruct[i]=(struct QRStruct *)malloc(sizeof(struct QRStruct));
        
        if (apQRStruct[i]!=nil)
        {
            NSString *key = [keyArray objectAtIndex:i];
            NSString *val = [dic objectForKey:key];
            (*apQRStruct[i]).Qkey=(char *)[key UTF8String];
            (*apQRStruct[i]).Qval=(char *)[val UTF8String];
        }
    }
    
    return SFCAddRecord([acpSerialNumber UTF8String], apQRStruct ,dicCount);
}

- (int)SFC_AddAttr:(NSString *)acpSerialNumber withDictionary:(NSDictionary *)dic
{
    int dicCount = (int)[dic count];
    struct QRStruct *  apQRStruct[dicCount+2];
    char StartTimeKey[]="start_time";
    char MacAddressKey[]="mac_address";
    NSDate *localDateTime=[NSDate date];
    NSDateFormatter *dateTimeFormat=[[[NSDateFormatter alloc]init] autorelease];
    dateTimeFormat.dateFormat=@"yyyy-MM-dd HH:mm:ss";
    
    NSString *dateStr=[dateTimeFormat stringFromDate:localDateTime];
    
    NSArray * keyArray = [dic allKeys];
    
    apQRStruct[0]=(struct QRStruct *)malloc(sizeof(struct QRStruct));
    
    (*apQRStruct[0]).Qkey=StartTimeKey;
    (*apQRStruct[0]).Qval=(char *)[dateStr UTF8String];
    
    apQRStruct[1]=(struct QRStruct *)malloc(sizeof(struct QRStruct));
    
    (*apQRStruct[1]).Qkey=MacAddressKey;
    (*apQRStruct[1]).Qval=stationMacAddr;
    for (int i=0; i<dicCount; i++)
    {
        apQRStruct[i+2]=(struct QRStruct *)malloc(sizeof(struct QRStruct));
        
        {
            NSString *key = [keyArray objectAtIndex:i];
            NSString *val = [dic objectForKey:key];
            (*apQRStruct[i+2]).Qkey=(char *)[key UTF8String];
            (*apQRStruct[i+2]).Qval=(char *)[val UTF8String];
        }
    }
    
    return SFCAddAttr([acpSerialNumber UTF8String], apQRStruct ,dicCount+2);
}

- (NSDictionary*)SFC_QueryRecordBySn:(NSString *)acpSerialNumber withKeyArray:(NSArray *)keyArr
{
    int aiSize=(int)[keyArr count];
    struct QRStruct *apQRStruct[aiSize];
    NSMutableDictionary* resultDic = [[[NSMutableDictionary alloc]init]autorelease];
    
    for (int i=0; i<aiSize; i++)
    {
        apQRStruct[i]=(struct QRStruct *)malloc(sizeof(struct QRStruct));
        if (apQRStruct[i]!=nil)
        {
            (*apQRStruct[i]).Qkey=(char *)[[keyArr objectAtIndex:i] UTF8String];
            (*apQRStruct[i]).Qval=(char *)malloc(256*sizeof(char));
        }
    }
    
    int result=SFCQueryRecord([acpSerialNumber UTF8String],apQRStruct,aiSize);
    
    if(result==0)
    {
        for (int i=0; i<aiSize; i++)
        {
            NSString *key = [keyArr objectAtIndex:i];
            NSString *val = [NSString stringWithFormat:@"%s",(*apQRStruct[i]).Qval];
            [resultDic setObject:val forKey:key];
        }
        
    }
    else
    {
        for (int i=0; i<[keyArr count]; i++)
        {
            NSString *key = [keyArr objectAtIndex:i];
            [resultDic setObject:[NSString stringWithFormat:@"SFCQueryRecord Error (%d)",result] forKey:key];
        }
    }
    return resultDic;
}
@end
