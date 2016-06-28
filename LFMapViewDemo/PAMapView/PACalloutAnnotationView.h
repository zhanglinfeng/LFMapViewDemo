//
//  PACalloutAnnotationView.h
//  HaoCheApp
//
//  Created by 张林峰1 on 15/6/26.
//  Copyright (c) 2015年 pahaoche. All rights reserved.
//
#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>


@interface PACalloutAnnotationView : MKAnnotationView {
    MKAnnotationView *_parentAnnotationView;
    MKMapView *_mapView;
    CGRect _endFrame;
    UIView *_contentView;
    CGFloat _yShadowOffset;
    CGPoint _offsetFromParent;
    CGFloat _contentHeight;
}

@property (nonatomic, retain) MKAnnotationView *parentAnnotationView;
@property (nonatomic, retain) MKMapView *mapView;
@property (nonatomic, readonly) UIView *contentView;
@property (nonatomic) CGPoint offsetFromParent;
@property (nonatomic) CGFloat contentHeight;
@property (nonatomic) CGFloat contentWidth;
@property (nonatomic, strong) UIColor *color;
@property (nonatomic) CGFloat radius;//半径

- (void)animateIn;
- (void)animateInStepTwo;
- (void)animateInStepThree;

@end
