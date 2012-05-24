//
//  QVerifyWebViewController.m
//  QWeiboSDK4iOSDemo
//
//  Created   on 11-1-14.
//   
//

#import "QVerifyWebViewController.h"
#import "QWeiboSyncApi.h"


#define VERIFY_URL @"http://open.t.qq.com/cgi-bin/authorize?oauth_token="

@implementation QVerifyWebViewController

@synthesize tokenKey = _tokenKey;
@synthesize tokenSecret = _tokenSecret;
@synthesize appKey = _appKey;
@synthesize appSecret = _appSecret;

// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.

- (void)dealloc {
    [_appSecret release];
    [_appKey release];
    [_tokenSecret release];
    [_tokenKey release];
    [super dealloc];
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization.
    }
    return self;
}



// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	mWebView = [[UIWebView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 480.0f)];
	mWebView.delegate = self;
	[self.view addSubview:mWebView];
	
	NSString *url = [NSString stringWithFormat:@"%@%@", VERIFY_URL, _tokenKey];
	NSURL *requestUrl = [NSURL URLWithString:url];
	NSURLRequest *request = [NSURLRequest requestWithURL:requestUrl];
	[mWebView loadRequest:request];
}



// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        return interfaceOrientation == UIInterfaceOrientationPortrait || interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown;
    else
        return interfaceOrientation == UIInterfaceOrientationPortrait;
}


- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}



#pragma mark -
#pragma mark private methods

-(NSString*) valueForKey:(NSString *)key ofQuery:(NSString*)query
{
	NSArray *pairs = [query componentsSeparatedByString:@"&"];
	for(NSString *aPair in pairs){
		NSArray *keyAndValue = [aPair componentsSeparatedByString:@"="];
		if([keyAndValue count] != 2) continue;
		if([[keyAndValue objectAtIndex:0] isEqualToString:key]){
			return [keyAndValue objectAtIndex:1];
		}
	}
	return nil;
}

#pragma mark -
#pragma mark UIWebViewDelegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
	
	NSString *query = [[request URL] query];
	NSString *verifier = [self valueForKey:@"oauth_verifier" ofQuery:query];
	
	if (verifier && ![verifier isEqualToString:@""]) {
				
		QWeiboSyncApi *api = [[[QWeiboSyncApi alloc] init] autorelease];
		NSString *retString = [api getAccessTokenWithConsumerKey:_appKey 
												  consumerSecret:_appSecret 
												 requestTokenKey:_tokenKey 
											  requestTokenSecret:_tokenSecret 
														  verify:verifier];
		NSLog(@"\nget access token:%@", retString);
//		[appDelegate parseTokenKeyWithResponse:retString];
//		[appDelegate saveDefaultKey];
		
		[self.navigationController popViewControllerAnimated:NO];
		return NO;
	}
	
	return YES;
}


@end
