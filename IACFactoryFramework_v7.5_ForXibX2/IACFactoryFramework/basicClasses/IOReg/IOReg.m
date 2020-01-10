//
//  IOReg.m
//  tryFramework
//
//  Created by May on 14/2/24.
//  Copyright (c) 2014年 Richard Li. All rights reserved.
//

#import "IOReg.h"
#define DFU @"mode_DFU"
#define UDID @"mode_UDID"

// globals
static IONotificationPortRef	gNotifyPort;
static io_iterator_t			gRawAddedIter;
static io_iterator_t			gRawRemovedIter;



@implementation IOReg

NSString *deviceAddedNotification = @"deviceAddedNotification";

- (id)init:(int)pID ProductStr:(CFStringRef)pStr testMode:(NSString *)pMode
{
    if (self) {
        modeName = pMode;
        kOurProductID=pID;
        kOuriPodProductString=pStr;
        NSLog(@"IO Reg: %@",kOuriPodProductString);
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(updateDeviceInfo:)
                                                     name:deviceAddedNotification
                                                   object:nil];
        
        [NSThread detachNewThreadSelector: @selector(initForMonitoringDFUDeviceWithPid:) toTarget:self withObject:nil];
    }
    return self;
}

- (void)updateDeviceInfo:(NSNotification *)theNotification
{
	NSDictionary *notification = [[NSDictionary alloc] initWithDictionary:[[theNotification retain] object]];
	[theNotification release];
    [notification release];
}

static void SignalHandler(int sigraised)
{
    printf("\nInterrupted\n");
	
    // Clean up here
    IONotificationPortDestroy(gNotifyPort);
	
    if (gRawAddedIter)
    {
        IOObjectRelease(gRawAddedIter);
        gRawAddedIter = 0;
    }
	
    if (gRawRemovedIter)
    {
        IOObjectRelease(gRawRemovedIter);
        gRawRemovedIter = 0;
    }
	
    // exit(0) should not be called from a signal handler.  Use _exit(0) instead
    //
    _exit(0);
}

static void DFU_RawDeviceRemoved(void *refCon, io_iterator_t iterator)
{
    kern_return_t	kr;
    io_service_t	obj;
    
    while ( (obj = IOIteratorNext(iterator)) )
    {
        printf("DFU: Raw device removed.\n");
        kr = IOObjectRelease(obj);
        [[NSNotificationCenter defaultCenter] postNotificationName:@"FLAG_STATE_REMOVED_DFU" object:nil];
    }
}
static void UDID_RawDeviceRemoved(void *refCon, io_iterator_t iterator)
{
    kern_return_t	kr;
    io_service_t	obj;
    
    while ( (obj = IOIteratorNext(iterator)) )
    {
        printf("UDID: Raw device removed.\n");
        kr = IOObjectRelease(obj);
        [[NSNotificationCenter defaultCenter] postNotificationName:@"FLAG_STATE_REMOVED_UDID" object:nil];
    }
}

