//
//  LocationManager.m
//  Wheelz
//
//  Created by Benson Huynh on 2016-02-08.
//  Copyright © 2016 Benson Huynh. All rights reserved.
//

#import "LocationManager.h"
#import <UIKit/UIKit.h>


@implementation LocationManager

+ (LocationManager *)locationManager {
    
    static LocationManager* _locationManager = nil;
    
    static dispatch_once_t oncePredicate;
    
    dispatch_once(&oncePredicate, ^{
        _locationManager = [[LocationManager alloc] init];
    });
    return _locationManager;
}

- (void) setupLocationManager {
    if (!_locationManager) {
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
        _locationManager.distanceFilter = 10;
        _locationManager.delegate = self;
        [_locationManager requestWhenInUseAuthorization];
        NSLog(@"new location manager in setupLocationManager");
    }
    [_locationManager startUpdatingLocation];
    
    NSLog(@"start regular location manager");
}

- (void)startLocationManager{
    
    if ([CLLocationManager locationServicesEnabled]) {
        
        if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined){
            [self setupLocationManager];
        }else if (!([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied || [CLLocationManager authorizationStatus] == kCLAuthorizationStatusRestricted)){
            [self setupLocationManager];
        }else{
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Yo!"
                                                                                     message:@"Location services are disabled, Please go into Settings > Privacy > Location to enable"
                                                                              preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                       handler:^(UIAlertAction * action) {
                                                           
                                                       }];
            [alertController addAction:ok];
        }
    }
}

-(void)stopLocationManager{
    
    if ([CLLocationManager locationServicesEnabled]) {
        
        if (_locationManager) {
            [_locationManager stopUpdatingLocation];
            NSLog(@"stop location manager");
        }
    }
}

-(void)locationManager:(nonnull CLLocationManager *)manager didUpdateLocations:(nonnull NSArray<CLLocation *> *)locations {
    CLLocation *loc = [locations objectAtIndex: [locations count]-1];
    
    NSLog(@"time %@, latitude %+.6f, longitude %+.6f currentLocation accuracy %1.2f location accuracy %1.2f timeinterval %f",[NSDate date],loc.coordinate.latitude, loc.coordinate.longitude, loc.horizontalAccuracy, loc.horizontalAccuracy, fabs([loc.timestamp timeIntervalSinceNow]));
    
    NSTimeInterval locationAge = -[loc.timestamp timeIntervalSinceNow];
    
    if (locationAge > 10.0){
        NSLog(@"location since is %1.2f",locationAge);
        return;
    }
    
    if (loc.horizontalAccuracy < 0){
        NSLog(@"location horizontal accuracy is %1.2f",loc.horizontalAccuracy);
        return;
    }
    
    if (_currentLocation == nil || _currentLocation.horizontalAccuracy >= loc.horizontalAccuracy) {
        _currentLocation = loc;
        
        if (loc.horizontalAccuracy <= _locationManager.desiredAccuracy) {
            [self stopLocationManager];
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:@"updatedLocation" object:nil];
    }
}

@end
