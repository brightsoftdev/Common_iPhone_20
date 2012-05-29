//
//  AdvertiseManager.m
//  HitGame
//
//  Created by Orange on 12-5-24.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "AdvertiseManager.h"
#import "GADBannerView.h"
#import "MobClickUtils.h"

#define ENABLE_AD           @"ENABLE_AD"
#define VALUE_ENABLE        @"1"
#define VALUE_NOT_ENABLE    @"0"

static AdvertiseManager* globalAdvertiseManager;
AdvertiseManager* globalGetAdvertiseManager() {
    if (globalAdvertiseManager == nil) {
        globalAdvertiseManager = [[AdvertiseManager alloc ] init ];
    } 
    return globalAdvertiseManager;
}

@implementation AdvertiseManager
@synthesize banner = _banner;
@synthesize delegate = _delegate;

- (void)dealloc
{
    [_banner release];
    [super dealloc];
}

+ (AdvertiseManager*)defaultManager
{
    return globalGetAdvertiseManager();
}

- (void)showAdsInViewController:(UIViewController<AdvertiseManagerDelegate> *)superViewController 
                       isUpside:(BOOL)isUpside 
                        autoFit:(BOOL)autoFit 
                      publishId:(NSString*)publishId
{
    NSString* str = [MobClick getConfigParams:ENABLE_AD];
    if (![str isEqualToString:VALUE_ENABLE]) {
        return;
    }
    if (!_banner) {
        _banner = [[GADBannerView alloc] initWithFrame:CGRectMake(0, 0, GAD_SIZE_320x50.width, GAD_SIZE_320x50.height)];
    }
    _banner.adUnitID = publishId;
    _banner.rootViewController = superViewController;
    self.delegate = superViewController;
    [_banner loadRequest:[GADRequest request]];
    
    if (isUpside) {
        [_banner setFrame:CGRectMake(0.0,
                                  0,
                                  GAD_SIZE_320x50.width,
                                  GAD_SIZE_320x50.height)];
        if (autoFit) {
            CGRect rect = superViewController.view.frame;
            rect.origin.y += GAD_SIZE_320x50.height;
            rect.size.height -= GAD_SIZE_320x50.height;
            [superViewController.view setFrame:rect];
        }
    } else {
        [_banner setFrame:CGRectMake(0.0,
                                  superViewController.view.frame.size.height-GAD_SIZE_320x50.height,
                                  GAD_SIZE_320x50.width,
                                  GAD_SIZE_320x50.height)];
        if (autoFit) {
            CGRect rect = superViewController.view.frame;
            rect.size.height -= GAD_SIZE_320x50.height;
            [superViewController.view setFrame:rect];
        }
    }
    
    [superViewController.view addSubview:_banner];
    [superViewController.view bringSubviewToFront:_banner];
    if (_delegate && [_delegate respondsToSelector:@selector(adsDidShowInController:)]) 
    {
        [_delegate adsDidShowInController:superViewController];
    }
}


@end
