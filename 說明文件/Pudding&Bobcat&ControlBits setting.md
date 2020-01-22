###Pudding 設定：

1. <font color="red">ini.plist內Allow_Pudding設定 Boolean = YES/NO，表示是否允許啟用Pudding功能。</font>
2. <font color="red">libInstantPudding.dylib：  必須存在於/usr/local/lib/libInstantPudding.dylib。</font>
3. <font color="red">libIPSFCPost.dylib：必須存在於/usr/local/lib/libIPSFCPost.dylib。</font>	
4. Function中每個method需要處理的變數：
	* testValue ：必須是數值（pudding 的要求），若測試項結果非數值類型，則以該項的測試結果當作數值（PASS=1, FAIL=0）
	* testMessage ：pudding對fail測試項增加上傳的fail message，簡潔的敘述。
	* testDisplayMessage： 用於顯示在UI/Log上的 Value。(即之前版本的testValue)
	* 新增 skipBelowTest 變數，其作用是當此變數為true時會跳過之後的測試，而之後的測試在ui 上value 會顯示skiped而result 則會顯示 pass
	* pudding/bobcat的回傳機制，現階段我們大概有三種情況可能會啟動skipBelowTest機制:1. 進不了diag , amiokay fail*2 case(2. out of process fail 3.fatal error)
現在開始我們只在finishworkhandler結束時才destory pudding..其他地方不會無端中斷pudding上傳動作
換句話說啟動skipBelowTest(1.進不了diag 2.out of process fail 3.fatal error)之後仍然要上傳PDCA/Bobcat
	* 由於autoTest 在v4.4 後 init_before_test 改為一個巨集定義函數，因此在Function.m填入測試內容時，每個測試method第一行要改為呼叫init_before_test，其中RTC_Set和finishworkhandler是呼叫init_before_test_wo_skip
	 
			例：-(void)DEMO:(NSMutableArray *)args
			{
			    init_before_test
			    //TODO:test content
			} 
			例：-(void)finishworkhandler:(NSMutableArray *)args
			{
			    init_before_test_wo_skip
			    //TODO:pudding content
			}  
	* init_before_test會在pudding正常的情況下檢查AMIOK，當AMIOK失敗則skipBelowTest即設定為TRUE
5. <font color="red">在Auto Test中，第一個測試項必須是CheckPudding，目的是啓動Pudding handler 並 記錄開始測試時間。也透過AMIOK來判斷Pudding是否正常運作，如果Fail情況就將以下的所有測項skip。(已經是通用格式,理論上無需改動)</font>
6. <font color="red">在Auto Test中，呼叫finishWorkHandler將包括finishWorkHandler本身之前的所有的測試項資料上傳server,finishWorkHandler不一定要是最後一個測試項。 (若有需要加入Attribute或Blob，請詳見以下注意事項)</font>
7. 當有要上傳測試資料到SFC，可調用pudding下SFC函數：
	* SFC_getLibVersion
	* SFC_getServerVersion
	* SFC_getHistoryBySN
	* SFC_AddRecord
	* SFC_QueryRecordBySn
	* 說明和範例
		- SFC_AddRecord & SFC_QueryRecordBySn都應該放在function.m內
		- SFC_AddRecord可視為利用pudding API直接做Bobcat AddRecord動作,正確運行返回0,底下舉例的8對key-value是必須的,result這個key值表最終測試結果如果為fail則需增加Symptom Code(key)-list_of_failing_tests(value)和Symptom Description(key)-ailure_message(value)的設置 (詳見Bobcat spec)
		- SFC_QueryRecordBySn可視為利用pudding API直接做BobcatQueryRecord動作,傳入的key值array內容必須由IT/客人定義
		- 以下為程式範例：（因為每一站的Parameter設定不同，可使用的Parameter也不同，為了避免因為沒有Parameter而導致程式crash，請使用@try,@catch語法）


				udding *pudding = [self catchObj:args name:pudding]; 
 
        		NSLog(@"SFC_getLibVersion = %s",[pudding SFC_getLibVersion]);
        		NSLog(@"SFC_getServerVersion = %s",[pudding SFC_getServerVersion]);
        		NSLog(@"SFC_getHistoryBySN = %s",[pudding SFC_getHistoryBySN:[self catchObj:args name:SN]]);
        		
       			NSDictionary* addDic = [NSDictionary dictionaryWithObjectsAndKeys:@"1.0d48", @"sw_version",@"FACT 1",@"test_station_name",@"PGPD_F05-3FT-AF02_2_FACT 1",@"station_id",@"2015-3-21 18:33:12",@"stop_time",@"2015-3-21 18:32:01", @"start_time", @"pro",@"product",@"PASS" ,@"result",@"00:25:00:f4:8f:99",@"mac_address",nil];
       			
        		NSLog(@"SFC_AddRecord = %d",[pudding SFC_AddRecord:[self catchObj:args name:SN] withDictionary:addDic]);
        		NSArray *queryArray = [NSArray arrayWithObjects:@"speaker_1",@"fgsn",@"mlbsn",@"sbuild",@"sbuild_unit",@"battery_sn",nil];
 
        		@try 
        		{
            		NSMutableDictionary *strQueryRecordBySn = [[NSMutableDictionary alloc] init];
           			[strQueryRecordBySn setDictionary: [pudding SFC_QueryRecordBySn:[self catchObj:args name:SN] withKeyArray:queryArray]];
            		NSLog(@"SFC_QueryRecordBySn = %@", strQueryRecordBySn);
            		[strQueryRecordBySn release];
        		}
        		@catch (NSException *exception) 
        		{
            		NSString *strTemp = [NSString stringWithFormat:@"Error message:%@", [exception description]];
            		NSRunAlertPanel(NSLocalizedString(@"Exception", nil) , NSLocalizedString(strTemp, nil) , NSLocalizedString(@"OK", nil), nil,nil);
        		}
        		@finally 
        		{
        			//TODO:
        		}


