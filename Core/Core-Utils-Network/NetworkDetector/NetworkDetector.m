//
//  NetworkDetector.m
//  FootballScore
//
//  Created by  on 11-12-19.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "NetworkDetector.h"
#import "UIUtils.h"
#import "PPDebug.h"

@implementation NetworkDetector
@synthesize interval = _interval;
@synthesize errorMessage = _errorMessage;
@synthesize errorTitle = _errorTitle;

- (id)initWithErrorMsg:(NSString *)msg detectInterval:(NSTimeInterval) interval
{
    self = [super init];
    if (self) {
        self.interval = interval;
        self.errorMessage = msg;
        _lastNetworkStatus = 1;
    }
    return self;
}
- (id)initWithErrorTitle:(NSString *)title ErrorMsg:(NSString *)msg detectInterval:(NSTimeInterval) interval
{
    self = [super init];
    if (self) {
        self.interval = interval;
        self.errorMessage = msg;
        self.errorTitle = title;
        _lastNetworkStatus = 1;
    }
    return self;    
}
- (void)detectNetwork
{
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0);
    dispatch_async(queue, ^{
//		PPDebug(@"<NetworkDetector:detectNetwork> starting...");
        Reachability* r = [Reachability reachabilityForInternetConnection];
		NetworkStatus status = [r currentReachabilityStatus];
//		PPDebug(@"<NetworkDetector:detectNetwork>: status = %d", status);
		if (status == NotReachable && _lastNetworkStatus != NotReachable){
			dispatch_async(dispatch_get_main_queue(), ^{
                if (_errorTitle) {
                    [UIUtils alertWithTitle:_errorTitle msg:_errorMessage];    
                }else{
                    [UIUtils alertWithTitle:@"网络连接失效" msg:_errorMessage];
                }
			});
		}
        _lastNetworkStatus = status;
	});
}

- (void) start
{
    if ([_timer isValid]) {
        return;
    }
    _timer = [NSTimer scheduledTimerWithTimeInterval:_interval target:self selector:@selector(detectNetwork) userInfo:nil repeats:YES];
}
- (void) stop
{
    if (_timer && [_timer isValid]) {
        [_timer invalidate];        
    }
    _timer = nil;
    _lastNetworkStatus = 1;
}


-(void)dealloc
{
    [_errorMessage release];
    [_errorTitle release];
    [super dealloc];
}
@end
