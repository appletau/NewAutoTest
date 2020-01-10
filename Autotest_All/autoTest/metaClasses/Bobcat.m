//
//  Bobcat.m
//  BobcatDemo
//
//  Created by Wang Sky on 13-10-18.
//  Copyright (c) 2013年 Wang Sky. All rights reserved.
//

#import "Bobcat.h"
#import "InstantPudding_Additional.h"

#define SFC_OK @"0 SFC_OK"
#define SFC_ERROR @"1 SFC_ERROR"
#define SFC_FATAL_ERROR @"2 SFC_FATAL_ERROR"
#define SFC_DATA_FORMAT_ERROR @"3 SFC_DATA_FORMAT_ERROR"”
#define SFC_INVALID_COMMAND_ERROR @"4 SFC_INVALID_COMMAND_ERROR"
#define SFC_UKNOWN_RESPONSE @"13 SFC_UKNOWN_RESPONSE"
#define REQUEST_INTERVAL 3
#define BOBCAT_STATIONINFO_LENGTH 256

@implementation Bobcat
@synthesize isReady;
@synthesize stationid;
@synthesize testMachineid;

-(void)DEMO
{
    NSString *sn=@"SkyWang1000FD6Q03";
    NSString *station=@"FACT 1";
    
//    Boolean isDone = [self initializeSerialNumber:sn];
//    NSLog(@"The Initialized SFC operation :%d",isDone);
    
    
    NSDictionary* addDic = [NSDictionary dictionaryWithObjectsAndKeys:
                            @"1.0d48",BC_SoftwareVersion,station,BC_StationName,sn,BC_SerialNumber,@"PGPD_F05-3FT-AF02_2_FACT 1",BC_StationID,
                            @"2015-03-21 18:33:12",BC_StopTime,@"2015-03-21 18:32:01",BC_StartTime,@"pro",BC_Product,
                            @"PASS" ,BC_TestResult,@"00:25:00:f4:8f:99",BC_TestMachineID,nil];
    
    NSLog(@"The ADD_RECORD operation:%d",[self addRecord:addDic]);

    NSArray *queryArray = [NSArray arrayWithObjects:BC_SoftwareVersion,BC_MarketPart,nil];
    NSDictionary* queryResult = [self queryRecord:sn queryArray:queryArray];
    NSLog(@"The QUERY_RECORD result:%@",queryResult);
    
    queryArray = [NSArray arrayWithObjects:BC_SoftwareVersion,BC_TestResult,BC_StopTime,nil];
    queryResult = [self queryRecord:sn queryStation:station queryStationID:nil queryArray:queryArray];
    NSLog(@"The QUERY_RECORD result:%@",queryResult);
    
    NSLog(@"The QUERY_HISTORY result:%@",[self queryHistory:sn]);
    NSLog(@"The QUERY_VERSION result:%@",[self queryVersion]);

}


- (id)init
{
    if (self = [super init])
    {
        request = [[IACHTTPRequest alloc] init];
        isReady = true;
        [self getMicIDByPudding];
        [self getSatationIdByPudding];
        [self getSFC_URLByPudding];
	}
    return self;
}


-(id)initWithArg:(NSDictionary *)dic
{
	id tmp = nil;
    
    tmp = [self init];
    
	return tmp;
}

-(void)dealloc
{
    isReady = false;
    [stationid release];
    [testMachineid release];
    [request release];
    [super dealloc];
}

-(Boolean)initializeSerialNumber:(NSString *)SN
{
    NSDate *initDate = [[NSDate alloc] initWithTimeIntervalSinceNow:0];
    Boolean result =[self initializeSerialNumber:SN initializeDate:initDate];
    [initDate release];
    return result;
    
}

-(Boolean)addRecord:(NSDictionary*)addDic
{
    NSDate *addDate = [[NSDate alloc] initWithTimeIntervalSinceNow:0];
    Boolean result = [self addRecord:addDic addDate:addDate];
    [addDate release];
    return result;
}

