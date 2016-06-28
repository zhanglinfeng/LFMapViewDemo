//
//  ViewController.h
//  LFMapViewDemo
//
//  Created by 张林峰 on 16/6/28.
//  Copyright © 2016年 张林峰. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PAMapView.h"

@interface ViewController : UIViewController

@property (nonatomic, strong) PAMapView *map;
@property (nonatomic, strong) NSString *addressName;
@property (nonatomic, assign) double longitude; //经度
@property (nonatomic, assign) double latitude;  //纬度
@property (nonatomic, strong) NSString * mainTitle;
@property (nonatomic, strong) NSString * subTitle;


@end

