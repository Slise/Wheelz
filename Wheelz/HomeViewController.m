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
#import "OpenInGoogleMapsController.h"

#define zoominMapArea 1800

@interface HomeViewController () <MKMapViewDelegate, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (strong, nonatomic) LocationManager *locationManager;
@property (strong,nonatomic) CLLocation *currentLocation;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) NSMutableArray *parkingSpots;
@property (strong, nonatomic) NSMutableArray *searchItems;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.searchItems = [NSMutableArray array];
    self.mapView.showsUserLocation = true;
    self.locationManager = [LocationManager locationManager];
    [self.locationManager startLocationManager];
    [self locationUpdate];
   // [self performSearch];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(locationUpdate) name:@"updatedLocation" object:nil];
    [self.navigationController.navigationBar setTitleTextAttributes:
      @{NSFontAttributeName: [UIFont fontWithName:@"Arial" size:26.0f],
            NSForegroundColorAttributeName:[UIColor whiteColor]}];
}

- (void) performSearch:(NSString *)searchString{
    [self.searchItems removeAllObjects];
    
    NSLog(@"started request");
    MKLocalSearchRequest *request =
    [[MKLocalSearchRequest alloc] init];
    request.naturalLanguageQuery = searchString;
    request.region = self.mapView.region;
    MKLocalSearch *search =
    [[MKLocalSearch alloc]initWithRequest:request];
    [search startWithCompletionHandler:^(MKLocalSearchResponse
                                         *response, NSError *error) {
        NSLog(@"finished request");
        if (response.mapItems.count == 0)
            NSLog(@"No Matches");
        else
            for (MKMapItem *item in response.mapItems)
            {
                [self.searchItems addObject:item];
            }
    [self.tableView reloadData];
    }];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([self.searchItems count] > 0)
        self.tableView.hidden = NO;
    else
        self.tableView.hidden = YES;
    return [self.searchItems count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    MKMapItem *mapAddrress = self.searchItems[indexPath.row];
    cell.textLabel.text = mapAddrress.name;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    MKMapItem *mapAddrress = self.searchItems[indexPath.row];
    UserSearchPin *searchedSpotPin = [[UserSearchPin alloc] initWithCoordinate:mapAddrress.placemark.coordinate address:@"" title:mapAddrress.name];
//    annotation.coordinate = mapAddrress.placemark.coordinate;
//    annotation.title = mapAddrress.name;
    self.tableView.hidden = YES;
    CLLocationCoordinate2D searchedItem = mapAddrress.placemark.coordinate;
    MKCoordinateRegion adjustedSearchRegion = MKCoordinateRegionMakeWithDistance(searchedItem, 400, 400);
    [self.mapView setRegion:adjustedSearchRegion animated:YES];
    [self.mapView addAnnotation:searchedSpotPin];
    
}

- (IBAction)cancelSearchButton:(id)sender {
    self.textField.text = @"";
    self.tableView.hidden = YES;
}

//- (BOOL) textFieldShouldClear:(UITextField *)textField {
//    return YES;
//}

-(void)addParkSpotAnnotation {
    RLMResults<ParkingSpot *> *parkingSpot = [ParkingSpot allObjects];
    NSLog(@"%@",parkingSpot);
    for (ParkingSpot *aSpot in parkingSpot){
        CLLocationCoordinate2D coord = CLLocationCoordinate2DMake(aSpot.lat, aSpot.lng);
        ParkSpotAnnotation *aAnnotation = [[ParkSpotAnnotation alloc] initWithCoordinate: coord address:aSpot.spotDescription title:aSpot.name];
        [self.mapView addAnnotation:aAnnotation];
    }
}
     
-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    [self performSearch:textField.text];
    return YES;
}

-(void)locationUpdate {
//    NSLog(@"CURRENT LOCATION: %f, %f", [self.locationManager.currentLocation coordinate].latitude, [self.locationManager.currentLocation coordinate].longitude);
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
        ParkingSpot *newSpot = [[ParkingSpot alloc] init];
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
    else if ([annotation isKindOfClass:[UserSearchPin class]]) {
        MKPinAnnotationView *view = (id)[mapView dequeueReusableAnnotationViewWithIdentifier:@"identifierSearch"];
        if (view) {
            view.annotation = annotation;
        } else {
            view = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"identifierSearch"];
            view.enabled = YES;
            view.canShowCallout = YES;
            view.multipleTouchEnabled = NO;
            view.animatesDrop = YES;
            view.pinTintColor = [UIColor purpleColor];
        }
        return view;
    }else {
        MKPinAnnotationView *view = (id)[mapView dequeueReusableAnnotationViewWithIdentifier:@"identifier"];
        if (view) {
            view.annotation = annotation;
        } else {
            view = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"identifier"];
            UIButton *infoButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
            view.rightCalloutAccessoryView= infoButton;
            infoButton.tag = 1200;
            view.enabled = YES;
            view.canShowCallout = YES;
            view.multipleTouchEnabled = NO;
            view.animatesDrop = YES;
            UIImage *image = [UIImage imageNamed:@"car_nav.png"];
            UIButton *openGoogleMap = [UIButton buttonWithType:UIButtonTypeCustom];
            openGoogleMap.frame = CGRectMake(0, 0, 44, 44);
            [openGoogleMap setImage:image forState:UIControlStateNormal];
            view.leftCalloutAccessoryView = openGoogleMap;
            openGoogleMap.tag = 1000;
        }       
        return view;
    }
}

-(void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {
    if (control.tag == 1000) {
        
        GoogleDirectionsDefinition *definition = [[GoogleDirectionsDefinition alloc] init];
        
        //if startingPoint is set to nil, directions will start at users current location.
        
        definition.startingPoint = nil;
        
        // accessing "MKAnnotationView *view" title property and passing to destinationPoint 
        
        definition.destinationPoint = [GoogleDirectionsWaypoint waypointWithQuery:view.annotation.title];
        definition.travelMode = kGoogleMapsTravelModeDriving;
        
        [[OpenInGoogleMapsController sharedInstance] openDirections:definition];

    } else if (control.tag == 1200) {
        
        UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        DetailViewController *detailViewController  =[mainStoryboard instantiateViewControllerWithIdentifier:@"detailViewController"];
        
        //configure detail view controller
        
        detailViewController.parkSpotAnnotation = view.annotation;
        [self.navigationController pushViewController:detailViewController animated:YES];
    }
}

-(void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view
{
    [view setCanShowCallout:YES];
}

@end
