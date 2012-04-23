//
//  StoreKitUtils.m
//  Draw
//
//  Created by  on 12-4-23.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "StoreKitUtils.h"
#import "ASIHTTPRequest.h"
#import "GTMBase64.h"
#import "SBJsonWriter.h"
#import "JSON.h"
#import "PPDebug.h"

#define IAP_TEST_SERVER

#ifdef IAP_TEST_SERVER
#define VAILDATING_RECEIPTS_URL @"https://sandbox.itunes.apple.com/verifyReceipt"
#else
#define VAILDATING_RECEIPTS_URL @"https://buy.itunes.apple.com/verifyReceipt"
#endif

@implementation StoreKitUtils

+ (TransactionVerifyResult)verifyReceipt:(NSString*)transactionReceipt
{
    TransactionVerifyResult verifyResult = VERIFY_UNKNOWN;
    
	NSURL *verifyURL = [NSURL URLWithString:VAILDATING_RECEIPTS_URL];
	ASIHTTPRequest *request = [[ASIHTTPRequest alloc] initWithURL:verifyURL];
	[request setRequestMethod: @"POST"];
	[request addRequestHeader: @"Content-Type" value: @"application/json"];
    	
    // set post data
	NSString *recepit = transactionReceipt;
	NSDictionary* data = [NSDictionary dictionaryWithObjectsAndKeys:recepit, @"receipt-data", nil];
	SBJsonWriter *writer = [SBJsonWriter new];
	[request appendPostData: [[writer stringWithObject:data] dataUsingEncoding: NSUTF8StringEncoding]];
	[writer release];
    
    [request startSynchronous];
    
    PPDebug(@"<verifyReceipt> status code=%d, result=%@",
            [request responseStatusCode], [request responseString]);

    if ([request responseStatusCode] == 200){        
        
        NSString* result = [request responseString];
        NSDictionary* dict = [result JSONValue];
        if (dict == nil || [dict objectForKey:@"status"] == nil)
            return verifyResult;
        
        if ([[dict objectForKey:@"status"] intValue] == 0){
            verifyResult = VERIFY_OK;
        }
        else{
            verifyResult = [[dict objectForKey:@"status"] intValue];
        }
    }   
    
    return verifyResult;
}

@end
