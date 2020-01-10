//
//  STM8.m
//  autoTest
//
//  Created by TOM on 2014/8/26.
//  Copyright (c) 2014年 TOM. All rights reserved.
//

#import "SeggerFlasher.h"
#define DELAY_TIME 500000//0.5 sec
#define STM8_TIMEOUT_SEC 15
#define ENDING_SYMBOL @"#OK"


@implementation SeggerFlasher
@synthesize isReady;
@synthesize PathKeyWord;

-(void)DEMO
{
    NSLog(@"#ERASE => %@", [self queryByCmd:@"#ERASE"]);
    NSLog(@"#auto => %@", [self queryByCmd:@"#auto"]);
}

-(id)init:(NSString *)path speed:(int)br flowCtrl:(BOOL)flow parityCtrl:(BOOL)paryity
{
    if(self=[super init])
    {
        uart=[[UART alloc]init];
        PathKeyWord = [[NSMutableString alloc] initWithString:@""];
        
        if([path rangeOfString:@"/dev/cu"].location != NSNotFound)
        {
            [self open:path speed:br flowCtrl:flow parityCtrl:paryity];
            [PathKeyWord setString:path];
        }
        else
        {
            if ([path length] > 0)
            {
                [PathKeyWord setString:path];
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

-(NSString *)findPathWithKeyWord
{
    NSArray *uartPathArr = [self scanUART];
    for (int i = 0; i<[uartPathArr count]; i++)
    {
        if ([[uartPathArr objectAtIndex:i] rangeOfString:PathKeyWord].location != NSNotFound)
            return [uartPathArr objectAtIndex:i];
    }
    return @"EMPTY";
}

-(NSArray *)scanUART
{
    return [uart uartList];
}

-(BOOL)writeToSF:(NSString *)uartCmd
{
    if([uart TX:uartCmd])
    {
        [self attachLogFileWithTitle:[NSString stringWithFormat:@"%@ %d",[self className],[self myThreadIndex]]
                            withDate:[Utility getTimeBy24hr]
                         withMessage:[NSString stringWithFormat:@"SEND: %@",uartCmd]];
        usleep(DELAY_TIME);
        return TRUE;
    }
    return FALSE;
}

-(NSString *)readFromSF
{
    NSString *echo=[uart RX];
    if ([echo length]>0)
    {
        [self attachLogFileWithTitle:[NSString stringWithFormat:@"%@ %d",[self className],[self myThreadIndex]]
                            withDate:[Utility getTimeBy24hr]
                         withMessage:[NSString stringWithFormat:@"READ: %@",echo]];
        return echo;
    }
    return @"";
}

-(NSString*)queryByCmd:(NSString *)cmd
{
    [self readFromSF];

    [self writeToSF:cmd];
    
    NSMutableString *msg = [[[NSMutableString alloc] initWithString:@""] autorelease];
    NSDate *over=[NSDate dateWithTimeIntervalSinceNow:STM8_TIMEOUT_SEC];
    
    while(1)
    {
        [msg appendString:[self readFromSF]];
        
        if ([msg rangeOfString:ENDING_SYMBOL].location != NSNotFound)
        {
            return msg;

        }else
        {
            NSDate *now=[NSDate dateWithTimeIntervalSinceNow:0];
            if ([now compare:over] == NSOrderedDescending )
                break;
        }
    }
    return msg;   // just return response
}


-(void)close
{
    if (isReady)
    {
        [uart closeComPort];
        isReady = false;
    }
}
@end
