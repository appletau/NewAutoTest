//
//  Stream.m
//  autoTest
//
//  Created by may on 26/05/2017.
//  Copyright © 2017 TOM. All rights reserved.
//

#import "Stream.h"
#define BUFF_SIZE 512
@implementation Stream
@synthesize isReady;

-(void)DEMO
{
    NSLog(@"%d",[self write:@"test string 1"]);
    sleep(1); NSLog(@"%@",[self read]);
    NSLog(@"%d",[self write:@"test string 2"]);
    sleep(1); NSLog(@"%@",[self read]);
    
    char bytes1[5]={'a','b','c','d','e'};
    NSLog(@"%d",[self writeBytes:[NSData dataWithBytes:bytes1 length:sizeof(bytes1)]]);
    sleep(1); NSLog(@"%@",[self converBytesToHexStr:[self readBytes]]);
    
    char bytes2[6]={0x54,0x4F,0x4D,0x54,0x4F,0x4D};
    NSLog(@"%d",[self writeBytes:[NSData dataWithBytes:bytes2 length:sizeof(bytes2)]]);
    sleep(1);   for(int i=0;i<sizeof(bytes2);i++)  printf("0X%02X ",[self getOneByte]);
    
    NSLog(@"%@",[self queryRawDataByCmd:@"cmd" strWaited:@":-)" retry:5 timeout:3]);
    NSLog(@"%@",[self queryRawDataByCmd:@"cmd\r\n:-)" strWaited:@":-)" retry:5 timeout:3]);
}

-(id)init:(NSString *)path
{
    if(self=[super init])
    {
        [self open:path timeout:3];
    }
    return self;
}

-(id)initWithArg:(NSDictionary *)dic
{
    id tmp=nil;
    tmp=[self init: [dic objectForKey:@"PATH"]];
    return tmp;
}

-(void)dealloc
{
    [self close];
    [readStr release];
    [readBytes release];
    [super dealloc];
}

-(BOOL)open:(NSString *)path timeout:(int)sec
{
    [self openAction:path];
    NSDate *over=[NSDate dateWithTimeIntervalSinceNow:sec];
    while (![self isReady])
    {
        usleep(500000);
        printf(".");
        if ([[NSDate dateWithTimeIntervalSinceNow:0] compare:over]==NSOrderedDescending)
        {
            [self close];
            return NO;
        }
    }
    return isReady;
}
-(void)openAction:(NSString *)path
{
    isReady=false;
    readBytes=[[NSMutableData alloc] init];
    readStr=[[NSMutableString alloc] initWithString:@""];
    
    dispatch_queue_t queue=dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0);
    dispatch_async(queue,^{
        iStream=[[NSInputStream alloc] initWithFileAtPath:path];
        [iStream setDelegate:self];
        usedLoop=[NSRunLoop currentRunLoop];;
        [iStream scheduleInRunLoop:usedLoop forMode:NSDefaultRunLoopMode];
        [iStream open];
        oStream=[[NSOutputStream alloc] initToFileAtPath:path append:YES];
        [oStream open];
        [[NSRunLoop currentRunLoop] run];//note: this method never returns, so it must be THE LAST LINE of your dispatch
    });
}

-(void)close
{
    if(iStream!=nil)
    {
        [iStream close];
        [iStream removeFromRunLoop:usedLoop forMode:NSDefaultRunLoopMode];
        iStream=nil;
        [iStream release];
    }
    if(oStream!=nil)
    {
        [oStream close];
        oStream=nil;
        [oStream release];
    }
}

#pragma mark NSStreamDelegate
-(void)stream:(NSStream *)stream handleEvent:(NSStreamEvent)eventCode//the delegate is only for read
{
    switch (eventCode)
    {
        case NSStreamEventHasBytesAvailable:
        {
            uint8_t buf[BUFF_SIZE];
            NSUInteger numBytesRead=[(NSInputStream *)stream read:buf maxLength:BUFF_SIZE];
            
            if (numBytesRead>0)       [self didReceiveData:[NSData dataWithBytes:buf length:numBytesRead]];
            else if (numBytesRead==0) NSLog(@"End of stream reached");
            else                        NSLog(@"Read error occurred");
            break;
        }
        case NSStreamEventErrorOccurred:
        {
            NSError * error=[stream streamError];
            NSLog(@"Error Occurred:%@\t%ld",error.localizedDescription,error.code);
            [self close];
            break;
        }
        case NSStreamEventEndEncountered:
        {
            NSLog(@"End Encountered");
            [self close];
            break;
        }
        case NSStreamEventOpenCompleted:
        {
            NSLog(@"Open Completed");
            isReady=true;
            break;
        }
        case NSStreamEventNone:
        {
            NSLog(@"None");
            break;
        }
        default:
            break;
    }
}

