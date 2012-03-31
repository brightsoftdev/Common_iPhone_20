//
//  QuadCurveMenu.h
//  HitGame
//  这里需要QuartzCore.framework
//  Created by Orange on 12-1-4.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QuadCurveMenuItem.h"

@class QuadCurveMenu;
@protocol QuadCurveMenuDelegate <NSObject>
- (void)quadCurveMenu:(QuadCurveMenu *)menu didSelectIndex:(NSInteger)anIndex;
@optional
- (void)quadCurveMenuDidExpand;
- (void)quadCurveMenuDidClose;
@end

@interface QuadCurveMenu : UIView <QuadCurveMenuItemDelegate>
{
    NSArray *_menusArray;
    int _flag;
    BOOL _isExpanding;
    NSTimer *_timer;
    QuadCurveMenuItem *_addButton;
    float _nearRadius;
    float _endRadius;
    float _farRadius;
    CGPoint _startPoint;
    float _timeOffset;
    float _rotateAngle;
    float _menuWholeAngle;
    
    id<QuadCurveMenuDelegate> _delegate;
    
}
@property (nonatomic, copy) NSArray *menusArray;
@property (nonatomic, assign)     BOOL isExpanding;
@property (nonatomic, assign) id<QuadCurveMenuDelegate> delegate;
@property (nonatomic, assign) float nearRadius;
@property (nonatomic, assign) float endRadius;
@property (nonatomic, assign) float farRadius;
@property (nonatomic, assign) CGPoint startPoint;
@property (nonatomic, assign) float timeOffset;
@property (nonatomic, assign) float rotateAngle;
@property (nonatomic, assign) float menuWholeAngle;
- (id)initWithFrame:(CGRect)frame menus:(NSArray *)aMenusArray;
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
contentHighLightImage:(UIImage*)aContentHighLightImage;
- (void)expandItems;
- (void)closeItems;
@end
