//
//  ParkingSpot.h
//  Wheelz
//
//  Created by Dave Hurley on 2016-02-09.
//  Copyright © 2016 Benson Huynh. All rights reserved.
//

#import <Realm/Realm.h>

@interface ParkingSpot : RLMObject

@property (nonatomic, strong) NSString * uniqueID;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *spotDescription;
@property (nonatomic, assign) double lng;
@property (nonatomic, assign) double lat;

@end

// This protocol enables typed collections. i.e.:
// RLMArray<ParkingSpot>

RLM_ARRAY_TYPE(ParkingSpot)
