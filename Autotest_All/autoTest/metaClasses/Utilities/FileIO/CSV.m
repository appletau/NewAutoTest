//
//  csv.m
//  autoTest
//
//  Created by May on 19/4/18.
//  Copyright (c) 2013年 TOM. All rights reserved.
//

#import "CSV.h"
#import "Utility.h"

@implementation CSV

-(id)init
{
    if(self=[super init])
    {
        plist=[PlistIO sharedPlistIO];
        csvPath=[[NSMutableString alloc] initWithString:[self createOppLogsDir]];
    }
    return self;
}

-(void)dealloc
{
    [csvPath release];
    [super dealloc];
}

-(NSString*)createOppLogsDir
{
    NSString *dirPath=[NSString stringWithFormat:@"/vault/IACHostLogs/StationTestRecord/%@",[Utility getTimeForLocalFolder]];
    NSString *headerPath=[NSString stringWithFormat:@"%@/%@-v%@-Logs.csv",dirPath,[plist StationName],plist.SW_Ver];

    if (![[NSFileManager defaultManager] fileExistsAtPath:headerPath])
    {
        [[NSFileManager defaultManager] createDirectoryAtPath:dirPath withIntermediateDirectories:YES attributes:nil error:nil];
        [self createOppHeader:headerPath];
    }
    return headerPath;
}

-(void)createOppHeader:(NSString*)headerPath
{
    NSString *host=[NSString stringWithFormat:@"%@,Version:v%@",[plist StationName],plist.SW_Ver];
    NSString *headerFormate=@"Product,SerialNumber,Received SN,Truncated Serial Number,Unit Number,Station ID,Test Pass/Fail Status,Start Time,End Time,List Of Failing Tests";
    
    NSMutableString *product     =[NSMutableString stringWithString:headerFormate];
    NSMutableString *displayName =[NSMutableString stringWithString:@"Display Name   ---->,,,,,,,,,"];
    NSMutableString *priority    =[NSMutableString stringWithString:@"PDCA Priority  ---->,,,,,,,,,"];
    NSMutableString *upperLimit  =[NSMutableString stringWithString:@"Upper Limit    ---->,,,,,,,,,"];
    NSMutableString *lowerLimit  =[NSMutableString stringWithString:@"Lower Limit    ---->,,,,,,,,,"];
    NSMutableString *unit        =[NSMutableString stringWithString:@"Measuring Unit ---->,,,,,,,,,"];
    
    for (int i=0; i<[plist.TestItemList count]; i++)
    {
        Item *item=plist.TestItemList[i];
        
        [product appendFormat:@",%@",item.Name];
        [displayName appendString:@","];
        [priority appendString:@",1"];
        [upperLimit appendFormat:@",%@",item.Max];
        [lowerLimit appendFormat:@",%@",item.Min];
        [unit appendFormat:@",%@",item.Unit] ;
    }
    
    NSString *header=[NSString stringWithFormat:@"%@\n%@\n%@\n%@\n%@\n%@\n%@\n",host,product,displayName,priority,upperLimit,lowerLimit,unit];
    [header writeToFile:headerPath atomically:YES encoding:NSUTF8StringEncoding error:nil];
}

-(void)saveOppRecord:(nonnull NSString*)sn dutNum:(int)dutNum begin:(nonnull NSString*)begin rSN:(nullable NSString *)rSN tSN:(nullable NSString *)tSN uNum:(nullable NSString*)uNum sID:(nullable NSString *)sID
{
    rSN=(rSN!=NULL)?rSN:@"TBD";
    tSN=(tSN!=NULL)?tSN:@"TBD";
    uNum=(uNum!=NULL)?uNum:@"TBD";
    sID=(sID!=NULL)?sID:@"TBD";
    
    NSString *end=[Utility getTimeBy24hrStdFormate];
    NSMutableArray *vals=[[NSMutableArray alloc] init];
    NSMutableArray *failedItems=[[NSMutableArray alloc] init];
    int count=(int)[plist.TestItemList count];
    
    for (int i=0; i<count; i++)
    {
        Item *item=plist.TestItemList[i];

        [vals addObject:[item valueForKey:[NSString stringWithFormat:@"Value_%d",dutNum]]];

        if (![[item valueForKey:[NSString stringWithFormat:@"isPass_%d",dutNum]] boolValue] && !item.isSkip)
            [failedItems addObject:item.Name];
    }

    NSString *pID=[plist getObjForKey:@"PRODUCT"];
    NSString *result=([plist checkIsAllPass:dutNum])?@"PASS":@"FAIL";
    NSString *record=[NSString stringWithFormat:@"%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@\n",pID,sn,rSN,tSN,uNum,sID,result,begin,end,[failedItems componentsJoinedByString:@";"],[vals componentsJoinedByString:@","]];

    NSFileHandle *handle=[NSFileHandle fileHandleForWritingAtPath:csvPath];
    [handle seekToEndOfFile];
    [handle writeData:[record dataUsingEncoding:NSUTF8StringEncoding]];
    
    [vals release];
    [failedItems release];
    NSLog(@"Save Local CSV (%@) DUT-%d",sn,dutNum);
}

-(void)saveCycleTimeRecord:(nonnull NSString*)sn dutNum:(int)dutNum
{
    NSMutableString *content=[[NSMutableString alloc] initWithString:[NSString stringWithFormat:@"%@,v%@,%@\n",plist.StationName,plist.SW_Ver,sn]];
    NSTimeInterval total=0.0f;
    
    for (int i=0; i<[plist.TestItemList count]; i++)
    {
        Item *item=plist.TestItemList[i];
        NSTimeInterval timeCosts=[[item valueForKey:[NSString stringWithFormat:@"Time_%d",dutNum]] floatValue];
        [content appendFormat:@"%d,%@,%f\n",i+1,item.Name,timeCosts];
        total+=timeCosts;
    }
    [content appendFormat:@"Cycle Time,,%f\n",total];
    
    NSString *dirPath=[NSString stringWithFormat:@"/vault/IACHostLogs/CycleTimeRecord/%@",[Utility getTimeForLocalFolder]];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:dirPath])
    {
        [[NSFileManager defaultManager] createDirectoryAtPath:dirPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    [content writeToFile:[NSString stringWithFormat:@"%@/%@-%@.csv",dirPath,[Utility getTimeForFile],sn] atomically:YES encoding:NSUTF8StringEncoding error:nil];
    
    [content release];
}
@end
