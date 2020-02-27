//
//  UI.m
//  autoTest
//
//  Created by TOM on 19/4/12.
//  Copyright © TOM. All rights reserved.
//

#import "UI.h"
#import "UART.h"
#import "IAC_Function.h"
#import "Utility.h"
#define IS_1UP ((sn2==nil) && (sn3==nil )&& (sn4==nil))
#define Test_Simultaneously_ByFixture //for only one start button case (1 up or One Big Start button)
#define RESERVE @""
#define SN_LEN 17

@implementation UI

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    puddingArray=[[NSArray alloc] initWithObjects:RESERVE,pudding1=[Pudding new],pudding2=[Pudding new],pudding3=[Pudding new],pudding4=[Pudding new],nil];
    ctrlbitsArray=[[NSArray alloc] initWithObjects:RESERVE,ctrlbits1=[ControlBits new],ctrlbits2=[ControlBits new],ctrlbits3=[ControlBits new],ctrlbits4=[ControlBits new],nil];
    validatorPWArray=[[NSArray alloc] initWithObjects:RESERVE,validatorPW1=[ValidatorPW new],validatorPW2=[ValidatorPW new],validatorPW3=[ValidatorPW new],validatorPW4=[ValidatorPW new],nil];
    ctrlMode = TempSn;
    [self setPlist:[PlistIO sharedPlistIO]];
    [self setUiOutlet:[UI_Outlet sharedInstance]];
    [self initMainUI];
    [self initSettingUI];
    threadSync=[ThreadSync new];
    csv=[CSV new];
    (_plist.isAllowPrefer)?[self clickOnShowSubWindow:self]:[_plist equipmentInit];
}

- (void)dealloc
{
    [settingDic release];
    [threadSync release];
    [pudding1 release];[pudding2 release];[pudding3 release];[pudding4 release];
    [ctrlbits1 release];[ctrlbits2 release];[ctrlbits3 release];[ctrlbits4 release];
    [validatorPW1 release];[validatorPW2 release];[validatorPW3 release];[validatorPW4 release];
    [puddingArray release];
    [ctrlbitsArray release];
    [validatorPWArray release];
    [super dealloc];
}

#pragma mark  Button & Menu Item Clicked Action

- (IBAction)clickOnTempBtn:(id)sender {
    NSInteger dutNum=[sender tag];
    [_uiOutlet setValue:_uiOutlet.temp_sn_str forKey:[NSString stringWithFormat:@"sn%ld_str",(long)dutNum]];
    [_uiOutlet setTemp_sn_str:@""];
}

- (IBAction)clickOnBigStartBtn:(id)sender
{
#ifdef Test_Simultaneously_ByFixture
    if (![self fixtureAction:@"PUSH_IN"])
        return;
    
    if(ctrlMode!=AutoReadSn && ![self confirmSNx4])
        return;
    
    [_uiOutlet setBigStartBtn_enable:NO];
    [threadSync Reset];
    
    [startBtn1 performClick:startBtn1];
    [startBtn2 performClick:startBtn2];
    [startBtn3 performClick:startBtn3];
    [startBtn4 performClick:startBtn4];
#endif
}

