//
//  RelayBox.m
//  autoTest
//
//  Created by May on 5/15/13.
//  Copyright (c) 2013 TOM. All rights reserved.
//

#import "RelayBox.h"

@implementation RelayBox

#define DELAY_TIME 500000//0.5 sec
#define READ_TIMEOUT 3
#define ENTER_KEY @"\r"
#define ENDING_SYMBOL @"OK"
#define STM8TIMEOUT @"STM8BASE Query Timeout"

@synthesize isReady;
@synthesize PathKeyWord;

-(void)DEMO
{
    [self writeToComPort:@"ver"];
    NSLog(@"relay read the ver = %d",[self readFromComPort]);// check the "OK", True or False
    NSLog(@"relay query the ver = %d",[self queryByCommand:@"ver"]); // check the "OK", True or False
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

-(NSArray *)scanUART
{
    return [uart uartList];
}

-(BOOL)cleanNoise
{
    if ([uart TX:@"\r"])
    {
        int counter=0;
        const int limitTimes=5;
        while ([uart RX]!=NULL)
        {
            counter++;
            if(counter==limitTimes)
                return FALSE;
        }
        return TRUE;
    }
    return FALSE;
}

-(BOOL)writeToComPort:(NSString *)uartCmd
{
    startSec=[self  getCurSec];
    NSString *cmd=[uartCmd stringByAppendingString:ENTER_KEY];
    if([uart TX:cmd])
    {
        [self attachLogFileWithTitle:[self className]
                            withDate:[Utility getTimeBy24hr]
                         withMessage:[NSString stringWithFormat:@"SEND: %@",uartCmd]];
        usleep(100000);
        return TRUE;
    }
    return FALSE;
}

-(BOOL)readFromComPort
{
    NSMutableString *readStr=[[NSMutableString  alloc] init];
    [readStr setString:@""];
    
    do
    {
        NSString *tempStr=[uart RX];
        if (tempStr!=NULL)
        {
            [readStr appendString:tempStr];
        }
        if ([self checkIsTimeOut])
        {
            NSString *fullStr=[NSString stringWithString:readStr];
            [self attachLogFileWithTitle:[self className]
                                withDate:[Utility getTimeBy24hr]
                             withMessage:[NSString stringWithFormat:@"READ: %@",fullStr]];
            [readStr release];
            return FALSE;
        }
        
    }while ([readStr rangeOfString:ENDING_SYMBOL].location==NSNotFound);
    
    NSString *fullStr=[NSString stringWithString:readStr];
    [self attachLogFileWithTitle:[self className]
                        withDate:[Utility getTimeBy24hr]
                     withMessage:[NSString stringWithFormat:@"READ: %@",fullStr]];
    [readStr release];
  
    if([fullStr rangeOfString:ENDING_SYMBOL].location!=NSNotFound)
        return TRUE;
    return FALSE;
}

-(NSString*)queryByCmd:(NSString *)cmd
{
    [uart TX:[NSString stringWithFormat:@"%@\r",cmd]];
    [self attachLogFileWithTitle:[self className]
                        withDate:[Utility getTimeBy24hr]
                     withMessage:[NSString stringWithFormat:@"SEND: %@",cmd]];
    NSDate *over=[NSDate dateWithTimeIntervalSinceNow:READ_TIMEOUT];
    NSMutableString *readStr=[[NSMutableString  alloc] initWithString:@""];

    
    while(1)
    {
        NSString *str = [uart RX];
        [readStr appendString:([str length]>0)?str:@""];
        if ([str rangeOfString:ENDING_SYMBOL].location != NSNotFound)
        {
            NSString *fullStr=[NSString stringWithString:readStr];
            [self attachLogFileWithTitle:[self className]
                                withDate:[Utility getTimeBy24hr]
                             withMessage:[NSString stringWithFormat:@"READ: %@",fullStr]];
            [readStr release];
            return str;
            
        }else
        {
            NSDate *now=[NSDate dateWithTimeIntervalSinceNow:0];
            if ([now compare:over] == NSOrderedDescending )
            {
                break;
            }
        }
    }
    NSString *fullStr=[NSString stringWithString:readStr];
    [self attachLogFileWithTitle:[self className]
                        withDate:[Utility getTimeBy24hr]
                     withMessage:[NSString stringWithFormat:@"READ: %@",fullStr]];
    [readStr release];
    return STM8TIMEOUT;
}

-(int)getCurSec
{
    NSCalendar *cal=[[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDate *now=[NSDate date];
    NSDateComponents *comps=[cal components:NSSecondCalendarUnit fromDate:now];
    int second=(int)[comps second];
    [cal release];
    return second;
}

-(BOOL)checkIsTimeOut
{
    isQueryTimeOut=FALSE;
    int endSec=[self getCurSec];
    int value=0;
    
    if (endSec>=startSec)
        value=endSec-startSec;
    else
        value=endSec+60-startSec;
    
    if (value>=READ_TIMEOUT)
    {
        isQueryTimeOut=TRUE;
        NSLog(@"relay read from uart timeout!");
        return TRUE;
    }
    return FALSE;
}


-(BOOL)queryByCommand:(NSString *)cmd;
{
    if([self writeToComPort:cmd])
        return [self readFromComPort];
    NSLog(@"relay query fail");
    return FALSE;
}



#pragma mark STM8 GEN
-(void)DEMO_GEN
{
    NSLog(@"ver => %@", [self queryByCmd:@"ver"]);
    NSLog(@"project => %@", [self queryByCmd:@"project"]);
    NSLog(@"adc_s => %@", [self queryByCmd:@"adc_s"]);
    NSLog(@"adc_s v => %@", [self queryByCmd:@"adc_s v"]);
    NSLog(@"iic_s => %@", [self queryByCmd:@"iic_s"]);
    NSLog(@"set C 6 1 => %@", [self queryByCmd:@"set C 6 1"]);
    NSLog(@"get C 6 => %@", [self queryByCmd:@"get C 6"]);
    NSLog(@"set C 6 0 => %@", [self queryByCmd:@"set C 6 0"]);
    NSLog(@"get C 6 => %@", [self queryByCmd:@"get C 6"]);
    NSLog(@"adc 3 => %d", [self ADC:3]);
    NSLog(@"rel_on 1 => %d", [self relayON:1]);
    NSLog(@"rel_off 1 => %d", [self relayOFF:1]);
    NSLog(@"rel_on => %d", [self relayON]);
    NSLog(@"rel_off => %d", [self relayOFF]);
}

-(int)ADC:(int)ch //ch=2~4 (unit=mv)
{
    NSString *response=[self queryByCmd:[NSString stringWithFormat:@"adc %d v",ch]];
    
    if ([response rangeOfString:STM8TIMEOUT].location == NSNotFound)
    return [response intValue];
    return -1;
}

-(BOOL)relayON:(int)ch
{
    if ([[self queryByCmd:[NSString stringWithFormat:@"rel_on %d",ch]] rangeOfString:STM8TIMEOUT].location == NSNotFound)
    {
        usleep(DELAY_TIME);
        return TRUE;
    }
    return FALSE;
}

-(BOOL)relayOFF:(int)ch
{
    if ([[self queryByCmd:[NSString stringWithFormat:@"rel_off %d",ch]] rangeOfString:STM8TIMEOUT].location == NSNotFound)
    {
        usleep(DELAY_TIME);
        return TRUE;
    }
    return FALSE;
}
-(BOOL)relayON
{
    if ([[self queryByCmd:@"rel_on"] rangeOfString:STM8TIMEOUT].location == NSNotFound)
    {
        usleep(DELAY_TIME);
        return TRUE;
    }
    return FALSE;
}

-(BOOL)relayOFF
{
    if ([[self queryByCmd:@"rel_off"] rangeOfString:STM8TIMEOUT].location == NSNotFound)
    {
        usleep(DELAY_TIME);
        return TRUE;
    }
    return FALSE;
}

#pragma mark STM8 FCT
-(void)DEMO_FCT
{
    NSLog(@"ver => %@", [self queryByCmd:@"ver"]);
    NSLog(@"project => %@", [self queryByCmd:@"project"]);
    NSLog(@"relayONByChannel:1=> %d", [self relayON_11ByCh:1]);
    sleep(1);
    NSLog(@"relayONByChannel:11=> %d", [self relayON_11ByCh:12]);
    sleep(1);
    NSLog(@"relayOFFByChannel:11=> %d", [self relayOFFByChannel:12]);
    sleep(1);
    NSLog(@"relayOFF=> %d", [self relayOFF_First11]);
    sleep(1);
}

-(BOOL)relayON_TenByCh:(int) ch
{
    NSString *cmd = @"";
    if (ch >= 1 && ch <= 10)
    cmd = [NSString stringWithFormat:@"rel_ten %d",ch];
    else
    cmd = [NSString stringWithFormat:@"rel_on %d",ch]; // only 11 12 13 14
    
    if ([[self queryByCmd:cmd] rangeOfString:STM8TIMEOUT].location == NSNotFound)
    {
        usleep(DELAY_TIME);
        return TRUE;
    }
    return FALSE;
}

-(BOOL)relayON_11ByCh:(int) ch
{
    NSString *cmd = @"";
    if (ch >= 1 && ch <= 11)
    cmd = [NSString stringWithFormat:@"rel_11 %d",ch];
    else
    cmd = [NSString stringWithFormat:@"rel_on %d",ch]; // only 12 13 14
    
    if ([[self queryByCmd:cmd] rangeOfString:STM8TIMEOUT].location == NSNotFound)
    {
        usleep(DELAY_TIME);
        return TRUE;
    }
    return FALSE;
}

-(BOOL)relayON_12ByCh:(int) ch
{
    NSString *cmd = @"";
    if (ch >= 1 && ch <= 12)
    cmd = [NSString stringWithFormat:@"rel_12 %d",ch];
    else
    cmd = [NSString stringWithFormat:@"rel_on %d",ch]; // only 13 14
    
    if ([[self queryByCmd:cmd] rangeOfString:STM8TIMEOUT].location == NSNotFound)
    {
        usleep(DELAY_TIME);
        return TRUE;
    }
    return FALSE;
}

-(BOOL)relayON_13ByCh:(int) ch
{
    NSString *cmd = @"";
    if (ch >= 1 && ch <= 13)
    cmd = [NSString stringWithFormat:@"rel_13 %d",ch];
    else
    cmd = [NSString stringWithFormat:@"rel_on %d",ch];  // only 14
    
    if ([[self queryByCmd:cmd] rangeOfString:STM8TIMEOUT].location == NSNotFound)
    {
        usleep(DELAY_TIME);
        return TRUE;
    }
    return FALSE;
}

-(BOOL)relayON_14ByCh:(int) ch
{
    NSString *cmd = @"";
    if (ch != 0)
    cmd = [NSString stringWithFormat:@"rel_14 %d",ch];
    
    if ([[self queryByCmd:cmd] rangeOfString:STM8TIMEOUT].location == NSNotFound)
    {
        usleep(DELAY_TIME);
        return TRUE;
    }
    return FALSE;
}


-(BOOL)relayOFF_FirstTen
{
    if ([[self queryByCmd:@"rel_ten 0"] rangeOfString:STM8TIMEOUT].location == NSNotFound)
    {
        usleep(DELAY_TIME);
        return TRUE;
    }
    return FALSE;
}
-(BOOL)relayOFF_First11
{
    if ([[self queryByCmd:@"rel_11 0"] rangeOfString:STM8TIMEOUT].location == NSNotFound)
    {
        usleep(DELAY_TIME);
        return TRUE;
    }
    return FALSE;
}
-(BOOL)relayOFF_First12
{
    if ([[self queryByCmd:@"rel_12 0"] rangeOfString:STM8TIMEOUT].location == NSNotFound)
    {
        usleep(DELAY_TIME);
        return TRUE;
    }
    return FALSE;
}
-(BOOL)relayOFF_First13
{
    if ([[self queryByCmd:@"rel_13 0"] rangeOfString:STM8TIMEOUT].location == NSNotFound)
    {
        usleep(DELAY_TIME);
        return TRUE;
    }
    return FALSE;
}
-(BOOL)relayOFF_First14
{
    if ([[self queryByCmd:@"rel_14 0"] rangeOfString:STM8TIMEOUT].location == NSNotFound)
    {
        usleep(DELAY_TIME);
        return TRUE;
    }
    return FALSE;
}
-(BOOL)relayOFFByChannel:(int) ch
{
    NSString *cmd = [NSString stringWithFormat:@"rel_off %d",ch];
    if ([[self queryByCmd:cmd] rangeOfString:STM8TIMEOUT].location == NSNotFound)
    {
        usleep(DELAY_TIME);
        return TRUE;
    }
    return FALSE;
}

-(BOOL)relayAll_OFF
{
    if ([[self queryByCmd:@"rel_off"] rangeOfString:STM8TIMEOUT].location == NSNotFound)
    {
        usleep(DELAY_TIME);
        return TRUE;
    }
    return FALSE;
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
