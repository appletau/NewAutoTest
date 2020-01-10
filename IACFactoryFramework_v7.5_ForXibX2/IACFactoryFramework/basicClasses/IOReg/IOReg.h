//
//  IOReg.h
//  tryFramework
//
//  Created by May on 14/2/24.
//  Copyright (c) 2014年 Richard Li. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <IOKit/usb/USBSpec.h>
#import <IOKit/usb/IOUSBLib.h>
#import <IOKit/IOCFPlugIn.h>

@interface IOReg : NSObject {
    int kOurProductID;
    CFStringRef kOuriPodProductString;
    NSString* modeName;
}

- (id)init:(int)pID ProductStr:(CFStringRef)pStr testMode:(NSString *)pMode;
-(void)initForMonitoringDFUDeviceWithPid:(id) anObject;
-(void)updateDeviceInfo:(NSNotification *)theNotification;

@end
