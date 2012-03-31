//
//  QuadCurveMenuItem.h
//  HitGame
//
//  Created by Orange on 12-1-4.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
@class QuadCurveMenuItem;

@protocol QuadCurveMenuItemDelegate <NSObject>
- (void)quadCurveMenuItemTouchesBegan:(QuadCurveMenuItem *)item;
- (void)quadCurveMenuItemTouchesEnd:(QuadCurveMenuItem *)item;
@end

@interface QuadCurveMenuItem : UIImageView
{
    UIImageView *_contentImageView;
    UILabel *_titleLabel;
    CGPoint _startPoint;
    CGPoint _endPoint;
    CGPoint _nearPoint; // near
    CGPoint _farPoint; // far
    
    id<QuadCurveMenuItemDelegate> _delegate;
}

@property (nonatomic) CGPoint startPoint;
@property (nonatomic) CGPoint endPoint;
@property (nonatomic) CGPoint nearPoint;
@property (nonatomic) CGPoint farPoint;

@property (nonatomic, assign) id<QuadCurveMenuItemDelegate> delegate;

- (id)initWithImage:(UIImage *)img 
   highlightedImage:(UIImage *)himg
       ContentImage:(UIImage *)cimg
highlightedContentImage:(UIImage *)hcimg;

- (id)initWithImage:(UIImage *)anImg 
   highlightedImage:(UIImage *)aHighlightImg 
       contentImage:(UIImage *)aContentImage 
highlightedContentImage:(UIImage *)aHighlightContentImage 
              title:(NSString*)aTitle;
- (void)setTitle:(NSString*)aTitle;
- (NSString*)title;

@end


