//
//  PACalloutAnnotationView.m
//  HaoCheApp
//
//  Created by 张林峰1 on 15/6/26.
//  Copyright (c) 2015年 pahaoche. All rights reserved.
//

#import "PACalloutAnnotationView.h"
#import <CoreGraphics/CoreGraphics.h>
#import <QuartzCore/QuartzCore.h>
#define CalloutMapAnnotationViewBottomShadowBufferSize 6.0f
#define CalloutMapAnnotationViewContentHeightBuffer 8.0f
#define CalloutMapAnnotationViewHeightAboveParent 2.0f
#define length = 15.0f

@interface PACalloutAnnotationView()

@property (nonatomic, readonly) CGFloat yShadowOffset;
@property (nonatomic) BOOL animateOnNextDrawRect;
@property (nonatomic) CGRect endFrame;

- (void)prepareContentFrame;
- (void)prepareFrameSize;
- (void)prepareOffset;
- (CGFloat)relativeParentXPosition;
- (void)adjustMapRegionIfNeeded;

@end

@implementation PACalloutAnnotationView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@synthesize parentAnnotationView = _parentAnnotationView;
@synthesize mapView = _mapView;
@synthesize contentView = _contentView;
@synthesize animateOnNextDrawRect = _animateOnNextDrawRect;
@synthesize endFrame = _endFrame;
@synthesize yShadowOffset = _yShadowOffset;
@synthesize offsetFromParent = _offsetFromParent;
@synthesize contentHeight = _contentHeight;

- (id) initWithAnnotation:(id <MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier]) {
        self.contentHeight = 80.0;
        self.contentWidth = 300;
        self.offsetFromParent = CGPointMake(0, -8); //this works for MKPinAnnotationView
        self.enabled = NO;
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)setAnnotation:(id <MKAnnotation>)annotation {
    [super setAnnotation:annotation];
    [self prepareFrameSize];
    [self prepareOffset];
    [self prepareContentFrame];
    [self setNeedsDisplay];
}


- (void)prepareFrameSize {
    CGRect frame = self.frame;
    CGFloat height =	self.contentHeight +
    CalloutMapAnnotationViewContentHeightBuffer +
    CalloutMapAnnotationViewBottomShadowBufferSize -
    self.offsetFromParent.y;
    
    CGFloat width =	self.contentWidth + 20;
    
    frame.size = CGSizeMake(width, height);
    self.frame = frame;
}

- (void)prepareContentFrame {
    CGRect contentFrame = CGRectMake(self.bounds.origin.x + 10,
                                     self.bounds.origin.y + 3,
                                     self.bounds.size.width - 20,
                                     self.contentHeight);
    
    self.contentView.frame = contentFrame;
//    self.backgroundColor = [UIColor redColor];
//    self.contentView.backgroundColor = [UIColor yellowColor];
}

- (void)prepareOffset {
    CGPoint parentOrigin = [self.mapView convertPoint:self.parentAnnotationView.frame.origin
                                             fromView:self.parentAnnotationView.superview];
    
    
    CGFloat xOffset = 0.0;//=(self.frame.size.width / 2) - (parentOrigin.x + self.offsetFromParent.x);
    NSLog(@"xOffset===%f,%f,%f",self.frame.size.width,self.offsetFromParent.x,parentOrigin.x + self.offsetFromParent.x);
    //Add half our height plus half of the height of the annotation we are tied to so that our bottom lines up to its top
    //Then take into account its offset and the extra space needed for our drop shadow
    CGFloat yOffset = -(self.frame.size.height / 2 +
                        self.parentAnnotationView.frame.size.height / 2) +
    self.offsetFromParent.y +
    CalloutMapAnnotationViewBottomShadowBufferSize;
    
    //修改
    xOffset = 0.0;
    self.centerOffset = CGPointMake(xOffset, yOffset);
}

