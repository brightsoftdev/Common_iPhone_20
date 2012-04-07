//
//  GifView.h
//  GIFViewer
//
//  Created by xToucher04 on 11-11-9.
//  Copyright 2011 Toucher. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ImageIO/ImageIO.h>
#import <MobileCoreServices/MobileCoreServices.h>

@interface GifView : UIView {
	CGImageSourceRef gif;
	NSDictionary *gifProperties;
	size_t index;
	size_t count;
	NSTimer *timer;
}
@property (assign, nonatomic) float playTimeInterval;
- (id)initWithFrame:(CGRect)frame filePath:(NSString *)_filePath playTimeInterval:(float)timeInterval;
@end
