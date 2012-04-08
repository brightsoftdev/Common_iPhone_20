//
//  QQWeiboService.h
//  Draw
//
//  Created by  on 12-3-25.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "CommonService.h"
#import "SNSServiceHandler.h"
#import "SINAWeiboRequest.h"
#import "SNSServiceDelegate.h"
#import "QQWeiboRequest.h"
#import "QWeiboSyncApi.h"

@interface QQWeiboService : SNSServiceHandler
{
    dispatch_queue_t    workingQueue;
        QWeiboSyncApi   *_weiboApi;
}

@property (nonatomic, retain) QQWeiboRequest *request;
@property (nonatomic, retain) NSString *appkey;
@property (nonatomic, retain) NSString *appSecret;
@property (nonatomic, retain) PPViewController<SNSServiceDelegate> *displayViewController;

- (void)startLogin:(PPViewController*)viewController;
- (void)setAppKey: (NSString *)key Secret:(NSString *)secret;
- (void)publishWeibo:(NSString*)text delegate:(id<SNSServiceDelegate>)delegate;
- (void)publishWeibo:(NSString*)text imageFilePath:(NSString*)imageFilePath delegate:(id<SNSServiceDelegate>)delegate;
+ (QQWeiboService*)defaultService;

@end