###ControlBits 設定：
1. <font color="red">libCBAuth.dylib：必須存在於/usr/local/lib/libCBAuth.dylib。</font>

2. <font color="red">在ini.plist中MY_CB設定Station CB index(e.g. 0x10),My_CB設為-1表關閉CB功能</font>

3. 當有Control Bits的需求時，在ini.plist中必須增加ControlBit測項，同時將以下的CB函數加入function.m中,且function必須是CBdelegate的delegate：
	* CBRead			（delegate function）
	* CBWrite			（delegate function）
	* CBErase			（delegate function）
	* CBRead_Fail_count （delegate function）
	* CBErrorInfoToPDCA （delegate function）

	若沒有Control Bits的需求時，即移除ini.plist中的ControlBit測項(CheckControlBits,SetCB_I,SetCB)，同時刪除以上function內函數。
	
4. 當CBWrite要寫PASS時候需要Secret Key(由客人提供)以及CBNONCE，作為CBAuth_API中SHA1函數的參數來取的真正的PASS Key。而在程式中是將Secret Key加以Base64編碼紀錄起來，然後在要確定寫入PASS時會在以Base64解碼成原來的Secret Key。

5. function.m內CBErrorInfoToPDCA功能是將CB Error直接上傳PDCA。(可在相關文件查閱)

6. ControlBits有兩種模式:Normal mode和Audit mode可在相關文件查閱，主要差別是Audit mode不管out of process fail情況。Mode的切換可以在APP介面上的Menu中CBMode設定並且需要輸入密碼(password:audit)。(在ini.plist中"ALLOW_AUDIT_MODE"來決定當下的CB Mode,預設為NO) 

7. 客人confirm與CB文件流程圖不同之處:
從GH端讀取到allowFailCount=-1的時候，表示不比對機器內的(relative)FailCount
(function) audit mode下遇到GH端讀取到allowFailCount=-1時候，至少要保持該站CB測試結果為Fail(至少寫一次fail)
GH端讀取到CBsToCheck為空(size=0), 除了不check前站CB之外亦不比對FailCount

####※其他注意事項：
* 程式中的ValidatorPW類別的函數功能: 會跳出警示視窗並要求輸入密碼。  
-(BOOL)checkPasswordMsg:(NSString *)msg checkPassword:(NSString*)password changeBGcolor:(BOOL)isBGChange;   
參數msg:提示訊息  
參數password:指定密碼  
參數isBGChange:改變背景顏色(紅黃變色)

* APP介面上有Test Times計數器，可以在Menu中View->Clear Test Times來清空此計數器值並且需要輸入密碼(password:engineer)。ini.plist中可以設定TEST_UPPER_LIMIT，主要用於治具使用的上限次數。當計數器值大於設定的上限次數，會跳出警示窗。

