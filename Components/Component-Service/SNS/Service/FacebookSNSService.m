//
//  FacebookSNSService.m
//  Draw
//
//  Created by  on 12-4-5.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "FacebookSNSService.h"
#import "PPDebug.h"
#import "PPViewController.h"
#import "SNSConstants.h"

enum{
    ACTION_NONE = 0,
    ACTION_GET_USER_INFO = 1,
    ACTION_SEND_WEIBO = 2
};


@implementation FacebookSNSService

@synthesize facebook = _facebook;
@synthesize appkey = _appkey;
@synthesize appSecret = _appSecret;
@synthesize appId = _appId;
@synthesize displayViewController = _displayViewController;

static FacebookSNSService* _defaultService;

+ (FacebookSNSService*)defaultService
{
    if (_defaultService == nil){
        _defaultService = [[FacebookSNSService alloc] init];
    }
    
    return _defaultService;
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
    
    [_appId release];
    [_facebook release];
    [_displayViewController release];
    [_appSecret release];
    [_appkey release];
    
    [super dealloc];    
}

- (void)setAppId:(NSString*)appId appKey:(NSString *)key Secret:(NSString *)secret{
    
    self.appSecret = secret;
    self.appkey = key;    
    self.appId = appId;

    self.facebook = [[[Facebook alloc] initWithAppId:_appId andDelegate:self] autorelease];   
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults objectForKey:@"FBAccessTokenKey"] && [defaults objectForKey:@"FBExpirationDateKey"]) {
        _facebook.accessToken = [defaults objectForKey:@"FBAccessTokenKey"];
        _facebook.expirationDate = [defaults objectForKey:@"FBExpirationDateKey"];
    }
    
    // Now check that the URL scheme fb[app_id]://authorize is in the .plist and can
    // be opened, doing a simple check without local app id factored in here
    NSString *url = [NSString stringWithFormat:@"fb%@://authorize", _appId];
    BOOL bSchemeInPlist = NO; // find out if the sceme is in the plist file.
    NSArray* aBundleURLTypes = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleURLTypes"];
    if ([aBundleURLTypes isKindOfClass:[NSArray class]] &&
        ([aBundleURLTypes count] > 0)) {
        NSDictionary* aBundleURLTypes0 = [aBundleURLTypes objectAtIndex:0];
        if ([aBundleURLTypes0 isKindOfClass:[NSDictionary class]]) {
            NSArray* aBundleURLSchemes = [aBundleURLTypes0 objectForKey:@"CFBundleURLSchemes"];
            if ([aBundleURLSchemes isKindOfClass:[NSArray class]] &&
                ([aBundleURLSchemes count] > 0)) {
                NSString *scheme = [aBundleURLSchemes objectAtIndex:0];
                if ([scheme isKindOfClass:[NSString class]] &&
                    [url hasPrefix:scheme]) {
                    bSchemeInPlist = YES;
                }
            }
        }
    }
    // Check if the authorization callback will work
    BOOL bCanOpenUrl = [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString: url]];
    if (!bSchemeInPlist || !bCanOpenUrl) {
        UIAlertView *alertView = [[UIAlertView alloc]
                                  initWithTitle:@"Setup Error"
                                  message:@"Invalid or missing URL scheme. You cannot run the app until you set up a valid URL scheme in your .plist."
                                  delegate:self
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil,
                                  nil];
        [alertView show];
        [alertView release];
    }
    
    [[self facebook] extendAccessTokenIfNeeded];
}


- (void)startLogin:(PPViewController<SNSServiceDelegate>*)viewController
{        
    self.displayViewController = viewController;
    
    [_facebook authorize:nil];

    _action = ACTION_GET_USER_INFO;    
    _needGetUserInfo = YES;
}

- (void)publishWeibo:(NSString*)text delegate:(id<SNSServiceDelegate>)delegate
{
    
}

- (void)publishWeibo:(NSString*)text imageFilePath:(NSString*)imageFilePath delegate:(id<SNSServiceDelegate>)delegate
{
    
}

- (void)apiFQLIMe {
    // Using the "pic" picture since this currently has a maximum width of 100 pixels
    // and since the minimum profile picture size is 180 pixels wide we should be able
    // to get a 100 pixel wide version of the profile picture
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   @"SELECT uid, name, pic, first_name FROM user WHERE uid=me()", @"query",
                                   nil];
    [_facebook requestWithMethodName:@"fql.query"
                                     andParams:params
                                 andHttpMethod:@"POST"
                                   andDelegate:self];
}

- (void)getUserInfo
{
    [self apiFQLIMe];
}

#pragma mark - Facebook Session Delegate

