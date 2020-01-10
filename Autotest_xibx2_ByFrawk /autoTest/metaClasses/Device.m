//
//  Device.m
//  autoTest
//
//  Created by TOM on 13/4/16.
//  Copyright (c) 2013年 TOM. All rights reserved.
//

#import "Device.h"

#define ENDING_SYMBOL @":-)"
#define DELAYTIME 5000//ORIGINAL 100000 tom
#define ENTERMODE_DELAY 1
#define PACKAGE_HDR_LEN  5
#define MAX_PACKAGE_LEN  255
#define SERIAL_REQ_NOTIFY_HDR_LEN 5
#define RESP_STATUS_OK 0X00

enum DEV_PACKAGE_DEFINE
{
    CMD_BYTE=0,
    LEN_BYTE,
    SEQ_BYTE,
    ST_BYTE,
    DATA_BYTE,
    MIN_PKG_LEN=4,
    MAX_PKG_LEN=0xFF,
    SEQ_NUM=0x01,
    OK_ST=0x00,
    RESP_CMD_CHECK_BYTE=0x80,
    PAYLOAD_START_IDX=DATA_BYTE,
};

enum VALID_PKG_ERROR_CODE
{
    NO_ERROR=0,
    CMD_ERROR=-1,
    SEQ_ERROR=-2,
    STATUS_ERROR=-3,
    CHECKSUM_ERROR=-4,
    ST_PKG_SEQ_NUM_ERROR=-5,
    ST_PKG_SMALL_ERROR=-6,
    ST_PKG_LARGE_ERROR=-7,
    ST_PKG_CK_ERROR=-8,
    ST_PKG_RES_MBZ_1=-9,
    ST_PKG_RES_MBZ_2=-10,
    ST_PKG_CMD_ERROR=-11,
    ST_SOC_NOT_READY_ERROR=-12,
};

enum STATUS_ERROR_BITS
{
    BIT_0=0x01,
    BIT_1=0x02,
    BIT_2=0x04,
    BIT_3=0x08,
    BIT_4=0x10,
    BIT_5=0x20,
    BIT_6=0x40,
    BIT_7=0x80,
};
@implementation Device
@synthesize isReady;
@synthesize seqNumer;
@synthesize PathKeyWord;

-(void)DEMO
{
    [self writeToDevice:@"ver\r"];
    NSLog(@"Device read the ver = %@",[self readFromDevice]);
    NSLog(@"Device query volt = %@",[self queryByCmd:@"volt" strWaited:ENDING_SYMBOL retry:1 timeout:3]);
    NSLog(@"Device Psoc iic write = %@",[self i2cWriteByDiag:@"3" chipAddr:@"0x55" cmd:0x15 Data:@"03" seqNumber:0x01]);
    NSLog(@"Device Psoc iic read = %@",[self i2cReadByDiag:@"3" chipAddr:@"0x55" cmdSent:0x15 len:@"6" seqNumber:0x01]);
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
    [PathKeyWord release];
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
                         withMessage:[NSString stringWithFormat:@"SEND_HEX: {%@}",[self byteToStr:[NSData dataWithBytes:buffer length:len]]]];
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
                         withMessage:[NSString stringWithFormat:@"READ_HEX: {%@}",[self byteToStr:data]]];
        return data;
    }
    return nil;
}

-(NSString*)queryRawDataByCmd:(NSString *)cmd strWaited:(NSString*)symbol retry:(int)times timeout:(int)sec
{
    [uart RX];
    for(int i=0; i<times; i++)
    {
        [self writeToDevice:[NSString stringWithFormat:@"%@",cmd]];
        
        NSDate *over=[NSDate dateWithTimeIntervalSinceNow:sec];
        NSMutableString *response=[[NSMutableString alloc] initWithString:@""];
        
        while(1)
        {
            usleep(1000);//tom
            NSString *echo=[uart RX];
            [response appendString:([echo length]>0)?echo:@""];
            if ([response rangeOfString:symbol].location != NSNotFound)
            {
                NSString *retunStr=[NSString stringWithString:response];
                [self attachLogFileWithTitle:[self className]
                                    withDate:[Utility getTimeBy24hr]
                                 withMessage:[NSString stringWithFormat:@"READ: %@",retunStr]];
                [response release];
                return retunStr;
            }
            else
            {
                NSDate *now=[NSDate dateWithTimeIntervalSinceNow:0];
                if ([now compare:over] == NSOrderedDescending )
                    break;
            }
            
        }
        NSString *retunStr=[NSString stringWithString:response];
        [self attachLogFileWithTitle:[self className]
                            withDate:[Utility getTimeBy24hr]
                         withMessage:[NSString stringWithFormat:@"READ: %@",retunStr]];
        [response release];
    }
    return nil;
}

