//
//  TKLoadingView.m
//  Created by Devin Ross on 7/2/09.
//
/*
 
 tapku.com || http://github.com/devinross/tapkulibrary
 
 Permission is hereby granted, free of charge, to any person
 obtaining a copy of this software and associated documentation
 files (the "Software"), to deal in the Software without
 restriction, including without limitation the rights to use,
 copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the
 Software is furnished to do so, subject to the following
 conditions:
 
 The above copyright notice and this permission notice shall be
 included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
 OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
 HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
 WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
 OTHER DEALINGS IN THE SOFTWARE.
 
 */
#import "TKLoadingView.h"

#import "UIView+TKCategory.h"


#define WIDTH_MARGIN_IPHONE 20
#define WIDTH_MARGIN_IPAD (WIDTH_MARGIN_IPHONE*2)
#define WIDTH_MARGIN ([self isIPAD] ? (WIDTH_MARGIN_IPAD) : (WIDTH_MARGIN_IPHONE))

#define HEIGHT_MARGIN_IPHONE 20
#define HEIGHT_MARGIN_IPAD (HEIGHT_MARGIN_IPHONE*2)
#define HEIGHT_MARGIN ([self isIPAD] ? (HEIGHT_MARGIN_IPAD) : (HEIGHT_MARGIN_IPHONE))

#define WIDTH_OF_LOADING_VIEW_IPHONE 280
#define WIDTH_OF_LOADING_VIEW_IPAD (WIDTH_OF_LOADING_VIEW_IPHONE*2)
#define WIDTH_OF_LOADING_VIEW ([self isIPAD] ? (WIDTH_OF_LOADING_VIEW_IPAD) : (WIDTH_OF_LOADING_VIEW_IPHONE))

#define HEIGHT_OF_LOADING_VIEW_IPHONE 200
#define HEIGHT_OF_LOADING_VIEW_IPAD (HEIGHT_OF_LOADING_VIEW_IPHONE*2)
#define HEIGHT_OF_LOADING_VIEW ([self isIPAD] ? (HEIGHT_OF_LOADING_VIEW_IPAD) : (HEIGHT_OF_LOADING_VIEW_IPHONE))

#define FONT_OF_TITLE_IPHONE [UIFont boldSystemFontOfSize:16]
#define FONT_OF_TITLE_IPAD [UIFont boldSystemFontOfSize:16*2]
#define FONT_OF_TITLE ([self isIPAD] ? (FONT_OF_TITLE_IPAD) : (FONT_OF_TITLE_IPHONE))

#define FONT_OF_MESSAGE_IPHONE [UIFont systemFontOfSize:12]
#define FONT_OF_MESSAGE_IPAD [UIFont systemFontOfSize:12*2]
#define FONT_OF_MESSAGE ([self isIPAD] ? (FONT_OF_MESSAGE_IPAD) : (FONT_OF_MESSAGE_IPHONE))

@interface TKLoadingView (PrivateMethods)
- (CGSize) calculateHeightOfTextFromWidth:(NSString*)text font: (UIFont*)withFont width:(float)width linebreak:(UILineBreakMode)lineBreakMode;
@end


@implementation TKLoadingView
@synthesize radius;

- (BOOL) isIPAD
{
    return (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad);
}

- (id) initWithTitle:(NSString*)ttl message:(NSString*)msg{
	if(!(self = [super initWithFrame:CGRectMake(0, 0, WIDTH_OF_LOADING_VIEW, HEIGHT_OF_LOADING_VIEW)])) return nil;
		
    _title = [ttl copy];
    _message = [msg copy];
    _activity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    _activity.transform = [self isIPAD] ? CGAffineTransformMakeScale(2.0, 2.0) : CGAffineTransformIdentity;
    [self addSubview:_activity];
    _hidden = YES;
    self.backgroundColor = [UIColor clearColor];
	
	return self;
}
- (id) initWithTitle:(NSString*)ttl{
	if(![self initWithTitle:ttl message:nil]) return nil;
	return self;	
}