- (IBAction)clickOnStartBtn:(id)sender
{
    int dutNum=[[sender identifier] intValue];
    [self resetUI:dutNum];
    //NSString __block *sn;
    dispatch_group_t taskGroup=dispatch_group_create();
    [threadSync SetSyncPointOnTC:NotYet_PassThru forThread:dutNum];
    
    switch (dutNum)
    {
        case 1: [_uiOutlet setStartBtn1_enable:NO]; break;
        case 2: [_uiOutlet setStartBtn2_enable:NO]; break;
        case 3: [_uiOutlet setStartBtn3_enable:NO]; break;
        case 4: [_uiOutlet setStartBtn4_enable:NO]; break;
        default: break;
    }
    
    [self tempSN_SettingByDutNum:dutNum];
    
    dispatch_group_async(taskGroup,dispatch_get_global_queue(0, 0),^{
        if (ctrlMode==AutoReadSn)
            [self autoRead_SN:dutNum];
    });
    
    dispatch_group_notify(taskGroup,dispatch_get_main_queue(),^{
        if ([self validateSN:[_uiOutlet valueForKey:[NSString stringWithFormat:@"sn%d_str",dutNum]]])
        {
            switch (dutNum)
            {
                case 1: [_uiOutlet setSn1_enable:NO]; break;
                case 2: [_uiOutlet setSn2_enable:NO]; break;
                case 3: [_uiOutlet setSn3_enable:NO]; break;
                case 4: [_uiOutlet setSn4_enable:NO]; break;
                default: break;
            }
            [_uiOutlet updateStatus:@"TESTING" dutNum:dutNum];
            [self performSelectorInBackground:@selector(executTest:) withObject:[NSNumber numberWithInt:dutNum]];
        }
        else
        {
            switch (dutNum)
            {
                case 1: [_uiOutlet setStartBtn1_enable:YES]; break;
                case 2: [_uiOutlet setStartBtn2_enable:YES]; break;
                case 3: [_uiOutlet setStartBtn3_enable:YES]; break;
                case 4: [_uiOutlet setStartBtn4_enable:YES]; break;
                default: break;
            }
            [_uiOutlet updateStatus:@"" dutNum:dutNum];
            [threadSync FillinStatus:Skiped forThread:dutNum];
            [self waitWholeTestEnd];
        }
    });
}

- (IBAction)clickOnShowSubWindow:(id)sender
{
    [_uiOutlet setHideSubWindowBtn:YES];
    [window orderBack:settingWindow];
    [window beginCriticalSheet:settingWindow completionHandler:^(NSInteger result) { [_uiOutlet setHideSubWindowBtn:NO]; } ];
}

- (IBAction)clickOnApplyBtn:(id)sender
{
    /*if (![self checkUartPathSeting])
     {
     [Utility showMessageBox:Error info:@"The UART path setting is overlape or empty"];
     return;
     }*/
    
    if ([Utility showMessageBox:Question text:@"Please confirm to reserved these setting ?"])
    {
        for (NSString *key in [settingDic keyEnumerator])
        {
            NSComboBox *combobox=[settingDic objectForKey:key];
            [_plist saveEquipmentDataToPlist:key forKey:@"PATH" value:[combobox stringValue]];
        }
        [_plist setIsAllowPrefer:NO];
        [_plist savePropertiesToPlist];
        [_plist equipmentInit];
    }
    [window endSheet:settingWindow];
}

- (IBAction)clickOnResetTestCounterBtn:(id)sender
{
    [_uiOutlet resetCounter];
}

- (IBAction)clickOnAuditModeBtn:(id)sender
{
    [_uiOutlet switchAuditMode];
}

