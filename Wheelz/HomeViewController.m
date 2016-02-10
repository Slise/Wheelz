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
#import <CoreLocation/CoreLocation.h>
#import "Wheelz-Swift.h"
#import "ParkingSpot.h"
#import <Realm/Realm.h>
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
    [self locationUpdate];
    self.mapView.showsUserLocation = true;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(locationUpdate) name:@"updatedLocation" object:nil];
    self.locationManager = [LocationManager locationManager];
    [self.locationManager startLocationManager];
}


-(void)addParkSpotAnnotation {
    RLMResults<ParkingSpot *> *parkingSpot = [ParkingSpot allObjects];
    NSLog(@"%@",parkingSpot);
    ParkingSpot *aSpot = [parkingSpot firstObject];
    CLLocationCoordinate2D coord = CLLocationCoordinate2DMake(aSpot.lat, aSpot.lng);
    ParkSpotAnnotation *aAnnotation = [[ParkSpotAnnotation alloc] initWithCoordinate: coord address:aSpot.spotDescription title:aSpot.name];
    [self.mapView addAnnotation:aAnnotation];
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
        
        NSString *uniqueID = [spot objectForKey:@"_id"];
        NSString *name = [spot objectForKey:@"name"];
        NSString *spotDesciption = [spot objectForKey:@"description"];
        NSString *location = spot[@"Point"][@"coordinates"];
        
        NSArray *coordinates = [location componentsSeparatedByString:@","];
        double lng = [coordinates[0] doubleValue];
        double lat = [coordinates[1] doubleValue];

//        CLLocationCoordinate2D spotLocation = CLLocationCoordinate2DMake(lat, lng);
        
        ParkingSpot *newSpot = [ParkingSpot new];
        newSpot.uniqueID = uniqueID;
        newSpot.name = name;
        newSpot.spotDescription = spotDesciption;
        newSpot.lng = lng;
        newSpot.lat = lat;
        RLMRealm *realm = [RLMRealm defaultRealm];
        [realm beginWriteTransaction];
        [realm addOrUpdateObject:newSpot];
        [realm commitWriteTransaction];
    }
    [self addParkSpotAnnotation];
}

-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    if ([annotation isKindOfClass:[MKUserLocation class]]) {
        return nil;
    }
    MKPinAnnotationView *view = (id)[mapView dequeueReusableAnnotationViewWithIdentifier:@"identifier"];
    if (view) {
        view.annotation = annotation;
    } else {
        view = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"identifier"];
        UIButton *btnViewVenue = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        view.rightCalloutAccessoryView=btnViewVenue;
        view.enabled = YES;
        view.canShowCallout = YES;
        view.multipleTouchEnabled = NO;
        view.animatesDrop = YES;
        UIImage *image = [UIImage imageNamed:@""];
        UIButton *openGoogleMap = [UIButton buttonWithType:UIButtonTypeCustom];
        openGoogleMap.frame = CGRectMake(0, 0, image.size.width, image.size.height);
        [openGoogleMap setImage:image forState:UIControlStateNormal];
        view.leftCalloutAccessoryView = openGoogleMap;
        
    }       
    return view;
}

-(void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {
//    if (<#condition#>) {
//        <#statements#>
//    }
//    NSURL *url = [NSURL URLWithString:@"http://maps.google.com/?q=Vancouver"];
//    [[UIApplication sharedApplication] openURL:url];
//
}

-(void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view
{
    [view setCanShowCallout:YES];
    
}

@end