* Pudding log 中，測試項名稱不可重覆，否則只會記錄第一個的資訊。

* Pudding log 中，在function 的 testValue必須是存 “NA” 或 數值，否則不記錄資料，若為“NA” 最後導出的PDCA 報表該欄位會是空白。

* 正確設定Pudding後，程式會自動產生 results.Json 檔，失敗則會產生 results.tmp 檔。

* 在Pudding.m 中 UUT_AddAttribute method，可以在Function.m中的finishWorkHandler內呼叫，藉此新增上傳Pudding所需要的Attribute, 且Attribute的值必須是NSString類別

* IACFactoryFramework.framework封裝內自動完成的attribute包含：
 * UUT_ADDATTRIBUTE_SERIALNUMBER
 * UUT_ADDATTRIBUTE_STATIONSOFTWAREVERSION
 * UUT_ADDATTRIBUTE_STATIONSOFTWARENAME
 * UUT_ADDATTRIBUTE_STATIONLIMITSVERSION
 * UUT_ADDATTRIBUTE_STATIONIDENTIFIER
 * 在Pudding.m 中 UUT_AddBlob method，可以在Function.m中的finishWorkHandler內呼叫，藉此上傳DUT的UART Logs
 * 在Pudding.m 中 UUTTestSpecSetSubTestName/UUTTestSpecSetSubSubTestName可以上傳sub_name/sub_sub_name

###Pudding 測試：

1. Groundhog配置文檔存於 Vault 資料夾。 (路徑：/vault)
	* gh_station_info.json 存於 /vault/data_collection/test_station_config
	* station_health_check.json 存於 /vault/data_collection/test_station_config

	如果不存在請確保Groundhog有正常運作。如果非Groundhog環境，請自行複製該文檔至對應路徑。

2.	二種Pudding logs存於 Vault 資料夾。 
	* instantPudding.log 存於 /vault。
	* results.Json檔 存於 /Vault/data_collection/uut_data(uut_data_bobcat) 對應的最新commit資料夾底下。audit mode資料夾: /Vault/data_collection/uut_data_audit
	
		如果不存在results.Json而僅僅是results.tmp，請檢查第一步的配置是否正常。

3.	results.Json 的相關資訊
	每一個測項的記錄內容：
	
			{
			
			"lower_limit" : "100.000000",     => 從 .plist 的 max 取得
			
			"message" : "no error",           => testMessage 內容
			
			"parametric_key" : "DEMO",
			
			"priority" : 0,
			
			"result" : "fail",                => 該項測試結果
			
			"test" : "DEMO",                  => 從 .plist 的 name 取得
			
			"units" : "mV",                   => 從 .plist 的 unit 取得
			
			"upper_limit" : "-1.000000",      => 從 .plist 的 min 取得
			
			"value" : "NA"                    => testValue 內容，必須是數值(測試項無數值則 Pass:0, Fail:1)，否則測試數據不會上傳
			},

4.	測試站的屬性設定
	
		"test_station_attributes" : 
		{
			"ip_version" : "1.1.74",									=> 目前Pudding (libInstantPudding.dylib) 的版本號
			
			"limits_version" : "1",
			
			"mac_addr" : "00:23:df:e0:04:e2",
			
			"software_name" : "FCT",									=> 從 .plist 的 SationName 取得名稱
			
			"software_version" : "3.0",									=> 專案中軟體的版本號
			
			"station_id" : "IACP_P02-4FT-12A_2_SHIPPING-SETTINGS",						=>  由GH生成的vault資料夾定義ID 
			
			"station_name" : "SHIPPING-SETTINGS"						=> 由GH生成的vault資料夾定義名稱
			},
			
			
---

