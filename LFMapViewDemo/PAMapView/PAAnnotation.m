//
//  PAAnnotation.m
//  HaoCheApp
//
//  Created by 张林峰1 on 15/6/26.
//  Copyright (c) 2015年 pahaoche. All rights reserved.
//

#import "PAAnnotation.h"

@implementation PAAnnotation

- (id)initWithCoordinate:(CLLocationCoordinate2D)coordinate {
    if (self = [super init]) {
        self.coordinate = coordinate;
    }
    return self;
}

@end
