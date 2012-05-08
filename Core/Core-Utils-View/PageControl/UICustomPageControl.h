//
//  UIUserDefinePageControl.h
//  Travel
//
//  Created by 小涛 王 on 12-3-7.
//  Copyright (c) 2012年 甘橙软件. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol UICustomPageControlDelegate <NSObject>

@optional
- (void)currentPageDidChange:(int)newPage;

@end

@interface UICustomPageControl : UIPageControl

@property (nonatomic, assign) id<UICustomPageControlDelegate> delegate;
- (void)setPageIndicatorImageForCurrentPage:(UIImage*)currentIndicatorImage 
                          forNotCurrentPage:(UIImage*)notCurrentIndicatorImage;


@end
