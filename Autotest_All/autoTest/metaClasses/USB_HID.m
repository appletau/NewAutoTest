//
//  USBHID.m
//  USB_HID
//
//  Created by May on 15/6/18.
//  Copyright (c) 2015年 MAY. All rights reserved.
//

#import "USB_HID.h"

@implementation USB_HID
@synthesize isReady;

-(void)DEMO
{
    NSLog(@"HID number = %d",[self Detect_HIDCount]);
    
    NSString *sn = @"1234567890ab";
    char cmd[64];
    cmd[0] = 0x30;
    for (int i = 0; i< [sn length]; i++)
        cmd[i+1] = [sn characterAtIndex:i];
    
    [self WriteDataToHID:[NSData dataWithBytes:cmd length:strlen(cmd)]];
    
    NSData *data = [self ReadFromHID];
    
    if (data != nil)
    {
        NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"HID read = %@",str);
        [str release];
    }
    
    [self WriteStringToHID:@"SBMSWtest"];
    
    data = [self ReadFromHID];
    if (data != nil)
    {
        NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"HID read = %@",str);
        [str release];
    }
    
}

-(id)init:(NSString *)VID ProductID:(NSString*)PID
{
    if (self = [super init])
    {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(ReadHID:)
                                                     name:HID_ReadNotify
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(CloseHID)
                                                     name:HID_RemovalNotify
                                                   object:nil];
        
        hid = [[HID alloc] init];
        msg = [[NSMutableArray alloc] init];
        VendorID  = VID;
        ProductID = PID;
        
        [self OpenHID:VID ProductID:PID];
        
        if (isReady)
            NSLog(@"HID is Ready");
        else
            NSLog(@"HID is not Ready");
    }
    return self ;
}

-(BOOL)OpenHID:(NSString*)VID ProductID:(NSString*)PID
{
    if ([VID  length] > 0 && [PID length] > 0)
    {
        HID_Amount = [hid HID_Match:VID ProductID:PID];
        
        if (HID_Amount == 1)
        {
            isReady = true; // already connected
        }
        else if (HID_Amount > 1)
        {
            //  found at least 2 HID
            for (int deviceIndex = 0; deviceIndex < HID_Amount; deviceIndex++ )
            {
                IOHIDDeviceRef devRef = hid.tIOHIDDeviceRefs[deviceIndex];
                //show device Name and LocationID, we may do more judgement here in future
                const char * deviceName = CFStringGetCStringPtr(IOHIDDeviceGetProperty(devRef,CFSTR(kIOHIDProductKey)),
                                                                kCFStringEncodingASCII);
                NSLog(@"Open device name = %s",deviceName);
                
                long result;
                IOHIDDevice_GetLongProperty(devRef, CFSTR( kIOHIDLocationIDKey ), &result );
                printf( "LocationID=%lx, \n",result);
            }
            isReady = [hid HID_Open:hid.tIOHIDDeviceRefs[0]];//in the future, we can have more judgemnet to decide which one to be choose/open
        }
    }
    return isReady;
}

-(void)dealloc
{
    [hid release];
    [msg release];
    [super dealloc];
}

-(id)initWithArg:(NSDictionary *)dic
{
	id tmp = nil;
	
    tmp = [self init: [dic objectForKey:@"Vendor_ID"] ProductID:[dic objectForKey:@"Product_ID"]];
	
	return tmp;
}

-(int)Detect_HIDCount
{
    return HID_Amount;
}

-(BOOL)WriteDataToHID:(NSData*)data
{
    if (isReady)
        return [hid HID_WriteData:data];
    
    return false;
}

-(BOOL)WriteStringToHID:(NSString*)str
{
    if (isReady)
        return [hid HID_WriteString:str];
           
    return false;
}

-(NSData*)ReadFromHID
{
    if ([msg count] > 0)
    {
        NSMutableArray *arr = [NSMutableArray arrayWithArray:msg];
        [msg setArray:[msg subarrayWithRange:NSMakeRange(1, [msg count]-1)]];
        return [arr firstObject];
    }
   
    return nil;
}

-(void)ReadHID:(NSNotification*)note
{
    NSData *data = (NSData *)[note object];
    [msg addObject:data];
}

-(void)CloseHID
{
    isReady = false;
    [msg removeAllObjects];
    [hid close];
}
@end
