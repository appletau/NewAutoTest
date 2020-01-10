//
//  IACHTTPRequest.m
//  autoTest
//
//  Created by may on 17/06/2019.
//  Copyright © 2019 TOM. All rights reserved.
//

#import "IACHTTPRequest.h"

@implementation IACHTTPRequest

-(id)init
{
    if(self=[super init])
    {
        content=[[NSMutableDictionary alloc] init];
        responseString=[[NSMutableString alloc] init];
        isInitRequest=NO;
    }
    
    return self;
}

-(void)dealloc
{
    [content release];
    [responseString release];
    
    if(isInitRequest)
    {
        [request release];
    }
    
    [super dealloc];
}

-(void)requestWithURL:(NSURL*)url
{
    NSLog(@"requestWithURL:%@",url);
    //创建HTTP请求
    //方法1（注：NSURLRequest只支持Get请求，NSMutableURLRequest可支持Get和Post请求）
    //NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
    //NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    
    //方法2，
    //NSURLRequest *request = [NSURLRequest requestWithURL:url];
    //NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    //方法2同时设置缓存策略和超时时间
    
    if(isInitRequest)
    {
        [request release];
        isInitRequest=NO;
    }
    
    request = [[NSMutableURLRequest alloc] initWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:15];
    //设置Http头
    NSDictionary *headers = [request allHTTPHeaderFields];
    [headers setValue:@"macOS-Client-IAC" forKey:@"User-Agent"];
    
    [content removeAllObjects];
    [responseString setString:@""];
    isInitRequest=YES;
    NSLog(@"requestWithURL End");
}

-(void)setPostValue:(NSString*)value forKey:(NSString*)key
{
    [self addPostValue:value  forKey:key];
}

-(void)addPostValue:(NSString*)value forKey:(NSString*)key
{
    [content setValue:value forKey:key];
    NSLog(@"content:%@",content);
}

-(void)setRequestMethod:(NSString*)requestType
{
    if(!isInitRequest)
    {
        NSLog(@"setRequestMethod Error:NSMutableURLRequest is not alloc\n");
        [responseString setString:@"Error:NSMutableURLRequest is not alloc\n"];
        return;
    }
    
    //设置请求方法
    //[request setHTTPMethod:@"GET"];
    [request setHTTPMethod:requestType];
    NSLog(@"setRequestMethod End");
}

-(void)startSynchronous
{
    if(!isInitRequest)
    {
        NSLog(@"startSynchronous Error:NSMutableURLRequest is not alloc\n");
        [responseString setString:@"Error:NSMutableURLRequest is not alloc\n"];
        return;
    }
    NSArray *keys = [content allKeys];
    NSMutableString * contentString = [[[NSMutableString alloc] initWithString:@""] autorelease];
    for (int i=0;i<keys.count;i++)
    {
        if(contentString.length!=0)
            [contentString appendString:@"&"];
        [contentString appendString:keys[i]];
        [contentString appendString:@"="];
        [contentString appendString:content[keys[i]]];
    }
    NSLog(@"ContainString:%@",contentString);
    NSData *data = [contentString dataUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"data size:%ld",data.length);
    [request setHTTPBody:data];
    
    //同步执行Http请求，获取返回数据
    NSURLResponse *response = nil;
    NSError *error = nil;
    NSData *result = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    NSLog(@"Http request Data size:%ld",result.length);
    
    //获取状态码和HTTP响应头信息
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
    NSLog(@"httpResponse:%@",httpResponse);
    NSInteger statusCode = [httpResponse statusCode];
    NSLog(@"statusCode:%ld",statusCode);
    //NSDictionary *responseHeaders = [httpResponse allHeaderFields];
    //NSString *cookie = [responseHeaders valueForKey:@"Set-Cookie"];
    
    //（如果有错误）错误描述
    NSLog(@"error:%@",error);
    NSString *errorDesc = [error localizedDescription];
    
    NSLog(@"check status code");
    if (statusCode==200)
    {
        //返数据转成字符串
        NSString *resultString = [[[NSString alloc] initWithData:result encoding:NSUTF8StringEncoding] autorelease];
        NSLog(@"resultString:%@",resultString);
        if (errorDesc == NULL)
        {
            NSLog(@"Result:%@\n",resultString);
            [responseString setString:resultString];
            NSLog(@"responseString:%@",responseString);
        }
        
    }
    else
    {
        NSLog(@"check errorDesc");
        if (errorDesc != NULL)
        {
            NSLog(@"Error:%@\n",errorDesc);
            [responseString setString:errorDesc];
        }
        NSLog(@"status code is not 200 & errorDecs is null");
    }
}

-(NSString*)getResponseString
{
    NSLog(@"getResponseString:%@",responseString);
    return responseString;
}
@end
