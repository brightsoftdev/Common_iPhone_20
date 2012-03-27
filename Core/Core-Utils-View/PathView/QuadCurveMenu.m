//
//  QuadCurveMenu.m
//  HitGame
//
//  Created by Orange on 12-1-4.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "QuadCurveMenu.h"
#import <QuartzCore/QuartzCore.h>

//#define NEARRADIUS 110.0f
//#define ENDRADIUS 120.0f
//#define FARRADIUS 140.0f
//#define STARTPOINT CGPointMake(160, 240)
//#define TIMEOFFSET 0.036f
//#define ROTATEANGLE 0
//#define MENUWHOLEANGLE  M_PI * 2

static CGPoint RotateCGPointAroundCenter(CGPoint point, CGPoint center, float angle)
{
    CGAffineTransform translation = CGAffineTransformMakeTranslation(center.x, center.y);
    CGAffineTransform rotation = CGAffineTransformMakeRotation(angle);
    CGAffineTransform transformGroup = CGAffineTransformConcat(CGAffineTransformConcat(CGAffineTransformInvert(translation), rotation), translation);
    return CGPointApplyAffineTransform(point, transformGroup);    
}

@interface QuadCurveMenu ()
- (void)_expand;
- (void)_close;
- (CAAnimationGroup *)_blowupAnimationAtPoint:(CGPoint)p;
- (CAAnimationGroup *)_shrinkAnimationAtPoint:(CGPoint)p;
@end

@implementation QuadCurveMenu
@synthesize isExpanding = _isExpanding;
@synthesize delegate = _delegate;
@synthesize menusArray = _menusArray;
@synthesize nearRadius = _nearRadius;
@synthesize endRadius = _endRadius;
@synthesize farRadius = _farRadius;
@synthesize startPoint = _startPoint;
@synthesize timeOffset = _timeOffset;
@synthesize rotateAngle = _rotateAngle;
@synthesize menuWholeAngle = _menuWholeAngle;

#pragma mark - initialization & cleaning up

- (id)init
{
    self = [super init];
    if (self) {
        _nearRadius = 110.0f;
        _endRadius = 120.0f;
        _farRadius = 140.0f;
        _startPoint = CGPointMake(160, 240);
        _timeOffset = 0.036f;
        _rotateAngle = 0;
        _menuWholeAngle = M_PI*2;
    }
    return self;
}
- (id)initWithFrame:(CGRect)frame menus:(NSArray *)aMenusArray
{
    self = [super initWithFrame:frame];
    if (self) {
        _nearRadius = 110.0f;
        _endRadius = 120.0f;
        _farRadius = 140.0f;
        _startPoint = CGPointMake(160, 240);
        _timeOffset = 0.036f;
        _rotateAngle = 0;
        _menuWholeAngle = M_PI*2;
        self.backgroundColor = [UIColor clearColor];
        
        // layout menus
        self.menusArray = aMenusArray;
        
        // add the "Add" Button.
        _addButton = [[QuadCurveMenuItem alloc] initWithImage:[UIImage imageNamed:@"bg-addbutton.png"]
                                             highlightedImage:[UIImage imageNamed:@"bg-addbutton-highlighted.png"] 
                                                 ContentImage:[UIImage imageNamed:@"icon-plus.png"] 
                                      highlightedContentImage:[UIImage imageNamed:@"icon-plus-highlighted.png"]];
        _addButton.delegate = self;
        _addButton.center = _startPoint;
        [self addSubview:_addButton];
    }
    return self;
}

- (void)dealloc
{
    [_addButton release];
    [_menusArray release];
    [super dealloc];
}

- (id)initWithFrame:(CGRect)frame 
              menus:(NSArray *)aMenusArray 
         nearRadius:(float)aNearRadius 
          endRadius:(float) aEndRadius 
          farRadius:(float)aFarRadius 
         startPoint:(CGPoint)aStartPoint 
         timeOffset:(float)atimeOffset 
        rotateAngle:(float)aRotateAngle 
     menuWholeAngle:(float)aMenuWholeAngle 
        buttonImage:(UIImage*)aButtonImage 
