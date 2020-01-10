//
//  UI_Outlet.h
//  MyBinding_Test
//
//  Created by Terry.Hsu on 2018/9/13.
//  Copyright © 2018 Terry.Hsu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <IACFactoryFramework/PlistIO.h>

@interface UI_Outlet : NSObject
{
    NSMutableParagraphStyle *paragraphStyle;
}
@property (assign) PlistIO *plist;
@property (assign) BOOL sn1_enable,sn2_enable,sn3_enable,sn4_enable;
@property (assign) BOOL temp_sn_hidden;
@property (assign) BOOL startBtn1_enable,startBtn2_enable,startBtn3_enable,startBtn4_enable;
@property (assign) BOOL startBtn1_hidden,startBtn2_hidden,startBtn3_hidden,startBtn4_hidden;
@property (assign) BOOL bigStartBtn_enable;
@property (assign) BOOL hideBigStartBtn;
@property (assign) BOOL hideSubWindowBtn;
@property (assign) NSString *auditModeBtnTitle;
@property (assign) NSString *sn1_str,*sn2_str,*sn3_str,*sn4_str,*temp_sn_str;
@property (assign) NSString *counter1,*counter2,*counter3,*counter4;
@property (assign) NSAttributedString *status1,*status2,*status3,*status4;
@property (assign) NSString *failList1,*failList2,*failList3,*failList4;
+ (UI_Outlet *)sharedInstance;
- (void)updateStatus:(NSString*)status dutNum:(int)dutNum;
- (void)updateCounter:(int)dutNum;
- (void)resetCounter;
- (void)switchAuditMode;
@end