-(NSDictionary*)queryRecord:(NSString *)SN queryArray:(NSArray *)queryArray
{
    NSDate *queryDate = [[NSDate alloc] initWithTimeIntervalSinceNow:0];
    NSDictionary* result =[self queryRecord:SN queryArray:queryArray queryDate:queryDate];
    [queryDate release];
    return result;
}
-(NSDictionary *)queryRecord:(NSString *)SN queryStation:(NSString *)station queryStationID:(NSString *)stationID queryArray:(NSArray *)queryArray
{
    NSDate *queryDate = [[NSDate alloc] initWithTimeIntervalSinceNow:0];
    NSDictionary* result =[self queryRecord:SN queryStation:station queryStationID:stationID queryArray:queryArray queryDate:queryDate];
    [queryDate release];
    return result;
}
-(NSString*)queryHistory:(NSString *)SN
{
    NSDate *queryDate = [[NSDate alloc] initWithTimeIntervalSinceNow:0];
    NSString* result =[self queryHistory:SN queryDate:queryDate];
    [queryDate release];
    return result;
}
-(NSString*)queryVersion
{
    NSDate *queryDate = [[NSDate alloc] initWithTimeIntervalSinceNow:0];
    NSString* result =[self queryVersion:queryDate];
    [queryDate release];
    return result;
}

-(Boolean)initializeSerialNumber:(NSString *)SN initializeDate:(NSDate*)initDate
{
    NSDate *localDateTime=[[NSDate alloc] initWithTimeIntervalSinceNow:0];
    NSTimeInterval interval = [localDateTime timeIntervalSinceDate:initDate];
    [localDateTime release];
    
    [request requestWithURL:[NSURL URLWithString:SERVER_URL]];
    [request setPostValue:@"INITIALIZE_SFC" forKey:BC_Command];
    [request setPostValue:SN forKey:BC_SerialNumber];
    [request setRequestMethod:BC_HTTP_POST_METHOD];
    [request startSynchronous];
    
    NSString* response =[request getResponseString];
    if (response != nil)
    {
        if ([response rangeOfString:SFC_OK].location!=NSNotFound)
        {
            return TRUE;
        }
        if ([response rangeOfString:SFC_ERROR].location!=NSNotFound)
        {
            if (interval< REQUEST_INTERVAL)
            {
                [self initializeSerialNumber:SN initializeDate:initDate];
            }
            NSLog(@"the server is bad ,please connect to the FIS DRI");
            return FALSE;
        }
        NSLog(@"the response is fail:%@",response);
        return FALSE;
    }
    NSLog(@"The connection to the internet is OFF");
    
    return FALSE;
}

-(Boolean)addRecord:(NSDictionary *)addDic addDate:(NSDate*)addDate
{
    NSDate *localDateTime=[[NSDate alloc] initWithTimeIntervalSinceNow:0];
    NSTimeInterval interval = [localDateTime timeIntervalSinceDate:addDate];
    [localDateTime release];
    [request requestWithURL:[NSURL URLWithString:SERVER_URL]];
    NSArray * parameterArray = [addDic allKeys];
    [request addPostValue:@"ADD_RECORD" forKey:BC_Command];
    
    for (int i = 0; i<[addDic count]; i++)
    {
        NSString* key = [parameterArray objectAtIndex:i];
        NSString* value = [addDic objectForKey:key];
        [request setPostValue:value forKey:key];
    }
    [request setRequestMethod:BC_HTTP_POST_METHOD];
    [request startSynchronous];
    
    NSString* response =[request getResponseString];
    
    if (response !=nil)
    {
        if ([response rangeOfString:SFC_OK].location!=NSNotFound)
        {
            return TRUE;
        }
        if ([response rangeOfString:SFC_ERROR].location!=NSNotFound)
        {
            if (interval < REQUEST_INTERVAL)
            {
                return [self addRecord:addDic addDate:addDate];
            }
            NSLog(@"the server is bad ,please connect to the FIS DRI");
            return FALSE;
        }
        NSLog(@"the response is fail:%@",response);
        return FALSE;
    }
    NSLog(@"The connection to the internet is OFF");
    return FALSE;
}

