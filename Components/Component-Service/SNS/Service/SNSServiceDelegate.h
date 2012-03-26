//
//  SNSServiceDelegate.h
//  Draw
//
//  Created by  on 12-3-25.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol SNSServiceDelegate <NSObject>

@optional
- (void)didLogin:(int)result userInfo:(NSDictionary*)userInfo;
- (void)didPublishWeibo:(int)result;

@end
