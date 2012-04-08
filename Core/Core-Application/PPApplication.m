//
//  PPApplication.m
//  ___PROJECTNAME___
//
//  Created by Peng Lingzhe on 9/29/10.
//  Copyright 2010 Ericsson. All rights reserved.
//

#import "PPApplication.h"
#import "HJObjManager.h"
#import "ASIHTTPRequest.h"
#import "JSON.h"

#pragma mark Global Methods

NSString* GlobalGetAppName()
{
	return NSLocalizedStringFromTable(@"CFBundleDisplayName", @"InfoPlist", @"");
}

dispatch_queue_t GlobalGetWorkingQueue()
{
	PPApplication* appObject = (PPApplication*)[[UIApplication sharedApplication] delegate];
	if ([appObject respondsToSelector:@selector(workingQueue)]){
		return appObject.workingQueue;
	}
	else {
		return NULL;
	}

}

HJObjManager* GlobalGetImageCache()
{
	PPApplication* appObject = (PPApplication*)[[UIApplication sharedApplication] delegate];
    return appObject.imageCacheManager;
}


BOOL isFree()
{
	int intValue = [[[[NSBundle mainBundle] infoDictionary] objectForKey:@"Free"] intValue]; 
	return intValue;
}

#pragma mark PPApplication Class Implementation

@implementation PPApplication

@synthesize locationManager, currentLocation, reverseGeocoder, currentPlacemark;
@synthesize workingQueue;
@synthesize player;
@synthesize imageCacheManager;

+ (NSString*)getAppVersion
{
    NSString* version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
    return version;
}

- (void)releaseResourceForAllViewControllers
{
	UITabBarController* tabBarController = nil;
	if ([self respondsToSelector:@selector(tabBarController)]){
		tabBarController = [self performSelector:@selector(tabBarController)];
	}
	
	if (tabBarController == nil)
		return;
	
	for (UIViewController* vc in tabBarController.viewControllers){
		if ([vc respondsToSelector:@selector(releaseResourceForEnterBackground)]){
			[vc performSelector:@selector(releaseResourceForEnterBackground)];
		}
	}
}

- (void)handleRemoteNotification:(UIApplication *)application launchOptions:(NSDictionary *)launchOptions
{
	NSDictionary* payload = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
	if (payload != nil){
        [self performSelector:@selector(application:didReceiveRemoteNotification:) withObject:application withObject:payload];
//		[self application:application didReceiveRemoteNotification:payload];
	}
	
}

#pragma mark Location Methods

- (void)initLocationManager
{
	if (locationManager == nil){
		locationManager = [[CLLocationManager alloc] init];
	}
}

- (void)startUpdatingLocation
{
	if (locationManager == nil){
		[self initLocationManager];
	}
	
	// start to update the location
	locationManager.delegate = self;		
	locationManager.desiredAccuracy = kCLLocationAccuracyBest;	
	[locationManager startUpdatingLocation];	
	
	[self performSelector:@selector(stopUpdatingLocation:) withObject:kAppTimeOutObjectString afterDelay:kAppLocationUpdateTimeOut];    
	
}

- (void)stopUpdatingLocation:(NSString *)state {
	
//	NSLog(@"stopUpdatingLocation,state=%@", state);
    [locationManager stopUpdatingLocation];
    locationManager.delegate = nil;    
}

// the following code is for copying, location delegate methods

/*
 * We want to get and store a location measurement that meets the desired accuracy. For this example, we are
 *      going to use horizontal accuracy as the deciding factor. In other cases, you may wish to use vertical
 *      accuracy, or both together.
 */
- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
	
    // save to current location
    self.currentLocation = newLocation;
	NSLog(@"Current location is %@", [self.currentLocation description]);
	
	// we can also cancel our previous performSelector:withObject:afterDelay: - it's no longer necessary
	// [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(stopUpdatingLocation:) object:kTimeOutObjectString];
	
	// we can also cancel our previous performSelector:withObject:afterDelay: - it's no longer necessary
	[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(stopUpdatingLocation:) object:kAppTimeOutObjectString];
	
	// IMPORTANT!!! Minimize power usage by stopping the location manager as soon as possible.
	[self stopUpdatingLocation:NSLocalizedString(@"Acquired Location", @"Acquired Location")];
	
	// translate location to address
	// [self reverseGeocodeCurrentLocation:self.currentLocation];
	
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
	
    // The location "unknown" error simply means the manager is currently unable to get the location.
    // We can ignore this error for the scenario of getting a single location fix, because we already have a 
    // timeout that will stop the location manager to save power.
    if ([error code] != kCLErrorLocationUnknown) {
        [self stopUpdatingLocation:NSLocalizedString(@"Error", @"Error")];
    }	
}




