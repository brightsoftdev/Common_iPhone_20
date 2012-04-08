//
//  SinaSNSService.m
//  Draw
//
//  Created by  on 12-3-25.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "SinaSNSService.h"
#import "PPDebug.h"
#import "JSON.h"

@implementation SinaSNSService

@synthesize request = _request;
@synthesize appkey = _appkey;
@synthesize appSecret = _appSecret;
@synthesize displayViewController = _displayViewController;
@synthesize engine = _engine;

static SinaSNSService* _defaultSinaService;

+ (SinaSNSService*)defaultService
{
    if (_defaultSinaService == nil){
        _defaultSinaService = [[SinaSNSService alloc] init];
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
    
    [_engine release];
    
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
    
    self.request = [[[SINAWeiboRequest alloc] initWithAppKey:self.appkey
                                                   appSecret:self.appSecret                                                
                                                 callbackURL:nil                                                
                                                  oauthToken:nil
                                            oauthTokenSecret:nil] autorelease];  
    
    self.engine = [[[WBEngine alloc] initWithAppKey:self.appkey appSecret:self.appSecret] autorelease];        
}

#pragma mark - Initate Login Request

- (void)startLogin:(PPViewController<SNSServiceDelegate>*)viewController snsRequest:(CommonSNSRequest*)snsRequest
{
    self.displayViewController = viewController; // save the view controller to parse reponse URL

    [_engine setRootViewController:viewController];
    [_engine setDelegate:self];
    [_engine setRedirectURI:@"http://"];
    [_engine setIsUserExclusive:NO];
    
    [_engine logIn];
//    [viewController showActivityWithText:NSLS(@"kInitiateAuthorization")];
//    dispatch_async(workingQueue, ^{        
//        BOOL result = [self loginForAuthorization:snsRequest viewController:viewController];
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [viewController hideActivity];
//            if (result == NO){
//                [UIUtils alert:NSLS(@"kFailInitAuthorization")];                
//            }
//        });        
//    });        
}

- (void)startLogin:(PPViewController<SNSServiceDelegate>*)viewController
{
    _needGetUserInfo = YES;
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

- (void)publishWeibo:(NSString*)text imageFilePath:(NSString*)imageFilePath delegate:(id<SNSServiceDelegate>)delegate
{
    self.displayViewController = delegate;
    _action = ACTION_SEND_WEIBO;
    [_engine sendWeiBoWithText:text imageFilePath:imageFilePath];
}

- (void)publishWeibo:(NSString*)text delegate:(id<SNSServiceDelegate>)delegate
{        
    [self publishWeibo:text imageFilePath:nil delegate:delegate];
}

#pragma mark - Weibo Engine Delegate

// If you try to log in with logIn or logInUsingUserID method, and
// there is already some authorization info in the Keychain,
// this method will be invoked.
// You may or may not be allowed to continue your authorization,
// which depends on the value of isUserExclusive.
- (void)engineAlreadyLoggedIn:(WBEngine *)engine
{
    PPDebug(@"<engineAlreadyLoggedIn>");
}

- (void)getUserInfo
{    
    [_displayViewController showActivityWithText:NSLS(@"请求授权中...")];
    _action = ACTION_GET_USER_INFO;    
    [_engine loadRequestWithMethodName:@"users/show.json" 
                            httpMethod:@"GET" 
                                params:[NSDictionary dictionaryWithObject:[_engine userID] forKey:@"uid"] 
                          postDataType:kWBRequestPostDataTypeNormal 
                      httpHeaderFields:nil];    
}

// Log in successfully.
- (void)engineDidLogIn:(WBEngine *)engine
{
    PPDebug(@"<engineDidLogIn>");
    if (_needGetUserInfo){
        [self getUserInfo];
    }
}

// Failed to log in.
// Possible reasons are:
// 1) Either username or password is wrong;
// 2) Your app has not been authorized by Sina yet.
- (void)engine:(WBEngine *)engine didFailToLogInWithError:(NSError *)error
{
    PPDebug(@"<didFailToLogInWithError> error=%@", [error description]);    
    [_displayViewController hideActivity];
}

// Log out successfully.
- (void)engineDidLogOut:(WBEngine *)engine
{
    PPDebug(@"<engineDidLogOut>");
    [_displayViewController hideActivity];
}

// When you use the WBEngine's request methods,
// you may receive the following four callbacks.
- (void)engineNotAuthorized:(WBEngine *)engine
{
    PPDebug(@"<engineNotAuthorized>");
    [_displayViewController hideActivity];

    
//    if (_action == ACTION_SEND_WEIBO){
//        if ([_displayViewController respondsToSelector:@selector(didPublishWeibo:)]){
//            [_displayViewController didPublishWeibo:FAIL_NO_AUTHORIZED];
//        }        
//    }    
//    
//    _action = ACTION_NONE;
}

- (void)engineAuthorizeExpired:(WBEngine *)engine
{
    PPDebug(@"<engineAuthorizeExpired>");
    [_displayViewController hideActivity];

    // login again
    _needGetUserInfo = NO;
    [_engine logIn];
    
//    if (_action == ACTION_SEND_WEIBO){
//        if ([_displayViewController respondsToSelector:@selector(didPublishWeibo:)]){
//            [_displayViewController didPublishWeibo:FAIL_AUTHORIZED_EXPIRED];
//        }        
//    }    
//
//    _action = ACTION_NONE;
}

- (void)engine:(WBEngine *)engine requestDidFailWithError:(NSError *)error
{
    PPDebug(@"<requestDidFailWithError> error=%@", [error description]);
    [_displayViewController hideActivity];
    
    if (ACTION_GET_USER_INFO == _action){
        NSString* nickName = [NSString stringWithFormat:@"新浪微博%@", [_engine userID]];
        NSMutableDictionary* userInfo = [NSMutableDictionary dictionary];
        
        [userInfo setObject:[_engine userID] forKey:SNS_USER_ID];
        [userInfo setObject:nickName forKey:SNS_NICK_NAME];
        [userInfo setObject:SNS_SINA_WEIBO forKey:SNS_NETWORK];
        
        if ([_displayViewController respondsToSelector:@selector(didLogin:userInfo:)]){
            [_displayViewController didLogin:0 userInfo:userInfo];
        }        
        _action = ACTION_NONE;
    }
}

- (void)engine:(WBEngine *)engine requestDidSucceedWithResult:(id)result
{
    PPDebug(@"<requestDidSucceedWithResult> result=%@", [result description]);    
    [_displayViewController hideActivity];
    if (_action == ACTION_GET_USER_INFO){
        NSDictionary* userInfo = [_request parseUserInfo:result];
        if ([_displayViewController respondsToSelector:@selector(didLogin:userInfo:)]){
            [_displayViewController didLogin:0 userInfo:userInfo];
        }
        
    }
    else if (_action == ACTION_SEND_WEIBO){
        if ([_displayViewController respondsToSelector:@selector(didPublishWeibo:)]){
            [_displayViewController didPublishWeibo:0];
        }        
    }

    _action = ACTION_NONE;
}

@end
