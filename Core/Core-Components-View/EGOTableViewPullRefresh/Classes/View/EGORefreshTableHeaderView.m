//
//  EGORefreshTableHeaderView.m
//  Demo
//
//  Created by Devin Doty on 10/14/09October14.
//  Copyright 2009 enormego. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#import "EGORefreshTableHeaderView.h"
#import "LocaleUtils.h"
#import "DeviceDetection.h"

#define STATUS_FONT_SIZE ([DeviceDetection isIPAD] ? 26 : 13)
#define LAST_UPDATE_FONT_SIZE ([DeviceDetection isIPAD] ? 24 : 12)

#define STATUS_HEIGHT ([DeviceDetection isIPAD] ? 40 : 20)
#define LAST_UPDATE_HEIGHT ([DeviceDetection isIPAD] ? 40 : 20)
#define STATUS_HEIGHT_DIFFER ([DeviceDetection isIPAD] ? 55 * 2 : 48)
#define LAST_UPDATE_HEIGHT_DIFFER ([DeviceDetection isIPAD] ? 30 * 2 : 30)

#define TEXT_COLOR	 [UIColor colorWithRed:87.0/255.0 green:108.0/255.0 blue:137.0/255.0 alpha:1.0]
#define BORDER_COLOR [UIColor colorWithRed:160.0/255.0 green:173.0/255.0 blue:182.0/255.0 alpha:1.0]

#define EGONS(x)     (NSLocalizedStringFromTable(x, @"EGORefresh", nil))

@implementation EGORefreshTableHeaderView

@synthesize state=_state;
@synthesize bottomBorderThickness;
@synthesize bottomBorderColor;
@synthesize _backgroundImage;

static NSDateFormatter *refreshFormatter;


+ (void)initialize
{
  /* Formatter for last refresh date */
  refreshFormatter = [[NSDateFormatter alloc] init];
  [refreshFormatter setDateStyle:NSDateFormatterShortStyle];
  [refreshFormatter setTimeStyle:NSDateFormatterShortStyle];
}


// Sets up the frame following the recipe in the samples except it doesn't *overlap* the partner view,
// ensuring that if you choose to draw a bottom border (by setting bottomBorderThickness > 0.0) then
// you'll get a proper border, not a partially obscured one.
- (id)initWithFrameRelativeToFrame:(CGRect)originalFrame {
	CGRect relativeFrame = CGRectMake(0.0f, 0.0f - originalFrame.size.height, originalFrame.size.width, originalFrame.size.height);
	[self setBottomBorderThickness:1.0f];
	return [self initWithFrame:relativeFrame];
}

- (void)setBackgroundImage:(UIImage *)image
{
    self._backgroundImage.contents = (id)image.CGImage;
}

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
		
		self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        
		lastUpdatedLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, frame.size.height - LAST_UPDATE_HEIGHT_DIFFER, self.frame.size.width, 20.0f)];
		lastUpdatedLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		lastUpdatedLabel.font = [UIFont systemFontOfSize:LAST_UPDATE_FONT_SIZE];
		lastUpdatedLabel.textColor = TEXT_COLOR;
		lastUpdatedLabel.shadowColor = [UIColor colorWithWhite:0.9f alpha:1.0f];
		lastUpdatedLabel.shadowOffset = CGSizeMake(0.0f, 1.0f);
		lastUpdatedLabel.backgroundColor = [UIColor clearColor];
		lastUpdatedLabel.textAlignment = UITextAlignmentCenter;
		[self addSubview:lastUpdatedLabel];
		[lastUpdatedLabel release];

		
		statusLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, frame.size.height - STATUS_HEIGHT_DIFFER, self.frame.size.width, STATUS_HEIGHT)];
		statusLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		statusLabel.font = [UIFont boldSystemFontOfSize:STATUS_FONT_SIZE];
		statusLabel.textColor = TEXT_COLOR;
		statusLabel.shadowColor = [UIColor colorWithWhite:0.9f alpha:1.0f];
		statusLabel.shadowOffset = CGSizeMake(0.0f, 1.0f);
		statusLabel.backgroundColor = [UIColor clearColor];
		statusLabel.textAlignment = UITextAlignmentCenter;
		[self setState:EGOOPullRefreshNormal];
		[self addSubview:statusLabel];
		[statusLabel release];
		
		arrowImage = [[CALayer alloc] init];
        if (![DeviceDetection isIPAD]) {
            arrowImage.frame = CGRectMake(25.0f, frame.size.height - 65.0f, 30.0f, 55.0f);            
        }else{
            arrowImage.frame = CGRectMake(25.0f * 2, frame.size.height - 65.0f * 2, 30.0f * 2, 55.0f * 2);
        }
        
		arrowImage.contentsGravity = kCAGravityResizeAspect;
		arrowImage.contents = (id)[UIImage imageNamed:@"blueArrow.png"].CGImage;
		[[self layer] addSublayer:arrowImage];
		[arrowImage release];
		
        self._backgroundImage = [CALayer layer];
        self._backgroundImage.frame = CGRectMake(0,0, self.frame.size.width, self.frame.size.height);
//        UIImage *back = [[UIImage imageNamed:@"tu_185.png"] stretchableImageWithLeftCapWidth:11 topCapHeight:0];
//        self._backgroundImage.contents = (id)back.CGImage;
        [self.layer insertSublayer:self._backgroundImage atIndex:0];
        

        
		activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        if ([DeviceDetection isIPAD]) {
            activityView.frame = CGRectMake(25.0f * 2, frame.size.height - 38.0f * 2, 20.0f * 2, 20.0f * 2);
            [activityView setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhiteLarge];
        }else{
            activityView.frame = CGRectMake(25.0f, frame.size.height - 38.0f, 20.0f, 20.0f);
        }
		activityView.hidesWhenStopped = YES;
		[self addSubview:activityView];
		[activityView release];
		
    }
    return self;
}