-(NSString*)queryByCmd:(NSString *)cmd strWaited:(NSString*)symbol retry:(int)times timeout:(int)sec
{
    [uart RX];
    for(int i=0; i<times; i++)
    {
        [self writeToDevice:[NSString stringWithFormat:@"%@",cmd]];
        
        NSDate *over=[NSDate dateWithTimeIntervalSinceNow:sec];
        NSMutableString *response=[[NSMutableString alloc] initWithString:@""];
        
        while(1)
        {
            usleep(1000);//tom
            NSString *echo=[uart RX];
            [response appendString:([echo length]>0)?echo:@""];
            if ([response rangeOfString:symbol].location != NSNotFound)
            {
                NSString *retunStr=[NSString stringWithString:response];
                [self attachLogFileWithTitle:[self className]
                                    withDate:[Utility getTimeBy24hr]
                                 withMessage:[NSString stringWithFormat:@"READ: %@",[Utility cleanStr:retunStr]]];
                [response release];
                return [Utility cleanStr:retunStr];
            }
            else
            {
                NSDate *now=[NSDate dateWithTimeIntervalSinceNow:0];
                if ([now compare:over] == NSOrderedDescending)
                    break;
            }
        }
        NSString *retunStr=[NSString stringWithString:response];
        [self attachLogFileWithTitle:[self className]
                            withDate:[Utility getTimeBy24hr]
                         withMessage:[NSString stringWithFormat:@"READ: %@",retunStr]];
        [response release];
    }
    return nil;
}

# pragma mark send IOS command
-(NSString*)queryByIOS_Cmd:(NSString *)iosCmd strWaited:(NSString*)keyWord retry:(int)times timeout:(NSTimeInterval)sec
{
    [self attachLogFileWithTitle:[self className]
                        withDate:[Utility getTimeBy24hr]
                     withMessage:[NSString stringWithFormat:@"SEND:%@",iosCmd]];
    
    [self readFromDevice];
    NSMutableString *resp=[NSMutableString stringWithString:@""];
    
    for (int re=0; re<times; re++)
    {
        for (int ch=0; ch<[iosCmd length]; ch++)
        {
            @try
            {
                if([uart TX:[iosCmd substringWithRange:NSMakeRange(ch,1)]])
                {
                    usleep(50000);
                }
            }
            @catch(NSException *exception)
            {
                NSRunAlertPanel(@"Error:",[NSString stringWithFormat:@"%@",exception],@"YES", nil, nil, nil);
                NSLog(@"%@",exception);
            }
        }
        
        [resp setString:@""];
        NSDate *timeout=[NSDate dateWithTimeIntervalSinceNow:sec];
        
        while ([[NSDate dateWithTimeIntervalSinceNow:0] compare:timeout] == NSOrderedAscending)
        {
            usleep(10000);
            NSString *echo=[uart RX];
            [resp appendString:([echo length]>0)?echo:@""];
            
            
            if ([resp rangeOfString:keyWord].location != NSNotFound)
            {
                [self attachLogFileWithTitle:[self className]
                                    withDate:[Utility getTimeBy24hr]
                                 withMessage:[NSString stringWithFormat:@"READ: %@",(NSString *)resp]];
                return (NSString *)resp;
            }
        }
        [self attachLogFileWithTitle:[self className]
                            withDate:[Utility getTimeBy24hr]
                         withMessage:[NSString stringWithFormat:@"READ: %@",(NSString *)resp]];
    }
    return [NSString stringWithFormat:@"queryByIOS_Cmd Timeout (Receive:%@)",resp];
}

