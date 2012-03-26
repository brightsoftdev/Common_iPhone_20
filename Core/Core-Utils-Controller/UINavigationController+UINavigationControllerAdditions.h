//
//  UINavigationController+UINavigationControllerAdditions.h
//  Draw
//
//  Created by  on 12-3-16.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UINavigationController (UINavigationControllerAdditions)

- (void)pushViewController: (UIViewController*)controller
    animatedWithTransition: (UIViewAnimationTransition)transition;

- (UIViewController*)popViewControllerAnimatedWithTransition:(UIViewAnimationTransition)transition;

@end
