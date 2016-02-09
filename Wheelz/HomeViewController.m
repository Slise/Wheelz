//
//  HomeViewController.m
//  Wheelz
//
//  Created by Benson Huynh & Dave Hurley on 2016-02-08.
//  Copyright © 2016 Benson Huynh. All rights reserved.
//

#import "HomeViewController.h"
#import "XMLDictionary.h"
#import "DetailViewController.h"
#import "ParkingSpot.h"
#import "LocationManager.h"
#import <AddressBookUI/AddressBookUI.h>
#import <CoreLocation/CLGeocoder.h>
#import <CoreLocation/CLPlacemark.h>
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
    self.mapView.showsUserLocation = true;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(locationUpdate) name:@"updatedLocation" object:nil];
    self.locationManager = [LocationManager locationManager];
    [self.locationManager startLocationManager];
}



-(void)locationUpdate {
    
    NSLog(@"CURRENT LOCATION: %f, %f", [self.locationManager.currentLocation coordinate].latitude, [self.locationManager.currentLocation coordinate].longitude);
    
    _currentLocation = _locationManager.currentLocation;
    CLLocationCoordinate2D zoomLocation = CLLocationCoordinate2DMake([_currentLocation coordinate].latitude, [_currentLocation coordinate].longitude);
    MKCoordinateRegion adjustedRegion = MKCoordinateRegionMakeWithDistance(zoomLocation, zoominMapArea, zoominMapArea);
    [self.mapView setRegion:adjustedRegion animated:YES];
    
    CLGeocoder *geocoder = [CLGeocoder new];
    [geocoder reverseGeocodeLocation:_currentLocation completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
        
        if (error) {
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        } else {
            CLPlacemark *placemark = [placemarks firstObject];
            if (placemark) {
                [self downloadParkingLocation];
            }
        }
    }];
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

-(void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view
{
    [view setCanShowCallout:YES];
}


-(void)someMethod {

    //omg a method srsly its p badass
}

@end