// Will only draw a bottom border if you've set bottomBorderThickness to be > 0.0
// and makes sure that the stroke is correctly centered so you get a border as thick
// as you've asked for.
- (void)drawRect:(CGRect)rect{
	if ([self bottomBorderThickness] == 0.0f) return;
	CGFloat strokeOffset = [self bottomBorderThickness] / 2.0f;
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextDrawPath(context,  kCGPathFillStroke);
	UIColor *strokeColor = ([self bottomBorderColor]) ? [self bottomBorderColor] : BORDER_COLOR;
	[strokeColor setStroke];
	CGContextSetLineWidth(context, [self bottomBorderThickness]);
	CGContextBeginPath(context);
	CGContextMoveToPoint(context, 0.0f, self.bounds.size.height - strokeOffset);
	CGContextAddLineToPoint(context, self.bounds.size.width, self.bounds.size.height - strokeOffset);
	CGContextStrokePath(context);
}


- (void)setLastRefreshDate:(NSDate*)date
{
    
  if (!date) {
    [lastUpdatedLabel setText:EGONS(@"kNeverUpdated")];
    return;
  }
  
	lastUpdatedLabel.text = [NSString stringWithFormat:@"%@: %@", EGONS(@"kLastUpdated"),
                             [refreshFormatter stringFromDate:date]];
}

#ifndef TIME_ZONE_GMT
    #define TIME_ZONE_GMT           @"Asia/Shanghai"
#endif

-(NSString *)getChineseDateString:(NSDate *)date withFormat:(NSString *)format
{
    if(date == nil)
        return nil;
    NSDateFormatter* formatter = [[[NSDateFormatter alloc] init] autorelease];
    NSTimeZone *tzGMT = [NSTimeZone timeZoneWithName:TIME_ZONE_GMT];
    [formatter setTimeZone:tzGMT];
    [formatter setDateFormat:format];
    NSString *period = [formatter stringFromDate:date];
    return period;
}


- (void)setLastUpdateLabelFont:(UIFont *)font
{
    [lastUpdatedLabel setFont:font];
}

- (void)setStatusLabelFont:(UIFont *)font
{
        [statusLabel setFont:font];
}

- (void)setFontColor:(UIColor *)color
{
    if (color) {
        [lastUpdatedLabel setTextColor:color];
        [statusLabel setTextColor:color];
    }
}

- (void)setCurrentDate {

    if ([LocaleUtils isChina]){    
        NSString *dateString = [self getChineseDateString:[NSDate date] withFormat:@"  MM月dd日 HH时mm分"];
        lastUpdatedLabel.text = [NSString stringWithFormat:@"%@: %@", @"最后更新",dateString];
    }
    else{
        NSString *dateString = [NSDateFormatter localizedStringFromDate:[NSDate date] dateStyle:NSDateFormatterShortStyle timeStyle:NSDateFormatterShortStyle];        
        lastUpdatedLabel.text = [NSString stringWithFormat:@"%@: %@", @"Last Update",dateString];        
    }
    
    
    
    
//	lastUpdatedLabel.text = [NSString stringWithFormat:@"%@: %@", 
//                             EGONS(@"kLastUpdated"),
//                             [refreshFormatter stringFromDate:[NSDate date]]];
//	[[NSUserDefaults standardUserDefaults] setObject:lastUpdatedLabel.text forKey:@"EGORefreshTableView_LastRefresh"];
//	[[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)setState:(EGOPullRefreshState)aState{
	
	switch (aState) {
		case EGOOPullRefreshPulling:
            
			statusLabel.text = EGONS(@"kReleaseToRefresh"); //@"Release to refresh...";
			[CATransaction begin];
			[CATransaction setAnimationDuration:.18];
			arrowImage.transform = CATransform3DMakeRotation((M_PI / 180.0) * 180.0f, 0.0f, 0.0f, 1.0f);
			[CATransaction commit];
			
			break;
		case EGOOPullRefreshNormal:
			
			if (_state == EGOOPullRefreshPulling) {
				[CATransaction begin];
				[CATransaction setAnimationDuration:.18];
				arrowImage.transform = CATransform3DIdentity;
				[CATransaction commit];
			}
			
			statusLabel.text = EGONS(@"kPullDownToRefresh"); // @"Pull down to refresh...";
			[activityView stopAnimating];
			[CATransaction begin];
			[CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions]; 
			arrowImage.hidden = NO;
			arrowImage.transform = CATransform3DIdentity;
			[CATransaction commit];
			
			break;
		case EGOOPullRefreshLoading:
			
			statusLabel.text = EGONS(@"kLoading"); // @"Loading...";
			[activityView startAnimating];
			[CATransaction begin];
			[CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions]; 
			arrowImage.hidden = YES;
			[CATransaction commit];
			
			break;
		case EGOOPullRefreshUpToDate:
        
			statusLabel.text = EGONS(@"kUpToDate"); // @"Up-to-date.";
			[activityView stopAnimating];
			[CATransaction begin];
			[CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions]; 
			arrowImage.hidden = YES;
			[CATransaction commit];
			
			break;
		default:
			break;
	}
	
	_state = aState;
}

- (void)dealloc {
	[bottomBorderColor release], bottomBorderColor = nil;
	activityView = nil;
	statusLabel = nil;
	arrowImage = nil;
	lastUpdatedLabel = nil;
    [_backgroundImage release];   
    [super dealloc];
}


@end
