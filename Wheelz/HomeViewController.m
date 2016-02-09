//
//  HomeViewController.m
//  Wheelz
//
//  Created by Benson Huynh on 2016-02-08.
//  Copyright © 2016 Benson Huynh. All rights reserved.
//

#import "HomeViewController.h"
#import "XMLDictionary.h"
#import "DetailViewController.h"
#import "ParkingSpot.h"
#import "LocationManager.h"
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

#define zoominMapArea 2100

@interface HomeViewController () <MKMapViewDelegate>

@property (strong, nonatomic) LocationManager *locationManager;
@property (strong,nonatomic) CLLocation *currentLocation;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) NSMutableArray *parkingSpots;

@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self downloadParkingLocation];
}


-(void)downloadParkingLocation {
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"disability_parking" ofType:@"kml"];
    NSDictionary *xmlDoc = [NSDictionary dictionaryWithXMLFile:filePath];
    NSLog(@"%@", xmlDoc);
    
    self.parkingSpots = xmlDoc[@"Document"][@"Folder"][@"Placemark"];
    
    for (NSDictionary *spot in self.parkingSpots) {
        NSString *address = [spot objectForKey:@"name"];
        NSString *desciption = [spot objectForKey:@"description"];
        NSString *location = spot[@"Point"][@"coordinates"];
        NSArray *coordinates = [location componentsSeparatedByString:@","];
        NSNumber *lng = @([coordinates[0] doubleValue]);
        NSNumber *lat = @([coordinates[1] doubleValue]);
        
        //NSLog(@"lat %@ lng %@ %@", lat, lng, address);
        
        CLLocationCoordinate2D spotLocation = CLLocationCoordinate2DMake([lat doubleValue], [lng doubleValue]);
        NSLog(@" coord %f %f", spotLocation.latitude, spotLocation.longitude);
    }
}

@end