//if the pin is too close to the edge of the map view we need to shift the map view so the callout will fit.
- (void)adjustMapRegionIfNeeded {
    //Longitude
    CGFloat xPixelShift = 0;
    if ([self relativeParentXPosition] < 38) {
        xPixelShift = 38 - [self relativeParentXPosition];
    } else if ([self relativeParentXPosition] > self.frame.size.width - 38) {
        xPixelShift = (self.frame.size.width - 38) - [self relativeParentXPosition];
    }
    
    
    //Latitude
    CGPoint mapViewOriginRelativeToParent = [self.mapView convertPoint:self.mapView.frame.origin toView:self.parentAnnotationView];
    CGFloat yPixelShift = 0;
    CGFloat pixelsFromTopOfMapView = -(mapViewOriginRelativeToParent.y + self.frame.size.height - CalloutMapAnnotationViewBottomShadowBufferSize);
    CGFloat pixelsFromBottomOfMapView = self.mapView.frame.size.height + mapViewOriginRelativeToParent.y - self.parentAnnotationView.frame.size.height;
    if (pixelsFromTopOfMapView < 7) {
        yPixelShift = 7 - pixelsFromTopOfMapView;
    } else if (pixelsFromBottomOfMapView < 10) {
        yPixelShift = -(10 - pixelsFromBottomOfMapView);
    }
    
    //Calculate new center point, if needed
    if (xPixelShift || yPixelShift) {
        CGFloat pixelsPerDegreeLongitude = self.mapView.frame.size.width / self.mapView.region.span.longitudeDelta;
        CGFloat pixelsPerDegreeLatitude = self.mapView.frame.size.height / self.mapView.region.span.latitudeDelta;
        
        CLLocationDegrees longitudinalShift = -(xPixelShift / pixelsPerDegreeLongitude);
        CLLocationDegrees latitudinalShift = yPixelShift / pixelsPerDegreeLatitude;
        
        CLLocationCoordinate2D newCenterCoordinate = {self.mapView.region.center.latitude + latitudinalShift,
            self.mapView.region.center.longitude + longitudinalShift};
        
        [self.mapView setCenterCoordinate:newCenterCoordinate animated:YES];
        
        //fix for now
        self.frame = CGRectMake(self.frame.origin.x - xPixelShift,
                                self.frame.origin.y - yPixelShift,
                                self.frame.size.width,
                                self.frame.size.height);
        //fix for later (after zoom or other action that resets the frame)
        
        self.centerOffset = CGPointMake(self.centerOffset.x - xPixelShift, self.centerOffset.y);
    }
}

- (CGFloat)xTransformForScale:(CGFloat)scale {
    CGFloat xDistanceFromCenterToParent = self.endFrame.size.width / 2 - [self relativeParentXPosition];
    return (xDistanceFromCenterToParent * scale) - xDistanceFromCenterToParent;
}

- (CGFloat)yTransformForScale:(CGFloat)scale {
    CGFloat yDistanceFromCenterToParent = (((self.endFrame.size.height) / 2) + self.offsetFromParent.y + CalloutMapAnnotationViewBottomShadowBufferSize + CalloutMapAnnotationViewHeightAboveParent);
    return yDistanceFromCenterToParent - yDistanceFromCenterToParent * scale;
}

- (void)animateIn {
    self.endFrame = self.frame;
    CGFloat scale = 0.001f;
    self.transform = CGAffineTransformMake(scale, 0.0f, 0.0f, scale, [self xTransformForScale:scale], [self yTransformForScale:scale]);
    [UIView beginAnimations:@"animateIn" context:nil];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    [UIView setAnimationDuration:0.075];
    [UIView setAnimationDidStopSelector:@selector(animateInStepTwo)];
    [UIView setAnimationDelegate:self];
    scale = 1.1;
    self.transform = CGAffineTransformMake(scale, 0.0f, 0.0f, scale, [self xTransformForScale:scale], [self yTransformForScale:scale]);
    [UIView commitAnimations];
}

- (void)animateInStepTwo {
    [UIView beginAnimations:@"animateInStepTwo" context:nil];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDuration:0.1];
    [UIView setAnimationDidStopSelector:@selector(animateInStepThree)];
    [UIView setAnimationDelegate:self];
    
    CGFloat scale = 0.95;
    self.transform = CGAffineTransformMake(scale, 0.0f, 0.0f, scale, [self xTransformForScale:scale], [self yTransformForScale:scale]);
    
    [UIView commitAnimations];
}

- (void)animateInStepThree {
    [UIView beginAnimations:@"animateInStepThree" context:nil];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDuration:0.075];
    
    CGFloat scale = 1.0;
    self.transform = CGAffineTransformMake(scale, 0.0f, 0.0f, scale, [self xTransformForScale:scale], [self yTransformForScale:scale]);
    
    [UIView commitAnimations];
}