-(NSDictionary*)queryRecord:(NSString *)SN queryArray:(NSArray *)queryArray queryDate:(NSDate*)queryDate
{
    NSDate *localDateTime=[[NSDate alloc] initWithTimeIntervalSinceNow:0];
    NSTimeInterval interval = [localDateTime timeIntervalSinceDate:queryDate];
    [localDateTime release];
    [request requestWithURL:[NSURL URLWithString:SERVER_URL]];
    NSMutableDictionary* resultDic = [[[NSMutableDictionary alloc]init]autorelease];
    
    [request addPostValue:@"QUERY_RECORD" forKey:BC_Command];
    [request addPostValue:SN forKey:BC_SerialNumber];
    
    for (int i = 0; i<[queryArray count]; i++)
    {
        [request addPostValue:[queryArray objectAtIndex:i] forKey:BC_Parameter];
    }
    [request setRequestMethod:BC_HTTP_POST_METHOD];
    [request startSynchronous];
    
    NSString* response =[request getResponseString];
    NSLog(@"the response is %@",response);
    
    if (response != nil)
    {
        if ([response rangeOfString:SFC_OK].location!=NSNotFound)
        {
            NSArray* queryResponds = [response componentsSeparatedByString:@"\n"];
            for (int i = 1; i<[queryResponds count]; i++)
            {
                NSString* queryRespond = [queryResponds objectAtIndex:i];
                NSArray* resultArray =[queryRespond componentsSeparatedByString:@"="];
                [resultDic setObject:[resultArray objectAtIndex:1] forKey:[resultArray objectAtIndex:0]];
            }
            
            return resultDic;
        }
        if ([response rangeOfString:SFC_ERROR].location!=NSNotFound)
        {
            if (interval < REQUEST_INTERVAL)
            {
                return [self queryRecord:SN queryArray:queryArray queryDate:queryDate];
            }
            NSLog(@"the server is bad ,please connect to the FIS DRI");
            return nil;
        }
        NSLog(@"the response is fail:%@",response);
        return nil;
    }
    NSLog(@"The connection to the internet is OFF");
    return nil;
}

-(NSDictionary *)queryRecord:(NSString *)SN queryStation:(NSString *)station queryStationID:(NSString *)stationID queryArray:(NSArray *)queryArray queryDate:(NSDate*)queryDate
{
    NSDate *localDateTime=[[NSDate alloc] initWithTimeIntervalSinceNow:0];
    NSTimeInterval interval = [localDateTime timeIntervalSinceDate:queryDate];
    [localDateTime release];
    
    [request requestWithURL:[NSURL URLWithString:SERVER_URL]];
    NSMutableDictionary* resultDic = [[[NSMutableDictionary alloc]init]autorelease];
    
    [request addPostValue:@"QUERY_RECORD" forKey:BC_Command];
    
    if (station)    [request addPostValue:station forKey:BC_StationName_ForQuery];
    if (stationID)  [request addPostValue:stationID forKey:BC_StationID_ForQuery];
    
    [request addPostValue:SN forKey:BC_SerialNumber];
    
    for (int i = 0; i<[queryArray count]; i++)
    {
        [request addPostValue:[queryArray objectAtIndex:i] forKey:BC_Parameter];
    }
    [request setRequestMethod:BC_HTTP_POST_METHOD];
    [request startSynchronous];
    
    NSString* response =[request getResponseString];
    NSLog(@"the response is %@",response);
    
    if (response != nil)
    {
        if ([response rangeOfString:SFC_OK].location!=NSNotFound)
        {
            NSArray* queryResponds = [response componentsSeparatedByString:@"\n"];
            
            for (int i = 1; i<[queryResponds count]; i++)
            {
                NSString* queryRespond = [queryResponds objectAtIndex:i];
                NSArray* resultArray =[queryRespond componentsSeparatedByString:@"="];
                [resultDic setObject:[resultArray objectAtIndex:1] forKey:[resultArray objectAtIndex:0]];
            }
            return resultDic;
        }
        if ([response rangeOfString:SFC_ERROR].location!=NSNotFound)
        {
            if (interval < REQUEST_INTERVAL)
            {
                return [self queryRecord:SN queryStation:station queryStationID:stationID queryArray:queryArray queryDate:queryDate];
            }
            NSLog(@"the server is bad ,please connect to the FIS DRI");
            return nil;
            
        }
        NSLog(@"the response is fail:%@",response);
        return nil;
    }
    NSLog(@"The connection to the internet is OFF");
    return nil;
}
                           
