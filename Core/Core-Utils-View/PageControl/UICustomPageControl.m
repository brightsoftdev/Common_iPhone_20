//
//  UIUserDefinePageControl.m
//  Travel
//
//  Created by 小涛 王 on 12-3-7.
//  Copyright (c) 2012年 甘橙软件. All rights reserved.
//

#import "UICustomPageControl.h"

@interface UICustomPageControl ()
{
    UIImage *_currentPageIndicatorImage;
    UIImage *_nonCurrentPageIndicatorImage;
}

@end

@implementation UICustomPageControl

@synthesize delegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code        
        [self addTarget:self action:@selector(currentPageDidChange) forControlEvents:UIControlEventValueChanged];
    }
    return self;
}

- (void)currentPageDidChange
{
    [self setCurrentPage:self.currentPage];
    NSLog(@"current page = %d", self.currentPage);
    if (delegate && [delegate respondsToSelector:@selector(currentPageDidChange:)]) {
        [delegate currentPageDidChange:self.currentPage];
    }
}

-(void)updateDots
{
    if (self.defersCurrentPageDisplay) {
        NSArray *pageIndicatorViews = self.subviews;
        for(NSInteger i=0; i<[pageIndicatorViews count]; i++)
        {
            UIImageView *pageIndicatorView = [pageIndicatorViews objectAtIndex:i];
//            NSLog(@"x=%f, y=%f, width=%f, height=%f", pageIndicatorView.frame.origin.x, pageIndicatorView.frame.origin.y, pageIndicatorView.frame.size.width, pageIndicatorView.frame.size.height);
            pageIndicatorView.image = self.currentPage == i ? _currentPageIndicatorImage : _nonCurrentPageIndicatorImage;
        }
        [self updateCurrentPageDisplay];
    }
}

- (void)setNumberOfPages:(NSInteger)numberOfPages
{
    [super setNumberOfPages:numberOfPages];
    [self updateDots];
}

- (void)setCurrentPage:(NSInteger)page
{
    [super setCurrentPage:page];
    [self updateDots];
}

- (void)setPageIndicatorImageForCurrentPage:(UIImage*)currentPageIndicatorImage 
                          forNotCurrentPage:(UIImage*)nonCurrentPageIndicatorImage
{
    [_currentPageIndicatorImage release];
    _currentPageIndicatorImage = [currentPageIndicatorImage retain];
    [_nonCurrentPageIndicatorImage release];
    _nonCurrentPageIndicatorImage = [nonCurrentPageIndicatorImage retain];
    self.defersCurrentPageDisplay = YES;
}

-(void)dealloc
{
    [_currentPageIndicatorImage release];
    [_nonCurrentPageIndicatorImage release];
    [super dealloc];
}

@end