buttonHighLightImage:(UIImage*)aButtonHighLightImage 
       contentImage:(UIImage*)aContentImage 
contentHighLightImage:(UIImage*)aContentHighLightImage
{
    self = [super initWithFrame:frame];
    if (self) {
        _nearRadius = aNearRadius;
        _endRadius = aEndRadius;
        _farRadius = aFarRadius;
        _startPoint = aStartPoint;
        _timeOffset = atimeOffset;
        _rotateAngle = aRotateAngle;
        _menuWholeAngle = aMenuWholeAngle;
        
        self.backgroundColor = [UIColor clearColor];
        
        // layout menus
        self.menusArray = aMenusArray;
        
        // add the "Add" Button.
        _addButton = [[QuadCurveMenuItem alloc] initWithImage:aButtonImage
                                             highlightedImage:aButtonHighLightImage 
                                                 ContentImage:aContentImage
                                      highlightedContentImage:aContentHighLightImage];
        _addButton.delegate = self;
        _addButton.center = _startPoint;
        [self addSubview:_addButton];
    }
    return self;
}




#pragma mark - UIView's methods
- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
{
    // if the menu state is expanding, everywhere can be touch
    // otherwise, only the add button are can be touch
    if (YES == _isExpanding) 
    {
        return YES;
    }
    else
    {
        return CGRectContainsPoint(_addButton.frame, point);
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    self.isExpanding = !self.isExpanding;
}

#pragma mark - QuadCurveMenuItem delegates
- (void)quadCurveMenuItemTouchesBegan:(QuadCurveMenuItem *)item
{
    if (item == _addButton) 
    {
        self.isExpanding = !self.isExpanding;
    }
}
- (void)quadCurveMenuItemTouchesEnd:(QuadCurveMenuItem *)item
{
    // exclude the "add" button
    if (item == _addButton) 
    {
        return;
    }
    // blowup the selected menu button
    CAAnimationGroup *blowup = [self _blowupAnimationAtPoint:item.center];
    [item.layer addAnimation:blowup forKey:@"blowup"];
    item.center = item.startPoint;
    
    // shrink other menu buttons
    for (int i = 0; i < [_menusArray count]; i ++)
    {
        QuadCurveMenuItem *otherItem = [_menusArray objectAtIndex:i];
        CAAnimationGroup *shrink = [self _shrinkAnimationAtPoint:otherItem.center];
        if (otherItem.tag == item.tag) {
            continue;
        }
        [otherItem.layer addAnimation:shrink forKey:@"shrink"];
        
        otherItem.center = otherItem.startPoint;
    }
    _isExpanding = NO;
    
    // rotate "add" button
    float angle = self.isExpanding ? -M_PI_4 : 0.0f;
    [UIView animateWithDuration:0.2f animations:^{
        _addButton.transform = CGAffineTransformMakeRotation(angle);
    }];
    
    if ([_delegate respondsToSelector:@selector(quadCurveMenu:didSelectIndex:)])
    {
        [_delegate quadCurveMenu:self didSelectIndex:item.tag - 1000];
    }
}

#pragma mark - instant methods
- (void)setMenusArray:(NSArray *)aMenusArray
{
    if (aMenusArray == _menusArray)
    {
        return;
    }
    [_menusArray release];
    _menusArray = [aMenusArray copy];
    
    
    // clean subviews
    for (UIView *v in self.subviews) 
    {
        if (v.tag >= 1000) 
        {
            [v removeFromSuperview];
        }
    }
    // add the menu buttons
    int count = [_menusArray count];
    for (int i = 0; i < count; i ++)
    {
        QuadCurveMenuItem *item = [_menusArray objectAtIndex:i];
        item.tag = 1000 + i;
        item.startPoint = self.startPoint;
        CGPoint endPoint = CGPointMake(self.startPoint.x + self.endRadius * sinf(i * self.menuWholeAngle / count), self.startPoint.y - self.endRadius * cosf(i * self.menuWholeAngle / count));
        item.endPoint = RotateCGPointAroundCenter(endPoint, self.startPoint, self.rotateAngle);
        CGPoint nearPoint = CGPointMake(self.startPoint.x + self.nearRadius * sinf(i * self.menuWholeAngle / count), self.startPoint.y - self.nearRadius * cosf(i * self.menuWholeAngle / count));
        item.nearPoint = RotateCGPointAroundCenter(nearPoint, self.startPoint, self.rotateAngle);
        CGPoint farPoint = CGPointMake(self.startPoint.x + self.farRadius * sinf(i * self.menuWholeAngle / count), self.startPoint.y - self.farRadius * cosf(i * self.menuWholeAngle / count));
        item.farPoint = RotateCGPointAroundCenter(farPoint, self.startPoint, self.rotateAngle);  
        item.center = item.startPoint;
        item.delegate = self;
        [self addSubview:item];
    }
}


- (void)setIsExpanding:(BOOL)expanding
{
    _isExpanding = expanding;  
    if (expanding) {
        if (_delegate && [_delegate respondsToSelector:@selector(quadCurveMenuDidExpand)]) {
            [_delegate quadCurveMenuDidExpand];
        }
    } else {
        if (_delegate && [_delegate respondsToSelector:@selector(quadCurveMenuDidClose)]) {
            [_delegate quadCurveMenuDidClose];
        }
    }

    // rotate add button
//    float angle = self.isExpanding ? -M_PI_4 : 0.0f;
//    [UIView animateWithDuration:0.2f animations:^{
//        _addButton.transform = CGAffineTransformMakeRotation(angle);
//    }];
//    
    // expand or close animation
    if (!_timer) 
    {
        _flag = self.isExpanding ? 0 : ([_menusArray count] - 1);
        SEL selector = self.isExpanding ? @selector(_expand) : @selector(_close);
        _timer = [[NSTimer scheduledTimerWithTimeInterval:self.timeOffset target:self selector:selector userInfo:nil repeats:YES] retain];
    }
}

- (void)expandItems
{
    if (!_isExpanding) {
        [self setIsExpanding:YES];
    }
    
}

- (void)closeItems
{
    if (_isExpanding) {
        [self setIsExpanding:NO];
    }
}

#pragma mark - private methods
- (void)_expand
{
    if (_flag == [_menusArray count])
    {
        [_timer invalidate];
        [_timer release];
        _timer = nil;
        return;
    }
    
    int tag = 1000 + _flag;
    QuadCurveMenuItem *item = (QuadCurveMenuItem *)[self viewWithTag:tag];
    
    CAKeyframeAnimation *rotateAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotateAnimation.values = [NSArray arrayWithObjects:[NSNumber numberWithFloat:M_PI],[NSNumber numberWithFloat:0.0f], nil];
    rotateAnimation.duration = 0.5f;
    rotateAnimation.keyTimes = [NSArray arrayWithObjects:
                                [NSNumber numberWithFloat:.3], 
                                [NSNumber numberWithFloat:.4], nil]; 
    
    CAKeyframeAnimation *positionAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    positionAnimation.duration = 0.5f;
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, item.startPoint.x, item.startPoint.y);
    CGPathAddLineToPoint(path, NULL, item.farPoint.x, item.farPoint.y);
    CGPathAddLineToPoint(path, NULL, item.nearPoint.x, item.nearPoint.y); 
    CGPathAddLineToPoint(path, NULL, item.endPoint.x, item.endPoint.y); 
    positionAnimation.path = path;
    CGPathRelease(path);
    
    CAAnimationGroup *animationgroup = [CAAnimationGroup animation];
    animationgroup.animations = [NSArray arrayWithObjects:positionAnimation, rotateAnimation, nil];
    animationgroup.duration = 0.5f;
    animationgroup.fillMode = kCAFillModeForwards;
    animationgroup.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    [item.layer addAnimation:animationgroup forKey:@"Expand"];
    item.center = item.endPoint;
    
    _flag ++;
    
}