-(void)didReceiveData:(NSData *)data
{
    NSString *encodeStr=[[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
    @synchronized (self)
    {
        [readBytes appendData:data];
        [readStr appendString:encodeStr];
    }
    [encodeStr release];
}


#pragma mark Basic IO Operation
-(NSString*)read
{
    NSString *temp=@"";
    @synchronized (self)
    {
        if([readStr length]>0)
        {
            [self attachLogFileWithTitle:[self className]
                                withDate:[Utility getTimeBy24hr]
                             withMessage:[NSString stringWithFormat:@"READ: %@",readStr]];
            temp=[NSString stringWithFormat:@"%@",readStr];
            [readStr setString:@""];
            [readBytes setLength:0];
        }
    }
    return temp;
}

-(BOOL)write:(NSString*)mesg
{
    if(!isReady) return NO;
    [self attachLogFileWithTitle:[self className]
                        withDate:[Utility getTimeBy24hr]
                     withMessage:[NSString stringWithFormat:@"SEND: %@",mesg]];
    NSUInteger len=[(NSOutputStream*)oStream write:(uint8_t*)[mesg UTF8String] maxLength:[mesg length]];
    return ([mesg length]==len)?YES:NO;
}

-(NSData*)readBytes
{
    NSData *temp=nil;
    @synchronized (self)
    {
        if([readBytes length]>0)
        {
            [self attachLogFileWithTitle:[self className]
                                withDate:[Utility getTimeBy24hr]
                             withMessage:[NSString stringWithFormat:@"READ_BYTES: %@",[self converBytesToHexStr:readBytes]]];
            temp=[NSData dataWithData:readBytes];
            [readBytes setLength:0];
            [readStr setString:@""];
        }
    }
    return temp;
}

-(BOOL)writeBytes:(NSData*)data
{
    if(!isReady) return NO;
    [self attachLogFileWithTitle:[self className]
                        withDate:[Utility getTimeBy24hr]
                     withMessage:[NSString stringWithFormat:@"SEND_BYTES: %@",[self converBytesToHexStr:data]]];
    NSUInteger len=[(NSOutputStream*)oStream write:(uint8_t*)[data bytes] maxLength:[data length]];
    return ([data length]==len)?YES:NO;
}

-(NSString*)converBytesToHexStr:(NSData*)data
{
    NSInteger len=data.length;
    NSMutableArray *temp=[[[NSMutableArray alloc] initWithCapacity:len] autorelease];
    const uint8_t *buf=data.bytes;

    for (NSInteger i=0; i<len; ++i)
        [temp addObject:[NSString stringWithFormat:@"0X%02X",buf[i]]];
    
    return [temp componentsJoinedByString:@" "];
}

-(NSString*)queryRawDataByCmd:(NSString *)cmd strWaited:(NSString*)symbol retry:(int)times timeout:(int)sec
{
    NSMutableString *response=[[[NSMutableString alloc] init] autorelease];
    
    do{ [response setString:[self read]]; } while ([response length]>0);//Empty the buffer
    
    for(int i=0; i<times; i++)
    {
        [response setString:@""];
        NSDate *over=[NSDate dateWithTimeIntervalSinceNow:sec];
        [self write:[NSString stringWithFormat:@"%@",cmd]];
    
        while(1)
        {
            usleep(10000);
            [response appendString:[self read]];
            
            if ([response rangeOfString:symbol].location!=NSNotFound)
                return response;
            else if ([[NSDate dateWithTimeIntervalSinceNow:0] compare:over]==NSOrderedDescending)
                break;
        }
    }
    return response;
}

-(uint8_t)getOneByte
{
    uint8_t oneByte=0;
    @synchronized (self)
    {
        if([readBytes length]>0)
        {
            const uint8_t *buf=readBytes.bytes;
            oneByte=buf[0];
            [readBytes replaceBytesInRange:NSMakeRange(0, 1) withBytes:NULL length:0];
            [readStr deleteCharactersInRange:NSMakeRange(0, 1)];
        }
    }
    return oneByte;
}
@end
