//
//  PlistIO.m
//  UIcontrol
//
//  Created by TOM on 19/4/19.
//  Copyright (c) 2019年 TOM. All rights reserved.
//

#import "PlistIO.h"
#define FILE_NAME @"ini"

@implementation PlistIO

+(PlistIO *)sharedPlistIO
{
    static PlistIO *sharedInstance=nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        sharedInstance=[PlistIO new];
    });
    
    return sharedInstance;
}

-(id)init
{
    if (self=[super init])
    {
        _Equipment=[NSMutableArray new];
        _TestItemList=[NSMutableArray new];
        [self testsDataInit];
        [self propertiesInit];
    }
    return self;
}

-(void)dealloc
{
    [_Equipment release];
    [_TestItemList release];
    [super dealloc];
}



-(void)testsDataInit
{
    NSString *filePath=[[NSBundle mainBundle] pathForResource:FILE_NAME ofType:@"plist"];
    NSDictionary *content=[NSDictionary dictionaryWithContentsOfFile:filePath];
    NSDictionary *tests=[content objectForKey:@"TESTS"];
    
    for (int i=0; i<[tests count]; i++)
    {
        Item *item=[[Item alloc] init:tests[[NSString stringWithFormat:@"TEST%d", i+1]]];
        [item setOrder:i+1];
        [_TestItemList addObject:item];
        [item release];
        //[(Item*)_TestItemList[i] print:1];
    }
}

