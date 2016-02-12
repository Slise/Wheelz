//
//  DetailViewController.m
//  Wheelz
//
//  Created by Benson Huynh & Dave Hurley on 2016-02-08.
//  Copyright © 2016 Benson Huynh. All rights reserved.
//

#import "DetailViewController.h"
#import <MapKit/MapKit.h>
#import <Realm/Realm.h>
#import "Wheelz-Swift.h"
#import <CoreLocation/CoreLocation.h>
#import "OpenInGoogleMapsController.h"


#define zoominMapArea 300

@interface DetailViewController () <MKMapViewDelegate>

@property (weak, nonatomic) IBOutlet MKMapView *detailMapView;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;


@end

@implementation DetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

-(void)viewWillAppear:(BOOL)animated {
    
    NSMutableAttributedString *noHTML = [[NSMutableAttributedString alloc] initWithData:[self.parkSpotAnnotation.address dataUsingEncoding:NSUTF8StringEncoding] options:@{NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType, NSCharacterEncodingDocumentAttribute: [NSNumber numberWithInt:NSUTF8StringEncoding]} documentAttributes:nil error:nil];
    
    self.descriptionLabel.text = noHTML.string;
    
    [super viewWillAppear:animated];
    [self initiateMap];
}


- (void)initiateMap {
    
    CLLocationCoordinate2D parkingSpot = CLLocationCoordinate2DMake(self.parkSpotAnnotation.coordinate.latitude, self.parkSpotAnnotation.coordinate.longitude);
    MKCoordinateRegion adjustedRegion = MKCoordinateRegionMakeWithDistance(parkingSpot, zoominMapArea, zoominMapArea);
    [self.detailMapView setRegion:adjustedRegion animated:YES];
    
    ParkSpotAnnotation *pin = [[ParkSpotAnnotation alloc] initWithCoordinate:parkingSpot address:@"" title:@""];
    [self.detailMapView addAnnotation:pin];
    
}

- (IBAction)getDirectionButtonPressed:(id)sender {
    
    GoogleDirectionsDefinition *definition = [[GoogleDirectionsDefinition alloc] init];
    
    //if startingPoint is set to nil, directions will start at users current location.
    
    definition.startingPoint = nil;
    definition.destinationPoint = [GoogleDirectionsWaypoint waypointWithQuery:self.parkSpotAnnotation.title];
    definition.travelMode = kGoogleMapsTravelModeDriving;
    
    //set a fallback strategy to open in apple maps if google maps isnt installed
    [OpenInGoogleMapsController sharedInstance].fallbackStrategy = kGoogleMapsFallbackChromeThenSafari;
    
    [[OpenInGoogleMapsController sharedInstance] openDirections:definition];
    
    
}

- (IBAction)mapStyleControl:(id)sender {
    UISegmentedControl *seg=(UISegmentedControl*)sender;
    if(seg.selectedSegmentIndex==0){
        self.detailMapView.mapType=MKMapTypeStandard;
    }
    if(seg.selectedSegmentIndex==1){
        self.detailMapView.mapType=MKMapTypeSatellite;
    }
    if(seg.selectedSegmentIndex==2){
        self.detailMapView.mapType=MKMapTypeHybrid;
    }
    
}


@end
