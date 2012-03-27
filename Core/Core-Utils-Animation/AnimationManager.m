//
//  AnimationManager.m
//  HitGameTest
//
//  Created by  on 11-12-26.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "AnimationManager.h"

AnimationManager *animatinManager;

@implementation AnimationManager

- (id)init
{
    self = [super init];
    if (self) {
        _animationDict  = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (AnimationManager *)defaultManager
{
    if (animatinManager == nil) {
        animatinManager = [[AnimationManager alloc] init];
    }
    return animatinManager;
}

- (CAAnimation *)animationForKey:(NSString *)key
{
    if ([_animationDict count] == 0) {
        return nil;
    }
    CAAnimation *animation = [_animationDict valueForKey:key];
    return animation;
}
- (void)setAnimation:(CAAnimation *)animation forKey:(NSString *)key
{
    
}

#pragma mark - common function

+ (CAAnimation *)rotationAnimationWithRoundCount:(CGFloat) count 
                                        duration:(CFTimeInterval)duration
{
    CABasicAnimation * animation = [CABasicAnimation 
                                  animationWithKeyPath:@"transform.rotation.z"]; 
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    animation.toValue = [NSNumber numberWithFloat:count * M_PI * 2];
    animation.duration = duration ;
    return animation;
}

+ (CAAnimation *)rotationAnimationFrom:(float)startValue 
                                    to:(float)endValue 
                              duration:(float)duration
{
    CABasicAnimation * animation = [CABasicAnimation 
                                    animationWithKeyPath:@"transform.rotation.z"]; 
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    animation.fromValue = [NSNumber numberWithFloat:startValue];
    animation.toValue = [NSNumber numberWithFloat:startValue];
    animation.duration = duration ;
    return animation;
}

+ (CAAnimation *)missingAnimationWithDuration:(CFTimeInterval)duration
{
    CABasicAnimation * animation = [CABasicAnimation 
                                    animationWithKeyPath:@"opacity"]; 
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    animation.toValue = [NSNumber numberWithInt:0];
    animation.duration = duration ;
    animation.fillMode = kCAFillModeForwards;
    animation.removedOnCompletion = NO;
    return animation;
}

+ (CAAnimation *)scaleAnimationWithScale:(CGFloat)scale  
                                duration:(CFTimeInterval)duration 
                                delegate:(id)delegate 
                        removeCompeleted:(BOOL)removedOnCompletion
{
    
    CABasicAnimation * animation=[CABasicAnimation animationWithKeyPath:@"transform"]; 
    animation.toValue = [ NSValue valueWithCATransform3D: CATransform3DMakeScale(scale, scale, scale)];
    animation.duration = duration;
    animation.fillMode = kCAFillModeForwards;
    animation.removedOnCompletion = removedOnCompletion;
    return animation;
}


+ (CAAnimation *)scaleAnimationWithFromScale:(CGFloat)fromScale 
                                     toScale:(CGFloat)toScale
                                duration:(CFTimeInterval)duration 
                                delegate:(id)delegate 
                        removeCompeleted:(BOOL)removedOnCompletion
{
    
    CABasicAnimation * animation=[CABasicAnimation animationWithKeyPath:@"transform"]; 
    animation.fromValue = [ NSValue valueWithCATransform3D: CATransform3DMakeScale(fromScale, fromScale, fromScale)];

    animation.toValue = [ NSValue valueWithCATransform3D: CATransform3DMakeScale(toScale, toScale, toScale)];
    animation.duration = duration;
    animation.delegate = delegate;
    animation.fillMode = kCAFillModeForwards;
    animation.removedOnCompletion = removedOnCompletion;
    return animation;
}

+ (CAAnimation *)translationAnimationFrom:(CGPoint) start
                                         to:(CGPoint)end
                                  duration:(CFTimeInterval)duration
{
    
    CABasicAnimation * animation=[CABasicAnimation animationWithKeyPath:@"position"]; 
    animation.fromValue = [NSValue valueWithCGPoint:start];
    animation.toValue = [NSValue valueWithCGPoint:end];
    animation.duration = duration;
    return animation;
}
+ (CAAnimation *)translationAnimationTo:(CGPoint)end
                                 duration:(CFTimeInterval)duration
{
    
    CABasicAnimation * animation=[CABasicAnimation animationWithKeyPath:@"position"]; 
    animation.toValue = [NSValue valueWithCGPoint:end];
    animation.duration = duration;
    return animation;
}

+ (CAAnimation *)translationAnimationFrom:(CGPoint) start
                                       to:(CGPoint)end
                                 duration:(CFTimeInterval)duration 
                                 delegate:(id)delegate 
                         removeCompeleted:(BOOL)removedOnCompletion
{
    
    CABasicAnimation * animation=[CABasicAnimation animationWithKeyPath:@"position"]; 
    animation.fromValue = [NSValue valueWithCGPoint:start];
    animation.toValue = [NSValue valueWithCGPoint:end];
    animation.duration = duration;
    animation.delegate = delegate;
    if (removedOnCompletion) {
        animation.removedOnCompletion = YES;
    }else{
        animation.fillMode = kCAFillModeForwards;
        animation.removedOnCompletion = NO;
    }
    return animation;
}

+ (CAAnimation *)shakeFor:(CGFloat)margin originX:(CGFloat)orginX times:(int)times duration:(CFTimeInterval)duration
{
    CABasicAnimation * animation=[CABasicAnimation animationWithKeyPath:@"position.x"]; 
    animation.fromValue = [NSNumber numberWithFloat:orginX-margin/2];
    animation.toValue = [NSNumber numberWithFloat:orginX+margin/2];
    animation.duration = duration / times;
    animation.repeatCount = times;
    animation.autoreverses = YES;
    return animation;
    
    
}

+ (CAAnimation *)view:(UIView*)view shakeFor:(CGFloat)margin times:(int)times duration:(CFTimeInterval)duration
{
    CABasicAnimation * animation=[CABasicAnimation animationWithKeyPath:@"position.y"]; 
    animation.fromValue = [NSNumber numberWithFloat:view.center.y-margin/2];
    animation.toValue = [NSNumber numberWithFloat:view.center.y+margin/2];
    animation.duration = duration / times;
    animation.repeatCount = times;
    animation.autoreverses = YES;
    return animation;    
}

@end