-(void)propertiesInit
{
    [self setIsAllowPrefer:[[self getObjForKey:@"ALLOW_PREFERENCES"] boolValue]];
    [self setIsAllowAuditMode:[[self getObjForKey:@"ALLOW_AUDIT_MODE"] boolValue]];
    [self setIsAllowPudding:[[self getObjForKey:@"ALLOW_PUDDING"] boolValue]];
    _StationName=[[self getObjForKey:@"STATION_NAME"] copy];
    _SW_Ver=[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    _Product=[[self getObjForKey:@"PRODUCT"] copy];
}

-(void)equipmentInit
{    
    [_Equipment removeAllObjects];
    
    NSString *filePath=[[NSBundle mainBundle] pathForResource:FILE_NAME ofType:@"plist"];
    NSDictionary *content=[NSDictionary dictionaryWithContentsOfFile:filePath];
	NSArray *equipTemp=[content objectForKey:@"EQUIPMENTS"];
	
	for (int i=0; i<[equipTemp count]; i++)
    {
		id obj=equipTemp[i];
        NSString *className=[obj objectForKey:@"CLASSNAME"];
        
		if ([NSClassFromString(className) instancesRespondToSelector:@selector(initWithArg:)])
        {
			id dev=[(Equipments *)[NSClassFromString(className) alloc] initWithArg:obj];
            
            //Set Equipments Thread index here
            NSString *equipName = [obj objectForKey:@"USEDFOR"];
            int threadIndex = [self getThreadIndex:equipName];
            
            if ([NSClassFromString(className) instancesRespondToSelector:@selector(setMyThreadIndex:)])
                [dev setMyThreadIndex:threadIndex];
            
			if (dev != nil)
            {
				NSMutableArray *tmp=[NSMutableArray new];
				[tmp addObject:dev];
				[tmp addObject:obj];

				[_Equipment addObject:tmp];
                
				[dev release];
				[tmp release];
			}
		}
	}
    NSLog(@"Init Equipment Done");
}

-(int)getThreadIndex:(NSString *)name
{
    if ([name rangeOfString:@"THRD"].length>0 && [name rangeOfString:@"_"].length>0)
    {
        int start=(int)[name rangeOfString:@"THRD"].location+(int)[@"THRD" length];
        int len=(int)[name rangeOfString:@"_"].location-start;
        
        if (start > 0 && len > 0)
            return [[name substringWithRange:NSMakeRange(start, len)] intValue] ;
    }
    return 1;
}

-(id)getEquipment:(NSString *)usedfor
{
	for (int i = 0; i < [_Equipment count]; i++)
    {
		if ([[[_Equipment[i] objectAtIndex:1] objectForKey:@"USEDFOR"] isEqualToString:usedfor])
        {
			return [_Equipment[i] objectAtIndex:0];
		}
	}
    NSLog(@"Get %@ Error",usedfor);
	return nil;
}

-(NSArray*)getEquipmentList
{
    NSArray *equ=[self getObjForKey:@"EQUIPMENTS"];
    NSMutableArray *info=[[[NSMutableArray alloc] init] autorelease];
    
    for (NSDictionary *dev in equ)
    {
        NSString *usedfor=[dev objectForKey:@"USEDFOR"];
        
        if (([[dev objectForKey:@"CTL_TYPE"] isEqualToString:@"UART"] || [[dev objectForKey:@"CTL_TYPE"] isEqualToString:@"VISAUSB"]) && [usedfor length]>0)
            [info addObject:dev];
    }
    return info;
}

-(id)getObjForKey:(NSString *)key
{
    NSString *filePath=[[NSBundle mainBundle] pathForResource:FILE_NAME ofType:@"plist"];
    NSDictionary *content=[NSDictionary dictionaryWithContentsOfFile:filePath];
    return [content objectForKey:key];
}

-(BOOL)checkIsAllPass:(int)dutNum
{
    for (int i=0; i<[_TestItemList count]; i++)
    {
        Item *item=_TestItemList[i];
        if([[item valueForKey:[NSString stringWithFormat:@"isPass_%d",dutNum]] boolValue]==NO)
            return NO;
    }
    return YES;
}

-(BOOL)checkIsAllPassForSetCB:(int)dutNum
{
    for (int i=0; i<[_TestItemList count]; i++)
    {
        Item *item=_TestItemList[i];
        
        if([item.Name isEqualToString:@"SetCB"] || [item.Name isEqualToString:@"finishWorkHandler"])
            continue;
        
        if([[item valueForKey:[NSString stringWithFormat:@"isPass_%d",dutNum]] boolValue]==NO)
            return NO;
    }
    return YES;
}

-(void)savePropertiesToPlist
{
    [self saveDataToPlist:@"ALLOW_PREFERENCES" value:[NSNumber numberWithBool:_isAllowPrefer]];
    [self saveDataToPlist:@"ALLOW_AUDIT_MODE" value:[NSNumber numberWithBool:_isAllowAuditMode]];
    [self saveDataToPlist:@"ALLOW_PUDDING" value:[NSNumber numberWithBool:_isAllowPudding]];
    [self propertiesInit];
}

-(void)saveDataToPlist:(NSString *)key value:(id)val
{
    NSString *filePath=[[NSBundle mainBundle] pathForResource:FILE_NAME ofType:@"plist"];
    NSMutableDictionary *content=[NSMutableDictionary dictionaryWithContentsOfFile:filePath];
    
    [content setObject:val forKey:key];
    
    if([content writeToFile:filePath atomically:YES])
        NSLog(@"Save (%@:%@) To Plist Ok",key,val);
    else
        NSLog(@"Save (%@:%@) To Plist Error",key,val);
}

-(void)saveEquipmentDataToPlist:(NSString *)usedfor forKey:(NSString *)key value:(id)val
{
    NSString *filePath=[[NSBundle mainBundle] pathForResource:FILE_NAME ofType:@"plist"];
    NSDictionary *content=[NSDictionary dictionaryWithContentsOfFile:filePath];
    
	for (int i=0; i<[[content objectForKey:@"EQUIPMENTS"] count]; i++)
    {
		if ([[[content objectForKey:@"EQUIPMENTS"][i] objectForKey:@"USEDFOR"] isEqualToString:usedfor])
        {
			[[content objectForKey:@"EQUIPMENTS"][i] setObject:val forKey:key];
            
            if([content writeToFile:filePath atomically:YES])
                NSLog(@"Save %@ (%@:%@) To Plist Ok",usedfor,key,val);
            else
                NSLog(@"Save %@ (%@:%@) To Plist Error",usedfor,key,val);
            return;
		}
	}
    NSLog(@"%@ Is Not Defined In Plist",usedfor);
}

@end
