//
//  IACHTTPRequest.h
//  autoTest
//
//  Created by may on 17/06/2019.
//  Copyright © 2019 TOM. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IACHTTPRequest : NSObject
{
    NSMutableURLRequest *request;
    NSMutableDictionary *content;
    NSMutableString *responseString;
    BOOL isInitRequest;
}

-(void)requestWithURL:(NSURL*)urlStr;
-(void)addPostValue:(NSString*)value forKey:(NSString*)key;
-(void)setPostValue:(NSString*)value forKey:(NSString*)key;
-(void)setRequestMethod:(NSString*)requestType;
-(void)startSynchronous;
-(NSString*)getResponseString;
@end