- (void)fbDidLogin
{
    PPDebug(@"<fbDidLogin>");
    
    // save token and key
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[_facebook accessToken] forKey:@"FBAccessTokenKey"];
    [defaults setObject:[_facebook expirationDate] forKey:@"FBExpirationDateKey"];
    [defaults synchronize];
    
    [self.displayViewController showActivityWithText:@"Reading Data..."];
    
    if (_needGetUserInfo){
        [self getUserInfo];
    }
}

/**
 * Called when the user dismissed the dialog without logging in.
 */
- (void)fbDidNotLogin:(BOOL)cancelled
{
    PPDebug(@"<fbDidNotLogin>");
    
}

/**
 * Called after the access token was extended. If your application has any
 * references to the previous access token (for example, if your application
 * stores the previous access token in persistent storage), your application
 * should overwrite the old access token with the new one in this method.
 * See extendAccessToken for more details.
 */
- (void)fbDidExtendToken:(NSString*)accessToken
               expiresAt:(NSDate*)expiresAt
{
    PPDebug(@"<fbDidExtendToken> accessToke=%@, expireAt=%@", accessToken, expiresAt);    
}

/**
 * Called when the user logged out.
 */
- (void)fbDidLogout
{
    PPDebug(@"<fbDidLogout>");
}

/**
 * Called when the current session has expired. This might happen when:
 *  - the access token expired
 *  - the app has been disabled
 *  - the user revoked the app's permissions
 *  - the user changed his or her password
 */
- (void)fbSessionInvalidated
{
    PPDebug(@"<fbSessionInvalidated>");
}

#pragma mark - FBRequestDelegate Methods
/**
 * Called when the Facebook API request has returned a response.
 *
 * This callback gives you access to the raw response. It's called before
 * (void)request:(FBRequest *)request didLoad:(id)result,
 * which is passed the parsed response object.
 */
- (void)request:(FBRequest *)request didReceiveResponse:(NSURLResponse *)response {
    PPDebug(@"FBRequest <didReceiveResponse>");
}

/**
 * Called when a request returns and its response has been parsed into
 * an object.
 *
 * The resulting object may be a dictionary, an array or a string, depending
 * on the format of the API response. If you need access to the raw response,
 * use:
 *
 * (void)request:(FBRequest *)request
 *      didReceiveResponse:(NSURLResponse *)response
 */

- (void)safeSetKeyFrom:(NSDictionary*)fromDict toDict:(NSMutableDictionary*)toDict fromKey:(NSString*)fromKey toKey:(NSString*)toKey
{
    if (fromKey == nil || toKey == nil)
        return;
    
    NSObject* value = [fromDict objectForKey:fromKey];
    if (value == nil)
        return;
    
    if ([value isKindOfClass:[NSString class]]){    
        [toDict setObject:value forKey:toKey];
    }
    else{
        [toDict setObject:[value description] forKey:toKey];
    }
}


- (NSMutableDictionary*)parseUserInfo:(NSDictionary*)origUserInfo
{
    NSMutableDictionary *retDict = [NSMutableDictionary dictionary];
    
    [retDict setObject:SNS_FACEBOOK forKey:SNS_NETWORK];
    
    [self safeSetKeyFrom:origUserInfo toDict:retDict fromKey:@"uid" toKey:SNS_USER_ID];    
    [self safeSetKeyFrom:origUserInfo toDict:retDict fromKey:@"first_name" toKey:SNS_NICK_NAME];
    [self safeSetKeyFrom:origUserInfo toDict:retDict fromKey:@"pic" toKey:SNS_USER_IMAGE_URL];
    
    return retDict;
}


- (void)request:(FBRequest *)request didLoad:(id)result {
    PPDebug(@"FBRequest <didLoad> result = %@", result);

    if (_action == ACTION_GET_USER_INFO){
        [self.displayViewController hideActivity];        
    }

    if ([result isKindOfClass:[NSArray class]]) {
        result = [result objectAtIndex:0];        
        NSDictionary* userInfo = [self parseUserInfo:result];
        if (_action == ACTION_GET_USER_INFO){
            if ([_displayViewController respondsToSelector:@selector(didLogin:userInfo:)]){
                [_displayViewController didLogin:0 userInfo:userInfo];
            }            
        }
    }
    

    // This callback can be a result of getting the user's basic
    // information or getting the user's permissions.    
    
}

/**
 * Called when an error prevents the Facebook API request from completing
 * successfully.
 */
- (void)request:(FBRequest *)request didFailWithError:(NSError *)error {
    NSLog(@"Err message: %@", [[error userInfo] objectForKey:@"error_msg"]);
    NSLog(@"Err code: %d", [error code]);
}

@end