###PDCA 登入方式：
* 若無法存取浦東公司網絡須先連上MRD(=Microsoft Remote Desktop)至IAC(rdp.iacwork.com),台北這邊通常需要多試幾次
* 若人在浦東公司網絡直接使用ie開啟PDCA網址(http://17.239.132.36/cgi-bin/WebObjects/QCR.woa/9/wo/W7GMQ0tqo1AgtZ000VR3d0/0.3.7.5)
連進網頁後會顯示登入PDCA畫面，帳號密碼分別為chang.tessa/apple321 or wang_gary和Apple@12345

###Bobcat 設定：
* spec:Bobcat Fields Definition.pdf&Bobcat Interface Specification 4.1.4.pdf&Bobcat Routing, Retest, and Data Flow 1.2.pdf  

###Bobcat 手動驗證方式：
* 使用curl命令工具對server驗證Bobcat查詢軟體版本的功能以及query一筆資料的功能
* query一筆資料使用IAC VPN(vpn.iacwork.com,把Advanced..下的send all traffic over VPN connection打開)
開啟console執行以下範例 (c=是post的意思)
 * xuzhiweideMacBook-Pro:~ Terry$ curl -d "c=QUERY_RECORD&sn=CC4T80V7HQK8&p=ecid" http://10.159.252.11/FIS/MAY/MvcBobcat_A7/Home/B238
0 SFC_OK
ecid=0x00054C80382BC226
* 查詢SERVER軟體版本使用Windows Remote Desktop(https://itunes.apple.com/us/app/microsoft-remote-desktop/id715768417?mt=12)範例如下: 
 * 開啟Windows Remote Desktop執行IE輸入http://10.159.252.11/FIS/MAY/MvcBobcat_A7/Home/B238?c=SERVER_VERSION
瀏覽器上回應:0 SFC_OK SERVER_VERSION=4.0
 * 開啟Windows Remote Desktop執行IE輸入http://10.159.252.11/FIS/MAY/MvcBobcat_A7/Home/B238?c=QUERY_RECORD&sn=CC4W60VCJLPQ&p=sbuild
瀏覽器上回應:0 SFC_OK sbuild=B238-PRQ2_4C

###1UP ＆ 4UP 設定方式
1. 專案中有三個 .xib檔，如下所示，將要選用的 .xib名稱改為MainMenu
 * MainMenu_1up
 * MainMenu_4up (4個TableView呈現4UP TestList)
 * MainMenu_4in1 (1個TableVew呈現4UP TestList)
2. 修改ini.plst檔裡面的EQUIPMENTS的欄位，1UP只會有一個Device item去控制DUT，而4UP將會有4個Device item去控制4個DUT，<font color="red">4UP Device item的命名方式必須要帶Thread index(1~4)</font>，ex: "THRD1 _ DevUART"。

### 

###Autotest基礎程式coding注意事項:	
1. 一開始在寫sample code或test host時必須使用有IACFactoryFramework.framework的版本，以保持底層的一致，確保程式的可移植性
2. source code 的名稱請改成有意義的命名，因為原本的名字的資料夾每個人都有了，以避免搞混
3. 在function.m中移除沒用到的程式碼或debug code，而在整個程式專案中也可以移掉沒有用到的類別,DEMO是必須移除的, 其餘CheckPudding，finishWorkHandler, controlbit則是看需求，如果確定不會用到controlbit，function.m 的controlbit  delegate method 也都可以拿掉
4. 沒有使用到的變數就拿掉，不要徒增無意義的警告(盡力減少警告!!讓真正問題浮現)
5. 函數名稱在習慣上會是以小寫進行命名，大寫通常會用在定義常數或class名稱，並且在命名上需具體明確，盡量做到保持程式碼的可讀性
6. 程式碼的縮排，括號，空白行的使用請盡量一致整齊
7. ini.plist的使用上一樣請移除未用到的equipment and test，另外為了保持程式維護的彈性，所以大家也要熟悉ini.plist的操作

###維護Autotest基礎程式SOP:
1. 若是修改 basic layer 請先在 all source version 內做修改並做測試，沒有問題後再更新到 framework version，而原本的 all source 的版本號＋1
2. 若 framework 有更新請將版本號＋1，並更新到有用到 framework 的 source code，並記得在修改UI內檢查版本的地方
3. 若是修改 meta layer 則需要更新到各 type source code
4. 修改UI時要考量到 full screen & unfull screen 的情況 
5. 若是修改 function 內各 type的共有的 method時要考慮 Ｎ＆Ｚ type 是使用 [plist getItemDataByIndex:i fromThrd:my_thread_index] 的case 而 1 type 則是使用 [plist getItemDataByIndex:i ]，除此之外請保持共有的 method 的一致性
6. 最後release 時則將各 type source code 放在同一個資料夾壓縮成同一個zip，資料夾名稱如autoTest-20170208，並以信件的方式寄送，信件內則說明 release note 
