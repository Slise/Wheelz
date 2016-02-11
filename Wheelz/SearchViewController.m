//
//  SearchViewController.m
//  Wheelz
//
//  Created by Benson Huynh on 2016-02-10.
//  Copyright © 2016 Benson Huynh. All rights reserved.
//

#import "SearchViewController.h"
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

@interface SearchViewController ()

@property (weak, nonatomic) IBOutlet UITextField *searchTextField;

@end

@implementation SearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (IBAction)searchButtonPressed:(UITextField *)sender {
    [self getCoordinatesForAddress:self.searchTextField.text
                        completion:^(MKCoordinateRegion region) {
                            
                        }];
}

- (void)getCoordinatesForAddress:(NSString *)address completion:(void (^)(MKCoordinateRegion region))completion {
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder geocodeAddressString:address completionHandler:^(NSArray *placemarks, NSError *error) {
        if (error) {
            NSLog(@"%@", error);
        } else {
            CLPlacemark *placemark = [placemarks lastObject];
            float spanX = 0.00725;
            float spanY = 0.00725;
            MKCoordinateRegion region = MKCoordinateRegionMake(CLLocationCoordinate2DMake(placemark.location.coordinate.latitude, placemark.location.coordinate.longitude), MKCoordinateSpanMake(spanX, spanY));
            completion(region);
        }
    }];
}



@end
