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


#define zoominMapArea 300

@interface DetailViewController () <MKMapViewDelegate>

@property (weak, nonatomic) IBOutlet MKMapView *detailMapView;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet UILabel *locationLabel;


@end

@implementation DetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

-(void)viewWillAppear:(BOOL)animated {
    
    NSMutableAttributedString *noHTML = [[NSMutableAttributedString alloc] initWithData:[self.parkSpotAnnotation.address dataUsingEncoding:NSUTF8StringEncoding] options:@{NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType, NSCharacterEncodingDocumentAttribute: [NSNumber numberWithInt:NSUTF8StringEncoding]} documentAttributes:nil error:nil];
    
    self.locationLabel.text = noHTML.string;
    
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
    
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"comgooglemaps://"]]) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"comgooglemaps://"]];
        
    } else {
        NSURL *url = [NSURL URLWithString:@"http://maps.google.com/?q=Vancouver"];
        [[UIApplication sharedApplication] openURL:url];
    }
}



@end
