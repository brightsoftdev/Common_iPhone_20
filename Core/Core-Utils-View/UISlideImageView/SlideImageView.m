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
@synthesize imageForPageStateNormal = _imageForPageStateNormal;
@synthesize imageForPageStateHighted = _imageForPageStateHighted;
@synthesize defaultImage = _defaultImage;

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
                
        pageControl = [[UICustomPageControl alloc] initWithFrame:CGRectMake(self.bounds.origin.x/2, self.bounds.size.height-DEFAULT_HEIGHT_OF_PAGE_CONTROL, self.bounds.size.width, DEFAULT_HEIGHT_OF_PAGE_CONTROL)]; 
        
        [pageControl addTarget:self action:@selector(pageClick:) forControlEvents:UIControlEventTouchUpInside];
        
    }
    return self;
}

-(void)dealloc
{
    [scrollView release];
    [pageControl release];
    [_imageForPageStateNormal release];
    [_imageForPageStateHighted release];
    [super dealloc];
}

// images is a NSString array that contain a list of absoute path or absolute URL or bundle file name of the images.
- (void)setImages:(NSArray*)images{
    [self addImageScrollView:images];
    [self addPageControl:[images count]];
}

- (void)addPageControl:(int)imagesCount
{
    if (imagesCount <=1 ) {
        return;
    }
    
    pageControl.numberOfPages = imagesCount;
    [pageControl setImagePageStateNormal:[UIImage imageNamed:_imageForPageStateNormal]];
    [pageControl setImagePageStateHighted:[UIImage imageNamed:_imageForPageStateHighted]];
            
    [self addSubview:pageControl];
}

- (void)addImageScrollView:(NSArray*)images
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
        
        [imageView setImage:[UIImage imageNamed:_defaultImage]];
                
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
    
    [self addSubview:scrollView];
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
- (void)scrollViewDidScroll:(UIScrollView *)scrollView1
{
    /* we switch page at %50 across */
    CGFloat pageWidth = scrollView1.frame.size.width;
    int page = floor((scrollView1.contentOffset.x - pageWidth/2)/pageWidth +1);
    pageControl.currentPage = page;
    [pageControl setImagePageStateNormal:[UIImage imageNamed:_imageForPageStateNormal]];
    [pageControl setImagePageStateHighted:[UIImage imageNamed:_imageForPageStateHighted]];
}

#pragma mark -
#pragma mark PageControl stuff
- (IBAction)pageClick:(id)sender
{
    // Change the scroll view 
    CGRect frame = scrollView.frame;
    frame.origin.x  = frame.size.width * pageControl.currentPage;
    frame.origin.y = 0;
    [scrollView scrollRectToVisible:frame animated:YES];
}

@end
