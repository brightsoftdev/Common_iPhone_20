//
//  FacebookSNSService.h
//  Draw
//
//  Created by  on 12-4-5.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SNSServiceDelegate.h"
#import "FBConnect.h"

@class PPViewController;

@interface FacebookSNSService : NSObject<FBSessionDelegate, FBRequestDelegate>
{
    dispatch_queue_t    workingQueue;
    Facebook            *_facebook;
    int                 _action;
    BOOL                _needGetUserInfo;
}

@property (nonatomic, retain) NSString *appId;
@property (nonatomic, retain) NSString *appkey;
@property (nonatomic, retain) NSString *appSecret;
@property (nonatomic, retain) Facebook *facebook;
@property (nonatomic, retain) PPViewController<SNSServiceDelegate> *displayViewController;

- (void)startLogin:(PPViewController<SNSServiceDelegate>*)viewController;
- (void)setAppId:(NSString*)appId appKey:(NSString *)key Secret:(NSString *)secret;
- (void)publishWeibo:(NSString*)text delegate:(id<SNSServiceDelegate>)delegate;
- (void)publishWeibo:(NSString*)text imageFilePath:(NSString*)imageFilePath delegate:(id<SNSServiceDelegate>)delegate;
+ (FacebookSNSService*)defaultService;


@end
