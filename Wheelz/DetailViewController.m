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


#define zoominMapArea 2100

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
    
    self.locationLabel.text = self.parkSpotAnnotation.title;
    self.descriptionLabel.text = self.parkSpotAnnotation.address;
    
    [super viewWillAppear:animated];
    [self initiateMap];
}


- (void)initiateMap {
    

   
}




- (IBAction)getDirectionButtonPressed:(id)sender {
    
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}


@end
