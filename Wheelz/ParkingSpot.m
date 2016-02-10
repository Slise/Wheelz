//
//  ParkingSpot.m
//  Wheelz
//
//  Created by Benson Huynh & Dave Hurley on 2016-02-09.
//  Copyright © 2016 Benson Huynh. All rights reserved.
//

#import "ParkingSpot.h"

@implementation ParkingSpot

// Specify default values for properties

+ (NSDictionary *)defaultPropertyValues
{
    return @{@"name":@"", @"spotDescription":@"", @"lng":@0, @"lat":@0};
}

// Specify properties to ignore (Realm won't persist these)

+ (NSArray *)ignoredProperties
{
    return @[];
}

+ (NSString *)primaryKey {
    return NSStringFromSelector(@selector(uniqueID));
}

@end
