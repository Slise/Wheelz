//
//  LocationManager.h
//  Wheelz
//
//  Created by Benson Huynh on 2016-02-08.
//  Copyright © 2016 Benson Huynh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface LocationManager : NSObject <CLLocationManagerDelegate>

@property (strong,nonatomic) CLLocation *currentLocation;
@property (strong, nonatomic) CLLocationManager *locationManager;

+ (LocationManager *)locationManager;
- (void)startLocationManager;

@end
