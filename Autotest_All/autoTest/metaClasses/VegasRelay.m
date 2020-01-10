//
//  VegasRelay.m
//  autoTest
//
//  Created by may on 10/19/16.
//  Copyright © 2016 TOM. All rights reserved.
//

#import "VegasRelay.h"
#import "Utility.h"
#define ENDING_SYMBOL @":-)"
#define DELAYTIME 100
@implementation VegasRelay
@synthesize isReady;
@synthesize PathKeyWord;

-(void)DEMO
{
    [self writeToDevice:@"ver\r"];
    NSLog(@"Device read the ver = %@",[self readFromDevice]);
    NSLog(@"Device query volt = %@",[self queryByCmd:@"volt" strWaited:ENDING_SYMBOL retry:1 timeout:3]);
}

-(id)init:(NSString *)path speed:(int)br flowCtrl:(BOOL)flow parityCtrl:(BOOL)paryity
{
    if(self=[super init])
    {
        uart=[[UART alloc]init];
        
        if([path rangeOfString:@"/dev/cu"].location != NSNotFound)
        {
            [self open:path speed:br flowCtrl:flow parityCtrl:paryity];
            PathKeyWord = path;
        }
        else
        {
            if ([path length] > 0)
            {
                PathKeyWord = path;
                isReady = true; //runtime decide isReady
            }
        }
    }
    return self;
}

-(id)initWithArg:(NSDictionary *)dic
{
    id tmp = nil;
    tmp = [self init: [dic objectForKey:@"PATH"] speed:[[dic objectForKey:@"BAUD_RATE"] intValue] flowCtrl:[[dic objectForKey:@"FLOW_CTL"] boolValue] parityCtrl:[[dic objectForKey:@"PARITY_CTL"] boolValue]] ;
    return tmp;
}

-(void)open:(NSString *)path speed:(int)br flowCtrl:(BOOL)flow parityCtrl:(BOOL)paryity
{
    [uart openComPort:path baudRate:br flowCtrl:flow parityCtrl:paryity];
    isReady=[uart isUartOpening];
    usleep(500000);
    
    if (!isReady)
        NSLog(@"%@ is not ready to use",[self className]);
    else
        NSLog(@"%@ is ready to use",[self className]);
}

-(void)dealloc
{
    [uart release];
    [super dealloc];
}

-(NSArray *)scanUART
{
    return [uart uartList];
}

-(NSString *)findPathWithKeyWord
{
    NSArray *uartPathArr = [self scanUART];
    for (int i = 0; i<[uartPathArr count]; i++)
    {
        if ([[uartPathArr objectAtIndex:i] rangeOfString:PathKeyWord].location != NSNotFound)
            return [uartPathArr objectAtIndex:i];
    }
    return @"";
}

-(BOOL)checkUARTOpening
{
    isReady = [uart isUartOpening];
    return isReady;
}

-(BOOL)writeToDevice:(NSString *)uartCmd
{
    if([uart TX:uartCmd])
    {
        [self attachLogFileWithTitle:[self className]
                            withDate:[Utility getTimeBy24hr]
                         withMessage:[NSString stringWithFormat:@"SEND: %@",uartCmd]];
        usleep(DELAYTIME);
        return TRUE;
    }
    return FALSE;
}

-(BOOL)writeToDeviceByBytes:(uint8_t *)buffer length:(int)len
{
    if([uart TXbyBytes:buffer length:len])
    {
        [self attachLogFileWithTitle:[self className]
                            withDate:[Utility getTimeBy24hr]
                         withMessage:[NSString stringWithFormat:@"SEND: %s",buffer]];
        
        usleep(DELAYTIME);
        return TRUE;
    }
    return FALSE;
}

-(NSString *)readFromDevice
{
    NSString *echo=[uart RX];
    if ([echo length]>0)
    {
        [self attachLogFileWithTitle:[self className]
                            withDate:[Utility getTimeBy24hr]
                         withMessage:[NSString stringWithFormat:@"READ: %@",echo]];
        return echo;
    }
    return @"";
}

