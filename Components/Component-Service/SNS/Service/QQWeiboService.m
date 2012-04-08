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
#import "JSON.h"

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
    
    _weiboApi = [[QWeiboSyncApi alloc] init];
    
    
    return self;
}

- (void)dealloc
{
    
    dispatch_release(workingQueue);
    workingQueue = NULL;
    
    [_weiboApi release];
    
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
                [_displayViewController didLogin:(finalResult ? 0 : 1) userInfo:(NSDictionary*)userInfo];
            }
        });            
    });    
}

- (void)publishWeibo:(NSString*)text delegate:(id<SNSServiceDelegate>)delegate
{
    [self publishWeibo:text imageFilePath:nil delegate:delegate];
}

- (void)publishWeibo:(NSString*)text imageFilePath:(NSString*)imageFilePath delegate:(id<SNSServiceDelegate>)delegate
{
    dispatch_async(workingQueue, ^{
        NSString* result = [_weiboApi publishMsgWithConsumerKey:_appkey 
                                                 consumerSecret:_appSecret 
                                                 accessTokenKey:[_request oauthToken]
                                              accessTokenSecret:[_request oauthTokenSecret]
                                                        content:text
                                                      imageFile:imageFilePath 
                                                     resultType:RESULTTYPE_JSON];
        
        PPDebug(@"<Publish QQ Weibo> result = %@", result);
        
        int resultCode = -1;
        if ([result length] > 0){
            NSDictionary* json = [result JSONValue];
            resultCode = [[json objectForKey:@"ret"] intValue];
        }                
        
        if ([delegate respondsToSelector:@selector(didPublishWeibo:)]){
            [delegate didPublishWeibo:resultCode];
        }
    });
}



@end
