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
#import "WBEngine.h"

enum{
    ACTION_NONE = 0,
    ACTION_GET_USER_INFO = 1,
    ACTION_SEND_WEIBO = 2
};

@interface SinaSNSService : SNSServiceHandler<WBEngineDelegate>
{
    dispatch_queue_t    workingQueue;
    WBEngine            *_engine;
    BOOL                _needGetUserInfo;
    int                 _action;
}

@property (nonatomic, retain) SINAWeiboRequest *request;
@property (nonatomic, retain) NSString *appkey;
@property (nonatomic, retain) NSString *appSecret;
@property (nonatomic, retain) PPViewController<SNSServiceDelegate> *displayViewController;
@property (nonatomic, retain) WBEngine *engine;

- (void)startLogin:(PPViewController*)viewController;
- (void)setAppKey: (NSString *)key Secret:(NSString *)secret;
- (void)publishWeibo:(NSString*)text delegate:(id<SNSServiceDelegate>)delegate;
- (void)publishWeibo:(NSString*)text imageFilePath:(NSString*)imageFilePath delegate:(id<SNSServiceDelegate>)delegate;
+ (SinaSNSService*)defaultService;

@end