-(void)close
{
    if (isReady)
    {
        [uart closeComPort];
        isReady = [uart isUartOpening];
    }
}

// ============== control bit ==============
#pragma mark control bit

- (BOOL)setRTC
{
    NSDate *localDateTime=[NSDate date];
    NSDateFormatter *dateTimeFormat=[[[NSDateFormatter alloc]init] autorelease];
    dateTimeFormat.dateFormat=@"yyyyMMddHHmmss";
    NSString *dateStr=[dateTimeFormat stringFromDate:localDateTime];
    
    NSString *readString = [self queryByCmd:[NSString stringWithFormat:@"rtc --set %@\r",dateStr] strWaited:ENDING_SYMBOL retry:1 timeout:5];
    return ([readString length] > 0)?YES:NO;
    
}

-(NSString *)getRTC
{
    NSString *readString = [self queryByCmd:@"rtc --get\r" strWaited:ENDING_SYMBOL retry:1 timeout:3];
    if ([readString length] == 0)
        return @"";
    
    NSMutableArray *msgArr = [RegxFunc regxByText:readString textRegx:@"(\\d+).(\\d+).(\\d+).(\\d+).(\\d+).(\\d+)"];
    return [NSString stringWithFormat:@"%@",msgArr[0]];
}

-(unsigned char *)getNonce
{
    [self writeToDevice:@"getnonce\r"];
    
    NSData *response = [uart RXbyBytes:100];
    if ([response length] > 0)
    {
        unsigned char newLine[2]={0x0a,0x0d};
        NSRange range=[response rangeOfData:[NSData dataWithBytes:newLine length:2] options:0 range:NSMakeRange(0, [response length])];
        
        if(range.location!=NSNotFound)
        {
            NSData *nonce=[response subdataWithRange:NSMakeRange(range.location+2, 20)];
            
            // save nonce log
            [self attachLogFileWithTitle:[self className]
                                withDate:[Utility getTimeBy24hr]
                             withMessage:[NSString stringWithFormat:@"READ_HEX:{%@}",[self byteToStr:nonce]]];
            
            return (unsigned char *)[nonce bytes];
        }
    }
    return nil;
}

- (unsigned char *)getSHA1:(unsigned char*)secretKey andNonce:(unsigned char*)nonce
{
    return [ControlBits getSHA1ByKey:secretKey andNonce:nonce];
}

// ============== Enter diags ==============
#pragma mark Enter diags

-(BOOL)enterDiags
{
    return [self queryByCmd:@"diags\r" strWaited:ENDING_SYMBOL retry:1 timeout:10]==nil? FALSE: TRUE;
}

// ============== Enter/EXIT passthrough ==============
#pragma mark Enter passthrough

-(BOOL)enterPassThrough
{
    [self queryByCmd:@"\r" strWaited:ENDING_SYMBOL retry:1 timeout:3];//clean buffer
    NSString *resp=[self queryByCmd:@"uartpassthrough --uart 8 --baud 115200 --type 2wire --parity even\r" strWaited:@"UART passthrough" retry:1 timeout:ENTERMODE_DELAY];
    usleep(5000);
    return resp==nil? FALSE: TRUE;
}

-(void)exitPassThrough
{
    [self writeToDevice:@"EXIT"];
    usleep(1000);
    NSLog(@"exit PassThru=>%@",[self readFromDevice]);//clearn buffer
    [self queryByCmd:@"\r" strWaited:ENDING_SYMBOL retry:1 timeout:3];  // clear UART buffer
    
}


// ============== Harness Package To MCU ==============

#pragma mark Write Harness Package To MCU
-(NSString*)SendHarnessMessageToMCU:(NSString*)data seqNumer:(uint8_t)seqNum
{
    NSData *ascData=[data dataUsingEncoding:NSASCIIStringEncoding];
    return [self SendMessageToMCU:@"5F" Data:[self byteToStr:ascData] seqNumer:seqNum];//5F is HARNESS Cmd code
}

