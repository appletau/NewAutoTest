//
//  UI_Outlet.m
//  MyBinding_Test
//
//  Created by Terry.Hsu on 2018/9/13.
//  Copyright © 2018 Terry.Hsu. All rights reserved.
//

#import "UI_Outlet.h"
#import "ValidatorPW.h"
#import "Utility.h"
#define CuntFilePath @"/vault/IACHostLogs/.TestCounter"
#define StatusFontSize 30

@implementation UI_Outlet

+ (UI_Outlet *)sharedInstance
{
    static UI_Outlet *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[UI_Outlet alloc] init];
    });
    return sharedInstance;
}

- (id)init
{
    if (self=[super init])
    {
        paragraphStyle=[[NSMutableParagraphStyle alloc] init];
        paragraphStyle.alignment=NSTextAlignmentCenter;
        
        [self setPlist:[PlistIO sharedPlistIO]];
        [self setAuditModeBtnTitle:([_plist isAllowAuditMode])?@"Disable Audit Mode":@"Enable Audit Mode"];
        [self setCounter1:[self initCounter:1]];
        [self setCounter2:[self initCounter:2]];
        [self setCounter3:[self initCounter:3]];
        [self setCounter4:[self initCounter:4]];
    }
    return self;
}

- (void)dealloc
{
    [paragraphStyle release];
    [super dealloc];
}

- (void)updateStatus:(NSString*)status dutNum:(int)dutNum
{
    NSDictionary *attr;
    
    if ([status isEqualToString:@"TESTING"])
        attr=@{NSForegroundColorAttributeName:[NSColor yellowColor],NSParagraphStyleAttributeName:paragraphStyle,NSFontAttributeName:[NSFont boldSystemFontOfSize:StatusFontSize]};
    else if ([status isEqualToString:@"PASS"])
        attr=@{NSForegroundColorAttributeName:[NSColor greenColor],NSParagraphStyleAttributeName:paragraphStyle,NSFontAttributeName:[NSFont boldSystemFontOfSize:StatusFontSize]};
    else if ([status isEqualToString:@"FAIL"])
        attr=@{NSForegroundColorAttributeName:[NSColor redColor],NSParagraphStyleAttributeName:paragraphStyle,NSFontAttributeName:[NSFont boldSystemFontOfSize:StatusFontSize]};
    else
        attr=@{NSForegroundColorAttributeName:[NSColor blackColor],NSParagraphStyleAttributeName:paragraphStyle,NSFontAttributeName:[NSFont boldSystemFontOfSize:StatusFontSize]};
    
    [self setValue:[[[NSAttributedString alloc] initWithString:status attributes:attr] autorelease] forKey:[NSString stringWithFormat:@"status%d",dutNum]];
}

- (NSString *)initCounter:(int)dutNum
{
    NSString *filePath=[NSString stringWithFormat:@"%@%d.txt",CuntFilePath,dutNum];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath])
        return [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
    
    [@"0" writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
    return @"0";
}

- (void)updateCounter:(int)dutNum
{
    NSString *cuntKey=[NSString stringWithFormat:@"counter%d",dutNum];
    int val=[[self valueForKey:cuntKey] intValue]+1;
    [self setValue:[NSString stringWithFormat:@"%d",val] forKey:cuntKey];
    [[NSString stringWithFormat:@"%d",val] writeToFile:[NSString stringWithFormat:@"%@%d.txt",CuntFilePath,dutNum] atomically:YES encoding:NSUTF8StringEncoding error:nil];
    
    int testLimit=[[[PlistIO sharedPlistIO] getObjForKey:@"TEST_UPPER_LIMIT"] intValue];
    
    if (val>=testLimit)
        [Utility showMessageBox:Information text:[NSString stringWithFormat:@"Test times is out of the upper limit %d",testLimit]];
}

- (void)resetCounter
{
    ValidatorPW *validatorPW=[ValidatorPW new];
    
    if ([validatorPW checkPasswordMsg:@"Reset Test Counter !" checkPassword:@"engineer" changeBGcolor:NO])
    {
        for (int i=1; i<=4; i++)
        {
            [self setValue:@"0" forKey:[NSString stringWithFormat:@"counter%d",i]];
            [@"0" writeToFile:[NSString stringWithFormat:@"%@%d.txt",CuntFilePath,i] atomically:YES encoding:NSUTF8StringEncoding error:nil];
        }
    }
    [validatorPW release];
}

- (void)switchAuditMode
{
    BOOL currentStatus=[_plist isAllowAuditMode];
    
    if (!currentStatus)
    {
        ValidatorPW *validatorPW=[ValidatorPW new];
        BOOL isConfirm=[validatorPW checkPasswordMsg:@"Enter Audit Mode !" checkPassword:@"audit" changeBGcolor:NO];
        [validatorPW release];
        if (!isConfirm)
            return;
    }
    [_plist setIsAllowAuditMode:!currentStatus];
    [self setAuditModeBtnTitle:([_plist isAllowAuditMode])?@"Disable Audit Mode":@"Enable Audit Mode"];
    [_plist savePropertiesToPlist];
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key
{
    NSLog(@"Set Value (%@) To Undefined Key == %@",value,key);
}
@end