- (void)_close
{
    if (_flag == -1)
    {
        [_timer invalidate];
        [_timer release];
        _timer = nil;
        return;
    }
    
    int tag = 1000 + _flag;
    QuadCurveMenuItem *item = (QuadCurveMenuItem *)[self viewWithTag:tag];
    
    CAKeyframeAnimation *rotateAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotateAnimation.values = [NSArray arrayWithObjects:[NSNumber numberWithFloat:0.0f],[NSNumber numberWithFloat:M_PI * 2],[NSNumber numberWithFloat:0.0f], nil];
    rotateAnimation.duration = 0.5f;
    rotateAnimation.keyTimes = [NSArray arrayWithObjects:
                                [NSNumber numberWithFloat:.0], 
                                [NSNumber numberWithFloat:.4],
                                [NSNumber numberWithFloat:.5], nil]; 
    
    CAKeyframeAnimation *positionAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    positionAnimation.duration = 0.5f;
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, item.endPoint.x, item.endPoint.y);
    CGPathAddLineToPoint(path, NULL, item.farPoint.x, item.farPoint.y);
    CGPathAddLineToPoint(path, NULL, item.startPoint.x, item.startPoint.y); 
    positionAnimation.path = path;
    CGPathRelease(path);
    
    CAAnimationGroup *animationgroup = [CAAnimationGroup animation];
    animationgroup.animations = [NSArray arrayWithObjects:positionAnimation, rotateAnimation, nil];
    animationgroup.duration = 0.5f;
    animationgroup.fillMode = kCAFillModeForwards;
    animationgroup.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    [item.layer addAnimation:animationgroup forKey:@"Close"];
    item.center = item.startPoint;
    _flag --;
}

