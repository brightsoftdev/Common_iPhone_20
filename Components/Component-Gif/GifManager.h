//
//  GifManager.h
//  Draw
//
//  Created by Orange on 12-4-6.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ANGifEncoder.h"
#import "ANCutColorTable.h"
#import "ANGifNetscapeAppExtension.h"
#import "ANImageBitmapRep.h"
#import "UIImagePixelSource.h"

@interface GifManager : NSObject

+ (void)createGifToPath:(NSString*)filePath byImages:(NSArray*)images;

@end
