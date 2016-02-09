//
//  ParkingSpot.m
//  Wheelz
//
//  Created by Benson Huynh on 2016-02-08.
//  Copyright © 2016 Benson Huynh. All rights reserved.
//

#import "ParkingSpot.h"

@implementation ParkingSpot

- (instancetype)initWithName:(NSString *)name detail:(NSString *)detail coordinate:(CLLocationCoordinate2D)coordinate {
    self = [super init];
    if (self) {
        _name = name;
        _detail = detail;
        _coordinate = coordinate;
    }
    return self;
}


@end
