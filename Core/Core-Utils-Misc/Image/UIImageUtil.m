//
//  UIImageUtil.m
//  three20test
//
//  Created by qqn_pipi on 10-3-23.
//  Copyright 2010 QQN-PIPI.com. All rights reserved.
//

#import "UIImageUtil.h"
#import "FileUtil.h"

@implementation UIImage (UIImageUtil)

- (UIImage*)defaultStretchableImage
{
    return [self stretchableImageWithLeftCapWidth:self.size.width/2 topCapHeight:self.size.height/2];
}

+ (UIImage*)strectchableImageName:(NSString*)name
{
    UIImage* image = [UIImage imageNamed:name];
    return [image defaultStretchableImage];
}

+ (UIImage*)strectchableTopImageName:(NSString*)name
{
    UIImage* image = [UIImage imageNamed:name];
    int topCapHeight = image.size.height/2;
    return [image stretchableImageWithLeftCapWidth:0 topCapHeight:topCapHeight];
}

+ (UIImage*)strectchableImageName:(NSString*)name leftCapWidth:(int)leftCapWidth
{
    UIImage* image = [UIImage imageNamed:name];
    return [image stretchableImageWithLeftCapWidth:leftCapWidth topCapHeight:0];
}

+ (UIImage*)strectchableImageName:(NSString*)name topCapHeight:(int)topCapHeight
{
    UIImage* image = [UIImage imageNamed:name];
    return [image stretchableImageWithLeftCapWidth:0 topCapHeight:topCapHeight];    
}

+ (UIImage*)strectchableImageName:(NSString*)name leftCapWidth:(int)leftCapWidth topCapHeight:(int)topCapHeight
{
    UIImage* image = [UIImage imageNamed:name];
    return [image stretchableImageWithLeftCapWidth:leftCapWidth topCapHeight:topCapHeight];    
}

+ (UIImageView*)strectchableImageView:(NSString*)name viewWidth:(int)viewWidth
{
    UIImage* image = [UIImage strectchableImageName:name];
    UIImageView* view = [[[UIImageView alloc] initWithImage:image] autorelease];
    view.frame = CGRectMake(0, 0, viewWidth, image.size.height);
    return view;
}

- (BOOL)saveImageToFile:(NSString*)fileName
{
	// Create paths to output images
//	NSString  *pngPath = [FileUtil getFileFullPath:fileName];
	
//	[NSHomeDirectory() stringByAppendingPathComponent:@"Documents/Test.png"];
//	NSString  *jpgPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/Test.jpg"];
	
	// Write a UIImage to JPEG with minimum compression (best quality)
	// The value 'image' must be a UIImage object
	// The value '1.0' represents image compression quality as value from 0.0 to 1.0
//	[UIImageJPEGRepresentation(image, 1.0) writeToFile:jpgPath atomically:YES];
	
	// Write image to PNG
	BOOL result = [UIImagePNGRepresentation(self) writeToFile:fileName atomically:YES];
	
	// Let's check to see if files were successfully written...
	
	// Create file manager
	//NSError *error;
	//NSFileManager *fileMgr = [NSFileManager defaultManager];
	
	// Point to Document directory
	//NSString *documentsDirectory = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
	
	// Write out the contents of home directory to console
	//NSLog(@"Documents directory: %@", [fileMgr contentsOfDirectoryAtPath:documentsDirectory error:&error]);
	
	NSLog(@"Write to file (%@), result=%d", fileName, result);
	
	return result;
}

+ (CGRect)shrinkFromOrigRect:(CGRect)origRect imageSize:(CGSize)imageSize
{
    CGRect retRect = origRect;
    
    if (imageSize.width > origRect.size.width && imageSize.height <= origRect.size.height){
        // use height 
        float percentage = origRect.size.width / imageSize.width;
        float width = imageSize.width * percentage;
        float height = imageSize.height * percentage;
        retRect.size = CGSizeMake(width, height);
    }
    else if (imageSize.width <= origRect.size.width && imageSize.height > origRect.size.height){
        // use width
        float percentage = origRect.size.height / imageSize.height;
        float width = imageSize.width * percentage;
        float height = imageSize.height * percentage;
        retRect.size = CGSizeMake(width, height);            
    }
    else if (imageSize.width > origRect.size.width && imageSize.height > origRect.size.height){
        float percentage1 = origRect.size.height / imageSize.height;
        float percentage2 = origRect.size.width / imageSize.width;
        float percentage;
        if (percentage1 > percentage2){
            percentage = percentage2;
        }
        else{
            percentage = percentage1;
        }
        float width = imageSize.width * percentage;
        float height = imageSize.height * percentage;
        retRect.size = CGSizeMake(width, height);                        
    }
    else{
        retRect.size = CGSizeMake(imageSize.width, imageSize.height);
    }
    
    return retRect;
}

#define IMAGE_DEFAULT_COMPRESS_QUALITY  1.0
#define IMAGE_POST_MAX_BYTE             (6000000)

+ (NSData *)compressImage:(UIImage *)image {

    NSData *data = UIImageJPEGRepresentation(image,IMAGE_DEFAULT_COMPRESS_QUALITY);
    int length = [data length];
    if (length <= IMAGE_POST_MAX_BYTE) {
        return data;
    }
    CGFloat quality = IMAGE_POST_MAX_BYTE/(CGFloat)length;
    NSData *tempData = UIImageJPEGRepresentation(image, quality);
    return tempData;
}

+ (NSData *)compressImage:(UIImage *)image byQuality:(float)quality{
    float compressQuality = quality;
    NSData *originData = UIImageJPEGRepresentation(image, 1.0);
    NSData *tempData = UIImageJPEGRepresentation(image, compressQuality);
    NSLog(@"before compress, size is %d\n after compress, size is %d", [originData length], [tempData length]);
    return tempData;

}

@end
