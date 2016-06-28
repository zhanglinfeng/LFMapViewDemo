//
//  PAMapView.m
//  HaoCheApp
//
//  Created by 张林峰1 on 15/5/28.
//  Copyright (c) 2015年 pahaoche. All rights reserved.
//

#import "PAMapView.h"
#import "PACalloutAnnotation.h"
#import "PACalloutAnnotationView.h"

@implementation PAMapView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (id)initWithFrame:(CGRect)frame Positioning:(BOOL)positioning {
    self = [super initWithFrame:frame];
    if (self) {
        _mapView = [[MKMapView alloc]initWithFrame:frame];
        [_mapView setAutoresizingMask:UIViewAutoresizingNone];
        [_mapView setAutoresizingMask:UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
//        self.backgroundColor = [UIColor redColor];
        /*
         MKMapTypeStandard 标注地图类型
         
         MKMapSatellite 卫星地图类型
         
         MKMapTypeHybrid 混合地图类型
         */
        _mapView.mapType = MKMapTypeStandard;
        //用于将当前视图控制器赋值给地图视图的delegate属性
        _mapView.delegate = self;
        [self addSubview:_mapView];
        
        _isPositioning = positioning;
        
        [self setupLocationManager];
        
    }
    return self;
}


#pragma mark - 外部传入数据
-(void)setAddressName:(NSString *)addressName {
    if (addressName.length > 0) {
        [self geocodeQuery:addressName];
    }
}

-(void)setLocation:(CLLocation *)location {
    [self getCLPlacemarkFromeCLLocation:location];
}

-(void)setPointAnnotation:(MKPointAnnotation *)pointAnnotation {
    _pointAnnotation = pointAnnotation;
//    CLLocationCoordinate2D coordinate = pointAnnotation.coordinate;
//    CLLocation *location = [[CLLocation alloc]initWithLatitude:coordinate.latitude longitude:coordinate.longitude];
//    NSLog(@"setPointAnnotation方法中location=%@",location);
    
    //调整地图位置和缩放比例,第一个参数是目标区域的中心点，第二个参数：目标区域南北的跨度，第三个参数：目标区域的东西跨度，单位都是米
    MKCoordinateRegion viewRegion =
    MKCoordinateRegionMakeWithDistance(_pointAnnotation.coordinate, 2000, 2000);
    
    //重新设置地图视图的显示区域
    [_mapView setRegion:viewRegion animated:YES];
    //对象添加到地图视图上，一旦该方法被调用，地图视图委托方法mapView：ViewForAnnotation:就会被回调
    [_mapView addAnnotation:_pointAnnotation];
}

-(void)setPaAnnotation:(PAAnnotation *)paAnnotation {
    _paAnnotation = paAnnotation;
    self.addAnnotation = [[PAAnnotation alloc]initWithCoordinate:paAnnotation.coordinate];
    CLLocationCoordinate2D coordinate = paAnnotation.coordinate;
    CLLocation *location = [[CLLocation alloc]initWithLatitude:coordinate.latitude longitude:coordinate.longitude];
    NSLog(@"setPaAnnotation方法中location=%@",location);
    
    //调整地图位置和缩放比例,第一个参数是目标区域的中心点，第二个参数：目标区域南北的跨度，第三个参数：目标区域的东西跨度，单位都是米
    MKCoordinateRegion viewRegion =
    MKCoordinateRegionMakeWithDistance(self.addAnnotation.coordinate, 2000, 2000);
    
    //重新设置地图视图的显示区域
    [_mapView setRegion:viewRegion animated:YES];
    //对象添加到地图视图上，一旦该方法被调用，地图视图委托方法mapView：ViewForAnnotation:就会被回调
    [_mapView addAnnotation:self.addAnnotation];
}

- (void)configWithLongitude:(double)longitude Latitude:(double)latitude Titel:(NSString *)title SubTitle:(NSString *)subTitle {
    MKPointAnnotation *annotaion = [[MKPointAnnotation alloc] init];
    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(latitude, longitude);
    annotaion.coordinate = coordinate;
    annotaion.title = title;
    annotaion.subtitle = subTitle;
    
    self.pointAnnotation = annotaion;
}

#pragma mark - 编译出地址信息

//根据名字编译出地址信息
- (void)geocodeQuery:(NSString *)addressName {
    CLGeocoder *geocode = [[CLGeocoder alloc] init];
    
    [geocode geocodeAddressString:addressName
                completionHandler:^(NSArray *placemarks, NSError *error) {
                    
//                    if ([placemarks count] > 0) {
//                        //移除目前地图上得所有标注点
//                        [_mapView removeAnnotations:_mapView.annotations];
//                    }
                    
//                    for (int i = 0; i < [placemarks count]; i++) {
                        CLPlacemark *placemark = placemarks[0];
                        if (self.contentView) {
//                            PAAnnotation *annotaion = [[PAAnnotation alloc] init];
//                            annotaion.coordinate = placemark.location.coordinate;
//                            annotaion.title = addressName;
//                            annotaion.subtitle = nil;
                            
                            self.addAnnotation = [[PAAnnotation alloc]initWithCoordinate:placemark.location.coordinate];
                            //调整地图位置和缩放比例,第一个参数是目标区域的中心点，第二个参数：目标区域南北的跨度，第三个参数：目标区域的东西跨度，单位都是米
                            MKCoordinateRegion viewRegion =
                            MKCoordinateRegionMakeWithDistance(self.addAnnotation.coordinate, 2000, 2000);
                            
                            //重新设置地图视图的显示区域
                            [_mapView setRegion:viewRegion animated:YES];
                            //对象添加到地图视图上，一旦该方法被调用，地图视图委托方法mapView：ViewForAnnotation:就会被回调
                            [_mapView addAnnotation:self.addAnnotation];
                        
                        } else {
                            MKPointAnnotation *annotaion = [[MKPointAnnotation alloc] init];
                            annotaion.coordinate = placemark.location.coordinate;
                            annotaion.title = placemark.locality;
                            annotaion.subtitle = addressName;
                            [self showMap:placemark isRemoveOld:NO MKPointAnnotation:annotaion];
                        }
                    
                }];
}

//根据CLLocation编译出地址信息
- (void)getCLPlacemarkFromeCLLocation:(CLLocation *)location {
    // 获取当前所在的城市名
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    //根据经纬度反向地理编译出地址信息
//    NSLog(@"getCLPlacemarkFromeCLLocation方法中location=%@",location);
    [geocoder reverseGeocodeLocation:location
                   completionHandler:^(NSArray *array, NSError *error) {
                       if (array.count > 0) {
                           CLPlacemark *placemark = [array objectAtIndex:0];
                           if (self.pointAnnotation) {
                               [self showMap:placemark isRemoveOld:NO MKPointAnnotation:_pointAnnotation];
                           } else if (self.paAnnotation) {
                               //调整地图位置和缩放比例,第一个参数是目标区域的中心点，第二个参数：目标区域南北的跨度，第三个参数：目标区域的东西跨度，单位都是米
                               MKCoordinateRegion viewRegion =
                               MKCoordinateRegionMakeWithDistance(placemark.location.coordinate, 2000, 2000);
                               
                               //重新设置地图视图的显示区域
                               [_mapView setRegion:viewRegion animated:YES];
                               //对象添加到地图视图上，一旦该方法被调用，地图视图委托方法mapView：ViewForAnnotation:就会被回调
                               [_mapView addAnnotation:self.addAnnotation];
                           } else {
                               [self showMap:placemark isRemoveOld:NO MKPointAnnotation:nil];
                           }
                           
                       }
                       else if (error == nil && [array count] == 0)
                       {
                           NSLog(@"No results were returned.");
                       }
                       else if (error != nil)
                       {
                           NSLog(@"An error occurred = %@", error);
                       }
                   }];
}

- (void)showMap:(CLPlacemark *)placemark isRemoveOld:(BOOL)isRemove MKPointAnnotation:(MKPointAnnotation *)pointAnnotation {
    if (isRemove) {
        [_mapView removeAnnotations:_mapView.annotations];
    }
    
    CLLocationCoordinate2D coordinate = placemark.location.coordinate;
    
    //调整地图位置和缩放比例,第一个参数是目标区域的中心点，第二个参数：目标区域南北的跨度，第三个参数：目标区域的东西跨度，单位都是米
    MKCoordinateRegion viewRegion =
    MKCoordinateRegionMakeWithDistance(placemark.location.coordinate, 2000, 2000);
    
    //重新设置地图视图的显示区域
    [_mapView setRegion:viewRegion animated:YES];
//    // 实例化 MapLocation 对象
//    MapLocation *annotation = [[MapLocation alloc] init];
//    annotation.streetAddress = placemark.thoroughfare;
//    annotation.city = placemark.locality;
//    annotation.state = placemark.administrativeArea;
//    annotation.zip = placemark.postalCode;
//    annotation.coordinate = placemark.location.coordinate;
//    
//    //把标注点MapLocation
//    //对象添加到地图视图上，一旦该方法被调用，地图视图委托方法mapView：ViewForAnnotation:就会被回调
//    [_mapView addAnnotation:annotation];
    
    // 添加Annotation
    if (pointAnnotation) {
        [_mapView addAnnotation: pointAnnotation];
    } else {
        MKPointAnnotation *annotaion = [[MKPointAnnotation alloc] init];
        annotaion.coordinate = coordinate;
        annotaion.title = placemark.locality;
        annotaion.subtitle = placemark.name;
         //对象添加到地图视图上，一旦该方法被调用，地图视图委托方法mapView：ViewForAnnotation:就会被回调
        [_mapView addAnnotation: annotaion];
    }
    
}

#pragma mark locationManager

- (void)setupLocationManager {
    
    // 判断定位操作是否被允许
    
    if ([CLLocationManager locationServicesEnabled]) {
        locationmanager = [[CLLocationManager alloc] init];
        //设置精度
        /*
         kCLLocationAccuracyBest
         kCLLocationAccuracyNearestTenMeters
         kCLLocationAccuracyHundredMeters
         kCLLocationAccuracyHundredMeters
         kCLLocationAccuracyKilometer
         kCLLocationAccuracyThreeKilometers
         */
        //设置定位的精度
        [locationmanager setDesiredAccuracy:kCLLocationAccuracyBest];
        //实现协议
        locationmanager.delegate = self;
        //开始定位
        [locationmanager startUpdatingLocation];
    } else {
        //提示用户无法进行定位操作
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示"
                                                            message:@"定位不成功 ,请确认开启定位"
                                                           delegate:nil
                                                  cancelButtonTitle:@"取消"
                                                  otherButtonTitles:@"确定", nil];
        [alertView show];
    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    
    //打印出精度和纬度
    CLLocation *location = [locations lastObject];
//    CLLocationCoordinate2D coordinate = location.coordinate;
//    NSLog(@"输出当前的精度和纬度");
//    NSLog(@"精度：%f 纬度：%f", coordinate.latitude, coordinate.longitude);
    checkinLocation = location;
    if (self.getCLLocation) {
        self.getCLLocation(checkinLocation);
    }
    
    // 获取当前所在的城市名
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    
    //根据经纬度反向地理编译出地址信息
    [geocoder reverseGeocodeLocation:location
                   completionHandler:^(NSArray *array, NSError *error) {
                       if (array.count > 0) {
                           CLPlacemark *placemark = [array objectAtIndex:0];
//                           NSLog(@"定位placemark信息%@",placemark);
                           //获取城市
                           NSString *city = placemark.locality;
                           if (!city) {
                               //四大直辖市的城市信息无法通过locality获得，只能通过获取省份的方法来获得（如果city为空，则可知为直辖市）
                               city = placemark.administrativeArea;
                           }
                           cityName = city;
                           if (self.getCityName) {
                               self.getCityName(cityName);
                           }
                           
                           
                           if (_isPositioning) {
                               [self showMap:placemark isRemoveOld:YES MKPointAnnotation:nil];
                           }
                       }
                       else if (error == nil && [array count] == 0)
                       {
                           NSLog(@"No results were returned.");
                       }
                       else if (error != nil)
                       {
                           NSLog(@"An error occurred = %@", error);
                       }
                   }];
    
    //停止定位
    
    [locationmanager stopUpdatingLocation];
}



#pragma mark mapView Delegate 地图 添加标注时 回调
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    // 获得地图标注对象
//    MKPinAnnotationView *annotationView =
//    (MKPinAnnotationView *) [_mapView equeueReusableAnnotationViewWithIdentifier:@"PIN_ANNOTATION"];
//    if (annotationView == nil) {
//        annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"PIN_ANNOTATION"];
//    }
    // 设置大头针标注视图为紫色
//    annotationView.pinColor = MKPinAnnotationColorPurple;
    
    // 标注地图时 是否以动画的效果形式显示在地图上
//    annotationView.animatesDrop = YES;
    
    
    
    
//    MKAnnotationView *annotationView=[[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"annotation1"];
//    UIImage *img = _imgPin;
//    annotationView.image = img;
//    annotationView.canShowCallout = YES;
//    // 用于标注点上的一些附加信息
//    if (self.rightCalloutAccessoryView) {
//        annotationView.rightCalloutAccessoryView = self.rightCalloutAccessoryView;
//    }
//    return annotationView;
    
    //调整地图位置和缩放比例,第一个参数是目标区域的中心点，第二个参数：目标区域南北的跨度，第三个参数：目标区域的东西跨度，单位都是米
//    MKCoordinateRegion viewRegion =
//    MKCoordinateRegionMakeWithDistance(annotation.coordinate, 2000, 2000);
//    //重新设置地图视图的显示区域
//    [_mapView setRegion:viewRegion animated:YES];
    
    //由于当前位置的标注也是一个大头针，所以此时需要判断，此代理方法返回nil使用默认大头针视图
    if ([annotation isKindOfClass:[PAAnnotation class]]) {
        static NSString *key1=@"AnnotationKey1";
        MKAnnotationView *annotationView=[_mapView dequeueReusableAnnotationViewWithIdentifier:key1];
        //如果缓存池中不存在则新建
        if (!annotationView) {
            annotationView=[[MKAnnotationView alloc]initWithAnnotation:annotation reuseIdentifier:key1];
            annotationView.canShowCallout=NO;//不允许交互点击
//            annotationView.calloutOffset=CGPointMake(0, 1);//定义详情视图偏移量
//            annotationView.leftCalloutAccessoryView=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"icon_classify_cafe.png"]];//定义详情左侧视图
        }
        
        //修改大头针视图
        //重新设置此类大头针视图的大头针模型(因为有可能是从缓存池中取出来的，位置是放到缓存池时的位置)
        annotationView.annotation=annotation;
//        annotationView.image=((PAAnnotation *)annotation).image;//设置大头针视图的图片
        annotationView.image = _imgPin;
        
        return annotationView;
    }else if([annotation isKindOfClass:[PACalloutAnnotation class]]){
        //对于作为弹出详情视图的自定义大头针视图无弹出交互功能（canShowCallout=false，这是默认值），在其中可以自由添加其他视图（因为它本身继承于UIView）
        PACalloutAnnotationView *calloutMapAnnotationView = (PACalloutAnnotationView *)[self.mapView dequeueReusableAnnotationViewWithIdentifier:@"CalloutAnnotation"];
        if (!calloutMapAnnotationView) {
            calloutMapAnnotationView = [[PACalloutAnnotationView alloc] initWithAnnotation:annotation
                                                                             reuseIdentifier:@"CalloutAnnotation"];
            calloutMapAnnotationView.contentHeight = self.contentView.frame.size.height;
            calloutMapAnnotationView.contentWidth = self.contentView.frame.size.width;
            [calloutMapAnnotationView.contentView addSubview:self.contentView];
            calloutMapAnnotationView.color = self.bubbleColor;
        }
        calloutMapAnnotationView.parentAnnotationView = self.selectedAnnotationView;
        calloutMapAnnotationView.mapView = self.mapView;
        return calloutMapAnnotationView;
    } else {
        MKAnnotationView *annotationView=[[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"annotation1"];
        annotationView.image = _imgPin;
        annotationView.canShowCallout = YES;
        // 用于标注点上的一些附加信息
        if (self.rightCalloutAccessoryView) {
            annotationView.rightCalloutAccessoryView = self.rightCalloutAccessoryView;
        }
        return annotationView;

    }
}

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation {
    _mapView.centerCoordinate = userLocation.location.coordinate;
}

- (void)mapViewDidFailLoadingMap:(MKMapView *)theMapView withError:(NSError *)error {
    NSLog(@"error : %@", [error description]);
}

-(void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
    PAAnnotation *annotation=view.annotation;
    if ([view.annotation isKindOfClass:[PAAnnotation class]]) {
        //点击一个大头针时移除其他弹出详情视图
        //        [self removeCustomAnnotation];
        //添加详情大头针，渲染此大头针视图时将此模型对象赋值给自定义大头针视图完成自动布局
        PACalloutAnnotation *annotation1=[[PACalloutAnnotation alloc]init];
        annotation1.icon=annotation.icon;
        annotation1.detail=annotation.detail;
        annotation1.rate=annotation.rate;
        annotation1.coordinate=view.annotation.coordinate;
        [mapView addAnnotation:annotation1];
        self.selectedAnnotationView = view;
    }
}

#pragma mark 取消选中时触发
-(void)mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)view{
    [self removeCustomAnnotation];
}