#pragma mark Read Harness Response From MCU
-(NSString*)GetHarnessResponseFromMCU:(uint8_t)seqNum
{
    NSData *resp=[self GetResponseFromMCU:@"5F" seqNumer:seqNum];
    uint8_t len=0;
    uint8_t temp[MAX_PACKAGE_LEN]={0};
    [resp getBytes:&len range:NSMakeRange(1, 1)];
    [resp getBytes:temp range:NSMakeRange(6, len)];
    
    NSString* respData = [[[NSString alloc] initWithData:[NSData dataWithBytes:temp length:len] encoding:NSUTF8StringEncoding] autorelease];
    return [Utility cleanStr:respData];
}

// ============== MCU Write/Read ==============

#pragma mark Write To MCU
-(uint8_t)calcChecksum:(uint8_t *)data size:(short)dataSize
{
    uint32_t sum = 0;
    uint32_t i;
    
    for (i=0; i<dataSize; i++)
    {
        sum += (uint8_t )data[i];
    }
    return (~sum + 1) & 0xff;
}
-(NSData*)prepare_sent_table:(uint8_t*)Table_received Table_received_len:(uint8_t)TableRecvLen Converted:(bool*)converted
{
    uint8_t TempTable[MAX_PACKAGE_LEN]={0};
    TempTable[0]= Table_received[0];
    *converted=false;
    short i=0;
    short insertIdx=1;
    
    for (i=1; i<TableRecvLen; i++)
    {
        if(Table_received[i]==0x7D || Table_received[i]==0x7E)
        {
            *converted = true;
            TempTable[insertIdx]=0x7D;
            insertIdx++;
            TempTable[insertIdx]=(Table_received[i] ^ 0x20) &0xff;
            insertIdx++;
        }
        else
        {
            TempTable[insertIdx]=Table_received[i];
            insertIdx++;
        }
    }
    return [NSData dataWithBytes:TempTable length:insertIdx];
}

-(NSString*)CreatePackage:(uint8_t)cmd Data:(uint8_t*)data DataLen:(uint8_t)dataLen seqNumer:(uint8_t)seqNum
{
    const short minPkgLen=SERIAL_REQ_NOTIFY_HDR_LEN;
    uint8_t startbyte = 0x7E;
    uint8_t msg[MAX_PACKAGE_LEN]={startbyte,dataLen,cmd,seqNum};
    
    if(dataLen>0)
    {
        for (int i=0; i<dataLen; i++)
        {
            msg[i+minPkgLen]=data[i];
        }
    }
    
    short msgLen=minPkgLen+dataLen;
    msg[4]=[self calcChecksum:msg size:msgLen];
    
    bool isConverted=false;
    NSData *ConvertedTable=[self prepare_sent_table:msg Table_received_len:msgLen Converted:&isConverted];
    
    if (isConverted)
    {
        [self writeToDeviceByBytes:(void*)[ConvertedTable bytes] length:(int)[ConvertedTable length]];
        return [NSString stringWithFormat:@"(converted):%@",[self byteToStr:ConvertedTable]];
    }
    else
    {
        [self writeToDeviceByBytes:msg length:msgLen];
        return [NSString stringWithFormat:@"%@",[self byteToStr:[NSData dataWithBytes:msg length:msgLen]]];
    }
}

//send package order is 0.START, 1.DATA_LEN, 2.CMD, 3.SEQ_NUM, 4.CHK_SUM , 5.DATA+
-(NSString*)SendMessageToMCU:(NSString*)cmd Data:(NSString*)data seqNumer:(uint8_t)seqNum
{
    seqNumer=seqNum;
    [self readFromDevice];
    
    uint8_t dataBytes[MAX_PACKAGE_LEN]={0};
    short dataByteCount=0;
    
    if([data length]>0)
    {
        NSArray *dataArray=[data componentsSeparatedByString:@" "];
        
        for(NSString *subData in dataArray)
        {
            dataBytes[dataByteCount]=[Utility convertHexStrToInt:subData];
            dataByteCount++;
        }
    }
    return [self CreatePackage:[Utility convertHexStrToInt:cmd] Data:dataBytes DataLen:dataByteCount seqNumer:seqNum];
}


