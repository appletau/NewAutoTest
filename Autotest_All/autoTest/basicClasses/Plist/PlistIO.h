//
//  PlistIO.h
//  UIcontrol
//
//  Created by TOM on 19/4/19.
//  Copyright (c) 2019年 TOM. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Equipments.h"
#import "Item.h"
@interface PlistIO : NSObject

@property (atomic, readonly) NSMutableArray *TestItemList;
@property (atomic, readonly) NSMutableArray *Equipment;
@property (atomic, assign) BOOL isAllowPrefer;
@property (atomic, assign) BOOL isAllowPudding;
@property (atomic, assign) BOOL isAllowAuditMode;
@property (atomic, readonly) NSString *StationName;
@property (atomic, readonly) NSString *SW_Ver;
@property (atomic, readonly) NSString *Product;

+(PlistIO *) sharedPlistIO;
-(void) propertiesInit;
-(void) testsDataInit;
-(void) equipmentInit;
-(NSArray *)getEquipmentList;
-(id) getEquipment:(NSString *)usedfor;
-(id) getObjForKey:(NSString *)key;
-(BOOL) checkIsAllPass:(int)dutNum;
-(BOOL) checkIsAllPassForSetCB:(int)dutNum;
-(void) savePropertiesToPlist;
-(void) saveDataToPlist:(NSString *)key value:(id)val;
-(void) saveEquipmentDataToPlist:(NSString *)usedfor forKey:(NSString *)key value:(id)val;
@end
