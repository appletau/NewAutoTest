//
//  SC18IM700.m
//  autoTest
//
//  Created by TOM on 2014/10/7.
//  Copyright (c) 2014年 TOM. All rights reserved.
//

#import "SC18IM700.h"
#import "Utility.h"
#import "RegxFunc.h"

#define SIZE        1024
#define START_BYTE  0X53
#define STOP_BYTE   0X50
#define REG_W_BYTE  0X57
#define REG_R_BYTE  0X52
#define GPIO_W_BYTE 0X4F
#define GPIO_R_BYTE 0X49

#define IICREAD_ERRORCODE  -1
#define IICWRITE_ERRORCODE  -2
#define IICREADEMPTY_ERRORCODE  -3

@implementation SC18IM700
@synthesize isReady;
@synthesize PathKeyWord;

-(void)DEMO
{
    NSMutableString *read = [[NSMutableString alloc] initWithString:@""];
    [self IICwriteAndRead:@"0x11" iicData:@"00" iicReadLen:32 outData:read];
    NSLog(@"read 0x11 data = %@",read);
    [self IICwriteAndRead:@"0x11" iicData:@"00" iicReadLen:32 outData:read ignore:YES];
    NSLog(@"read 0x11 data = %@",read);
    [read release];
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
    NSArray *tmp = [uart uartList];
    for (int i = 0; i < [tmp count]; i++)
    {
        if ([RegxFunc isMatchByRegx:[tmp objectAtIndex:i] validRegx:PathKeyWord])
        {
            return [tmp objectAtIndex:i];
        }
    }
    return @"EMPTY";
}

-(NSArray *)scanUART
{
    return [uart uartList];
}

-(BOOL)checkUARTOpening
{
    isReady = [uart isUartOpening];
    return isReady;
}

#pragma mark IIC Access
-(bool)IICwrite:(NSString*)chipAddr iicData:(NSString*)data
{
    if ([chipAddr length]>0 && [data length]>0 && isReady)
    {
        uint8_t seq[SIZE] = {0};
        NSArray *dataSet=[data componentsSeparatedByString:@" "];
        int dataLen=(int)[dataSet count];
        
        if (dataLen>0)
        {
            const int minLen=4;
            const int dataStartIdx=3;
            
            seq[0]=START_BYTE;
            seq[1]=[Utility convertHexStrToInt:chipAddr]<<1;
            seq[2]=dataLen;
            
            for (int i=0;i<dataLen;i++)
                seq[i+dataStartIdx]=[Utility convertHexStrToInt:[dataSet objectAtIndex:i]];
            
            int len=dataLen+minLen;
            seq[len-1]=STOP_BYTE;
            
            [uart TXbyBytes:seq length:len];
        }
        
        NSMutableString *read=[[[NSMutableString alloc] init] autorelease];
        [self REGread:@"0x0A" outData:read];
        
        if(![read isEqualToString:@"F0"])
        {
            NSLog(@"chipAddr=%@\tiicData:%@ state:%@------>iic error",chipAddr,data,read);
            return false;
        }
        
        return  true;
    }
    return false;
}

-(int)IICread:(NSString*)chipAddr iicReadLen:(int)len outData:(NSMutableString*)opt
{
    if (len>0)
    {
        const int maxSize=4;
        uint8_t seq[maxSize]={0};
        
        seq[0]=START_BYTE;
        seq[1]=([Utility convertHexStrToInt:chipAddr]<<1)+1;
        seq[2]=len;
        seq[3]=STOP_BYTE;
        
        if([uart TXbyBytes:seq length:maxSize])
        {
            //if([chipAddr isEqualToString:@"0x35"])
            usleep(50000);
            
            NSData *readData=[uart RXbyBytes:len];
            if (readData!=nil)
            {
                [opt setString:[self bytesToStr:readData]];
                return (int)[readData length];
            }
        }
        return IICREAD_ERRORCODE;
    }
    return IICREAD_ERRORCODE;
}

-(int)IICwriteAndRead:(NSString*)chipAddr iicData:(NSString*)data iicReadLen:(int)len outData:(NSMutableString*)opt
{
    [self IICwrite:chipAddr iicData:data];
    return [self IICread:chipAddr iicReadLen:len outData:opt];
}

