//
//  I2CMaster.m
//  I2CMaster
//
//  Created by HenryLee on 6/26/13.
//  Copyright (c) 2013 HenryLee. All rights reserved.
//

#import "I2CMaster.h"
#import "Utility.h"
#define BUS_TIMEOUT 150  // ms
#define I2C_BITRATE 400	 // kHz
#define BUFFER 512
#define X1_WRITE_ADDR	0x33
#define X1_READ_ADDR	0x32

@implementation X1_Aardvark
@synthesize isReady;
@synthesize isNAK;

X1_Aardvark *cftsI2CMaster = nil;
static int count=0;

-(void)DEMO
{
    [self writeToAddress:0x50 data:@"00 00 13"];
    usleep(500000);
    NSMutableString *info = [[[NSMutableString alloc] initWithString:@""] autorelease];
    [self readFromAddress:0x50 dataout:info rlen:1 datain:@"00 00"];
    NSLog(@"Aardvark reading = %@",info);
}

+(X1_Aardvark *)sharedI2CMaster
{
    @synchronized(self)
    {
        if (cftsI2CMaster == nil && count==0)
        {
			cftsI2CMaster = [[X1_Aardvark alloc] init];
			count++;
		}
    }
    return cftsI2CMaster;
}

- (id)init
{
	if (cftsI2CMaster == nil && count == 0)
    {
		if ((self = [super init]))
        {
			numberOfMastersAttached = 0;
			numberOfMastersAttached = aa_find_devices(MAXI2CMASTERS, masterPorts);
			NSLog(@"I2C find master: %d",numberOfMastersAttached);
			int j = 0;
            
			for (int i = 0; i < numberOfMastersAttached; i++)
            {
				Aardvark handle = 0;
				handle = [ self i2c_open: masterPorts[i]];
                
				if (handle > 0)
                {
					mastersHandler[j] = handle;
					masterPortsOpened[j] = masterPorts[i];
					j++;
					aa_configure(handle,  AA_CONFIG_SPI_I2C);
					aa_i2c_pullup(handle, AA_I2C_PULLUP_BOTH);
                    aa_target_power(handle, AA_TARGET_POWER_BOTH);
					
					int bitrate = aa_i2c_bitrate(handle, I2C_BITRATE);
					NSLog(@"I2C Bitrate set to %d kHz\n", bitrate);
					
					int bus_timeout = aa_i2c_bus_timeout(handle, BUS_TIMEOUT);
					NSLog(@"I2C Bus lock timeout set to %d ms\n", bus_timeout);
					
					isReady = TRUE;
				}
			}
			numberOfMastersopened = j;
			cftsI2CMaster = self;
		}
		else
			return nil;
        
		count++;
	}
	return cftsI2CMaster;
}

-(id)initWithArg:(NSDictionary *)dic
{
	return [self init];
}

-(Aardvark)i2c_open:(int) port
{
	Aardvark handle = aa_open(port);
    
	if (handle <= 0)
    {
        NSLog(@"Unable to open Aardvark device on port %d\n", port);
		NSLog(@"Error code = %d\n", handle);
    }
	return handle;
}

-(u16*)masterPortsOpened
{
	return masterPortsOpened;
}

-(void)dealloc
{
	for (int i = 0; i < numberOfMastersopened; i++)
		aa_close(mastersHandler[numberOfMastersopened]);
    
	isReady = FALSE;
	[super dealloc];
}

-(Aardvark)i2c_read:(Aardvark) handle slaveAddress:(u16)sladdr readNumbers:(u16)rnum writeNumbers:(u16)wnum dataIn:(u08 *) dataIn dataOut:(u08 *)dataOut
{
	if (wnum > 0)
		aa_i2c_write(handle, sladdr, AA_I2C_NO_STOP, wnum, dataIn);

    int length = aa_i2c_read(handle, sladdr, AA_I2C_NO_FLAGS, rnum, dataOut);
    
    if (length < 0)
        NSLog(@"I2c Read Error: %s\n", aa_status_string(count));
    
	return length;
}

-(Aardvark)i2c_write:(Aardvark) handle slaveAddress:(u16)sladdr writeNumbers:(u16)num data:(const u08 *)dataIn
{
	u08 tmp[1024];
	memset(tmp, 0, 1024);
	memcpy(tmp, dataIn, num);
	return aa_i2c_write(handle, sladdr, AA_I2C_NO_FLAGS, num, tmp);
}

//assume the data to be write is separatedby space, and all are Hex make sure the input data dose not exceed BUFFER SIZE
-(int) writeToAddress:(u16)sladdr data:(NSString *)data;
{
	u08 dataIn[BUFFER];
	memset(dataIn, 0, BUFFER);
	NSArray *tmp = [data componentsSeparatedByString:@" "];
	NSInteger len = [tmp count];
	int i = 0, k = 0;
    
	while (len)
    {
		if ([(NSString *)[tmp objectAtIndex:i] compare:@""] != NSOrderedSame)
		{
			NSInteger hexstringlen = [(NSString*)[tmp objectAtIndex:i] length];
			
			for (int j = 0; j < hexstringlen; j++)
            {
				dataIn[k] = dataIn[k]  << 4;
				unsigned char hexchar = [(NSString*)[tmp objectAtIndex:i] characterAtIndex:j];
				
				if (hexchar >= '0' && hexchar <= '9')           dataIn[k] += (hexchar - '0');
                else if( (hexchar >= 'a' && hexchar <= 'f'))    dataIn[k] += (10 + hexchar - 'a');
				else if (hexchar >= 'A' && hexchar <= 'F')      dataIn[k] += (10 + hexchar - 'A');
			}
			k ++;
		}
		len --;
		i ++;
	}
    
	len = [tmp count];
	int wlen =  [self i2c_write:mastersHandler[0] slaveAddress:sladdr writeNumbers:len data:dataIn];
    
	if (wlen != len)
		NSLog(@"I2c write %x %@ Fail",sladdr,data);
    
	return wlen;
}