#pragma mark reverseGeocoder

- (void)reverseGeocodeCurrentLocation:(CLLocation *)location
{
    self.reverseGeocoder = [[[MKReverseGeocoder alloc] initWithCoordinate:location.coordinate] autorelease];
    reverseGeocoder.delegate = self;
    [reverseGeocoder start];
}

- (void)reverseGeocoder:(MKReverseGeocoder *)geocoder didFailWithError:(NSError *)error
{
    NSLog(@"MKReverseGeocoder has failed.");	
}

- (void)reverseGeocoder:(MKReverseGeocoder *)geocoder didFindPlacemark:(MKPlacemark *)placemark
{
	self.currentPlacemark = placemark;
	NSLog(@"reverseGeocoder finish, placemark=%@", [placemark description] );
	//	NSLog(@"current country is %@, province is %@, city is %@, street is %@%@", self.currentPlacemark.country, currentPlacemark.administrativeArea, currentPlacemark.locality, placemark.thoroughfare, placemark.subThoroughfare);	
}


/*
NSDictionary *payload = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
if (nil != payload) {
	int type = [[payload valueForKey:@"type"] intValue];
	NSString *userId = [payload valueForKey:@"userId"];
	NSString *phone = [payload valueForKey:@"phone"];
	NSDictionary *contacts = [[NSUserDefaults standardUserDefaults] dictionaryForKey:@"contacts"];
	NSDictionary *contact = [contacts objectForKey:userId];
	NSString *name = nil;
	if (nil != contact) {
		name = [contact objectForKey:@"name"]; 
	}
	double latitude = [[payload valueForKey:@"lat"] doubleValue];
	double longitude = [[payload valueForKey:@"long"] doubleValue];
	double accuracy = [[payload valueForKey:@"accuracy"] doubleValue];
	
	if (0 == type) {
		[self answerContact:userId];
	}
	
	rootController.selectedIndex = 0;
	MyMapViewController *myMapViewController = [[rootController viewControllers] objectAtIndex:0];
	[myMapViewController showContactWithPhone:phone name:name latitude:latitude longitude:longitude accuracy:accuracy];
}

// Reset badge number to 0
[UIApplication sharedApplication].applicationIconBadgeNumber = 0;
 
 - (void)bindDeviceWithCountryCode:(NSString *)countryCode phone:(NSString *)phone {
 [[NSUserDefaults standardUserDefaults] setObject:countryCode forKey:@"countryCode"];
 [[NSUserDefaults standardUserDefaults] setObject:phone forKey:@"phone"];
 [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
 }
 
 - (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
 if ([application enabledRemoteNotificationTypes] == UIRemoteNotificationTypeNone) return;
 
 // Get a hex string from the device token with no spaces or < >	
 NSString *_deviceToken = [deviceToken description];
 _deviceToken = [_deviceToken stringByReplacingOccurrencesOfString: @"<" withString: @""];
 _deviceToken = [_deviceToken stringByReplacingOccurrencesOfString: @">" withString: @""];
 _deviceToken = [_deviceToken stringByReplacingOccurrencesOfString: @" " withString: @""];	
 [[NSUserDefaults standardUserDefaults] setObject:_deviceToken forKey:@"deviceToken"];
 
 NSString *countryCode = [[NSUserDefaults standardUserDefaults] valueForKey:@"countryCode"];
 NSString *phone = [[NSUserDefaults standardUserDefaults] valueForKey:@"phone"];
 
 NSString *UAServer = @"http://locdialer.appspot.com";
 NSString *urlString = [NSString stringWithFormat:@"%@%@%", UAServer, @"/service"];
 NSURL *url = [NSURL URLWithString:urlString];
 
 NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
 [request setHTTPMethod:@"POST"];
 
 [request setHTTPBody:[[NSString stringWithFormat: @"method=bind&countryCode=%@&phone=%@&deviceToken=%@", countryCode, phone, _deviceToken] dataUsingEncoding:NSUTF8StringEncoding]];
 
 registerConnection = [NSURLConnection connectionWithRequest:request delegate:self];
 
 registerProgressView = [[UIAlertView alloc] initWithTitle:@"注册" message:@"正在注册" delegate:nil cancelButtonTitle:nil otherButtonTitles:nil];
 [registerProgressView show];
 }
 
 - (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *) error {
 NSString *message = [error description];
 UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Failed to register with error" 
 message: message
 delegate: nil
 cancelButtonTitle: @"ok"
 otherButtonTitles: nil];
 [alert show];
 [alert release];
 }
 
 - (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
 NSDictionary *payload = userInfo;
 if (nil != payload) {
 int type = [[payload valueForKey:@"type"] intValue];
 NSString *userId = [payload valueForKey:@"userId"];
 NSString *phone = [payload valueForKey:@"phone"];
 NSDictionary *contacts = [[NSUserDefaults standardUserDefaults] dictionaryForKey:@"contacts"];
 NSDictionary *contact = [contacts objectForKey:userId];
 NSString *name = nil;
 if (nil != contact) {
 name = [contact objectForKey:@"name"]; 
 }
 double latitude = [[payload valueForKey:@"lat"] doubleValue];
 double longitude = [[payload valueForKey:@"long"] doubleValue];
 double accuracy = [[payload valueForKey:@"accuracy"] doubleValue];
 
 if (0 == type) {
 [self answerContact:userId];
 }
 
 rootController.selectedIndex = 0;
 MyMapViewController *myMapViewController = [[rootController viewControllers] objectAtIndex:0];
 [myMapViewController showContactWithPhone:phone name:name latitude:latitude longitude:longitude accuracy:accuracy];
 }
 }
 
*/

