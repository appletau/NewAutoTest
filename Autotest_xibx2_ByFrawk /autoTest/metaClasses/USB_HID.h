//
//  USBHID.h
//  USB_HID
//
//  Created by May on 15/6/18.
//  Copyright (c) 2015年 MAY. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <IACFactoryFramework/HID.h>

@interface USB_HID : NSObject
{
    bool isReady;
    int HID_Amount;
    HID *hid ;
    NSString *VendorID;
    NSString *ProductID;
    NSMutableArray *msg;
}

@property bool isReady;

-(void)DEMO;
-(BOOL)OpenHID:(NSString*)VID ProductID:(NSString*)PID;
-(BOOL)WriteDataToHID:(NSData*)data;
-(BOOL)WriteStringToHID:(NSString*)str;
-(int)Detect_HIDCount;
-(NSData*)ReadFromHID;
-(void)CloseHID;

@end
