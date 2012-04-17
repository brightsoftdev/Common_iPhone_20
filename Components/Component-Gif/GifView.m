//
//  GifView.m
//  GIFViewer
//
//  Created by xToucher04 on 11-11-9.
//  Copyright 2011 Toucher. All rights reserved.
//

#import "GifView.h"
#import <QuartzCore/QuartzCore.h>

@implementation GifView
@synthesize playTimeInterval;


- (id)initWithFrame:(CGRect)frame filePath:(NSString *)_filePath playTimeInterval:(float)timeInterval{
    
    self = [super initWithFrame:frame];
    if (self) {
        self.playTimeInterval = timeInterval;
		gifProperties = [[NSDictionary dictionaryWithObject:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:0] forKey:(NSString *)kCGImagePropertyGIFLoopCount]
													 forKey:(NSString *)kCGImagePropertyGIFDictionary] retain];
		gif = CGImageSourceCreateWithURL((CFURLRef)[NSURL fileURLWithPath:_filePath], (CFDictionaryRef)gifProperties);
		count =CGImageSourceGetCount(gif);
		timer = [NSTimer scheduledTimerWithTimeInterval:self.playTimeInterval target:self selector:@selector(play) userInfo:nil repeats:YES];
		[timer fire];
    }
    return self;
}

-(void)play
{
	index ++;
	index = index%count;
	CGImageRef ref = CGImageSourceCreateImageAtIndex(gif, index, (CFDictionaryRef)gifProperties);
	self.layer.contents = (id)ref;
}

-(void)removeFromSuperview
{
	NSLog(@"removeFromSuperview");
	[timer invalidate];
	timer = nil;
	[super removeFromSuperview];
}
- (void)dealloc {
		NSLog(@"dealloc");
	CFRelease(gif);
	[gifProperties release];
    [super dealloc];
}


@end