#pragma mark Assist code
- (void)executTest:(NSNumber*)dutNumer
{
    __block int dutNum=[dutNumer intValue];
    __block NSString *sn;
    dispatch_sync(dispatch_get_main_queue(),^{
        sn=[_uiOutlet valueForKey:[NSString stringWithFormat:@"sn%d_str",dutNum]];
        [window setBackgroundColor:([_plist isAllowAuditMode])?[NSColor magentaColor]:[NSColor yellowColor]];
    });
    
    NSString *startTestingTime=[Utility getTimeBy24hrStdFormate];
    NSAutoreleasePool *pool=[NSAutoreleasePool new];
    IAC_Function *fun=[[IAC_Function alloc] initWithDutNum:dutNum withThreadsync:threadSync];
    NSMutableString *failedList = [NSMutableString new];
    
    for (int i=0; i<[_plist.TestItemList count]; i++)
    {
        Item *item=_plist.TestItemList[i];
        
        if (!item.isSkip)
        {
            NSDate *beginTime=[NSDate date];
            NSArray *sns=[NSArray arrayWithObjects:sn, @"MLB_SN", @"MPN", @"Region", nil];
            NSArray *other=[NSArray arrayWithObjects:puddingArray[dutNum],ctrlbitsArray[dutNum],validatorPWArray[dutNum],nil];
            NSArray *args=[NSArray arrayWithObjects:item.Name,item.Command,item.Validator,item.Min,item.Max,item.Unit,sns,other,nil];
            
            if ([item.Name isEqualToString:@"finishWorkHandler"])
            {
                @synchronized(self.class){ [fun performSelector:NSSelectorFromString(@"finishWorkHandler:") withObject:args]; }
            }
            else
                [fun performSelector:NSSelectorFromString([NSString stringWithFormat:@"%@:",item.Name]) withObject:args];
            
            __block NSString *displayStr=[NSString stringWithString:fun.testDisplayMessage];
            __block NSString *testValue=[NSString stringWithString:fun.testValue];
            __block NSString *result=fun.isPass?@"PASS":@"FAIL";
            [failedList appendString:fun.isPass?@"":[NSString stringWithFormat:@"%@--%d\r",item.Name,dutNum]];
            
            dispatch_sync(dispatch_get_main_queue(),^{
                switch (dutNum)
                {
                    case 1: [_uiOutlet setFailList1:failedList];break;
                    case 2: [_uiOutlet setFailList2:failedList];break;
                    case 3: [_uiOutlet setFailList3:failedList];break;
                    case 4: [_uiOutlet setFailList4:failedList];break;
                    default: break;
                }
                [item setResult:result displayStr:displayStr valueStr:testValue item:item dutNum:dutNum];
                [item setValue:[NSString stringWithFormat:@"%.4f",[[NSDate date] timeIntervalSinceDate:beginTime]] forKey:[NSString stringWithFormat:@"Time_%d",dutNum]];
            });
        }
        else
        {
            dispatch_sync(dispatch_get_main_queue(),^{
                [item setResult:@"SKIP" displayStr:@"Untested" valueStr:nil item:item dutNum:dutNum];
                [item setValue:@"0" forKey:[NSString stringWithFormat:@"Time_%d",dutNum]];
            });
        }
        
        dispatch_sync(dispatch_get_main_queue(),^{
            switch (dutNum)
            {
                case 1: [table1 scrollRowToVisible:i]; break;
                case 2: [table2 scrollRowToVisible:i]; break;
                case 3: [table3 scrollRowToVisible:i]; break;
                case 4: [table4 scrollRowToVisible:i]; break;
                default: break;
            }
        });
    }
    
    dispatch_sync(dispatch_get_main_queue(),^{
        [csv saveOppRecord:sn dutNum:dutNum begin:startTestingTime rSN:NULL tSN:NULL uNum:NULL sID:NULL];
        [csv saveCycleTimeRecord:sn dutNum:dutNum];
        [_uiOutlet updateCounter:dutNum];
        [_uiOutlet updateStatus:([_plist checkIsAllPass:dutNum])?@"PASS":@"FAIL" dutNum:dutNum];
        
        switch (dutNum)
        {
            case 1: [_uiOutlet setStartBtn1_enable:YES]; [_uiOutlet setSn1_enable:ctrlMode==ScanSn?YES:NO]; [_uiOutlet setSn1_str:@""]; break;
            case 2: [_uiOutlet setStartBtn2_enable:YES]; [_uiOutlet setSn2_enable:ctrlMode==ScanSn?YES:NO]; [_uiOutlet setSn2_str:@""]; break;
            case 3: [_uiOutlet setStartBtn3_enable:YES]; [_uiOutlet setSn3_enable:ctrlMode==ScanSn?YES:NO]; [_uiOutlet setSn3_str:@""]; break;
            case 4: [_uiOutlet setStartBtn4_enable:YES]; [_uiOutlet setSn4_enable:ctrlMode==ScanSn?YES:NO]; [_uiOutlet setSn4_str:@""]; break;
            default: break;
        }
        [threadSync SetSyncPointOnTC:Passthru forThread:dutNum];
        
        [self waitWholeTestEnd];
    });
    
    [fun release];
    [failedList release];
    [pool drain];
}

- (void)waitWholeTestEnd
{
#ifdef Test_Simultaneously_ByFixture
    if ([threadSync CheckSyncPointOnUI])
    {
        if (![self fixtureAction:@"PULL_OUT"])
        {
            [Utility showMessageBox:Error text:@"Please contact the PE to check te Fixture"];
        }
        
        [_uiOutlet setBigStartBtn_enable:YES];
        [sn1 becomeFirstResponder];
        [window setBackgroundColor:[NSColor controlColor]];
        //[Utility showMessageBox:Information text:@"Test is Finished & Done"];
    }
#else
    [sn1 becomeFirstResponder];
    [window setBackgroundColor:[NSColor controlColor]];
    //[Utility showMessageBox:Information text:@"Independent One Test is Finished & Done"];
#endif
    
}

