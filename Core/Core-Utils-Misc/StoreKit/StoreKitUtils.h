//
//  StoreKitUtils.h
//  Draw
//
//  Created by  on 12-4-23.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    VERIFY_OK = 0,
    VERIFY_UNKNOWN = -1,
    
} TransactionVerifyResult;

@interface StoreKitUtils : NSObject

+ (TransactionVerifyResult)verifyReceipt:(NSString*)transactionReceipt;

@end