#pragma mark Read From MCU
-(uint8_t)get_onebyte
{
    const uint8_t *oneByte=[[self readFromDeviceByBytes:1] bytes];
    return (oneByte!=NULL)? oneByte[0]: '\0';
}

-(int)validPackage:(uint8_t*)buf command:(uint8_t)cmd seqNumer:(uint8_t)seqNum
{
    buf[0]=0x7e;
    int index=1;
    int total_len=MAX_PACKAGE_LEN;
    int data_len=0, checksum=0, buf_checksum=0;
    uint8_t ch, tmp;
    
    while(index<total_len)
    {
        ch=[self get_onebyte];
        
        if(ch==0x7e)            return 0x7e;//filt the continue 7e byte case
        if(ch==0x7d)
        {
            tmp=[self get_onebyte];
            
            if(tmp==0x5d)		ch=0x7d;
            else if(tmp==0x5e)	ch=0x7e;
            else				return -1;
        }
        
        buf[index]=ch;
        
        if(index==5)
        {
            //get the data_len and the checksum etc …
            data_len=buf[1];
            checksum=buf[4];
            if(data_len>MAX_PACKAGE_LEN)    return -2;
            if(buf[4]!=RESP_STATUS_OK)      return -3;
            if(buf[2]!=(cmd|0x80))          return -4;
            if(buf[3]!=seqNum)              return -5;
            total_len=data_len+PACKAGE_HDR_LEN;
        }
        index++;
    }
    //now we get whole package in the buf[] then calculate buf_checksum for checksum of buf[]
    
    for(int i=0;i<total_len;i++)
    {
        if(i!=5)    buf_checksum+=buf[i];
    }
    buf_checksum=(~buf_checksum + 1) & 0xff;
    
    return (buf_checksum==checksum)? total_len: -6;
}

//get package order is 0.START, 1.DATA_LEN, 2.CMD, 3.SEQ_NUM, 4.status 5.CHK_SUM , 6.DATA+
-(NSData*)GetResponseFromMCU:(NSString*)cmd seqNumer:(uint8_t)seqNum
{
    //below is used to non [] command
    uint8_t buf[MAX_PACKAGE_LEN]={0};
    bool done=false;
    bool header_found=false;
    short buf_Len=0;
    
    while(done!=true)
    {
        if(!header_found)
        {
            const uint8_t *oneByte=[[self readFromDeviceByBytes:1] bytes];
            
            if(oneByte==NULL)
                break;
            if(oneByte[0]==0x7e)
                header_found=true;
        }
        else
        {
            int value=[self validPackage:buf command:[Utility convertHexStrToInt:cmd] seqNumer:seqNum];
            
            if(value==0x7e)
                header_found=true;
            else if(value<0)
            {
                header_found=false;
                
                if(value==-1) NSLog(@"Get Package 7D Byte Error");
                if(value==-2) NSLog(@"Get Package Data Length Error");
                if(value==-3) NSLog(@"Get Package Status Error");
                if(value==-4) NSLog(@"Get Package Command  Error");
                if(value==-5) NSLog(@"Get Package SeqNumber Error");
                if(value==-6) NSLog(@"Get Package Checksum  Error");
            }
            else
            {
                buf_Len=value;
                done=true;
            }
        }
    }
    //analysis buf[] to get we need here
    return (done)?[NSData dataWithBytes:buf length:buf_Len]:nil;
}

-(NSString*)ForAnyCmd:(NSString*)cmd Data:(NSString*)data seqNumer:(uint8_t)seqNum
{
    [self SendMessageToMCU:cmd Data:data seqNumer:seqNum];
    usleep(100);
    return [self byteToStr:[self GetResponseFromMCU:cmd seqNumer:seqNum]];//raw data including package header
}

#pragma mark Psoc I2C creat package
-(NSString*)writeMesgToPsoc:(uint8_t)cmd Data:(NSString*)data seqNumber:(uint8_t)seqNum
{
    uint8_t sendBytes[MAX_PKG_LEN]={0};
    short byteCunt=0;
    
    if([data length]>0)
    {
        NSArray *dataArray=[data componentsSeparatedByString:@" "];
        
        for(NSString *subData in dataArray)
        {
            sendBytes[byteCunt]=[Utility convertHexStrToInt:subData];
            byteCunt++;
        }
    }
    return [self createPkgToSend:cmd Data:sendBytes DataLen:byteCunt seqNumber:seqNum];
}

