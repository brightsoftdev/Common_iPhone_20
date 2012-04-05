//
//  QVerifyWebViewController.h
//  QWeiboSDK4iOSDemo
//
//  Created   on 11-1-14.
//   
//

#import <UIKit/UIKit.h>


@interface QVerifyWebViewController : UIViewController<UIWebViewDelegate> {
	
	UIWebView *mWebView;

}

@property (nonatomic, retain) NSString* tokenKey;
@property (nonatomic, retain) NSString* tokenSecret;

@property (nonatomic, retain) NSString* appKey;
@property (nonatomic, retain) NSString* appSecret;

@end
