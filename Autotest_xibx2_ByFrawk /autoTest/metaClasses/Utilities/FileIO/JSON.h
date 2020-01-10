//
//  JSON.h
//  mutiAutoTest
//
//  Created by May on 13/6/13.
//  Copyright (c) 2013年 May. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <IACFactoryFramework/PlistIO.h>

@interface JSON : NSObject
{
    PlistIO *plistData;
}

@property (atomic, readonly) NSString *logFilePath;
-(void)saveJsonLog:(NSString*)sn dutNum:(int)dutNum;
@end