- (CAAnimationGroup *)_blowupAnimationAtPoint:(CGPoint)p
{
    CAKeyframeAnimation *positionAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    positionAnimation.values = [NSArray arrayWithObjects:[NSValue valueWithCGPoint:p], nil];
    positionAnimation.keyTimes = [NSArray arrayWithObjects: [NSNumber numberWithFloat:.3], nil]; 
    
    CABasicAnimation *scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform"];
    scaleAnimation.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeScale(3, 3, 1)];
    
    CABasicAnimation *opacityAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    opacityAnimation.toValue  = [NSNumber numberWithFloat:0.0f];
    
    CAAnimationGroup *animationgroup = [CAAnimationGroup animation];
    animationgroup.animations = [NSArray arrayWithObjects:positionAnimation, scaleAnimation, opacityAnimation, nil];
    animationgroup.duration = 0.3f;
    animationgroup.fillMode = kCAFillModeForwards;
    
    return animationgroup;
}

- (CAAnimationGroup *)_shrinkAnimationAtPoint:(CGPoint)p
{
    CAKeyframeAnimation *positionAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    positionAnimation.values = [NSArray arrayWithObjects:[NSValue valueWithCGPoint:p], nil];
    positionAnimation.keyTimes = [NSArray arrayWithObjects: [NSNumber numberWithFloat:.3], nil]; 
    
    CABasicAnimation *scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform"];
    scaleAnimation.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeScale(.01, .01, 1)];
    
    CABasicAnimation *opacityAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    opacityAnimation.toValue  = [NSNumber numberWithFloat:0.0f];
    
    CAAnimationGroup *animationgroup = [CAAnimationGroup animation];
    animationgroup.animations = [NSArray arrayWithObjects:positionAnimation, scaleAnimation, opacityAnimation, nil];
    animationgroup.duration = 0.3f;
    animationgroup.fillMode = kCAFillModeForwards;
    
    return animationgroup;
}


@end