- (void)tempSN_SettingByDutNum:(int)dutNum
{
    if([[_uiOutlet valueForKey:[NSString stringWithFormat:@"sn%d_str",dutNum]] length] != SN_LEN) {
        [_uiOutlet setValue:_uiOutlet.temp_sn_str forKey:[NSString stringWithFormat:@"sn%d_str",dutNum]];
        [_uiOutlet setTemp_sn_str:@""];
    }
}

-(void)autoRead_SN:(int)dutNum
{
    //TODO:read sn By diagnose command
    sleep(2);//simulate working time jsut for test
    NSString *sn=[NSString stringWithFormat:@"%dXXXXXXXXZZZZZZZZ",dutNum];//@"Auto Read SN Error !";
    dispatch_sync(dispatch_get_main_queue(),^{
        switch (dutNum)
        {
            case 1: [_uiOutlet setSn1_str:sn]; break;
            case 2: [_uiOutlet setSn2_str:sn]; break;
            case 3: [_uiOutlet setSn3_str:sn]; break;
            case 4: [_uiOutlet setSn4_str:sn]; break;
            default: break;
        }
    });
}

- (BOOL)fixtureAction:(NSString*)action
{
    //TODO: Fixture control operaation
    if ([action isEqualToString:@"PUSH_IN"])
    {
        return YES;
    }
    else if ([action isEqualToString:@"PULL_OUT"])
    {
        return YES;
    }
    return NO;
}

- (void)resetUI:(int)dutNum
{
    for (Item *item in _plist.TestItemList)
    {
        [item setResult:@"" displayStr:nil valueStr:nil item:item dutNum:dutNum];
    }
    
    switch (dutNum)
    {
        case 1: [_uiOutlet setFailList1:@""]; break;
        case 2: [_uiOutlet setFailList2:@""]; break;
        case 3: [_uiOutlet setFailList3:@""]; break;
        case 4: [_uiOutlet setFailList4:@""]; break;
        default: break;
    }
    
    [_uiOutlet updateStatus:@"" dutNum:dutNum];
}

- (BOOL)validateSN:(NSString*)sn
{
    if ([sn containsString:@"Auto Read SN Error !"])  return NO;
    if ([sn length]!=SN_LEN)                          return NO;
    
    //TODO:insert others validate SN rule
    
    return YES;
}

- (BOOL)confirmSNx4
{
    if ([_uiOutlet.sn1_str length]==0 && [_uiOutlet.sn2_str length]==0 && [_uiOutlet.sn3_str length]==0 && [_uiOutlet.sn4_str length]==0)
    {
        [Utility showMessageBox:Error text:@"no sn input"];
        return NO;
    }
    NSMutableString *temp=[[NSMutableString new] autorelease];
    
    for (int i=1; i<=4; i++)
    {
        NSString *sn=[_uiOutlet valueForKey:[NSString stringWithFormat:@"sn%d_str",i]];
        
        if([sn length]>0)
        {
            if([temp containsString:sn])
            {
                [Utility showMessageBox:Error text:@"there is a overlap occurred between these sn"];
                return NO;
            }
            else
                [temp appendString:sn];
        }
    }
    return YES;
}

