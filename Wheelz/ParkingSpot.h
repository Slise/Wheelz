//
//  ParkingSpot.h
//  Wheelz
//
//  Created by Benson Huynh on 2016-02-08.
//  Copyright © 2016 Benson Huynh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

@interface ParkingSpot : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *detail;
@property (nonatomic) CLLocationCoordinate2D coordinate;

- (instancetype)initWithName:(NSString *)name detail:(NSString *)detail coordinate:(CLLocationCoordinate2D)coordinate;

@end