-(NSString*)createPkgToSend:(uint8_t)cmd Data:(uint8_t*)data DataLen:(uint8_t)len seqNumber:(uint8_t)seqNum
{
    uint8_t msg[MAX_PKG_LEN]={cmd, len, seqNum, OK_ST};
    
    if(len>0)
    {
        for (int i=0; i<len; i++)
        {
            msg[i+MIN_PKG_LEN]=data[i];
        }
    }
    
    short checksumIdx=MIN_PKG_LEN+len;
    short msgLen=checksumIdx+1;
    msg[checksumIdx]=[self calcChecksum:msg size:msgLen-1];
    
    return [NSString stringWithFormat:@"%@",[self byteToStr:[NSData dataWithBytes:msg length:msgLen]]];
}
//the package order is Cmd Len Nun Status Data checksum
-(int)validReadPkg:(uint8_t)cmdSent readPackage:(NSString*)readPkgStr seqNumber:(uint8_t)seqNum
{
    uint8_t readPkg[MAX_PKG_LEN]={0};
    NSArray *tmpPkg=[readPkgStr componentsSeparatedByString:@" "];
    
    short readCunt=0;
    for(NSString *val in tmpPkg)
    {
        readPkg[readCunt]=[Utility convertHexStrToInt:val];
        readCunt++;
    }
    uint8_t checksum=readPkg[(readCunt-1)];
    uint8_t status=readPkg[ST_BYTE];
    
    if ((cmdSent | RESP_CMD_CHECK_BYTE) != readPkg[CMD_BYTE])
        return CMD_ERROR;
    if (seqNum != readPkg[SEQ_BYTE])
        return SEQ_ERROR;
    if (OK_ST != status)
    {
        if(status & BIT_0)
            return ST_PKG_SEQ_NUM_ERROR;
        if(status & BIT_1)
            return ST_PKG_SMALL_ERROR;
        if(status & BIT_2)
            return ST_PKG_LARGE_ERROR;
        if(status & BIT_3)
            return ST_PKG_CK_ERROR;
        if(status & BIT_4)
            return ST_PKG_RES_MBZ_1;
        if(status & BIT_5)
            return ST_PKG_RES_MBZ_2;
        if(status & BIT_6)
            return ST_PKG_CMD_ERROR;
        if(status & BIT_7)
            return ST_SOC_NOT_READY_ERROR;
        return STATUS_ERROR;
    }
    if (checksum != [self calcChecksum:readPkg size:(readCunt-1)])
        return CHECKSUM_ERROR;
    return NO_ERROR;
}

-(NSString*)getPkgErrorMesg:(int)errorCode
{
    if(errorCode==NO_ERROR)
        return @"Package is valid";
    if(errorCode==CMD_ERROR)
        return @"Package command error";
    if(errorCode==SEQ_ERROR)
        return @"Package seq num error";
    if(errorCode==STATUS_ERROR)
        return @"Package status error";
    if(errorCode==CHECKSUM_ERROR)
        return @"Package checksum error";
    //below is package status error ref:B238 Peppy Interface Protocol v0.0.3
    if(errorCode==ST_PKG_SEQ_NUM_ERROR)
        return @"Incorrect sequence number";
    if(errorCode==ST_PKG_SMALL_ERROR)
        return @"Package size too small";
    if(errorCode==ST_PKG_LARGE_ERROR)
        return @"Package size too large";
    if(errorCode==ST_PKG_CK_ERROR)
        return @"Incorrect checksum";
    if(errorCode==ST_PKG_RES_MBZ_1)
        return @"Reserved MBZ_bit4";
    if(errorCode==ST_PKG_RES_MBZ_2)
        return @"Reserved MBZ_bit5";
    if(errorCode==ST_PKG_CMD_ERROR)
        return @"Command not implemented";
    if(errorCode==ST_SOC_NOT_READY_ERROR)
        return @"soc not ready for command";
    return @"Unknow package error";
}
// ============== Psoc I2C read write ==============
#pragma mark Psoc I2C by diag

