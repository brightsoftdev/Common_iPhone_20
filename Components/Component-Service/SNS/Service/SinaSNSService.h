//
//  SinaSNSService.h
//  Draw
//
//  Created by  on 12-3-25.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "CommonService.h"
#import "SNSServiceHandler.h"
#import "SINAWeiboRequest.h"
#import "SNSServiceDelegate.h"

@interface SinaSNSService : SNSServiceHandler
{
    dispatch_queue_t    workingQueue;
}

@property (nonatomic, retain) SINAWeiboRequest *request;
@property (nonatomic, retain) NSString *appkey;
@property (nonatomic, retain) NSString *appSecret;
@property (nonatomic, retain) PPViewController<SNSServiceDelegate> *displayViewController;

- (void)startLogin:(PPViewController*)viewController;
- (void)setAppKey: (NSString *)key Secret:(NSString *)secret;
- (void)publishWeibo:(NSString*)text delegate:(id<SNSServiceDelegate>)delegate;
+ (SinaSNSService*)defaultService;

@end