#pragma mark IIC Ignor Case Access
-(bool)IICwrite:(NSString*)chipAddr iicData:(NSString*)data ignore:(BOOL)ignoreState
{
    if ([chipAddr length]>0 && [data length]>0 && isReady)
    {
        uint8_t seq[SIZE] = {0};
        NSArray *dataSet=[data componentsSeparatedByString:@" "];
        int dataLen=(int)[dataSet count];
        
        if (dataLen>0)
        {
            const int minLen=4;
            const int dataStartIdx=3;
            
            seq[0]=START_BYTE;
            seq[1]=[Utility convertHexStrToInt:chipAddr]<<1;
            seq[2]=dataLen;
            
            for (int i=0;i<dataLen;i++)
                seq[i+dataStartIdx]=[Utility convertHexStrToInt:[dataSet objectAtIndex:i]];
            
            int len=dataLen+minLen;
            seq[len-1]=STOP_BYTE;
            
            [uart TXbyBytes:seq length:len];
        }
        
        NSMutableString *read=[[[NSMutableString alloc] init] autorelease] ;
        [self REGread:@"0x0A" outData:read];
        
        if((!ignoreState) && ![read isEqualToString:@"F0"])
        {
            NSString *errorInfo=[NSString stringWithFormat:@"chipAddr=%@\tiicData:%@ state:%@------>iic write error",chipAddr,data,read];
            NSLog(@"%@",errorInfo);
//            [self displayMsg:errorInfo];
//            exit(0);
            return false;
        }
        else
            usleep(1000);
        
        return  true;
    }
    return false;
}

-(int)IICread:(NSString*)chipAddr iicReadLen:(int)len outData:(NSMutableString*)opt ignore:(BOOL)ignoreState
{
    if (len>0)
    {
        const int maxSize=4;
        uint8_t seq[maxSize] = {0};
        
        seq[0]=START_BYTE;
        seq[1]=([Utility convertHexStrToInt:chipAddr]<<1)+1;
        seq[2]=len;
        seq[3]=STOP_BYTE;
        
        if([uart TXbyBytes:seq length:maxSize])
        {
            //if([chipAddr isEqualToString:@"0x35"])
            usleep(50000);
            
            NSData *readData=[uart RXbyBytes:len];
            if (readData!=nil)
            {
                [opt setString:[self bytesToStr:readData]];
                
                if ((!ignoreState) && [readData length]!=len)
                {
                    NSString *errorInfo=[NSString stringWithFormat:@"chipAddr=%@\tlen:%d------>iic read error",chipAddr,len];
                    NSLog(@"%@",errorInfo);
                  //  [self displayMsg:errorInfo];
                  //  exit(0);
                }
                
                return (int)[readData length];
            }
        }
        return IICREAD_ERRORCODE;
    }
    return IICREAD_ERRORCODE;
}

-(int)IICwriteAndRead:(NSString*)chipAddr iicData:(NSString*)data iicReadLen:(int)len outData:(NSMutableString*)opt ignore:(BOOL)ignoreState
{
    if ([self IICwrite:chipAddr iicData:data ignore:ignoreState]) {
        int result = [self IICread:chipAddr iicReadLen:len outData:opt ignore:ignoreState];
        if (result == IICREAD_ERRORCODE) {
            if  (!ignoreState)
                NSLog(@"AMP ADDR %@ IICREAD_ERROR",chipAddr);
            return IICREAD_ERRORCODE;
        }
        else if ([opt length] == 0) {
                NSLog(@"AMP ADDR %@ IICREAD EMPTY DATA",chipAddr);
                return IICREADEMPTY_ERRORCODE;
        }
        return result;
    }
    if  (!ignoreState)
        NSLog(@"AMP ADDR %@ IICWRITE_ERROR",chipAddr);
    return IICWRITE_ERRORCODE;
}


#pragma mark IIC Ignor Case Access with Delay
-(bool)IICwrite:(NSString*)chipAddr
        iicData:(NSString*)data
         ignore:(BOOL)ignoreState
      withDelay:(int)microSeconds
{
    if ([chipAddr length]>0 && [data length]>0 && isReady)
    {
        uint8_t seq[SIZE] = {0};
        NSArray *dataSet=[data componentsSeparatedByString:@" "];
        int dataLen=(int)[dataSet count];
        
        if (dataLen>0)
        {
            const int minLen=4;
            const int dataStartIdx=3;
            
            seq[0]=START_BYTE;
            seq[1]=[Utility convertHexStrToInt:chipAddr]<<1;
            seq[2]=dataLen;
            
            for (int i=0;i<dataLen;i++)
                seq[i+dataStartIdx]=[Utility convertHexStrToInt:[dataSet objectAtIndex:i]];
            
            int len=dataLen+minLen;
            seq[len-1]=STOP_BYTE;
            
            [uart TXbyBytes:seq length:len];
            usleep(microSeconds);
        }
        
        NSMutableString *read=[[[NSMutableString alloc] init] autorelease];
        [self REGread:@"0x0A" outData:read];
        
        if((!ignoreState) && ![read isEqualToString:@"F0"])
        {
            NSString *errorInfo=[NSString stringWithFormat:@"chipAddr=%@\tiicData:%@ state:%@------>iic write error",chipAddr,data,read];
            NSLog(@"%@",errorInfo);
            //            [self displayMsg:errorInfo];
            //            exit(0);
            return false;
        }
        
        return  true;
    }
    return false;
}