-(NSString*)i2cWriteByDiag:(NSString*)ch chipAddr:(NSString*)addr cmd:(uint8_t)cmd Data:(NSString*)data seqNumber:(uint8_t)seqNum
{
    NSArray *array=[[self writeMesgToPsoc:cmd Data:data seqNumber:seqNum] componentsSeparatedByString:@" "];
    
    NSMutableString *temp=[[[NSMutableString alloc] init] autorelease];
    
    for(NSString *val in array)
    {
        [temp appendFormat:@"0x%@ ",val];
    }
    NSString *package=[temp stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSString *wmesg=[NSString stringWithFormat:@"i2c -w %@ %@ %@ multiple\r",ch,addr,package];
    NSLog(@"the i2c write data %@",wmesg);
    
    return [self queryByCmd:wmesg strWaited:ENDING_SYMBOL retry:1 timeout:2];
}

-(NSString*)i2cReadByDiag:(NSString*)ch chipAddr:(NSString*)addr cmdSent:(uint8_t)cmdSent len:(NSString*)len seqNumber:(uint8_t)seqNum
{
    NSString *rmesg=[NSString stringWithFormat:@"i2c -r %@ %@ %@\r",ch,addr,len];
    NSString *getPkg=[self queryByCmd:rmesg strWaited:ENDING_SYMBOL retry:1 timeout:2];
    NSArray *msgArr =[RegxFunc regxByText:getPkg textRegx:@"0x\\w+ "];
    NSString *pskStr = @"";
    for (int i = 1;  i < [msgArr count];  i++) {
        
        if (i != [msgArr count] - 1)
            pskStr=[pskStr stringByAppendingString:[[msgArr objectAtIndex:i] substringToIndex:5]];
        else
            pskStr=[pskStr stringByAppendingString:[[msgArr objectAtIndex:i] substringToIndex:4]];
    }
    
    int errorCode=[self validReadPkg:cmdSent readPackage:pskStr seqNumber:seqNum];
    
    
    if(errorCode==NO_ERROR)
        return getPkg;
    else
        return [self getPkgErrorMesg:errorCode];
}

# pragma mark save logs to IACHostLogs

-(void)saveSmokeyLogBySeqName:(NSString *)SeqName
{
    [self queryByCmd:@"\r" strWaited:ENDING_SYMBOL retry:1 timeout:3]; // clear uart buffer
    
    NSString *cmd = [NSString stringWithFormat:@"cat nandfs:/AppleInternal/Diags/Logs/Smokey/%@/Smokey.log\r",SeqName];
    NSString *msg = [self queryRawDataByCmd:cmd strWaited:@"] :-)" retry:1 timeout:10];
    
    if (msg != nil)
    {
        NSArray *temp = [RegxFunc regxByGroup:msg groupRegx:@"SrNm: (\\w+)"];
        if ([temp count] > 0)
        {
            NSString *sn = [temp objectAtIndex:0];
            NSString *fdName = [NSString stringWithFormat:@"Smokey-%@",SeqName];
            
            //create folder
            [[NSFileManager defaultManager] createDirectoryAtPath:[NSString stringWithFormat:@"vault/IACHostLogs/%@",fdName] withIntermediateDirectories:YES attributes:nil error:nil];
            
            NSString *logFilePath = [NSString stringWithFormat:@"/vault/IACHostLogs/%@/%@-%@.txt",fdName,[Utility getTimeForFile],sn];
            
            [msg writeToFile:logFilePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
            NSLog(@"Save %@ log OK",fdName);
        }
    }
}

#pragma mark Assistant Code
-(NSString *)byteToStr:(NSData*)data
{
    if (data!=nil)
    {
        NSMutableString *opt=[[[NSMutableString alloc] init] autorelease];
        const unsigned char *bytes=[data bytes];
        
        for (int i=0;i<[data length];i++)
            [opt appendFormat:@"%02X ",bytes[i]];
        return [opt stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    }
    return @"";
}
@end