-(NSString *)queryHistory:(NSString *)SN queryDate:(NSDate*)queryDate
{
    NSDate *localDateTime=[[NSDate alloc] initWithTimeIntervalSinceNow:0];
    NSTimeInterval interval = [localDateTime timeIntervalSinceDate:queryDate];
    [localDateTime release];
    
    [request requestWithURL:[NSURL URLWithString:SERVER_URL]];
    [request setPostValue:@"QUERY_HISTORY" forKey:BC_Command];
    [request setPostValue:SN forKey:BC_SerialNumber];
    [request setRequestMethod:BC_HTTP_POST_METHOD];
    [request startSynchronous];
    
    NSString* response =[request getResponseString];
    
    if (response != nil)
    {
        if ([response rangeOfString:SFC_OK].location!=NSNotFound)
        {
            return response;
        }
        if ([response rangeOfString:SFC_ERROR].location!=NSNotFound)
        {
            if (interval< REQUEST_INTERVAL)
            {
                [self queryHistory:SN queryDate:queryDate];
            }
            NSLog(@"the server is bad ,please connect to the FIS DRI");
            return nil;
        }
        NSLog(@"the response is fail:%@",response);
        return nil;
    }
    NSLog(@"The connection to the internet is OFF");
    return response;
}

-(NSString *)queryVersion:(NSDate*)queryDate
{
    NSDate *localDateTime=[[NSDate alloc] initWithTimeIntervalSinceNow:0];
    NSTimeInterval interval = [localDateTime timeIntervalSinceDate:queryDate];
    [localDateTime release];
    
    [request requestWithURL:[NSURL URLWithString:SERVER_URL]];
    [request setPostValue:@"SERVER_VERSION" forKey:BC_Command];
    [request setRequestMethod:BC_HTTP_POST_METHOD];
    [request startSynchronous];
    NSString* response =[request getResponseString];
    
    if (response != nil)
    {
        if ([response rangeOfString:SFC_OK].location!=NSNotFound)
        {
            NSArray* queryResponses = [response componentsSeparatedByString:@"\n"];
            NSString* queryResponse = [queryResponses objectAtIndex:1] ;
            return queryResponse;
        }
        if ([response rangeOfString:SFC_ERROR].location!=NSNotFound)
        {
            if (interval< REQUEST_INTERVAL)
            {
                return [self queryVersion:queryDate];
            }
            NSLog(@"the server is bad ,please connect to the FIS DRI");
            return nil;
        }
        NSLog(@"the response is fail:%@",response);
        return nil;
    }
    NSLog(@"The connection to the internet is OFF");
    return nil;
}

-(void)getSatationIdByPudding
{
    char *stationID = (char *)malloc(BOBCAT_STATIONINFO_LENGTH*sizeof(char));
    
    [self getGHSatationInfo:IP_STATION_ID outputData:stationID];
    
    stationid=[[NSMutableString alloc]initWithFormat:@"%s",stationID];
    NSLog(@"BOBCAT stationid = %@",stationid);
    free(stationID);
    
}

-(void)getMicIDByPudding
{
    char *micID = (char *)malloc(BOBCAT_STATIONINFO_LENGTH*sizeof(char));
    
    [self getGHSatationInfo:IP_MAC outputData:micID];
    
    testMachineid=[[NSMutableString alloc]initWithFormat:@"%s",micID];
    NSLog(@"BOBCAT testMachineid = %@",testMachineid);
    free(micID);
    
}

