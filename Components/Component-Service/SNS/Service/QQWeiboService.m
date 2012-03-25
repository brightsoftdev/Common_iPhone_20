//
//  QQWeiboService.m
//  Draw
//
//  Created by  on 12-3-25.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "QQWeiboService.h"
#import "QQWeiboRequest.h"
#import "PPDebug.h"

@implementation QQWeiboService

@synthesize request = _request;
@synthesize appkey = _appkey;
@synthesize appSecret = _appSecret;
@synthesize displayViewController = _displayViewController;

static QQWeiboService* _defaultSinaService;

+ (QQWeiboService*)defaultService
{
    if (_defaultSinaService == nil){
        _defaultSinaService = [[QQWeiboService alloc] init];
    }
    
    return _defaultSinaService;
}

- (id)init
{
    self = [super init];
    
    workingQueue = dispatch_queue_create("sns service queue", NULL);
    
    
    
    
    return self;
}

- (void)dealloc
{
    
    dispatch_release(workingQueue);
    workingQueue = NULL;
    
    [_displayViewController release];
    [_request release];
    [_appSecret release];
    [_appkey release];
    
    [super dealloc];    
}

- (void)setAppKey: (NSString *)key Secret:(NSString *)secret{
    
    self.appSecret = secret;
    self.appkey = key;
    
    self.request = [[[QQWeiboRequest alloc] initWithAppKey:self.appkey
                                                  appSecret:self.appSecret
                                                callbackURL:@"null"
                                                 oauthToken:nil
                                           oauthTokenSecret:nil] autorelease];
    
    
    //    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    //    [userDefaults setObject:key forKey:USER_DEFAULT_SINA_KEY];
    //    [userDefaults setObject:secret forKey:USER_DEFAULT_SINA_SECRET];
    
}

#pragma mark - Initate Login Request

- (void)startLogin:(PPViewController<SNSServiceDelegate>*)viewController snsRequest:(CommonSNSRequest*)snsRequest
{
    self.displayViewController = viewController; // save the view controller to parse reponse URL
    
    [viewController showActivityWithText:NSLS(@"kInitiateAuthorization")];
    dispatch_async(workingQueue, ^{        
        BOOL result = [self loginForAuthorization:snsRequest viewController:viewController];
        dispatch_async(dispatch_get_main_queue(), ^{
            [viewController hideActivity];
            if (result == NO){
                [UIUtils alert:NSLS(@"kFailInitAuthorization")];                
            }
        });        
    });        
}

- (void)startLogin:(PPViewController<SNSServiceDelegate>*)viewController
{
    [self startLogin:viewController snsRequest:_request];
}


// parse PIN from UIWebView pages
- (void)finishParsePin:(int)pinResult pin:(NSString*)pin snsRequest:(CommonSNSRequest *)snsRequest
{
    [_displayViewController showActivityWithText:NSLS(@"请求授权中...")];
    dispatch_async(workingQueue, ^{                
        BOOL finalResult = YES;
        // parse authorization response
        BOOL result = [self parsePin:pinResult pin:pin snsRequest:snsRequest];
        if (result == NO)
            finalResult = NO;
        
        // get user info
        NSDictionary* userInfo = [self getUserInfo:snsRequest];
        if (userInfo != nil){                        
            // success
            finalResult = YES;            
        }
        else{
            finalResult = NO;
        }                
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [_displayViewController hideActivity];
            PPDebug(@"SNS Login Result = %d", finalResult);
            if ([_displayViewController respondsToSelector:@selector(didLogin:userInfo:)]){
                [_displayViewController didLogin:finalResult userInfo:(NSDictionary*)userInfo];
            }
        });            
    });    
}

@end