static void DFU_RawDeviceAdded(void *refCon, io_iterator_t iterator)
{
    kern_return_t						kr;
    io_service_t						usbDevice;
    IOCFPlugInInterface					**plugInInterface	=	NULL;
    IOUSBDeviceInterface300				**dev				=	NULL;
    HRESULT								res;
    SInt32								score;
    UInt16								vendor;
    UInt16								product;
    
    while ( (usbDevice = IOIteratorNext(iterator)) )
    {
        
        kr = IOCreatePlugInInterfaceForService(usbDevice, kIOUSBDeviceUserClientTypeID, kIOCFPlugInInterfaceID, &plugInInterface, &score);
        kr = IOObjectRelease(usbDevice);				// done with the device object now that I have the plugin
        if ((kIOReturnSuccess != kr) || !plugInInterface)
        {
            printf("unable to create a plugin (%08x)\n", kr);
            continue;
        }
		
        // I have the device plugin, I need the device interface
        res = (*plugInInterface)->QueryInterface(plugInInterface, CFUUIDGetUUIDBytes(kIOUSBDeviceInterfaceID300), (LPVOID)&dev);
        IODestroyPlugInInterface(plugInInterface);			// done with this
		
        if (res || !dev)
        {
            printf("couldn't create a device interface (%08x)\n", (int) res);
            continue;
        }
        // technically should check these kr values
        kr = (*dev)->GetDeviceVendor(dev, &vendor);
        kr = (*dev)->GetDeviceProduct(dev, &product);
        
        {
            //ffd923fd8b2721deaac456836c51b08e0cd8a949
            CFTypeRef platformSerialNumber = IORegistryEntryCreateCFProperty(usbDevice, CFSTR(kUSBSerialNumberString), kCFAllocatorDefault, 0);
            if (CFGetTypeID(platformSerialNumber) == CFStringGetTypeID())
            {
                printf("DFU: Raw device added.\n");
                [[NSNotificationCenter defaultCenter] postNotificationName:@"FLAG_STATE_ADDED_DFU" object:nil];
                
            }
            CFRelease(platformSerialNumber);
            // IOObjectRelease(platformExpertDevice);
        }
        
        
        if (vendor != kAppleVendorID)
        {
            // We should never get here because the matching criteria we specified above
            // will return just those devices with our vendor and product IDs
            //printf("found device i didn't want (vendor = 0x%x, product = 0x%x)\n", vendor, product);
            (void) (*dev)->Release(dev);
            continue;
        }
		
        // need to open the device in order to change its state
        kr = (*dev)->USBDeviceOpen(dev);
        if (kIOReturnSuccess != kr)
        {
            printf("unable to open device: %08x\n", kr);
            (void) (*dev)->Release(dev);
            continue;
        }
		
        kr = (*dev)->USBDeviceClose(dev);
        kr = (*dev)->Release(dev);
    }
	
}

