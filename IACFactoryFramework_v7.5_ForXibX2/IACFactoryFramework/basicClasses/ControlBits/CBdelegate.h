//
//  CBdelegate.h
//  autoTest
//
//  Created by MAY on 1/17/15.
//  Copyright (c) 2015 TOM. All rights reserved.
//

#ifndef autoTest_CBdelegate_h
#define autoTest_CBdelegate_h
#import <Foundation/Foundation.h>
@protocol CBdelegate <NSObject>
@optional
- (NSString*)CBRead:(NSString *)atIndex;
- (BOOL)CBWrite:(NSString *)atIndex forResult:(NSString *)result;
- (BOOL)CBErase:(NSString *)atIndex;
- (int)CBRead_Fail_count:(NSString *)atIndex;
- (void)CBErrorInfoToPDCA:(NSString *)test SubTest:(NSString *)subtest failMesg:(NSString *)mesg;
@end
#endif
