//
//  QuadCurveMenuItem.m
//  HitGame
//
//  Created by Orange on 12-1-4.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "QuadCurveMenuItem.h"
static inline CGRect ScaleRect(CGRect rect, float n) {return CGRectMake((rect.size.width - rect.size.width * n)/ 2, (rect.size.height - rect.size.height * n) / 2, rect.size.width * n, rect.size.height * n);}
@implementation QuadCurveMenuItem
@synthesize startPoint = _startPoint;
@synthesize endPoint = _endPoint;
@synthesize nearPoint = _nearPoint;
@synthesize farPoint = _farPoint;
@synthesize delegate  = _delegate;

#pragma mark - initialization & cleaning up
- (id)initWithImage:(UIImage *)img 
   highlightedImage:(UIImage *)himg
       ContentImage:(UIImage *)cimg
highlightedContentImage:(UIImage *)hcimg
{
    if (self = [super init]) 
    {
        self.image = img;
        self.highlightedImage = himg;
        self.userInteractionEnabled = YES;
        _contentImageView = [[UIImageView alloc] initWithImage:cimg];
        _contentImageView.highlightedImage = hcimg;
        [self addSubview:_contentImageView];
    }
    return self;
}

- (id)initWithImage:(UIImage *)anImg 
   highlightedImage:(UIImage *)aHighlightImg 
       contentImage:(UIImage *)aContentImage 
highlightedContentImage:(UIImage *)aHighlightContentImage 
              title:(NSString*)aTitle
{
    self = [super init];
    if (self) {
        self.image = anImg;
        self.highlightedImage = aHighlightImg;
        self.userInteractionEnabled = YES;
        _contentImageView = [[UIImageView alloc] initWithImage:aContentImage];
        _contentImageView.highlightedImage = aHighlightContentImage;
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 40, 40, 20)];
        [_titleLabel setBackgroundColor:[UIColor clearColor]];
        [_titleLabel setText:aTitle];
        [self addSubview:_contentImageView];
        [self addSubview:_titleLabel];
    }
    return self;
}
- (void)dealloc
{
    [_titleLabel release];
    [_contentImageView release];
    [super dealloc];
}

- (void)setTitle:(NSString*)aTitle
{
    [_titleLabel setText:aTitle];
}

- (NSString*)title
{
    return _titleLabel.text ;
}


#pragma mark - UIView's methods
- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.bounds = CGRectMake(0, 0, self.image.size.width, self.image.size.height);
    
    float width = _contentImageView.image.size.width;
    float height = _contentImageView.image.size.height;
    _contentImageView.frame = CGRectMake(self.bounds.size.width/2 - width/2, self.bounds.size.height/2 - height/2, width, height);
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    self.highlighted = YES;
    if ([_delegate respondsToSelector:@selector(quadCurveMenuItemTouchesBegan:)])
    {
        [_delegate quadCurveMenuItemTouchesBegan:self];
    }
    
}
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    // if move out of 2x rect, cancel highlighted.
    CGPoint location = [[touches anyObject] locationInView:self];
    if (!CGRectContainsPoint(ScaleRect(self.bounds, 2.0f), location))
    {
        self.highlighted = NO;
    }
    
}
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    self.highlighted = NO;
    // if stop in the area of 2x rect, response to the touches event.
    CGPoint location = [[touches anyObject] locationInView:self];
    if (CGRectContainsPoint(ScaleRect(self.bounds, 2.0f), location))
    {
        if ([_delegate respondsToSelector:@selector(quadCurveMenuItemTouchesEnd:)])
        {
            [_delegate quadCurveMenuItemTouchesEnd:self];
        }
    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    self.highlighted = NO;
}

#pragma mark - instant methods
- (void)setHighlighted:(BOOL)highlighted
{
    [super setHighlighted:highlighted];
    [_contentImageView setHighlighted:highlighted];
}
@end