static void UDID_RawDeviceAdded(void *refCon, io_iterator_t iterator)
{
    kern_return_t						kr;
    io_service_t						usbDevice;
    IOCFPlugInInterface					**plugInInterface	=	NULL;
    IOUSBDeviceInterface300				**dev				=	NULL;
    HRESULT								res;
    SInt32								score;
    UInt16								vendor;
    UInt16								product;
    UInt32								locationID;
    io_name_t                           className;
    
    while ( (usbDevice = IOIteratorNext(iterator)) )
    {
        kr = IOObjectGetClass(usbDevice, className);
        
        if (kr != kIOReturnSuccess) {
            printf("Failed to get class name. (0x%08x)\n", kr);
            continue;
        }
        
        kr = IOCreatePlugInInterfaceForService(usbDevice, kIOUSBDeviceUserClientTypeID, kIOCFPlugInInterfaceID, &plugInInterface, &score);
        kr = IOObjectRelease(usbDevice);				// done with the device object now that I have the plugin
        if ((kIOReturnSuccess != kr) || !plugInInterface)
        {
            printf("unable to create a plugin (%08x)\n", kr);
            continue;
        }
		
        // I have the device plugin, I need the device interface
        res = (*plugInInterface)->QueryInterface(plugInInterface, CFUUIDGetUUIDBytes(kIOUSBDeviceInterfaceID300), (LPVOID)&dev);
        IODestroyPlugInInterface(plugInInterface);			// done with this
		
        if (res || !dev)
        {
            printf("couldn't create a device interface (%08x)\n", (int) res);
            continue;
        }
        // technically should check these kr values
        kr = (*dev)->GetDeviceVendor(dev, &vendor);
        kr = (*dev)->GetDeviceProduct(dev, &product);
        kr = (*dev)->GetLocationID(dev, &locationID);
        
        {
            io_name_t devName;
            io_string_t pathName;
            IORegistryEntryGetName(usbDevice, devName);
            //printf("Device's name = %s\n", devName);
            IORegistryEntryGetPath(usbDevice, kIOServicePlane, pathName);
            //printf("Device's path in IOService plane = %s\n", pathName);
            IORegistryEntryGetPath(usbDevice, kIOUSBPlane, pathName);
            //printf("Device's path in IOUSB plane = %s\n", pathName);
            
            //ffd923fd8b2721deaac456836c51b08e0cd8a949
            CFTypeRef platformSerialNumber = IORegistryEntryCreateCFProperty(usbDevice, CFSTR(kUSBSerialNumberString), kCFAllocatorDefault, 0);
            
            if (platformSerialNumber == 0)
                continue;
            
            if (CFGetTypeID(platformSerialNumber) == CFStringGetTypeID())
            {
                //printf("UDID: Raw device added.\n");
                NSMutableString * deviceUDID =[NSMutableString stringWithString:(NSString*)platformSerialNumber];
                //NSLog(@"udid:%@",deviceUDID);
                NSMutableString * deviceLocationID =[NSMutableString stringWithFormat:@"%X", (unsigned int)locationID];
                //NSLog(@"loc:%@",deviceLocationID);
                
                [deviceUDID setString:([deviceUDID length]>0)?deviceUDID:@" "];
                [deviceLocationID setString:([deviceLocationID length]>0)?deviceLocationID:@" "];
                
                NSMutableDictionary *devInfo=[[NSMutableDictionary alloc] initWithObjectsAndKeys:deviceUDID,@"udid",deviceLocationID,@"locationID",nil];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"FLAG_STATE_ADDED_UDID" object:devInfo];
                [devInfo release];
            }
            CFRelease(platformSerialNumber);
            //IOObjectRelease(platformExpertDevice);
        }
        
        
        if (vendor != kAppleVendorID)
        {
            // We should never get here because the matching criteria we specified above
            // will return just those devices with our vendor and product IDs
            //printf("found device i didn't want (vendor = 0x%x, product = 0x%x)\n", vendor, product);
            (void) (*dev)->Release(dev);
            continue;
        }
		
        // need to open the device in order to change its state
        kr = (*dev)->USBDeviceOpen(dev);
        if (kIOReturnSuccess != kr)
        {
            printf("unable to open device: %08x\n", kr);
            (void) (*dev)->Release(dev);
            continue;
        }
		
        kr = (*dev)->USBDeviceClose(dev);
        kr = (*dev)->Release(dev);
    }
	
}