- (void)initMainUI
{
    [window setTitle:[NSString stringWithFormat:@"%@:%@ <Pudding:%s>",_plist.StationName,_plist.SW_Ver,[Pudding getVersion]]];
#ifdef Test_Simultaneously_ByFixture
    [_uiOutlet setHideBigStartBtn:NO];
#else
    [_uiOutlet setHideBigStartBtn:YES];
#endif
    [_uiOutlet setStartBtn1_hidden:!_uiOutlet.hideBigStartBtn];
    [_uiOutlet setStartBtn2_hidden:!_uiOutlet.hideBigStartBtn];
    [_uiOutlet setStartBtn3_hidden:!_uiOutlet.hideBigStartBtn];
    [_uiOutlet setStartBtn4_hidden:!_uiOutlet.hideBigStartBtn];
    [_uiOutlet setTemp_sn_hidden:ctrlMode==TempSn?NO:YES];
    [_uiOutlet setSn1_enable:ctrlMode==ScanSn?YES:NO];
    [_uiOutlet setSn2_enable:ctrlMode==ScanSn?YES:NO];
    [_uiOutlet setSn3_enable:ctrlMode==ScanSn?YES:NO];
    [_uiOutlet setSn4_enable:ctrlMode==ScanSn?YES:NO];
    [_uiOutlet setStartBtn1_enable:YES];
    [_uiOutlet setStartBtn2_enable:YES];
    [_uiOutlet setStartBtn3_enable:YES];
    [_uiOutlet setStartBtn4_enable:YES];
    [_uiOutlet setBigStartBtn_enable:YES];
}

- (void)initSettingUI
{
    settingDic=[NSMutableDictionary new];
    
    CGFloat y=8;
    NSArray *eq=[_plist getEquipmentList];
    NSMutableArray *usbList=[NSMutableArray new];
    
    for (int i=0; i<[eq count]; i++)
    {
        NSString *usedfor=eq[i][@"USEDFOR"];
        NSTextField *lable=[[NSTextField alloc] initWithFrame:NSMakeRect(10,y,125,23)];
        [lable setStringValue:usedfor];
        [lable setBezeled:NO];
        [lable setEditable:NO];
        [lable setSelectable:NO];
        [lable setDrawsBackground:NO];
        
        NSComboBox*combobox=[[NSComboBox alloc] initWithFrame:NSMakeRect(133,y,270,25)];
        [combobox setEditable:NO];
        
        if ([eq[i][@"CTL_TYPE"] isEqualToString:@"VISAUSB"])
        {
            VisaUSB *visaUSB=[[VisaUSB alloc] init];
            [usbList setArray:[visaUSB findUSBDevices]];
            [combobox addItemsWithObjectValues:usbList];
            [visaUSB release];
        }
        else if ([eq[i][@"CTL_TYPE"] isEqualToString:@"UART"])
        {
            UART *uart=[UART new];
            [combobox addItemsWithObjectValues:[uart uartList]];
            [uart release];
        }
        
        ([eq[i][@"PATH"] length]>0)?[combobox selectItemWithObjectValue:eq[i][@"PATH"]]:[combobox selectItemAtIndex:0];
        
        [settingDic setObject:combobox forKey:usedfor];
        [[settingWindow contentView] addSubview:lable];
        [[settingWindow contentView] addSubview:combobox];
        [lable release];
        [combobox release];
        y+=30;
    }
    [settingWindow setFrame:NSMakeRect(0,0,410,70+y) display:YES];
    [usbList release];
}

- (BOOL)checkUartPathSeting
{
    NSMutableArray *temp=[[[NSMutableArray alloc] init] autorelease];
    
    for (NSString *key in [settingDic keyEnumerator])
    {
        NSComboBox *combobox=[settingDic objectForKey:key];
        if ([temp containsObject:[combobox stringValue]] || [[combobox stringValue] length]==0)
            return NO;
        else
            [temp addObject:[combobox stringValue]];
    }
    return YES;
}

- (void)controlTextDidChange:(NSNotification *)notification
{
    NSTextField *textField=[notification object];
    
    if ([[textField stringValue] length] == SN_LEN)
    {
        if (ctrlMode==TempSn)
        {
            [temp_sn becomeFirstResponder];
            return;
        }
        if(IS_1UP)
        {
            [sn1 becomeFirstResponder];
            return;
        }
        
        if ([textField isEqual:sn1] && [sn2 isEnabled])      [sn2 becomeFirstResponder];
        else if ([textField isEqual:sn2] && [sn3 isEnabled]) [sn3 becomeFirstResponder];
        else if ([textField isEqual:sn3] && [sn4 isEnabled]) [sn4 becomeFirstResponder];
        else if ([textField isEqual:sn4] && [sn1 isEnabled]) [sn1 becomeFirstResponder];
    }
}
@end
