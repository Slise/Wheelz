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
#import "LocationManager.h"
#import <AddressBookUI/AddressBookUI.h>
#import <CoreLocation/CLGeocoder.h>
#import <CoreLocation/CLPlacemark.h>
#import <MapKit/MapKit.h>
#import "Wheelz-Swift.h"
#import "ParkingSpot.h"
#import <Realm/Realm.h>

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
    [self locationUpdate];
    self.mapView.showsUserLocation = true;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(locationUpdate) name:@"updatedLocation" object:nil];
    self.locationManager = [LocationManager locationManager];
    [self.locationManager startLocationManager];
}

-(void)addParkSpotAnnoptation {
    
}

-(void)locationUpdate {
    
    NSLog(@"CURRENT LOCATION: %f, %f", [self.locationManager.currentLocation coordinate].latitude, [self.locationManager.currentLocation coordinate].longitude);
    
    self.currentLocation = self.locationManager.currentLocation;
    CLLocationCoordinate2D zoomLocation = CLLocationCoordinate2DMake([self.currentLocation coordinate].latitude, [self.currentLocation coordinate].longitude);
    MKCoordinateRegion adjustedRegion = MKCoordinateRegionMakeWithDistance(zoomLocation, zoominMapArea, zoominMapArea);
    [self.mapView setRegion:adjustedRegion animated:YES];
    
    CLGeocoder *geocoder = [CLGeocoder new];
    [geocoder reverseGeocodeLocation:self.currentLocation completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
        
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
    
    self.parkingSpots = xmlDoc[@"Document"][@"Folder"][@"Placemark"];
    
    for (NSDictionary *spot in self.parkingSpots) {
        
        NSString *name = [spot objectForKey:@"name"];
        NSString *spotDesciption = [spot objectForKey:@"description"];
        NSString *location = spot[@"Point"][@"coordinates"];
        
        NSArray *coordinates = [location componentsSeparatedByString:@","];
        double lng = [coordinates[0] doubleValue];
        double lat = [coordinates[1] doubleValue];

        CLLocationCoordinate2D spotLocation = CLLocationCoordinate2DMake(lat, lng);
        
        ParkingSpot *newSpot = [ParkingSpot new];
        newSpot.name = name;
        newSpot.spotDescription = spotDesciption;
        newSpot.lng = lng;
        newSpot.lat = lat;
        
        RLMRealm *realm = [RLMRealm defaultRealm];
        
        [realm transactionWithBlock:^{
            [realm addObject:newSpot];
        }];
        
        
    }
}

-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    
    return [[MKAnnotationView alloc] init];
    
    
}

-(void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view
{
    [view setCanShowCallout:YES];
    
}

-(void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {
    
    
}

@end
