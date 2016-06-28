//
//  PACalloutAnnotation.h
//  HaoCheApp
//
//  Created by 张林峰1 on 15/6/26.
//  Copyright (c) 2015年 pahaoche. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
@interface PACalloutAnnotation : NSObject<MKAnnotation>

@property (nonatomic) CLLocationCoordinate2D coordinate;
@property (nonatomic, copy,readonly) NSString *title;
@property (nonatomic, copy,readonly) NSString *subtitle;


@property (nonatomic,strong) UIImage *icon;

@property (nonatomic,copy) NSString *detail;

@property (nonatomic,strong) UIImage *rate;

@end
