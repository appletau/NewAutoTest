//
//  Tektronix_DPO4104BL_USB.h
//  autoTest
//
//  Created by Ben on 2018/2/2.
//  Copyright © 2018年 TOM. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <IACFactoryFramework/Equipments.h>
#import <IACFactoryFramework/VisaUSB.h>

@interface Tektronix_DPO4104BL_USB : Equipments
{
    BOOL isReady;
    VisaUSB *visaUSB;
}
@property(readonly)BOOL isReady;

-(void)DEMO;

-(id)initWithArg:(NSDictionary *)dic;
-(BOOL)screenshot:(NSString*)fileName readbyte:(int)byte;
-(BOOL)invertFunction:(NSString*)channel Switch:(NSString*)OnOff;
-(BOOL)setChannelOffset:(NSString*)channel value:(NSString*)value;
-(BOOL)setLabelName:(NSString*)channel name:(NSString*)name;
-(BOOL)setMaxiumOfBandwidth:(NSString*)channel value:(NSString*)value;
-(BOOL)setLabelPosition:(NSString*)channel value:(NSString*)value;
-(BOOL)setWaveFormScale:(NSString*)channel value:(NSString*)value;
-(BOOL)lockFrontPannel:(NSString *)OnOff;
-(double)queryByCommand:(NSString *)cmd;
-(void)closeUSB;

@end
