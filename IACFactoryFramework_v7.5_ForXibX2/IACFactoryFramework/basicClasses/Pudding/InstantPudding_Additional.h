//
//  InstantPudding_Additional.h
//  autoTest
//
//  Created by Li Richard on 13-8-28.
//  Copyright (c) 2013年 Li Richard. All rights reserved.
//

#import "InstantPudding_API.h"

//typedef void* IP_API_Reply;

///use this to send a station failure (not a UUT failure or error) up to PDCA for your own edification at a later time.
///where / how this shows up in PDCA is still TBD
//IP_API_Reply IP_sendStationFailureReport( const char* failureStep, const char* failureReason );

/// Test Results should be same as IP_PASSFAILRESULT
enum TEST_PASSFAILRESULT1
{
	
	/// test failed
	TEST_FAIL1 = 0,
    
	/// test passed
	TEST_PASS1,
    
	/// test was not run or was skipped
	TEST_SKIP1
	
};

