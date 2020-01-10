//
//  Equipments.m
//  autoTest
//
//  Created by HenryLee on 1/3/14.
//  Copyright (c) 2014 TOM. All rights reserved.
//

#import "Equipments.h"

@implementation Equipments

@synthesize myThreadIndex;
NSMutableString *folderPath;
NSMutableString *thread1EchoColectionStr;
NSMutableString *thread2EchoColectionStr;
NSMutableString *thread3EchoColectionStr;
NSMutableString *thread4EchoColectionStr;

-(id)initWithArg:(NSDictionary *)dic
{
    return nil;
}

+(void)setLogFolderPath:(NSString*)path
{
    @synchronized (self)
    {
        if(folderPath == nil)
            folderPath = [[NSMutableString alloc] init];
        
        [folderPath setString:path];
    }
}

+(void)attachLogFileWithTitle:(NSString*)title withDate:(NSString*)date withMessage:(NSString*)content forThread:(int)num
{
    NSMutableString *echoColectionStr = [Equipments selectEchoStringWithNum:num];
    
    //If title is nil or empty string,it won't be append.
    if (title.length > 0 && title != nil)
        [echoColectionStr appendFormat:@"\n[%@]",title];
    
    //If date is nil or empty string,it won't be append.
    if (date.length > 0 && date != nil)
        [echoColectionStr appendFormat:(title.length == 0)?@"\n[%@]":@" %@",date];
    
    //If content is nil append "nil" string.
    if (content != nil)
        [echoColectionStr appendFormat:(title.length == 0 && date.length == 0 )?@"\n%@":@" %@",content];
    else
        [echoColectionStr appendString:(title.length == 0 && date.length == 0 )?@"\nnil":@" nil"];
    
}

+(void)attachLogFileWithTitle:(NSString*)title withDate:(NSString*)date withMessage:(NSString*)content
{
    [self attachLogFileWithTitle:title withDate:date withMessage:content forThread:1];
}

+(NSString *)saveLogWithFileName:(NSString *)name forThread:(int)num
{
    @synchronized (self)
    {
        //:Check folder path
        if(folderPath == nil)
        {
            NSString * defaultPath = @"/vault/IACHostLogs/Equipments_Log";
            folderPath = [[NSMutableString alloc] initWithString:defaultPath];
        }
        
        //:Create directory
        NSString *filePath = [NSString stringWithFormat:@"%@/%@",folderPath,name];
        [[NSFileManager defaultManager] createDirectoryAtPath:folderPath withIntermediateDirectories:YES attributes:nil error:nil];
        
        //:Select echoString and write
        NSMutableString *echoColectionStr = [Equipments selectEchoStringWithNum:num];
        if ([echoColectionStr writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:nil])
        {
            NSLog(@"save:%@",filePath);
            [echoColectionStr setString:@""];
            return filePath;
        }
        return @"save failed";
    }
}

+(NSString *)saveLogWithFileName:(NSString *)name
{
    return [self saveLogWithFileName:name forThread:1];
}

+(void)clearLogFileWithThread:(int)num
{
    NSMutableString *echoColectionStr = [Equipments selectEchoStringWithNum:num];
    [echoColectionStr setString:@""];
}

+(void)clearLogFile
{
    [self clearLogFileWithThread:1];
}

+(void)delayWithSecond:(int)sec forThread:(int)num
{
    sleep(sec);
    NSMutableString *echoColectionStr = [Equipments selectEchoStringWithNum:num];
    [echoColectionStr appendString:[NSString stringWithFormat:@"\nWait %d second!!",sec]];
}

+(void)delayWithSecond:(int)sec
{
    [self delayWithSecond:sec forThread:1];
}

+(void)delayWithMicorSecond:(int)ms forThread:(int)num
{
    usleep(ms);
    NSMutableString *echoColectionStr = [Equipments selectEchoStringWithNum:num];
    [echoColectionStr appendString:[NSString stringWithFormat:@"\nWait %d microsecond!!",ms]];
}

+(void)delayWithMicorSecond:(int)ms
{
    [self delayWithMicorSecond:ms forThread:1];
}

+(NSMutableString *)selectEchoStringWithNum:(int)num
{
    switch (num)
    {
        case 1:
            if(thread1EchoColectionStr == nil)
                thread1EchoColectionStr = [[NSMutableString alloc] init];
            return thread1EchoColectionStr;
        case 2:
            if(thread2EchoColectionStr == nil)
                thread2EchoColectionStr = [[NSMutableString alloc] init];
            return thread2EchoColectionStr;
        case 3:
            if(thread3EchoColectionStr == nil)
                thread3EchoColectionStr = [[NSMutableString alloc] init];
            return thread3EchoColectionStr;
        case 4:
            if(thread4EchoColectionStr == nil)
                thread4EchoColectionStr = [[NSMutableString alloc] init];
            return thread4EchoColectionStr;
        default:
            return nil;
    }
}

-(void)setLogFolderPath:(NSString*)path
{
    [Equipments setLogFolderPath:path];
}

-(void)attachLogFileWithTitle:(NSString*)title withDate:(NSString*)date withMessage:(NSString*)content
{
    [Equipments attachLogFileWithTitle:title withDate:date withMessage:content forThread:myThreadIndex];
}

-(NSString *)saveLogWithFileName:(NSString *)name
{
    return [Equipments saveLogWithFileName:name forThread:myThreadIndex ];
}

-(void)dealloc
{
    [super dealloc];
    [thread1EchoColectionStr release];
    [thread2EchoColectionStr release];
    [thread3EchoColectionStr release];
    [thread4EchoColectionStr release];
    [folderPath release];
}

@end
