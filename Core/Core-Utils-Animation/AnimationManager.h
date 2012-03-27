//
//  AnimationManager.h
//  HitGameTest
//  这里需要QuartzCore.framework
//  Created by  on 11-12-26.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>
@interface AnimationManager : NSObject
{
    NSMutableDictionary *_animationDict;
}

- (CAAnimation *)animationForKey:(NSString *)key;
- (void)setAnimation:(CAAnimation *)animation forKey:(NSString *)key;

//rotation
+ (CAAnimation *)rotationAnimationWithRoundCount:(CGFloat) count 
                                        duration:(CFTimeInterval)duration;
+ (CAAnimation *)rotationAnimationFrom:(float)startValue 
                                    to:(float)endValue 
                              duration:(float)duration;

//opacity
+ (CAAnimation *)missingAnimationWithDuration:(CFTimeInterval)duration;

//scale
+ (CAAnimation *)scaleAnimationWithScale:(CGFloat)scale  
                                duration:(CFTimeInterval)duration 
                                delegate:(id)delegate 
                        removeCompeleted:(BOOL)removedOnCompletion;
+ (CAAnimation *)scaleAnimationWithFromScale:(CGFloat)fromScale 
                                     toScale:(CGFloat)toScale
                                    duration:(CFTimeInterval)duration 
                                    delegate:(id)delegate 
                            removeCompeleted:(BOOL)removedOnCompletion;

//translation
+ (CAAnimation *)translationAnimationFrom:(CGPoint) start
                                       to:(CGPoint)end
                                 duration:(CFTimeInterval)duration;
+ (CAAnimation *)translationAnimationTo:(CGPoint)end
                               duration:(CFTimeInterval)duration;
+ (CAAnimation *)translationAnimationFrom:(CGPoint) start
                                       to:(CGPoint)end
                                 duration:(CFTimeInterval)duration 
                                 delegate:(id)delegate 
                         removeCompeleted:(BOOL)removedOnCompletion;
+ (CAAnimation *)shakeFor:(CGFloat)margin originX:(CGFloat)orginX times:(int)times duration:(CFTimeInterval)duration;
+ (CAAnimation *)view:(UIView*)view shakeFor:(CGFloat)margin times:(int)times duration:(CFTimeInterval)duration;
@end
