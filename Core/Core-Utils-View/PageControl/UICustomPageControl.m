//
//  UIUserDefinePageControl.m
//  Travel
//
//  Created by 小涛 王 on 12-3-7.
//  Copyright (c) 2012年 甘橙软件. All rights reserved.
//

#import "UICustomPageControl.h"

@interface UICustomPageControl(private)
- (void)updateDots;
@end

@implementation UICustomPageControl

@synthesize imagePageStateNormal;
@synthesize imagePageStateHighted;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setImagePageStateNormal:(UIImage *)image
{
    [imagePageStateNormal release];
    imagePageStateNormal = [image retain];
    [self updateDots];
}

- (void)setImagePageStateHighted:(UIImage *)image
{
    [imagePageStateHighted release];
    imagePageStateHighted = [image retain];
    [self updateDots];
}

-(void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    [super endTrackingWithTouch:touch withEvent:event];
    [self updateDots];
}

-(void)updateDots
{
    if (imagePageStateNormal || imagePageStateHighted) {
        NSArray *subViews = self.subviews;
        for(NSInteger i=0; i<[subViews count]; i++)
        {
            UIImageView *dot = [subViews objectAtIndex:i];
            dot.image = self.currentPage == i ? imagePageStateNormal : imagePageStateHighted;
        }
    }
}

-(void)dealloc
{
    [imagePageStateNormal release];
    imagePageStateNormal = nil;
    [imagePageStateHighted release];
    imagePageStateHighted = nil;
    [super dealloc];
    
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