-(int)IICread:(NSString*)chipAddr
   iicReadLen:(int)len
      outData:(NSMutableString*)opt
       ignore:(BOOL)ignoreState
    withDelay:(int)microSeconds
{
    if (len>0)
    {
        const int maxSize=4;
        uint8_t seq[maxSize]={0};
        
        seq[0]=START_BYTE;
        seq[1]=([Utility convertHexStrToInt:chipAddr]<<1)+1;
        seq[2]=len;
        seq[3]=STOP_BYTE;
        
        if([uart TXbyBytes:seq length:maxSize])
        {
            //if([chipAddr isEqualToString:@"0x35"])
            usleep(microSeconds);
            NSData *readData=[uart RXbyBytes:len];
            if (readData!=nil)
            {
                [opt setString:[self bytesToStr:readData]];
                
                if ((!ignoreState) && [readData length]!=len)
                {
                    NSString *errorInfo=[NSString stringWithFormat:@"chipAddr=%@\tlen:%d------>iic read error",chipAddr,len];
                    NSLog(@"%@",errorInfo);
                    //  [self displayMsg:errorInfo];
                    //  exit(0);
                }
                
                return (int)[readData length];
            }
        }
        return IICREAD_ERRORCODE;
    }
    return IICREAD_ERRORCODE;
}

-(int)IICwriteAndRead:(NSString*)chipAddr
              iicData:(NSString*)data
           iicReadLen:(int)len
              outData:(NSMutableString*)opt
               ignore:(BOOL)ignoreState
            withDelay:(int)microSeconds
{
    if ([self IICwrite:chipAddr iicData:data ignore:ignoreState withDelay:microSeconds]) {
        int result = [self IICread:chipAddr iicReadLen:len outData:opt ignore:ignoreState withDelay:microSeconds];
        if (result == IICREAD_ERRORCODE)
            return IICREAD_ERRORCODE;
        else if ([opt length] == 0)
            return IICREADEMPTY_ERRORCODE;
        
        return result;
    }
    
    return IICWRITE_ERRORCODE;
}

#pragma mark REG Access
-(void)REGwrite:(NSString*)regAndData
{
    if ([regAndData length]>0)
    {
        uint8_t seq[SIZE] = {0} ;
        NSArray *allData=[regAndData componentsSeparatedByString:@" "];
        int dataLen=(int)[allData count];
        
        if (dataLen>0)
        {
            const int minLen=2;
            const int dataStartIdx=1;
            
            seq[0]=REG_W_BYTE;
            
            for (int i=0;i<dataLen;i++)
            seq[i+dataStartIdx]=[Utility convertHexStrToInt:[allData objectAtIndex:i]];
            
            seq[dataLen+minLen-1]=STOP_BYTE;
            
            [uart TXbyBytes:seq length:dataLen+minLen];
        }
    }
}

-(int)REGread:(NSString*)reg outData:(NSMutableString*)opt
{
    if ([reg length]>0)
    {
        uint8_t seq[SIZE] = {0};
        NSArray *regSet=[reg componentsSeparatedByString:@" "];
        int dataLen=(int)[regSet count];
        
        if (dataLen>0)
        {
            const int minLen=2;
            const int dataStartIdx=1;
            
            seq[0]=REG_R_BYTE;
            
            for (int i=0;i<dataLen;i++)
            seq[i+dataStartIdx]=[Utility convertHexStrToInt:[regSet objectAtIndex:i]];
            
            int len=dataLen+minLen;
            seq[len-1]=STOP_BYTE;
            
            if([uart TXbyBytes:seq length:len])
            {
                NSData *readData=[uart RXbyBytes:len];
                
                if (readData!=nil)
                {
                    [opt setString:[self bytesToStr:readData]];
                    return (int)[readData length];
                }
            }
            return -1;
        }
    }
    return -1;
}

-(NSString*)bytesToStr:(NSData *)data
{
    NSMutableString *str=[[NSMutableString alloc] initWithString:@""];
    const unsigned char *bytes = [data bytes];
    
    for (int i=0;i<[data length];i++)
        [str appendFormat:@"%02X ",bytes[i]];
    
    NSString *output=[str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    [str release];
    return output;
}

-(void)close
{
    if (isReady)
    {
        [uart closeComPort];
        isReady = false;
    }
}

-(void)displayMsg:(NSString *)text
{
    [self performSelectorOnMainThread:@selector(msgBox:) withObject:text waitUntilDone:YES];
}

-(void)msgBox:(NSString *)text
{
    NSAlert *alert=[[NSAlert alloc] init];
    [alert addButtonWithTitle:@"YES"];
    [alert addButtonWithTitle:@"NO"];
    [alert setMessageText:@"Question:"];
    [alert setInformativeText:text];
    [alert setAlertStyle:0];
    [alert setIcon:[NSImage imageNamed:@"Qimg"]];
    [alert runModal];
    [alert release];
}
@end
