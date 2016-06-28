//
//  PAAnnotation.h
//  HaoCheApp
//
//  Created by 张林峰1 on 15/6/26.
//  Copyright (c) 2015年 pahaoche. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

//大头针模型：KCAnnotation.h

@interface PAAnnotation : NSObject<MKAnnotation>

@property (nonatomic) CLLocationCoordinate2D coordinate;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *subtitle;

// 自定义一个图片属性在创建大头针视图时使用
@property (nonatomic,strong) UIImage *image;
// 大头针详情左侧图标
@property (nonatomic,strong) UIImage *icon;
// 大头针详情描述
@property (nonatomic,copy) NSString *detail;

@property (nonatomic,strong) UIImage *rate;

- (id)initWithCoordinate:(CLLocationCoordinate2D)coordinate;

@end
