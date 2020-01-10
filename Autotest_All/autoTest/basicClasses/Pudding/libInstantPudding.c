//
//  libInstantPudding.c
//  autoTest
//
//  Created by Li Richard on 13-8-28.
//  Copyright (c) 2013年 Li Richard. All rights reserved.
//


#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <string.h>
#include <stdbool.h> //C99 support boolean

#include "InstantPudding_API.h"
#include "libInstantPudding.h"


IP_UUTHandle UID;
IP_TestSpecHandle testSpec;
IP_TestResultHandle testResult;

bool handleReply( IP_API_Reply reply,enum UUT_FUNCTIONTYPE uutFunctionType,char* replyMessage);
bool UUTTestSpecSetPriority(enum IP_PDCA_PRIORITY priority);
bool UUTTestSpecSetResult(enum TEST_PASSFAILRESULT result);
bool UUTCommit(enum TEST_PASSFAILRESULT result,char* replyMessage);

bool handleReply( IP_API_Reply reply,enum UUT_FUNCTIONTYPE uutFunctionType,char* replyMessage)
{
    char functionType[FUNCTIONTYPE_LENGTH];
    char temp_msg[1024] ;
    memset(temp_msg, 0, 1024);
    
    switch (uutFunctionType) {
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
                strncat(replyMessage, temp_msg,API_REPLY_MSGLENGTH);
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
            sprintf(temp_msg, "amIOkay() ERROR[%d] : %s\t",doneMessageID,IP_reply_getError(reply));
        }
        else if (IP_reply_isOfClass( reply, IP_MSG_CLASS_QUERY))
        {
            sprintf(temp_msg, "amIOkay() ERROR[%d] : %s\t",doneMessageID,IP_reply_getError(reply));
        }
        else if (IP_reply_isOfClass( reply, IP_MSG_CLASS_QUERY_RESPONSE))
        {
            sprintf(temp_msg, "amIOkay() ERROR[%d] : %s\t",doneMessageID,IP_reply_getError(reply));
        }
        else if(IP_reply_isOfClass( reply, IP_MSG_CLASS_QUERY_DELAYED_RESPONSE))
        {
            sprintf(temp_msg, "amIOkay() ERROR[%d] : %s\t",doneMessageID,IP_reply_getError(reply));
        }
        else
        {
            sprintf(temp_msg, "other error");
        }
        
        //IP_UUTCancel(UID); //MUST CALL HERE TO CLEAN THE BRICKS
        strncat(replyMessage, temp_msg, API_REPLY_MSGLENGTH);
        IP_reply_destroy(reply);
        return false;
    }
    
    IP_reply_destroy(reply);
    return true;
}

//## required step #1:  IP_UUTStart()
bool UUTStart(const char* serialNumber,unsigned int snLength, char* replyMessage)
{

    IP_API_Reply reply = IP_UUTStart(&UID);
    
    int i = 0;
    
    for (i = 0;i < snLength;i++)
        unitSerialNumber[i] = serialNumber[i];
    
    unitSerialNumber[i] = '\0';
    
	return handleReply(reply,UUT_FUNCTIONTYPE_START,replyMessage);
}

bool UUTSetStartTime(void)
{
    time_t rawtime;
    time( &rawtime );
    
    IP_setStartTime(UID, rawtime);
    
    return true;
}

bool UUTSetStopTime(void)
{
    time_t rawtime;
    time( &rawtime );
    
    IP_setStopTime(UID, rawtime);
    
    return true;
}

bool UUTAddAttribute(enum UUT_ADDATTRIBUTE addAttribute,char* value,char* replyMessage)
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

            getGHStationInfo(IP_STATION_ID,stationID);
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
        reply = IP_addAttribute( UID, name, value);
    
    return handleReply(reply,UUT_FUNCTIONTYPE_ADDATTRIBUTE,replyMessage);
}



bool UUTAddAttributeByName(char *name,char* value,char* replyMessage)
{
    IP_API_Reply reply;
    char stationValue[STATIONID_LENGTH];
    
    if (!strcmp(name,"STATION_IDENTIFIER")) {
        
        char *stationID = (char *)malloc(STATIONID_LENGTH*sizeof(char));
        
        getGHStationInfo(IP_STATION_ID,stationID);
        printf("station id:%s, length:%ld\n",stationID,strlen(stationID));
        
        strcpy(name,IP_ATTRIBUTE_STATIONIDENTIFIER);
        strcpy(stationValue,stationID);
        
        free(stationID);
        
        reply = IP_addAttribute( UID, name, stationValue);
        
    }
    else {
        reply = IP_addAttribute( UID, name, value);
    }
    
    return handleReply(reply,UUT_FUNCTIONTYPE_ADDATTRIBUTE,replyMessage);
}

