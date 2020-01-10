//
//  JSON.m
//  mutiAutoTest
//
//  Created by May on 13/6/13.
//  Copyright (c) 2013年 May. All rights reserved.
//

#import "JSON.h"
#import "Utility.h"
#define FOLDER @"Log-JSON"

@implementation JSON

-(id)init
{
    if(self=[super init])
    {
        plistData=[PlistIO sharedPlistIO];
        [self creatFolder];
    }
    return self;
}

-(void)creatFolder
{
    NSFileManager *fileMgr=[[NSFileManager alloc]init];
    NSString *workingPath=[[NSFileManager defaultManager] currentDirectoryPath];
    workingPath=[workingPath stringByAppendingPathComponent:FOLDER];
    [fileMgr createDirectoryAtPath:workingPath withIntermediateDirectories:YES attributes:nil error:nil];
    _logFilePath=workingPath;
    [fileMgr release];
}

-(void)saveJsonLog:(NSString*)sn dutNum:(int)dutNum
{
    NSMutableArray *jsonItems=[[NSMutableArray alloc] init];
    
    for (int i=0; i<[[plistData TestItemList] count]; i++)
    {
        Item *item=[plistData TestItemList][i];

        NSDictionary *jsonItem=[NSDictionary dictionaryWithObjectsAndKeys:
                            item.Name,[NSString stringWithFormat:@"TEST%d",i+1],
                            [item valueForKey:[NSString stringWithFormat:@"Value_%d",dutNum]],@"VALUE",
                            [NSNumber numberWithBool:[[item valueForKey:[NSString stringWithFormat:@"isPass_%d",dutNum]] boolValue]],@"RESULT", nil];
       
        [jsonItems addObject:jsonItem];
    }
    NSDictionary *json=[NSDictionary dictionaryWithObject:jsonItems forKey:@"results"];
    
    if ([NSJSONSerialization isValidJSONObject:json])
    {
        NSData *jsonData=[NSJSONSerialization dataWithJSONObject:json options:NSJSONWritingPrettyPrinted error:nil];
        
        NSString *filePath=[NSString stringWithFormat:@"%@/%@-%@.json",_logFilePath,[Utility getTimeForFile],sn];
        [jsonData writeToFile:filePath atomically:YES];
        NSLog(@"Save JSON log");
    }
    [jsonItems release];
}
@end
