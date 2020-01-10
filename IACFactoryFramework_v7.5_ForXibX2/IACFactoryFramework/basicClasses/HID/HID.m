//
//  MyHID.m
//  USB_HID
//
//  Created by May on 15/6/18.
//  Copyright (c) 2015年 MAY. All rights reserved.
//

#import "HID.h"

@implementation HID
@synthesize tIOHIDDeviceRefs;

-(int)HID_Match:(NSString *)VID ProductID:(NSString *)PID
{
    int HID_deviceCount = 0 ;
    
    NSScanner *sVID = [NSScanner scannerWithString:VID];
    NSScanner *sPID = [NSScanner scannerWithString:PID];
    [sVID scanHexInt:&vendor_id];
    [sPID scanHexInt:&product_id];
    
    // Create the USB HID Manager (OSX 10.5 & later only)
    HIDManager = IOHIDManagerCreate(kCFAllocatorDefault,kIOHIDOptionsTypeNone);
    // Create a matching dictionary for filtering USB devices by PID and VID
    CFStringRef keys[2],values[2];
    CFNumberRef vendorID = CFNumberCreate( kCFAllocatorDefault, kCFNumberIntType, &vendor_id );
    CFNumberRef productID = CFNumberCreate( kCFAllocatorDefault, kCFNumberIntType, &product_id );
    
    keys[0] = CFSTR( kIOHIDVendorIDKey );  values[0] = (void *) vendorID;
    keys[1] = CFSTR( kIOHIDProductIDKey ); values[1] = (void *) productID;
    
    CFDictionaryRef matchDict = CFDictionaryCreate( kCFAllocatorDefault, (const void **) &keys, (const void **) &values, 1, NULL, NULL);
    
    // Apply the matching to our HID manager
    IOHIDManagerSetDeviceMatching(HIDManager, matchDict);
    
    // We're done with the matching dictionary
    if(matchDict) CFRelease(matchDict);
    if(vendorID)  CFRelease(vendorID);
    if(productID) CFRelease(productID);
    
    
    // Try to open the HID mangager
    IOReturn IOReturn = IOHIDManagerOpen(HIDManager, kIOHIDOptionsTypeNone);
    if(IOReturn)
    {
        NSLog(@"%s","IOHIDManagerOpen failed.\n");  //  Couldn't open the HID manager!
        // TODO: application specific error handling
        CFRelease( HIDManager );
        return false;
    }
    
    CFSetRef deviceCFSetRef = IOHIDManagerCopyDevices( HIDManager );
    if(deviceCFSetRef == NULL)
    {
        NSLog( @"%s", "no device match!!\n" );
        return false;
    }
    
    //Add the HID manager to the main run loop (or the callback functions won't be called)
    IOHIDManagerScheduleWithRunLoop(HIDManager, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode);
    
    CFIndex deviceIndex, deviceCount = CFSetGetCount( deviceCFSetRef );
    tIOHIDDeviceRefs = malloc( sizeof( IOHIDDeviceRef ) * deviceCount );
    CFSetGetValues( deviceCFSetRef, (const void **) tIOHIDDeviceRefs );
    CFRelease(deviceCFSetRef);
    
    IOHIDDeviceRef temp_IOHIDDeviceRef = nil;
    
    for ( deviceIndex = 0; deviceIndex < deviceCount; deviceIndex++ )
    {
        CFTypeRef p_id = IOHIDDeviceGetProperty(tIOHIDDeviceRefs[deviceIndex],CFSTR(kIOHIDProductIDKey));
        CFTypeRef v_id = IOHIDDeviceGetProperty(tIOHIDDeviceRefs[deviceIndex],CFSTR(kIOHIDVendorIDKey));
        NSNumber *pid = p_id ;
        NSNumber *vid = v_id ;
        
        if ([pid intValue] == (int)product_id  &&  [vid intValue] == (int)vendor_id)
        {
            temp_IOHIDDeviceRef = tIOHIDDeviceRefs[deviceIndex];
            HID_deviceCount++;
        }
        
    }
    if (HID_deviceCount == 1)   // just only found a2 HID and opent it
    {
        [self HID_Open:temp_IOHIDDeviceRef];
    }
    
    return HID_deviceCount;
}


-(BOOL)HID_Open:(IOHIDDeviceRef) HID_device
{
    if (my_IOHIDDeviceRef != nil)
    {
        IOHIDDeviceClose( my_IOHIDDeviceRef, kIOHIDOptionsTypeNone );
        my_IOHIDDeviceRef = nil;
    }
    
    CFTypeRef p_id = IOHIDDeviceGetProperty(HID_device,CFSTR(kIOHIDProductIDKey));
    CFTypeRef v_id = IOHIDDeviceGetProperty(HID_device,CFSTR(kIOHIDVendorIDKey));
    NSNumber *pid = p_id ;
    NSNumber *vid = v_id ;
    
    if ([pid intValue] == (int)product_id  &&  [vid intValue] == (int)vendor_id)
    {
        
        IOReturn IOReturn = IOHIDDeviceOpen( HID_device, kIOHIDOptionsTypeNone );
        if(IOReturn)
        {
            NSLog(@"%s","IOHIDDeviceOpen failed.\n");  //  Couldn't open the HID device!
            // TODO: application specific error handling
            IOHIDDeviceClose( HID_device, kIOHIDOptionsTypeNone );
            
            return false;
        }
        
        const char * deviceName = CFStringGetCStringPtr(IOHIDDeviceGetProperty(HID_device,CFSTR(kIOHIDProductKey)),
                                                        kCFStringEncodingASCII);
        NSString *deviceName_Str = [NSString stringWithFormat:@"%s",deviceName];
        NSLog(@"Open device name = %@",deviceName_Str);
        

        // The HID manager will use callbacks when specified USB devices are connected / disconnected.
        IOHIDDeviceRegisterInputReportCallback(HID_device,      // register input callback
                                               read_buf,
                                               BUFF_SIZE,
                                               Handle_IOHIDDeviceInputReportCallback,
                                               NULL);
        
        IOHIDDeviceRegisterRemovalCallback(HID_device,          //register remove callback
                                           (void*)Handle_DeviceRemovalCallback,
                                           NULL);
        
        
        
        my_IOHIDDeviceRef=HID_device;
        return true;
    }
    NSLog(@"PID or VIP no match");
    return false;
}


