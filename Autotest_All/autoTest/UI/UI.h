//
//  UI.h
//  autoTest
//
//  Created by TOM on 19/4/12.
//  Copyright © 2019 TOM. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PlistIO.h"
#import "Pudding.h"
#import "ControlBits.h"
#import "VisaUSB.h"
#import "UI_Outlet.h"
#import "ValidatorPW.h"
#import "ThreadSync.h"
#import "CSV.h"

typedef enum _ControlMode
{
    ScanSn,//manual scan sn for 1 & 4 up
    AutoReadSn,//auto read sn from DUT for 1 & 4 up
    TempSn//for manual scan sn & 4 independent start button
}ControlMode;

@interface UI : NSObject <NSTextFieldDelegate>
{
    NSMutableDictionary *settingDic;
    NSArray *puddingArray;
    NSArray *ctrlbitsArray;
    NSArray *validatorPWArray;
    Pudding *pudding1,*pudding2,*pudding3,*pudding4;
    ControlBits *ctrlbits1,*ctrlbits2,*ctrlbits3,*ctrlbits4;
    ValidatorPW *validatorPW1,*validatorPW2,*validatorPW3,*validatorPW4;
    ThreadSync *threadSync;
    CSV *csv;
    IBOutlet NSWindow *window;
    IBOutlet NSPanel *settingWindow;
    IBOutlet NSTextField *sn1,*sn2,*sn3,*sn4,*temp_sn;
    IBOutlet NSButton *startBtn1,*startBtn2,*startBtn3,*startBtn4;
    IBOutlet NSTableView *table1,*table2,*table3,*table4;
    ControlMode ctrlMode;
}
@property (assign) PlistIO *plist;
@property (assign) UI_Outlet *uiOutlet;
@end
