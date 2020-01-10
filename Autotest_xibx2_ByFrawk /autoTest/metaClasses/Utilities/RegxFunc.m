//
//  RegxFunc.m
//  createI2Cplist
//
//  Created by May on 13/8/6.
//  Copyright (c) 2013年 May. All rights reserved.
//

#import "RegxFunc.h"
@implementation RegxFunc

+(void)DEMO
{
    //below is demo function
    NSLog(@"%@",[self regxByText:@"xxxxx12345xxx678910vvvvvv6789model: \"BCM4324\"" textRegx:@"\\d+model:"]);
    NSLog(@"%@",[self regxByText:@"Sent = 10, Received = 10, Lost = 0" textRegx:@"Sent = \\d+, Received = \\d+, Lost = \\d+"]);
    NSLog(@"%d",[self isMatchByRegx:@"xxxxx12345xxxxxxxxxxx" validRegx:@"\\d+"]);
    NSLog(@"%d",[self isMatchByRegx:@"xxxxxXXXXXxxxxxxxxxxx" validRegx:@"\\d+"]);
    NSLog(@"%@",[self replaceByRegx:@"xxxx12345xxx1234567xxxx1245xxxx" replaceStr:@"Z" validRegx:@"\\d+"]);
    NSLog(@"%@",[self replaceByRegx:@"xxxx12345xxx1234567xxxx1245xxxx" replaceStr:@"12" validRegx:@"\\d+"]);
    NSLog(@"%@",[self regxByGroup:@"xxxx1234xxxbookxxx" groupRegx:@"xxxx(\\d+)xxx(\\w+)xxx"]);
    NSLog(@"test bug 1-----%@",[self replaceByRegx:@"aaaaaa" replaceStr:@"|" validRegx:@"xx"]);//nothing to replace case
    NSLog(@"test bug 2-----%@",[self regxByGroup:@"<\"a\"><b><c><1><2><3>" groupRegx:@"(<[a-z]>)|(<[0-9]>)"]);//multi-match case
    NSLog(@"test bug 3-----%@",[self replaceByRegx:@"xxxx12345xxx1234567xxxx1245xxxx" replaceStr:@"12" validRegx:@"\\d+"]);
}

+(NSMutableArray*)regxByText:(NSString*)content textRegx:(NSString*)regx
{
    NSRange r=[content rangeOfString:regx options:NSRegularExpressionSearch];
    NSMutableArray *list=[NSMutableArray array];
    while (r.location!=NSNotFound && r.length!=0)
    {
        [list addObject:[content substringWithRange:r]];
        NSRange temp=NSMakeRange(r.location+r.length, [content length]-r.location-r.length);
        r=[content rangeOfString:regx options:NSRegularExpressionSearch range:temp];
    }
    return list;
}

+(NSMutableArray*)regxByGroup:(NSString*)content groupRegx:(NSString*)regx
{
    NSRegularExpression *re=[NSRegularExpression regularExpressionWithPattern:regx options:NSRegularExpressionCaseInsensitive error:nil];
    NSArray *matches=[re matchesInString:content options:0 range:NSMakeRange(0,[content length])];
    
    if([matches count]>0)
    {
        NSMutableArray *list=[NSMutableArray array];
        for(NSTextCheckingResult *match in matches)
        {
            for (int i=1; i<[match numberOfRanges]; i++)
            {
                if (([match rangeAtIndex:i].location+[match rangeAtIndex:i].length)<=[content length])
                    [list addObject:[content substringWithRange:[match rangeAtIndex:i]]];
            }
        }
        return list;
    }
    return nil;
}

+(Boolean)isMatchByRegx:(NSString*)content validRegx:(NSString*)regx
{
    NSRegularExpression *re=[NSRegularExpression regularExpressionWithPattern:regx options:NSRegularExpressionCaseInsensitive error:nil];
    int count=(int)[re numberOfMatchesInString:content options:NSMatchingReportProgress range:NSMakeRange(0, [content length])];
    
    if (count>0)
        return true;
    return false;
}

+(NSString*)replaceByRegx:(NSString*)content replaceStr:(NSString*)str validRegx:(NSString*)regx
{
    NSRegularExpression *re=[NSRegularExpression regularExpressionWithPattern:regx options:NSRegularExpressionCaseInsensitive error:nil];
    return  [re stringByReplacingMatchesInString:content options:0 range:NSMakeRange(0,[content length]) withTemplate:str];
}
@end