-(BOOL)HID_WriteData:(NSData *)data
{
    memset(write_buf,0,BUFF_SIZE);
    
    if ([data length] >= BUFF_SIZE)
        memcpy(write_buf,[data bytes],BUFF_SIZE);
    else
        memcpy(write_buf,[data bytes],[data length]);
    
    usleep(50000);
    IOReturn  tIOReturn = IOHIDDeviceSetReport(my_IOHIDDeviceRef,        // IOHIDDeviceRef for the HID device
                                               kIOHIDReportTypeOutput,   // IOHIDReportType for the report
                                               0,                        // CFIndex for the report ID
                                               (uint8_t*)write_buf,      // address of report buffer
                                               BUFF_SIZE);               //sizeof(command));  // length of the report
    
    if(tIOReturn)
    {
        // device write failed
        NSLog(@"Write ERROR: SetReport return value: %08x\n", tIOReturn);
        
        // TODO: application specific error handling
        
        return false ;
    }

    return true;
}

-(BOOL)HID_WriteString:(NSString *)str
{
    memset(write_buf,0,BUFF_SIZE);
    
    if ([str length] >= BUFF_SIZE)
        memcpy(write_buf,[str UTF8String],BUFF_SIZE-1);
    else
        memcpy(write_buf,[str UTF8String],[str length]);
    
    usleep(50000);
    IOReturn  tIOReturn = IOHIDDeviceSetReport(my_IOHIDDeviceRef,        // IOHIDDeviceRef for the HID device
                                               kIOHIDReportTypeOutput,   // IOHIDReportType for the report
                                               0,                        // CFIndex for the report ID
                                               (uint8_t*)write_buf,      // address of report buffer
                                               BUFF_SIZE);               //sizeof(command)); // length of the report
    
    if(tIOReturn)
    {
        // device write failed
        NSLog(@"Write ERROR: SetReport return value: %08x\n", tIOReturn);
        
        // TODO: application specific error handling
        
        return false ;
    }
    
    return true;
}

-(void)close
{
    if (my_IOHIDDeviceRef != nil)
    {
        IOHIDDeviceClose( my_IOHIDDeviceRef, kIOHIDOptionsTypeNone );
        my_IOHIDDeviceRef = nil;
    }
    if (HIDManager != nil)
    {
        CFRelease( HIDManager );
        HIDManager = nil;
    }
}


// Device specified in the matching dictionary has been removed (callback function)
//
static void Handle_DeviceRemovalCallback(void *inContext,
                                         IOReturn inResult,
                                         void *inSender,
                                         IOHIDDeviceRef inIOHIDDeviceRef){
    
    NSLog(@"%s","DeviceRemove!!\n");
    [[NSNotificationCenter defaultCenter] postNotificationName:HID_RemovalNotify object:nil];
}

static void Handle_IOHIDDeviceInputReportCallback(void * inContext,
                                                  IOReturn inResult,
                                                  void * inSender,
                                                  IOHIDReportType inType,
                                                  uint32_t inReportID,
                                                  uint8_t * inReport,
                                                  CFIndex inReportLength){
    if (inResult)
    {
        NSLog(@"%08x\n", inResult);
        
        // TODO: applicaiton-specific error handling
        
        return;
    }
    
    long len = strlen((const char*)inReport);
    if (len>0)
    {
        if (len>BUFF_SIZE)
        {
            NSLog(@"64rec=%s(%d)\n",inReport,BUFF_SIZE);
            NSData *data = [NSData dataWithBytes:inReport length:BUFF_SIZE];
            [[NSNotificationCenter defaultCenter] postNotificationName:HID_ReadNotify object:data];
        }
        else
        {
            NSLog(@"rec=%s(%ld)\n",inReport,len);
            NSData *data = [NSData dataWithBytes:inReport length:len];
            [[NSNotificationCenter defaultCenter] postNotificationName:HID_ReadNotify object:data];
        }
    }
}

Boolean IOHIDDevice_GetLongProperty( IOHIDDeviceRef inIOHIDDeviceRef, CFStringRef inKey, long * outValue )
{
    Boolean result = FALSE;
    
    if ( inIOHIDDeviceRef ) {
        //assert( IOHIDDeviceGetTypeID() == CFGetTypeID( inIOHIDDeviceRef ) );
        
        CFTypeRef tCFTypeRef = IOHIDDeviceGetProperty( inIOHIDDeviceRef, inKey );
        
        if ( tCFTypeRef ) {
            // if this is a number
            if ( CFNumberGetTypeID() == CFGetTypeID( tCFTypeRef ) ) {
                // get it's value
                result = CFNumberGetValue( ( CFNumberRef ) tCFTypeRef, kCFNumberSInt32Type, outValue );
            }
        }
    }
    return result;
}


@end