-(void)initForMonitoringDFUDeviceWithPid:(id) anObject
{
	kern_return_t			kr				= kIOReturnSuccess;
	CFMutableDictionaryRef	matchingDict;
	CFMutableDictionaryRef 	subDict;
	SInt32					usbProduct		= kOurProductID;
    CFRunLoopSourceRef		runLoopSource;
    //SInt32					usbVendor		= kAppleVendorID;
    sig_t					oldHandler;
	
    
	// Set up a signal handler so we can clean up when we're interrupted from the command line
    // Otherwise we stay in our run loop forever.
    oldHandler = signal(SIGINT, SignalHandler);
    if (oldHandler == SIG_ERR)
        printf("Could not establish new signal handler");
	
	//printf("Looking for devices matching vendor ID=0x%x and product ID=0x%x\n", (int)usbVendor, (int)usbProduct);
	
	// Create the dictionaries
    matchingDict = CFDictionaryCreateMutable(kCFAllocatorDefault, 0, &kCFTypeDictionaryKeyCallBacks,
											 &kCFTypeDictionaryValueCallBacks);
    if (matchingDict != NULL) {
        subDict = CFDictionaryCreateMutable(kCFAllocatorDefault, 0, &kCFTypeDictionaryKeyCallBacks,
											&kCFTypeDictionaryValueCallBacks);
		
        if (subDict != NULL) {
			// Create a dictionary with the kUSBProductString key with the appropriate value
            // for the device type we're interested in.
            SInt32	deviceTypeNumber = usbProduct;
			CFNumberRef	deviceTypeRef = NULL;
			
            //CFDictionarySetValue(subDict, CFSTR(kUSBProductString),CFSTR(kOuriPodProductString));
            CFDictionarySetValue(subDict, CFSTR(kUSBProductString),kOuriPodProductString);
			deviceTypeRef = CFNumberCreate(kCFAllocatorDefault, kCFNumberIntType, &deviceTypeNumber);
			CFDictionarySetValue(subDict, CFSTR(kUSBProductID), deviceTypeRef);
            CFRelease (deviceTypeRef);
			
			//
			//	Note: We are setting up a matching dictionary which looks like the following:
			//
			//	<dict>
			//		<key>IOPropertyMatch</key>
			//		<dict>
			//			<key>USB Product Name</key>
			//			<string>kOurProductString</string>
			//			<key>idProduct</key>
			//			<integer>kOurVendorID</integer>
			//		</dict>
			// </dict>
			//
			
			CFDictionarySetValue(matchingDict, CFSTR(kIOPropertyMatchKey), subDict);
			CFRelease(subDict);
			
        }

        
		gNotifyPort = IONotificationPortCreate(kIOMasterPortDefault);
		
		runLoopSource = IONotificationPortGetRunLoopSource(gNotifyPort);
		
		CFRunLoopAddSource(CFRunLoopGetCurrent(), runLoopSource, kCFRunLoopDefaultMode);
		
		// Retain additional references because we use this same dictionary with two calls to
		// IOServiceAddMatchingNotification, each of which consumes one reference.
		matchingDict = (CFMutableDictionaryRef) CFRetain( matchingDict );
		
		// Now set up two notifications, one to be called when a raw device is first matched by I/O Kit, and the other to be
		// called when the device is terminated.
        if ([modeName isEqualToString:UDID])
        {
            kr = IOServiceAddMatchingNotification( gNotifyPort,
                                                  kIOFirstMatchNotification,
                                                  matchingDict,
                                                  UDID_RawDeviceAdded,
                                                  (void*)self,
                                                  &gRawAddedIter );
		
            UDID_RawDeviceAdded((void*)self, gRawAddedIter);	// Iterate once to get already-present devices and
            // arm the notification
		
            kr = IOServiceAddMatchingNotification( gNotifyPort,
                                                  kIOTerminatedNotification,
                                                  matchingDict,
                                                  UDID_RawDeviceRemoved,
                                                  (void*)self,
                                                  &gRawRemovedIter );
		
            UDID_RawDeviceRemoved((void*)self, gRawRemovedIter);	// Iterate once to arm the notification
        }
        else if ([modeName isEqualToString:DFU])
        {
            kr = IOServiceAddMatchingNotification( gNotifyPort,
                                                  kIOFirstMatchNotification,
                                                  matchingDict,
                                                  DFU_RawDeviceAdded,
                                                  (void*)self,
                                                  &gRawAddedIter );
            
            DFU_RawDeviceAdded((void*)self, gRawAddedIter);	// Iterate once to get already-present devices and
            // arm the notification
            
            kr = IOServiceAddMatchingNotification( gNotifyPort,
                                                  kIOTerminatedNotification,
                                                  matchingDict,
                                                  DFU_RawDeviceRemoved,
                                                  (void*)self,
                                                  &gRawRemovedIter );
            
            DFU_RawDeviceRemoved((void*)self, gRawRemovedIter);	// Iterate once to arm the notification
        }
		// Now done with the master_port
		//mach_port_deallocate(mach_task_self(), masterPort);
		//masterPort = 0;
		
		// Start the run loop. Now we'll receive notifications.
		CFRunLoopRun();
		
	}
    // We should never get here
    return ;
}


@end
