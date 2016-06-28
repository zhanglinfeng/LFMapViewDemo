//
//  PAMapView.h
//  HaoCheApp
//
//  Created by 张林峰1 on 15/5/28.
//  Copyright (c) 2015年 pahaoche. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import "PAAnnotation.h"

typedef void(^GetCityName)(NSString * cityName);
typedef void(^GetCLLocation)(CLLocation * cllocation);

@interface PAMapView : UIView <CLLocationManagerDelegate, MKMapViewDelegate>
{
//    NSString *currentLatitude;
//    NSString *currentLongitude;
    //这两个变量，locationManaager用于获取位置，checkinLocation用于保存获取到的位置信息
    CLLocationManager *locationmanager;
    CLLocation *checkinLocation;
    NSString *cityName;
}

@property (strong, nonatomic) MKMapView *mapView;
@property (strong, nonatomic) NSString *addressName;
@property (strong, nonatomic) MKPointAnnotation *pointAnnotation;
@property (strong, nonatomic) PAAnnotation * paAnnotation;//外部传入
@property (strong, nonatomic) PAAnnotation * addAnnotation;//内部使用
@property (strong, nonatomic) CLLocation *location;
@property (strong, nonatomic) UIView * rightCalloutAccessoryView;
@property (strong, nonatomic) UIView * contentView;
@property (nonatomic, retain) MKAnnotationView *selectedAnnotationView;
@property (strong, nonatomic) UIImage *imgPin;//大头针
@property (nonatomic, strong) UIColor *bubbleColor;
@property (nonatomic, assign) BOOL isPositioning;
@property (nonatomic, copy)GetCityName getCityName;
@property (nonatomic, copy)GetCLLocation getCLLocation;

/**
 *  Description
 *
 *  @param frame       frame description
 *  @param positioning yes表示地图显示自动定位的位置，no表示地图传入经纬度的位置
 *
 *  @return return value description
 */
- (id)initWithFrame:(CGRect)frame Positioning:(BOOL)positioning;
- (void)goToLocation:(CLLocationCoordinate2D)toCoordinate;

- (void)configWithLongitude:(double)longitude Latitude:(double)latitude Titel:(NSString *)title SubTitle:(NSString *)subTitle;

@end
