//
//  Bobcat.h
//  BobcatDemo
//
//  Created by Wang Sky on 13-10-18.
//  Copyright (c) 2013年 Wang Sky. All rights reserved.
//


#import <IACFactoryFramework/Equipments.h>
#import <IACFactoryFramework/IACHTTPRequest.h>
#import <IACFactoryFramework/Pudding.h>

//Bobcat basic definition
#define BC_HTTP_POST_METHOD @"POST"
#define BC_Command @"c"
#define BC_Parameter @"p"

//ADD_RECORD Parameter
#define BC_SerialNumber @"sn"                   //Required
#define BC_Product @"product"                   //Required
#define BC_StationName @"test_station_name"     //Required
#define BC_StationID @"station_id"              //Required
#define BC_SoftwareVersion @"sw_version"        //Required
#define BC_TestResult @"result"                 //Required
#define BC_StartTime @"start_time"              //Required
#define BC_StopTime @"stop_time"                //Required
#define BC_OS_BundleVersion @"os_bundle_version"
#define BC_IMEI @"imei"
#define BC_DeviceID @"device_id"
#define BC_UniqueDeviceID @"udid"
#define BC_ECID @"ecid"
#define BC_ICCID @"iccid"
#define BC_Wifi_MAC_Address @"wifi_mac_address"
#define BC_Bluetooth_MAC_Address @"bt_mac_address"
#define BC_USB_MAC_Address @"usb_mac_address"
#define BC_TestMachineID @"mac_address"         //Required
#define BC_SymptomCode @"list_of_failing_tests" //required when test result=FAIL
#define BC_SymptomDescription @"failure_message"//required when test result=FAIL
#define BC_Override @"override"
#define BC_Special_Build @"sbuild"
#define BC_Special_BuildUnitNumber @"sbuild_unit"
#define BC_Blob @"blob"
#define BC_NAND_ID @"nandid"
#define BC_HardwareConfiguration @"hwconfig"
#define BC_Wifi_Vendor @"wifivendor"
#define BC_ColorConfiguration @"clrc"
#define BC_Baseband_SN @"bb_snum"
#define BC_Baseband_Firmware @"bb_firmware_version"
#define BC_StorageSizeLow @"storage_size_low"
#define BC_StorageSizeHigh @"storage_size_high"
#define BC_GrapeSN @"grp_sn"
#define BC_LCD_SN @"lcg_sn"
#define BC_Band_SN @"band_sn"
#define BC_Area @"area"
#define BC_BandSubassemblySN @"ban_sn"
#define BC_BatteryChemicalID @"battery_chemid"
#define BC_FrontCameraSN @"front_nvm_barcode"
#define BC_BackCameraSN @"back_nvm_barcode"
#define BC_AuditMode @"audit_mode"

//QUERY_RECORD Additional Parameter
#define BC_StationID_ForQuery @"tsid"           //Required
#define BC_StationName_ForQuery @"ts"           //Required
#define BC_MarketPart @"mpn"
#define BC_RegionCode @"region_code"

//QUERY_RECORD Station Parameter
#define BC_UnitProcessCheck @"unit_process_check"

//babcat pass fail string
#define BC_PASS @"PASS"
#define BC_FAIL @"FAIL"

@interface Bobcat : Equipments
{
    IACHTTPRequest *request;
    BOOL isReady;
    NSMutableString *stationid;
    NSMutableString *testMachineid;
    NSString* SERVER_URL;
}
@property(readonly)BOOL isReady;
@property(readonly)NSString* stationid;
@property(readonly)NSString* testMachineid;

//构造测试序号资料，只有如此才能够对序号进行操作 TRUE 成功，FALSE失败
-(Boolean)initializeSerialNumber:(NSString*)SN;

/*添加记录,关于addDic必须包含9对dictionary，其他的是可选的。
sw_version=sw
test_station_name=test
sn=12345678901F3MQXX
start_time=20120310
station_id=station
stop_time=20120311
product=product
result=PASS
mac_address=mac_address
 */
-(Boolean)addRecord:(NSDictionary*)addDic;

//查询记录，SN为要查询序号，queryArray为要查询key值的数组
-(NSDictionary*)queryRecord:(NSString*)SN queryArray:(NSArray*)queryArray;

//查询某一站的信息，queryArray｛station_id,sw_version,result,start_time,stop_time,mac_address,list_of_failing_tests,failure_message,blob,unit_process_check｝
-(NSDictionary*)queryRecord:(NSString*)SN queryStation:(NSString*)station queryStationID:(NSString*)stationID queryArray:(NSArray*)queryArray;

//查询历史 失败返回nil 成功返回具体数据
-(NSString*)queryHistory:(NSString*)SN;

//查询服务器版本 失败返回nil 成功返回具体数据
-(NSString*)queryVersion;

-(id)initWithArg:(NSDictionary *)dic;
-(void)DEMO ;

- (NSString *)testSN:(NSString *)caseSN withLeftSN:(NSString *)LSN withRightSN:(NSString *)RSN;
- (NSString *)saveSN:(NSString *)caseSN withLeftSN:(NSString *)LSN withRightSN:(NSString *)RSN withLeftFail:(NSString *)itemL withRightFail:(NSString *)itemR withCaseFail:(NSString *)itemC withResult:(NSString *)aresult;
@end