- (void)didMoveToSuperview {
//    [self adjustMapRegionIfNeeded];
//    [self animateIn];
}

- (void)drawRect:(CGRect)rect {
    CGFloat stroke = 1.0;
    self.radius = 5;
    CGFloat triangleH = 10;//三角形高
    CGFloat triangleW = 10;//三角形底边长
    CGMutablePathRef path = CGPathCreateMutable();
    CGColorSpaceRef space = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGFloat parentX = self.bounds.size.width / 2;//[self relativeParentXPosition];
    
    //Determine Size 画三角
    rect = self.bounds;
    rect.size.width -= stroke + 14;
    rect.size.height -= stroke + CalloutMapAnnotationViewHeightAboveParent - self.offsetFromParent.y + CalloutMapAnnotationViewBottomShadowBufferSize;
    rect.origin.x += stroke / 2.0 + 7;
    rect.origin.y += stroke / 2.0;
    
    //Create Path For Callout Bubble
    CGPathMoveToPoint(path, NULL, rect.origin.x, rect.origin.y + self.radius);
    CGPathAddLineToPoint(path, NULL, rect.origin.x, rect.origin.y + rect.size.height - self.radius);
    CGPathAddArc(path, NULL, rect.origin.x + self.radius, rect.origin.y + rect.size.height - self.radius,
                 self.radius, M_PI, M_PI / 2, 1);
    CGPathAddLineToPoint(path, NULL, parentX - triangleW/2,
                         rect.origin.y + rect.size.height);
    CGPathAddLineToPoint(path, NULL, parentX,
                         rect.origin.y + rect.size.height + triangleH);
    CGPathAddLineToPoint(path, NULL, parentX + triangleW/2,
                         rect.origin.y + rect.size.height);
    CGPathAddLineToPoint(path, NULL, rect.origin.x + rect.size.width - self.radius,
                         rect.origin.y + rect.size.height);
    CGPathAddArc(path, NULL, rect.origin.x + rect.size.width - self.radius,
                 rect.origin.y + rect.size.height - self.radius, self.radius, M_PI / 2, 0.0f, 1);
    CGPathAddLineToPoint(path, NULL, rect.origin.x + rect.size.width, rect.origin.y + self.radius);
    CGPathAddArc(path, NULL, rect.origin.x + rect.size.width - self.radius, rect.origin.y + self.radius,
                 self.radius, 0.0f, -M_PI / 2, 1);
    CGPathAddLineToPoint(path, NULL, rect.origin.x + self.radius, rect.origin.y);
    CGPathAddArc(path, NULL, rect.origin.x + self.radius, rect.origin.y + self.radius, self.radius,
                 -M_PI / 2, M_PI, 1);
    CGPathCloseSubpath(path);
    
    //Fill Callout Bubble & Add Shadow
//    color = [[UIColor blackColor] colorWithAlphaComponent:0.8];
    [self.color setFill];
    CGContextAddPath(context, path);
    CGContextSaveGState(context);
//    CGContextSetShadowWithColor(context, CGSizeMake (0, self.yShadowOffset), 6, [UIColor colorWithWhite:0 alpha:.5].CGColor);
    CGContextFillPath(context);
    CGContextRestoreGState(context);
    
    //Stroke Callout Bubble 边缘线
//    color = [[UIColor darkGrayColor] colorWithAlphaComponent:.9];
//    [color setStroke];
//    CGContextSetLineWidth(context, stroke);
//    CGContextSetLineCap(context, kCGLineCapSquare);
//    CGContextAddPath(context, path);
//    CGContextStrokePath(context);
    
    //Determine Size for Gloss
//    CGRect glossRect = self.bounds;
//    glossRect.size.width = rect.size.width - stroke;
//    glossRect.size.height = (rect.size.height - stroke) / 2;
//    glossRect.origin.x = rect.origin.x + stroke / 2;
//    glossRect.origin.y += rect.origin.y + stroke / 2;
//    
//    CGFloat glossTopRadius = radius - stroke / 2;
//    CGFloat glossBottomRadius = radius / 1.5;
    
    //Create Path For Gloss 光泽路径
//    CGMutablePathRef glossPath = CGPathCreateMutable();
//    CGPathMoveToPoint(glossPath, NULL, glossRect.origin.x, glossRect.origin.y + glossTopRadius);
//    CGPathAddLineToPoint(glossPath, NULL, glossRect.origin.x, glossRect.origin.y + glossRect.size.height - glossBottomRadius);
//    CGPathAddArc(glossPath, NULL, glossRect.origin.x + glossBottomRadius, glossRect.origin.y + glossRect.size.height - glossBottomRadius,
//                 glossBottomRadius, M_PI, M_PI / 2, 1);
//    CGPathAddLineToPoint(glossPath, NULL, glossRect.origin.x + glossRect.size.width - glossBottomRadius,
//                         glossRect.origin.y + glossRect.size.height);
//    CGPathAddArc(glossPath, NULL, glossRect.origin.x + glossRect.size.width - glossBottomRadius,
//                 glossRect.origin.y + glossRect.size.height - glossBottomRadius, glossBottomRadius, M_PI / 2, 0.0f, 1);
//    CGPathAddLineToPoint(glossPath, NULL, glossRect.origin.x + glossRect.size.width, glossRect.origin.y + glossTopRadius);
//    CGPathAddArc(glossPath, NULL, glossRect.origin.x + glossRect.size.width - glossTopRadius, glossRect.origin.y + glossTopRadius,
//                 glossTopRadius, 0.0f, -M_PI / 2, 1);
//    CGPathAddLineToPoint(glossPath, NULL, glossRect.origin.x + glossTopRadius, glossRect.origin.y);
//    CGPathAddArc(glossPath, NULL, glossRect.origin.x + glossTopRadius, glossRect.origin.y + glossTopRadius, glossTopRadius,
//                 -M_PI / 2, M_PI, 1);
//    CGPathCloseSubpath(glossPath);
    
    //Fill Gloss Path	颜色梯度变化
//    CGContextAddPath(context, glossPath);
//    CGContextClip(context);
//    CGFloat colors[] =
//    {
//        1, 1, 1, .3,
//        1, 1, 1, .1,
//    };
//    CGFloat locations[] = { 0, 1.0 };
//    CGGradientRef gradient = CGGradientCreateWithColorComponents(space, colors, locations, 2);
//    CGPoint startPoint = glossRect.origin;
//    CGPoint endPoint = CGPointMake(glossRect.origin.x, glossRect.origin.y + glossRect.size.height);
//    CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, 0);
    
    //Gradient Stroke Gloss Path
//    CGContextAddPath(context, glossPath);
//    CGContextSetLineWidth(context, 2);
//    CGContextReplacePathWithStrokedPath(context);
//    CGContextClip(context);
//    CGFloat colors2[] =
//    {
//        1, 1, 1, .3,
//        1, 1, 1, .1,
//        1, 1, 1, .0,
//    };
//    CGFloat locations2[] = { 0, .1, 1.0 };
//    CGGradientRef gradient2 = CGGradientCreateWithColorComponents(space, colors2, locations2, 3);
//    CGPoint startPoint2 = glossRect.origin;
//    CGPoint endPoint2 = CGPointMake(glossRect.origin.x, glossRect.origin.y + glossRect.size.height);
//    CGContextDrawLinearGradient(context, gradient2, startPoint2, endPoint2, 0);
    
    //Cleanup
    CGPathRelease(path);
//    CGPathRelease(glossPath);
    CGColorSpaceRelease(space);
//    CGGradientRelease(gradient);
//    CGGradientRelease(gradient2);
}

- (CGFloat)yShadowOffset {
    if (!_yShadowOffset) {
        float osVersion = [[[UIDevice currentDevice] systemVersion] floatValue];
        if (osVersion >= 3.2) {
            _yShadowOffset = 6;
        } else {
            _yShadowOffset = -6;
        }
        
    }
    return _yShadowOffset;
}

- (CGFloat)relativeParentXPosition {
    CGPoint parentOrigin = [self.mapView convertPoint:self.parentAnnotationView.frame.origin 
                                             fromView:self.parentAnnotationView.superview];
    return  parentOrigin.x + self.offsetFromParent.x;
}

- (UIView *)contentView {
    if (!_contentView) {
        _contentView = [[UIView alloc] init];
        self.contentView.backgroundColor = [UIColor clearColor];
        self.contentView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        [self addSubview:self.contentView];
    }
    return _contentView;
}

- (void)dealloc {
    self.parentAnnotationView = nil;
    self.mapView = nil;
}

@end