- (void) drawRect:(CGRect)rect {
	
	if(_hidden) return;
	int width, rWidth, rHeight, x;
	
	UIFont *titleFont = FONT_OF_TITLE;
	UIFont *messageFont = FONT_OF_MESSAGE;
	
	CGSize s1 = [self calculateHeightOfTextFromWidth:_title font:titleFont width:HEIGHT_OF_LOADING_VIEW linebreak:UILineBreakModeTailTruncation];
	CGSize s2 = [self calculateHeightOfTextFromWidth:_message font:messageFont width:HEIGHT_OF_LOADING_VIEW linebreak:UILineBreakModeCharacterWrap];
	
	if([_title length] < 1) s1.height = 0;
	if([_message length] < 1) s2.height = 0;
	
	
	rHeight = (s1.height + s2.height + (HEIGHT_MARGIN*2) + 10 + _activity.frame.size.height);
	rWidth = width = (s2.width > s1.width) ? (int) s2.width : (int) s1.width;
	rWidth += WIDTH_MARGIN * 2;
	x = (WIDTH_OF_LOADING_VIEW - rWidth) / 2;
	
	_activity.center = CGPointMake(WIDTH_OF_LOADING_VIEW/2,HEIGHT_MARGIN + _activity.frame.size.height/2);
	
	
	//NSLog(@"DRAW RECT %d %f",rHeight,self.frame.size.height);
	
	// DRAW ROUNDED RECTANGLE
	[[UIColor colorWithRed:0 green:0 blue:0 alpha:0.9] set];
	CGRect r = CGRectMake(x, 0, rWidth,rHeight);
	[[UIColor colorWithRed:0 green:0 blue:0 alpha:0.75] set];
	[UIView drawRoundRectangleInRect:r withRadius:10.0];
	
	
	// DRAW FIRST TEXT
	[[UIColor whiteColor] set];
	r = CGRectMake(x+WIDTH_MARGIN, _activity.frame.size.height + 10 + HEIGHT_MARGIN, width, s1.height);
	CGSize s = [_title drawInRect:r withFont:titleFont lineBreakMode:UILineBreakModeTailTruncation alignment:UITextAlignmentCenter];
	
	
	// DRAW SECOND TEXT
	r.origin.y += s.height;
	r.size.height = s2.height;
	[_message drawInRect:r withFont:messageFont lineBreakMode:UILineBreakModeCharacterWrap alignment:UITextAlignmentCenter];
	
	
	
}


- (void) setTitle:(NSString*)str{
	[_title release];
	_title = [str copy];
	//[self updateHeight];
	[self setNeedsDisplay];
}
- (NSString*) title{
	return _title;
}

- (void) setMessage:(NSString*)str{
	[_message release];
	_message = [str copy];
	[self setNeedsDisplay];
}
- (NSString*) message{
	return _message;
}

- (void) setRadius:(float)f{
	if(f==radius) return;
	
	radius = f;
	[self setNeedsDisplay];
	
}

- (void) startAnimating{
	if(!_hidden) return;
	_hidden = NO;
	[self setNeedsDisplay];
	[_activity startAnimating];
	
}
- (void) stopAnimating{
	if(_hidden) return;
	_hidden = YES;
	[self setNeedsDisplay];
	[_activity stopAnimating];
	
}


- (CGSize) calculateHeightOfTextFromWidth:(NSString*)text font: (UIFont*)withFont width:(float)width linebreak:(UILineBreakMode)lineBreakMode{
	return [text sizeWithFont:withFont 
			constrainedToSize:CGSizeMake(width, FLT_MAX) 
				lineBreakMode:lineBreakMode];
}



- (CGSize) heightWithString:(NSString*)str font:(UIFont*)withFont width:(float)width linebreak:(UILineBreakMode)lineBreakMode{
	
	
	CGSize suggestedSize = [str sizeWithFont:withFont constrainedToSize:CGSizeMake(width, FLT_MAX) lineBreakMode:lineBreakMode];
	
	return suggestedSize;
}


- (void) adjustHeight{
	
	CGSize s1 = [self heightWithString:_title font:[UIFont boldSystemFontOfSize:16.0] 
								 width:HEIGHT_OF_LOADING_VIEW 
							 linebreak:UILineBreakModeTailTruncation];
	
	CGSize s2 = [self heightWithString:_message font:[UIFont systemFontOfSize:12.0] 
								   width:HEIGHT_OF_LOADING_VIEW 
							   linebreak:UILineBreakModeCharacterWrap];

	CGRect r = self.frame;
	r.size.height = s1.height + s2.height + 20;
	self.frame = r;
}





- (void) dealloc{
	[_activity release];
	[_title release];
	[_message release];
	[super dealloc];
}

@end