//
//  SlideImageView.h
//  Travel
//
//  Created by  on 12-2-29.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UICustomPageControl.h"
#import "HJManagedImageV.h"

@interface SlideImageView : UIView <UIScrollViewDelegate, HJManagedImageVDelegate>

@property (nonatomic, retain)IBOutlet UIScrollView *scrollView;
@property (nonatomic, retain)IBOutlet UICustomPageControl *pageControl;
@property (nonatomic, retain) NSString *imageForPageStateNormal;
@property (nonatomic, retain) NSString *imageForPageStateHighted;
@property (nonatomic, retain) NSString *defaultImage;

- (id)initWithFrame:(CGRect)frame;
- (void)setImages:(NSArray*)images;

- (IBAction)pageClick:(id)sender;

@end
