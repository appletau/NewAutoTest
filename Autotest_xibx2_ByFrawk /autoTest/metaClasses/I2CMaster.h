//
//  I2CMaster.h
//  I2CMaster
//
//  Created by HenryLee on 6/26/13.
//  Copyright (c) 2013 HenryLee. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <IACFactoryFramework/aardvark.h>
#import <IACFactoryFramework/Equipments.h>

#define MAXI2CMASTERS	4  

@interface X1_Aardvark : Equipments
{
	BOOL isReady;
	BOOL isNAK;
	
	u16	masterPorts[MAXI2CMASTERS];
	u16	masterPortsOpened[MAXI2CMASTERS];
	int numberOfMastersAttached;
	int numberOfMastersopened;
	Aardvark mastersHandler[MAXI2CMASTERS];
}
@property(readonly)BOOL isReady,isNAK;

+(X1_Aardvark *)sharedI2CMaster;
-(void)DEMO;
-(id)init;
-(id)initWithArg:(NSDictionary *)dic;
-(u16*) masterPortsOpened;
-(Aardvark) i2c_open:(int) port;

-(int) writeToAddress:(u16)sladdr data:(NSString *)data;
-(int) readFromAddress:(u16)sladdr dataout:(NSMutableString *)dataOut rlen:(int)rnum datain:(NSString *)dataIn ;
-(int) readIntFromAddress:(u16)sladdr dataout:(NSMutableString *)dataOut rlen:(int)rnum datain:(NSString *)dataIn;

-(int) write:(NSString*)chipAddr Data:(NSString*)data;
-(int) read:(NSString*)chipAddr ReadLen:(int)len outData:(NSMutableString*)opt;
-(int) writeAndRead:(NSString*)chipAddr Data:(NSString*)data ReadLen:(int)len outData:(NSMutableString*)opt;
@end