bool UUTAddBlob(const char* inBlobName, const char* inPathToBlobFile, char* replyMessage)
{
    IP_API_Reply reply;
    
    reply = IP_addBlob(UID, inBlobName, inPathToBlobFile);
    
    return handleReply(reply, UUT_FUNCTIONTYPE_BLOB, replyMessage);
}

bool UUTCleanTest(void)
{
	IP_testResult_destroy(testResult);
	IP_testSpec_destroy(testSpec);
    
    return true;
}

bool UUTCreateTest(char* replyMessage)
{
    // create a test specification for our test
	testSpec = IP_testSpec_create(); // a new testSpec is needed for every test result
	
	// now determine whether we pass or fail
	testResult = IP_testResult_create();
	
	if (( NULL == testResult ) || ( NULL == testSpec )) {
        sprintf(replyMessage,"ERROR with IP_addResult.\n");
        
		UUTCleanTest();
        return false;
	}
    
    return true;
}

bool UUTTestSpecSetTestName(const char* name)
{
    size_t nameLength = strlen(name);
    
    IP_testSpec_setTestName( testSpec, name, nameLength);
    
    return true;
}

bool UUTTestSpecSetSubTestName(const char* name)
{
    size_t nameLength = strlen(name);
    
    IP_testSpec_setSubTestName( testSpec, name, nameLength);
    
    return true;
}

bool UUTTestSpecSetSubSubTestName(const char* name)
{
    size_t nameLength = strlen(name);
    
    IP_testSpec_setSubSubTestName( testSpec, name, nameLength );
    return true;
}



bool UUTTestSpecSetResult(enum TEST_PASSFAILRESULT result)
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

bool UUTTestSpecSetValue(const char* value)
{
    size_t valueLength = strlen(value);
    
    IP_testResult_setValue( testResult,value,valueLength );
    
    return true;
}

bool UUTTestSpecSetMessage(const char* message)
{
    size_t messageLength = strlen(message);
    
    IP_testResult_setMessage( testResult, message, messageLength);
    
    return true;
}

bool UUTTestSpecSetUnits(const char* units)
{
   return IP_testSpec_setUnits( testSpec, units, strlen(units));
}

bool UUTTestSpecSetPriority(enum IP_PDCA_PRIORITY priority)
{
    IP_testSpec_setPriority( testSpec, priority );
    
    return true;
}

bool UUTTestSpecSetLimits(const char* lowerLimit,const char* upperLimit)
{
    return IP_testSpec_setLimits( testSpec, lowerLimit, strlen(lowerLimit),
                                     upperLimit, strlen(upperLimit) );
}

bool UUTAddResult(char* replyMessage)
{
    //## required step #3:  IP_addResult()
    IP_API_Reply reply = IP_addResult(UID, testSpec, testResult );
    
	return handleReply(reply,UUT_FUNCTIONTYPE_ADDRESULT,replyMessage);
    
}

bool UUTDestroy(void)
{
    IP_UID_destroy(UID);
    
    return true;
}

bool UUTamIOkay(char* replyMessage)
{
    IP_API_Reply reply = IP_amIOkay(UID,unitSerialNumber);
    
    return handleReply(reply,UUT_FUNCTIONTYPE_AMIOKAY,replyMessage);
}

bool UUTDone(char* replyMessage)
{
    //## required step #4:  IP_UUTDone()
    //printf("Testing finished, calling 'UUTDone' for handle %s\n",UID);
	IP_API_Reply reply = IP_UUTDone(UID);
    
    return handleReply(reply,UUT_FUNCTIONTYPE_DONE,replyMessage);
    
}


bool UUTCommit(enum TEST_PASSFAILRESULT result,char* replyMessage)
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
    
    return handleReply(reply,UUT_FUNCTIONTYPE_COMMIT,replyMessage);
}

//Always call this api to show the IP version in your GUI application
const char* getIPVersion(void)
{
    return IP_getVersion();
}

bool getGHStationInfo(int stationID,char * strStationID)
{
    size_t length = 0;
    
    IP_API_Reply reply = IP_getGHStationInfo(UID,stationID,NULL,&length);
    IP_reply_destroy(reply);
    
    reply=IP_getGHStationInfo(UID,stationID,&strStationID,&length);
    IP_reply_destroy(reply);
    //printf("%ld:",length);
    
    if (strStationID == NULL) {
        
        return false;
    }
    
    return true;
}

// Bobcat URL
char* getSFC_URL()
{
    char *sfc_url = (char *)malloc(STATIONID_LENGTH*sizeof(char));
    getGHStationInfo(IP_SFC_URL,sfc_url);
    return sfc_url;
}