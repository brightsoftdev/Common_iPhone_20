//
//  AdvertiseManager.h
//  HitGame
//
//  Created by Orange on 12-5-24.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
@class GADBannerView;
@protocol AdvertiseManagerDelegate <NSObject>
@optional
- (void)adsDidShowInController:(UIViewController*)controler;

@end

@interface AdvertiseManager : NSObject {
    GADBannerView* _banner;
}
+ (AdvertiseManager*)defaultManager;
- (void)showAdsInViewController:(UIViewController *)superViewController 
                       isUpside:(BOOL)isUpside 
                        autoFit:(BOOL)autoFit 
                      publishId:(NSString*)publishId;
@property (retain, nonatomic) GADBannerView* banner;
@property (assign, nonatomic) id<AdvertiseManagerDelegate> delegate;
@end