- (void)bindDevice {	
	[[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
}

- (BOOL)isPushNotificationEnable {
	NSUserDefaults* userDefault = [NSUserDefaults standardUserDefaults];
	return ( [[userDefault objectForKey:kKeyDeviceToken] length] > 0 );
}

- (void)saveDeviceToken:(NSData*)deviceToken {

	NSString *_deviceToken = [deviceToken description];
	_deviceToken = [_deviceToken stringByReplacingOccurrencesOfString: @"<" withString: @""];
	_deviceToken = [_deviceToken stringByReplacingOccurrencesOfString: @">" withString: @""];
	_deviceToken = [_deviceToken stringByReplacingOccurrencesOfString: @" " withString: @""];	
	[[NSUserDefaults standardUserDefaults] setObject:_deviceToken forKey:kKeyDeviceToken];
	
	NSLog(@"<saveDeviceToken> %@", _deviceToken);
}

- (NSString*)getDeviceToken
{
	return [[NSUserDefaults standardUserDefaults] objectForKey:kKeyDeviceToken];
}

- (void)initAudioPlayer:(NSString*)soundFile
{
	NSError* error = nil;
	self.player = [[[AVAudioPlayer alloc] initWithContentsOfURL:[[NSBundle mainBundle] URLForResource:soundFile withExtension:@"caf"] error:&error] autorelease];
	if (!error){
		NSLog(@"Init audio player successfully, sound file %@", soundFile);
		[player setNumberOfLoops:0];
		[player setVolume:1.0];
		[player prepareToPlay];
	}
	else {
		NSLog(@"Fail to init audio player with sound file%@, error = %@", soundFile, [error description]);
	}
	
}

- (void)initImageCacheManager
{
    // Create the object manager
	self.imageCacheManager = [[[HJObjManager alloc] initWithLoadingBufferSize:6 memCacheSize:5] autorelease];
	
	//if you are using for full screen images, you'll need a smaller memory cache than the defaults,
	//otherwise the cached images will get you out of memory quickly
	//objMan = [[HJObjManager alloc] initWithLoadingBufferSize:6 memCacheSize:1];

    // Create a file cache for the object manager to use
	// A real app might do this durring startup, allowing the object manager and cache to be shared by several screens
	NSString* cacheDirectory = [NSHomeDirectory() stringByAppendingString:@"/Library/Caches/imgcache/default/"] ;
	HJMOFileCache* fileCache = [[[HJMOFileCache alloc] initWithRootPath:cacheDirectory] autorelease];
	imageCacheManager.fileCache = fileCache;
	
	// Have the file cache trim itself down to a size & age limit, so it doesn't grow forever
	fileCache.fileCountLimit = 100;
	fileCache.fileAgeLimit = 60*60*24*7; //1 week
	[fileCache trimCacheUsingBackgroundThread];    
}

#define KEY_APP_NEW_VERSION             @"checkAppVersion_KEY_APP_NEW_VERSION"
#define KEY_APP_NEW_VERSION_URL         @"checkAppVersion_KEY_APP_NEW_VERSION_URL"
#define KEY_APP_NEW_VERSION_INFO        @"checkAppVersion_KEY_APP_NEW_VERSION_INFO"

- (void)askToDownloadNewVersion:(NSString*)newVersionId newVersionInfo:(NSString*)newVersionInfo newVersionUrl:(NSString*)newVersionUrl
{
    NSString* message = [NSString stringWithFormat:NSLS(@"kNewVersionMessage"), newVersionId];
    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:NSLS(@"kNewVersionTitle") message:message delegate:self cancelButtonTitle:NSLS(@"Cancel") otherButtonTitles:NSLS(@"OK"), nil];
    alertView.tag = CHECK_APP_VERSION_ALERT_VIEW;
    [alertView show];
    [alertView release];
}

- (void)checkAppVersion:(NSString*)appId
{
    NSDictionary *infoDict = [[NSBundle mainBundle] infoDictionary];  
    NSString *currentVersion = [infoDict objectForKey:@"CFBundleVersion"];    
    
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    NSString* newVersion = [userDefaults objectForKey:KEY_APP_NEW_VERSION];
    NSString* appUrl = [userDefaults objectForKey:KEY_APP_NEW_VERSION_URL];
    NSString* newVersionInfo = [userDefaults objectForKey:KEY_APP_NEW_VERSION_INFO];
    if (newVersion && appUrl){
        [self askToDownloadNewVersion:newVersion newVersionInfo:newVersionInfo newVersionUrl:appUrl];
        return;
    }    

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        NSURL* url = [NSURL URLWithString:[NSString stringWithFormat:@"http://itunes.apple.com/lookup?id=%@", appId]]; 
        ASIHTTPRequest* request = [ASIHTTPRequest requestWithURL:url];
        [request startSynchronous];
        NSString* responseString = [request responseString];
        if ([responseString length] > 0){
            NSDictionary *jsonData = [responseString JSONValue];  
            NSArray *infoArray = [jsonData objectForKey:@"results"];  
            if ([infoArray count] == 0)
                return;
            
            NSDictionary *releaseInfo = [infoArray objectAtIndex:0];  
            
            NSString *latestVersion = [releaseInfo objectForKey:@"version"];  
            NSString *trackViewUrl = [releaseInfo objectForKey:@"trackViewUrl"];
            NSString *releaseNotes = [releaseInfo objectForKey:@"releaseNotes"];
            NSLog(@"releaseInfo=%@", [releaseInfo description]);
            
            if ([latestVersion isEqualToString:currentVersion] == NO){
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    // save track view URL and new version to user defaults
                    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
                    [userDefaults setObject:latestVersion forKey:KEY_APP_NEW_VERSION];
                    [userDefaults setObject:trackViewUrl forKey:KEY_APP_NEW_VERSION_URL];
                    [userDefaults setObject:releaseInfo forKey:KEY_APP_NEW_VERSION_INFO];
                    
                    [self askToDownloadNewVersion:latestVersion newVersionInfo:releaseNotes newVersionUrl:trackViewUrl];
                });
            }
        }
    });
}

- (void)dealloc
{
	[player release];

	if (workingQueue != NULL){
		CFRelease(workingQueue);
		workingQueue = NULL;
	}
	
	if (addressBook != NULL){
		CFRelease(addressBook);
		addressBook = NULL;
	}
	
    [imageCacheManager release];
    
	[super dealloc];
}

@end