-(NSData *)readFromDeviceByBytes:(int)len
{
    NSData *data = [uart RXbyBytes:len];
    if ([data length] > 0)
    {
        [self attachLogFileWithTitle:[self className]
                            withDate:[Utility getTimeBy24hr]
                         withMessage:[NSString stringWithFormat:@"READ: %s",[data bytes]]];
        return data;
    }
    return nil;
}

-(NSString*)queryRawDataByCmd:(NSString *)cmd strWaited:(NSString*)symbol retry:(int)times timeout:(int)sec
{
    [uart RX];
    NSMutableString *response=[[[NSMutableString alloc] initWithString:@""] autorelease];
    
    for(int i=0; i<times; i++)
    {
        [self writeToDevice:[NSString stringWithFormat:@"%@\r",cmd]];
        NSDate *over=[NSDate dateWithTimeIntervalSinceNow:sec];
        [response setString:@""];
        
        while([[NSDate dateWithTimeIntervalSinceNow:0] compare:over]!= NSOrderedDescending)
        {
            usleep(DELAYTIME);
            NSString *echo=[uart RX];
            [response appendString:([echo length]>0)?echo:@""];
            if ([response rangeOfString:symbol].location != NSNotFound)
            {
                [self attachLogFileWithTitle:[self className]
                                    withDate:[Utility getTimeBy24hr]
                                 withMessage:[NSString stringWithFormat:@"READ: %@",response]];
                return response;
            }
        }
        [self attachLogFileWithTitle:[self className]
                            withDate:[Utility getTimeBy24hr]
                         withMessage:[NSString stringWithFormat:@"READ: %@",response]];
    }
    
    if ([response isEqualToString:@""])
        return [NSString stringWithFormat:@"%@ cause by no response (%@) in %d sec",TIMEOUT_KEYWORD,cmd,sec];
    return [NSString stringWithFormat:@"%@ cause by wrong response (%@) in %d sec--->%@",TIMEOUT_KEYWORD,cmd,sec,response];
}

-(NSString*)queryByCmd:(NSString *)cmd strWaited:(NSString*)symbol retry:(int)times timeout:(int)sec
{
    [uart RX];
    NSMutableString *response=[[[NSMutableString alloc] initWithString:@""] autorelease];
    
    for(int i=0; i<times; i++)
    {
        [self writeToDevice:[NSString stringWithFormat:@"%@\r",cmd]];
        NSDate *over=[NSDate dateWithTimeIntervalSinceNow:sec];
        [response setString:@""];
        
        while([[NSDate dateWithTimeIntervalSinceNow:0] compare:over]!= NSOrderedDescending)
        {
            usleep(DELAYTIME);
            NSString *echo=[uart RX];
            [response appendString:([echo length]>0)?echo:@""];
            if ([response rangeOfString:symbol].location != NSNotFound)
            {
                [self attachLogFileWithTitle:[self className]
                                    withDate:[Utility getTimeBy24hr]
                                 withMessage:[NSString stringWithFormat:@"READ: %@",[Utility cleanStr:response]]];
                return [Utility cleanStr:response];
            }
        }
        [self attachLogFileWithTitle:[self className]
                            withDate:[Utility getTimeBy24hr]
                         withMessage:[NSString stringWithFormat:@"READ: %@",[Utility cleanStr:response]]];
    }
    
    if ([response isEqualToString:@""])
        return [NSString stringWithFormat:@"%@ cause by no response (%@) in %d sec",TIMEOUT_KEYWORD,cmd,sec];
    return [NSString stringWithFormat:@"%@ cause by wrong response (%@) in %d sec--->%@",TIMEOUT_KEYWORD,cmd,sec,response];
}

-(void)close
{
    if (isReady)
    {
        [uart closeComPort];
        isReady = [uart isUartOpening];
    }
}
@end
