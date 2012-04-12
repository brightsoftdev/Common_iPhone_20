//
//  GifManager.m
//  Draw
//
//  Created by Orange on 12-4-6.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "GifManager.h"
#import "PPDebug.h"

@implementation GifManager

+ (ANGifImageFrame *)imageFrameWithImage:(UIImage *)anImage fitting:(CGSize)imageSize {
	UIImage * scaledImage = anImage;
	if (!CGSizeEqualToSize(anImage.size, imageSize)) {
		scaledImage = [anImage imageFittingFrame:imageSize];
	}
    
	UIImagePixelSource * pixelSource = [[UIImagePixelSource alloc] initWithImage:scaledImage];
	ANCutColorTable * colorTable = [[ANCutColorTable alloc] initWithTransparentFirst:YES pixelSource:pixelSource];
	ANGifImageFrame * frame = [[ANGifImageFrame alloc] initWithPixelSource:pixelSource colorTable:colorTable delayTime:1];
#if !__has_feature(objc_arc)
	[colorTable release];
	[pixelSource release];
	[frame autorelease];
#endif
	return frame;
}

#define GIF_COMPRESS    0.5
#define GIF_SPEED       0.2

+ (void)createGifToPath:(NSString*)filePath byImages:(NSArray*)images
{
    NSString* tempFile = filePath;
    NSArray* gifFrameArray = images;
    //NSString * tempFile = [NSString stringWithFormat:@"%@/test1.gif", NSTemporaryDirectory()];
    if ([[NSFileManager defaultManager] fileExistsAtPath:tempFile]) {
        [[NSFileManager defaultManager] removeItemAtPath:tempFile error:nil];
    }
    UIImage * firstImage = nil;
    if ([gifFrameArray count] > 0) {
        firstImage = [gifFrameArray objectAtIndex:0];
    }
    NSLog(@"gif frame count = %d", gifFrameArray.count);
    CGSize canvasSize = (firstImage ? firstImage.size : CGSizeZero);
    ANGifEncoder * encoder = [[ANGifEncoder alloc] initWithOutputFile:tempFile size:canvasSize globalColorTable:nil];
    ANGifNetscapeAppExtension * extension = [[ANGifNetscapeAppExtension alloc] init];
    [encoder addApplicationExtension:extension];
#if !__has_feature(objc_arc)
    [extension release];
#endif
    for (int i = 0; i < [gifFrameArray count]; i++) {
        PPDebug(@"dealing with No.%d image", i);
        UIImage * image = [gifFrameArray objectAtIndex:i];
//        NSData* dataAfterCompressed = UIImageJPEGRepresentation(image, GIF_COMPRESS);
        PPDebug(@"frame size before = %d", [(NSData*)UIImageJPEGRepresentation(image, 1.0) length]);
        ANGifImageFrame * theFrame = [GifManager imageFrameWithImage:image fitting:canvasSize];
        theFrame.delayTime = GIF_SPEED;
        //        [self setProgressLabel:[NSString stringWithFormat:@"Encoding Frame (%d/%d)", i + 1, (int)[images count]]];
        [encoder addImageFrame:theFrame];
    }
    [encoder closeFile];
#if !__has_feature(objc_arc)
    [encoder release];
#endif
    //[self performSelectorOnMainThread:@selector(informCallbackDone:) withObject:fileOutput waitUntilDone:NO];
    
    //[[NSFileManager defaultManager] removeItemAtPath:aFile error:nil];
//    MFMailComposeViewController * compose = [[MFMailComposeViewController alloc] init];
//    [compose setSubject:@"Gif Image"];
//    [compose setMessageBody:@"I have kindly attached a GIF image to this E-mail. I made this GIF using ANGif, an open source Objective-C library for exporting animated GIFs." isHTML:NO];
//    [compose addAttachmentData:attachmentData mimeType:@"image/gif" fileName:@"image.gif"];
//    //[compose setMailComposeDelegate:self];
//    [self performSelector:@selector(showViewController:) withObject:compose afterDelay:1];
//    [compose release];
#ifdef DEBUG    
//    NSData * attachmentData = [NSData dataWithContentsOfFile:tempFile];
//    NSLog(@"Path: %@", tempFile);

    NSDictionary * attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:tempFile error:nil];
    PPDebug(@"file path = %@, size = %.2fMB", tempFile,
            [(NSNumber*)[attributes objectForKey:NSFileSize] intValue]/1024/1024.0);
#endif    
}

@end