// Bobcat URL
-(void)getSFC_URLByPudding
{
    char *sfc_url = (char *)malloc(BOBCAT_STATIONINFO_LENGTH*sizeof(char));
    
    [self getGHSatationInfo:IP_SFC_URL outputData:sfc_url];
    
    SERVER_URL=[[NSMutableString alloc]initWithFormat:@"%s",sfc_url];
    NSLog(@"BOBCAT SERVER_URL = %@",SERVER_URL);
    free(sfc_url);

}

-(void)getGHSatationInfo:(enum IP_ENUM_GHSTATIONINFO)info outputData:(char *)data
{
    Pudding *puddings = [[Pudding alloc] init];
    [puddings UUTStart:"" snLength:BOBCAT_STATIONINFO_LENGTH replyMessage:nil];
    [puddings getGHStationInfo:info outputData:data];
    [puddings UUTDestroy];
    [puddings dealloc];
}

#pragma mark ---发送HTTP请求
- (NSString *)testSN:(NSString *)caseSN withLeftSN:(NSString *)LSN withRightSN:(NSString *)RSN{
    NSURL *url = [[[NSURL alloc] initWithString:SERVER_URL] autorelease];
    [request requestWithURL:url];
    [request setRequestMethod:@"POST"];
    [request setPostValue:@"SS_PRECHECK" forKey:@"c"];
    [request setPostValue:[caseSN stringByReplacingOccurrencesOfString:@" " withString:@""] forKey:@"sn"];
    [request setPostValue:[LSN stringByReplacingOccurrencesOfString:@" " withString:@""] forKey:@"accessory_1"];
    [request setPostValue:[RSN stringByReplacingOccurrencesOfString:@" " withString:@""] forKey:@"accessory_2"];
    [request setPostValue:[caseSN stringByReplacingOccurrencesOfString:@" " withString:@""] forKey:@"accessory_3"];
    [request setPostValue:stationid forKey:@"station_id"];
    [request startSynchronous];
    return [request getResponseString];
}


- (NSString *)saveSN:(NSString *)caseSN withLeftSN:(NSString *)LSN withRightSN:(NSString *)RSN withLeftFail:(NSString *)itemL withRightFail:(NSString *)itemR withCaseFail:(NSString *)itemC withResult:(NSString *)aresult{
    
    NSURL *url = [[[NSURL alloc] initWithString:SERVER_URL] autorelease];
    [request requestWithURL:url];
    [request setRequestMethod:@"POST"];
    [request setPostValue:@"SS_SAVE_PRECHECK_RESULT" forKey:@"c"];
    [request setPostValue:[caseSN stringByReplacingOccurrencesOfString:@" " withString:@""] forKey:@"sn"];
    [request setPostValue:[LSN stringByReplacingOccurrencesOfString:@" " withString:@""] forKey:@"accessory_1"];
    [request setPostValue:[RSN stringByReplacingOccurrencesOfString:@" " withString:@""] forKey:@"accessory_2"];
    [request setPostValue:[caseSN stringByReplacingOccurrencesOfString:@" " withString:@""] forKey:@"accessory_3"];
    [request setPostValue:stationid forKey:@"station_id"];
    [request setPostValue:[itemL stringByReplacingOccurrencesOfString:@" " withString:@""] forKey:@"list_of_failing_tests_1"];
    [request setPostValue:[itemR stringByReplacingOccurrencesOfString:@" " withString:@""] forKey:@"list_of_failing_tests_2"];
    [request setPostValue:[itemC stringByReplacingOccurrencesOfString:@" " withString:@""] forKey:@"list_of_failing_tests_3"];
    [request setPostValue:[aresult stringByReplacingOccurrencesOfString:@" " withString:@""] forKey:@"result"];
    [request startSynchronous];
    return [request getResponseString];
}
@end
