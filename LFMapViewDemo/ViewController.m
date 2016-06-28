//
//  ViewController.m
//  LFMapViewDemo
//
//  Created by 张林峰 on 16/6/28.
//  Copyright © 2016年 张林峰. All rights reserved.
//

#import "ViewController.h"


@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    //假数据，应该从上一个界面传进来；
    _mainTitle = @"德必易园";
    _addressName = @"石龙路345弄27号德必易园C座101-109室";
    _longitude = 121.447947;
    _latitude = 31.159528;
    
    //初始化地图
    [self initMapView];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//初始化地图
- (void)initMapView {
    _map = [[PAMapView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)
                                Positioning:NO];
    _map.imgPin = [UIImage imageNamed:@"ditu"];
    _map.bubbleColor = [[UIColor blackColor] colorWithAlphaComponent:0.7];
    [_map setAutoresizingMask:UIViewAutoresizingFlexibleHeight |
     UIViewAutoresizingFlexibleWidth];
    
    _map.contentView = [self customView:_mainTitle];;
    NSLog(@"进入大地图经纬度:%@,%f,%f",_mainTitle, _longitude,_latitude);
    // !!! 接口给经纬度后将注释打开
    //    if (_latitude && _longitude && _latitude < 90 && _latitude > -90) {
    //        PAAnnotation *annotaion = [[PAAnnotation alloc] init];
    //        CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(_latitude, _longitude);
    //        annotaion.coordinate = coordinate;
    //        annotaion.title = _mainTitle;
    //        annotaion.subtitle = _subTitle;
    //        _map.paAnnotation = annotaion;
    //    } else {
    _map.addressName = _addressName;
    //    }
    
    [self.view addSubview:_map];
}

//自定义标注内容
- (UIView *)customView:(NSString *)MainTitle {
    //设置大头针标注
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width - 40, 44)];
    view.backgroundColor = [UIColor clearColor];
    UITextField *title = [[UITextField alloc] initWithFrame:CGRectMake(15, 7, view.frame.size.width - 90, 30)];
    title.inputView = [[UIView alloc] initWithFrame:CGRectZero];
    title.textColor = [UIColor whiteColor];
    title.backgroundColor = [UIColor clearColor];
    title.font = [UIFont systemFontOfSize:13];
    title.text = MainTitle;
    
    
    float lbW = [MainTitle sizeWithAttributes:@{NSFontAttributeName : title.font}].width;
    if (lbW > [UIScreen mainScreen].bounds.size.width - 130 - 2) {
        
    } else if (lbW < 78) {
        title.frame = CGRectMake(title.frame.origin.x, title.frame.origin.y, 78, 30);
        view.frame = CGRectMake(view.frame.origin.x, view.frame.origin.y, 78 + 90, 44);
    } else {
        title.frame = CGRectMake(title.frame.origin.x, title.frame.origin.y, lbW, 30);
        view.frame = CGRectMake(view.frame.origin.x, view.frame.origin.y, lbW + 90, 44);
    }
    [view addSubview:title];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(view.frame.size.width - 65, 10, 50, 24);
    button.backgroundColor = [UIColor orangeColor];
    [button setTitle:@"导航" forState:UIControlStateNormal];
    // 设置按钮文字颜色
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    // 设置按钮文字字体
    [button.titleLabel setFont:[UIFont systemFontOfSize:13]];
    [button setImage:[UIImage imageNamed:@"daohang.png"] forState:UIControlStateNormal];
    [button setTitleEdgeInsets:UIEdgeInsetsMake(0, 5, 0, 0)];
    [button setImageEdgeInsets:UIEdgeInsetsMake(0, -5, 0, 0)];
    // 添加点击事件
    [button addTarget:self action:@selector(goOtherMap) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:button];
    
    return view;
}


//导航
- (void)goOtherMap {
    
    MKPlacemark *toPlacemark   = [[MKPlacemark alloc] initWithCoordinate:CLLocationCoordinate2DMake(_latitude, _longitude)
                                                       addressDictionary:nil];
    MKMapItem *toItem   = [[MKMapItem alloc] initWithPlacemark:toPlacemark];
    
    //调用自带地图导航
    NSDictionary *options=@{MKLaunchOptionsMapTypeKey:@(MKMapTypeStandard),MKLaunchOptionsDirectionsModeKey:MKLaunchOptionsDirectionsModeDriving};
    [MKMapItem openMapsWithItems:@[toItem] launchOptions:options];
}

@end
