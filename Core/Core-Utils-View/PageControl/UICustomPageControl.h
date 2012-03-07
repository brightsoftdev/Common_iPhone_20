//
//  UIUserDefinePageControl.h
//  Travel
//
//  Created by 小涛 王 on 12-3-7.
//  Copyright (c) 2012年 甘橙软件. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UICustomPageControl : UIPageControl

{
    UIImage *imagePageStateNormal;
    UIImage *imagePageStateHighted;
}

@property (nonatomic, retain)UIImage *imagePageStateNormal;
@property (nonatomic, retain)UIImage *imagePageStateHighted;

@end