#pragma mark 移除所用自定义大头针
-(void)removeCustomAnnotation{
    [_mapView.annotations enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([obj isKindOfClass:[PACalloutAnnotation class]]) {
            [_mapView removeAnnotation:obj];
        }
    }];
}

//自动显示气泡
-(void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)views
{
    if ([[[views objectAtIndex:0]annotation] isKindOfClass:[PAAnnotation class]]) {
        MKPinAnnotationView * piview = (MKPinAnnotationView *)[views objectAtIndex:0];
        [_mapView selectAnnotation:piview.annotation animated:YES];
    }
    
}

#pragma mark - Private

- (void)goToLocation:(CLLocationCoordinate2D)toCoordinate {
    
//    [self getCLPlacemarkFromeCLLocation:checkinLocation];
//    if (!(toCoordinate.latitude && toCoordinate.longitude)) {
        toCoordinate = self.addAnnotation.coordinate;
//    }
//    CLLocationCoordinate2D fromCoordinate = checkinLocation.coordinate;
//    CLLocationCoordinate2D toCoordinate   = CLLocationCoordinate2DMake(32.010241,118.719635);
//    MKPlacemark *fromPlacemark = [[MKPlacemark alloc] initWithCoordinate:fromCoordinate
//                                                       addressDictionary:nil];
    MKPlacemark *toPlacemark   = [[MKPlacemark alloc] initWithCoordinate:toCoordinate
                                                       addressDictionary:nil];
//    MKMapItem *fromItem = [[MKMapItem alloc] initWithPlacemark:fromPlacemark];
    MKMapItem *toItem   = [[MKMapItem alloc] initWithPlacemark:toPlacemark];
    
    //调用自带地图导航
    NSDictionary *options=@{MKLaunchOptionsMapTypeKey:@(MKMapTypeStandard),MKLaunchOptionsDirectionsModeKey:MKLaunchOptionsDirectionsModeDriving};
    [MKMapItem openMapsWithItems:@[toItem] launchOptions:options];
    
    //自己画路线导航
//    [self findDirectionsFrom:fromItem
//                          to:toItem];
    
    
}



#pragma mark - 导航线路

- (void)findDirectionsFrom:(MKMapItem *)source
                        to:(MKMapItem *)destination
{
    MKDirectionsRequest *request = [[MKDirectionsRequest alloc] init];
    request.source = source;
    request.destination = destination;
    request.requestsAlternateRoutes = YES;
    MKDirections *directions = [[MKDirections alloc] initWithRequest:request];
    [directions calculateDirectionsWithCompletionHandler:
     ^(MKDirectionsResponse *response, NSError *error) {
         if (error) {
             NSLog(@"error:%@", error);
         }
         else {

             MKRoute *route = response.routes[0];
//             for (MKRoute *route in response.routes) {
                 [_mapView addOverlay:route.polyline];
//             }
             
         }
     }];
}





-(MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay {
    MKPolylineRenderer *renderer = [[MKPolylineRenderer alloc] initWithPolyline:overlay];
    renderer.strokeColor = [UIColor redColor];
    renderer.lineWidth = 4.0;
    return  renderer;
}
@end