-(int) readFromAddress:(u16)sladdr dataout:(NSMutableString *)dataOut rlen:(int)rnum datain:(NSString *)dataIn
{
	u08 tmpIn[BUFFER];
	u08 tmpOut[BUFFER];
	memset(tmpOut, 0, BUFFER);
	memset(tmpIn, 0, BUFFER);
	NSArray *tmp = [dataIn componentsSeparatedByString:@" "];
	NSInteger len = [tmp count];
	int i = 0, k = 0;
    
	while (len)
    {
		if ([(NSString *)[tmp objectAtIndex:i] compare:@""] != NSOrderedSame)
		{
			NSInteger hexstringlen = [(NSString*)[tmp objectAtIndex:i] length];
			
			for (int j = 0; j < hexstringlen; j++)
            {
				tmpIn[k] = tmpIn[k]  << 4;
				unsigned char hexchar = [(NSString*)[tmp objectAtIndex:i] characterAtIndex:j];
				
				if (hexchar >= '0' && hexchar <= '9')           tmpIn[k] += (hexchar - '0');
                else if( (hexchar >= 'a' && hexchar <= 'f'))    tmpIn[k] += (10 + hexchar - 'a');
				else if (hexchar >= 'A' && hexchar <= 'F')      tmpIn[k] += (10 + hexchar - 'A');
			}
			k ++;
		}
		len --;
		i ++;
	}
    
	len = [tmp count];
	int length = [self i2c_read:mastersHandler[0] slaveAddress:sladdr readNumbers:rnum writeNumbers:len dataIn:tmpIn dataOut:tmpOut];
    
    if(length==1)
        [dataOut appendFormat:@"%02X",tmpOut[0]];
    else
    {
        for (int i=0; i<length; i++)
        {
            if(i==(length-1))   [dataOut appendFormat:@"%02X",tmpOut[i]];
            else                [dataOut appendFormat:@"%02X ",tmpOut[i]];
        }
    }
    
	return (int)len;
}

-(int) readIntFromAddress:(u16)sladdr dataout:(NSMutableString *)dataOut rlen:(int)rnum datain:(NSString *)dataIn
{
	u08 tmpIn[BUFFER];
	u08 tmpOut[BUFFER];
	memset(tmpOut, 0, BUFFER);
	memset(tmpIn, 0, BUFFER);
	NSArray *tmp = [dataIn componentsSeparatedByString:@" "];
	NSInteger len = [tmp count];
	int i = 0 ,k = 0;
    
	while (len)
    {
		if ([(NSString *)[tmp objectAtIndex:i] compare:@""] != NSOrderedSame)
		{
			NSInteger hexstringlen = [(NSString*)[tmp objectAtIndex:i] length];
			
			for (int j = 0; j < hexstringlen; j++)
            {
				tmpIn[k] = tmpIn[k]  << 4;
				unsigned char hexchar = [(NSString*)[tmp objectAtIndex:i] characterAtIndex:j];
				
				if (hexchar >= '0' && hexchar <= '9')           tmpIn[k] += (hexchar - '0');
                else if( (hexchar >= 'a' && hexchar <= 'f'))    tmpIn[k] += (10 + hexchar - 'a');
				else if (hexchar >= 'A' && hexchar <= 'F')      tmpIn[k] += (10 + hexchar - 'A');
			}
			k ++;
		}
		len --;
		i ++;
	}
    
	len = [tmp count];
	int length = [self i2c_read:mastersHandler[0] slaveAddress:sladdr readNumbers:rnum writeNumbers:len dataIn:tmpIn dataOut:tmpOut];
	int tmpValue = 0;

	if (length == 1)        tmpValue = tmpOut[0];
    else if(length == 2)    tmpValue = tmpOut[0]<<8 | tmpOut[1];
    
	[dataOut setString:[NSString stringWithFormat:@"%d", tmpValue]];
    
	return (int)len;
}

-(int) write:(NSString*)chipAddr Data:(NSString*)data
{
    return [self writeToAddress:[Utility convertHexStrToInt:chipAddr] data:data] ;
}

-(int) read:(NSString*)chipAddr ReadLen:(int)len outData:(NSMutableString*)opt
{
    return [self readFromAddress:[Utility convertHexStrToInt:chipAddr] dataout:opt rlen:len datain:nil];
}

-(int) writeAndRead:(NSString*)chipAddr Data:(NSString*)data ReadLen:(int)len outData:(NSMutableString*)opt
{
    return [self readFromAddress:[Utility convertHexStrToInt:chipAddr] dataout:opt rlen:len datain:data];
}

@end
