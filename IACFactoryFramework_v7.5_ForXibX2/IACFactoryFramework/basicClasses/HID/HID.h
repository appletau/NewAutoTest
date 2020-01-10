//
//  MyHID.h
//  USB_HID
//
//  Created by May on 15/6/18.
//  Copyright (c) 2015年 MAY. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <IOKit/hid/IOHIDManager.h>
static NSString *HID_ReadNotify = @"HID_ReadNotification";
static NSString *HID_RemovalNotify = @"HID_RemovalNotification";

#define BUFF_SIZE 64

extern Boolean IOHIDDevice_GetLongProperty( IOHIDDeviceRef inIOHIDDeviceRef, CFStringRef inKey, long * outValue );


@interface HID : NSObject
{
    IOHIDManagerRef HIDManager;
    IOHIDDeviceRef my_IOHIDDeviceRef;

    unsigned int vendor_id;
    unsigned int product_id;
    unsigned char read_buf[BUFF_SIZE];
    unsigned char write_buf[BUFF_SIZE];
    
    IOHIDDeviceRef *tIOHIDDeviceRefs;
    
}
@property IOHIDDeviceRef *tIOHIDDeviceRefs;

-(int)HID_Match:(NSString *)VID ProductID:(NSString *)PID;
-(BOOL)HID_Open:(IOHIDDeviceRef) HID_device;
-(BOOL)HID_WriteData:(NSData *)data;
-(BOOL)HID_WriteString:(NSString *)str;
-(void)close;

@end
