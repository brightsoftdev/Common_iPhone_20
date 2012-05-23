//
//  SlideImageView.m
//  Travel
//
//  Created by  on 12-2-29.
//  Copyright (c) 2012Âπ?__MyCompanyName__. All rights reserved.
//

#import "SlideImageView.h"
#import "HJObjManager.h"
#import "PPApplication.h"

#define DEFAULT_HEIGHT_OF_PAGE_CONTROL 20

@implementation SlideImageView

@synthesize scrollView;
@synthesize pageControl;
@synthesize defaultImage;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
        scrollView.pagingEnabled = YES;
        scrollView.showsVerticalScrollIndicator = NO;
        scrollView.showsHorizontalScrollIndicator = NO;
        scrollView.delegate = self;
        
        [self addSubview:scrollView];
        
        pageControl = [[UICustomPageControl alloc] initWithFrame:CGRectMake(self.bounds.origin.x/2, self.bounds.size.height-DEFAULT_HEIGHT_OF_PAGE_CONTROL, self.bounds.size.width, DEFAULT_HEIGHT_OF_PAGE_CONTROL)]; 
        self.backgroundColor = [UIColor clearColor];
        pageControl.hidesForSinglePage = YES;
        pageControl.delegate = self;
        
        [self addSubview:pageControl];
    }
    
    return self;
}

- (void)clearImagesInCache
{
    for (UIView *view in scrollView.subviews) {
        HJManagedImageV *imageView = (HJManagedImageV*)view;
        [imageView clear];
    }
}

-(void)dealloc
{
    [self clearImagesInCache];
    [scrollView release];
    [pageControl release];
    [defaultImage release];

    [super dealloc];
}

// images is a NSString array that contain a list of absoute path or absolute URL or bundle file name of the images.
- (void)setImages:(NSArray*)images{
    [self addImagesToScrollView:images];
    pageControl.numberOfPages = [images count];
}

- (void)addImagesToScrollView:(NSArray*)images
{
    // remove all old previous images
    NSArray* subviews = [scrollView subviews];
    for (UIView* subview in subviews){
        [subview removeFromSuperview];
    }

    //set content size of scroll view.
    int imagesCount = [images count];
    scrollView.contentSize = CGSizeMake(scrollView.frame.size.width*imagesCount, scrollView.frame.size.height);
    
    for (int i=0; i<imagesCount; i++) {
        CGRect frame;
        frame.origin.x = scrollView.frame.size.width * i;
        frame.origin.y = 0;
        frame.size = scrollView.frame.size;
        
        HJManagedImageV *imageView = [[HJManagedImageV alloc] initWithFrame:frame];
        
        [imageView setImage:[UIImage imageNamed:defaultImage]];
                
        NSString *imagePath = [images objectAtIndex:i];
//        NSLog(@"imagePath = %@", imagePath);
        if ([imagePath isAbsolutePath]) {
            // Load image from file
            UIImage *image = [[UIImage alloc] initWithContentsOfFile:imagePath];
            [imageView setImage:image];
            [image release];
        }
        else if([imagePath hasPrefix:@"http:"]){
            // Load image from url
            [imageView showLoadingWheel];
        
            imageView.callbackOnSetImage = self;
            imageView.url = [NSURL URLWithString:imagePath];
            [GlobalGetImageCache() manage:imageView];
        }
        else{
            // Load image from bundle
            [imageView setImage:[UIImage imageNamed:imagePath]];
        }
        
        [scrollView addSubview:imageView];
        [imageView release];
    }
}

- (void) managedImageSet:(HJManagedImageV*)mi
{
}

// Loading image failed will call this method
- (void) managedImageCancelled:(HJManagedImageV*)mi
{
}

#pragma mark -
#pragma mark UIScrollViewDelegate stuff
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView1
{
    /* we switch page at %50 across */
    CGFloat pageWidth = scrollView1.frame.size.width;
    int page = floor((scrollView1.contentOffset.x - pageWidth/2)/pageWidth +1);
    pageControl.currentPage = page;
}

#pragma mark -
#pragma mark PageControl stuff
- (void)currentPageDidChange:(int)newPage;
{
    // Change the scroll view 
    CGRect frame = scrollView.frame;
    frame.origin.x  = frame.size.width * newPage;
    frame.origin.y = 0;
    [scrollView scrollRectToVisible:frame animated:YES];
}

@end
