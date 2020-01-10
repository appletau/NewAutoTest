//
//  Tektronix_DPO4104BL_USB.m
//  autoTest
//
//  Created by Ben on 2018/2/2.
//  Copyright © 2018年 TOM. All rights reserved.
//

#import "Tektronix_DPO4104BL_USB.h"

@implementation Tektronix_DPO4104BL_USB
@synthesize isReady;

-(void)DEMO
{
    [self invertFunction:@"CH1" Switch:@"OFF"];//inverts the waveform for the specified channel,Para:ON/OFF
    [self setChannelOffset:@"CH1" value:@"20E-1"];//offsets the vertical acquisition window
    [self setLabelName:@"CH1" name:@"'Q2'"];//The label text string is limited to 30 characters
    [self setMaxiumOfBandwidth:@"CH1" value:@"20E6"];//Sets the selectable low-pass bandwidth limit filter,Para:20、250、full(MHz)
    [self setLabelPosition:@"CH1" value:@"0.5"];//Sets the vertical position
    [self setWaveFormScale:@"CH1" value:@"0.01"];//Sets the vertical scale
    [self lockFrontPannel:@"ALL"];//ALL:locl,NONE:unlock
    [self screenshot:@"~/Desktop/try.png" readbyte:1024*1024];

}

-(id)init:(NSString*)usbName
{
    visaUSB = [[VisaUSB alloc]init];
    [visaUSB openUSB:usbName];
    isReady = visaUSB.isUSBopening;
    
    if (!isReady)
        NSLog(@"%@ (%@) is not ready to use",[self className],usbName);
    else
        NSLog(@"%@ (%@) is ready to use",[self className],usbName);
    return self;
}

-(id)initWithArg:(NSDictionary *)dic
{
    id tmp = nil;
    tmp = [self init:[dic objectForKey:@"PATH"] ];
    return tmp;
}


-(BOOL)invertFunction:(NSString*)channel Switch:(NSString*)OnOff
{
   return [visaUSB writeToUSB:[NSString stringWithFormat:@"%@:INVert %@",channel,OnOff]];
}

-(BOOL)setChannelOffset:(NSString*)channel value:(NSString*)value
{
    return [visaUSB writeToUSB:[NSString stringWithFormat:@"%@:OFFSET %@",channel,value]];
}

-(BOOL)setLabelName:(NSString*)channel name:(NSString*)name
{
    return [visaUSB writeToUSB:[NSString stringWithFormat:@"%@:LABEL %@",channel,name]];
}

-(BOOL)setMaxiumOfBandwidth:(NSString*)channel value:(NSString*)value
{
    return [visaUSB writeToUSB:[NSString stringWithFormat:@"%@:BANDWIDTH %@",channel,value]];
}

-(BOOL)setLabelPosition:(NSString*)channel value:(NSString*)value
{
    return [visaUSB writeToUSB:[NSString stringWithFormat:@"%@:POSition %@",channel,value]];
}

-(BOOL)setWaveFormScale:(NSString*)channel value:(NSString*)value
{
    return [visaUSB writeToUSB:[NSString stringWithFormat:@"%@:SCALE %@",channel,value]];
}

-(BOOL)lockFrontPannel:(NSString *)OnOff
{
    return [visaUSB writeToUSB:[NSString stringWithFormat:@"Lock %@",OnOff]];
}

-(BOOL)screenshot:(NSString*)filePath readbyte:(int)byteCount
{
    [visaUSB writeToUSB:@"SAVE:IMAGe:FILEFormat png\n"];
    [visaUSB writeToUSB:@"HARDCOPY CLEARS"];
    [visaUSB writeToUSB:@"HARDCOPY START"];
    return [visaUSB readFromUSB_ToFile:[filePath stringByExpandingTildeInPath] readByte:byteCount];
}

-(void)dealloc
{
    [visaUSB closeUSB];
    [visaUSB release];
    [super dealloc];
}

-(void)closeUSB
{
    [visaUSB closeUSB];
    isReady = FALSE;
}

-(double)queryByCommand:(NSString *)cmd
{
    [visaUSB writeToUSB:cmd];
    usleep(500000);
    return [visaUSB readFromUSB];
}
@end
