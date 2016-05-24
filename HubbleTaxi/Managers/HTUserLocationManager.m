//
//  HTUserLocationManager.m
//  HubbleTaxi
//
//  Created by Aamir Javed on 30/01/2014.
//  Copyright (c) 2014 Apponative. All rights reserved.
//

#import "HTUserLocationManager.h"
#import "HTDMManager.h"
static HTUserLocationManager *_sharedManager;

@implementation HTUserLocationManager


+ (HTUserLocationManager *)sharedManager
{
    if (!_sharedManager) {
        _sharedManager = [[HTUserLocationManager alloc] init];
    }
    return _sharedManager;
}

-(id)locationAgainstAddress:(NSString*)address inLocality:(NSString*)locality completionNotificationName:(NSString *)completionNotificationName;
{
    return [[HTDMManager sharedManager] locationAgainstAddress:address inLocality:locality completionNotificationName:completionNotificationName];
}

- (id)searchNearbyPlacesFromLatitude:(float)lat longitude:(float)lng nearbyRadius:(NSUInteger)radius searchType:(NSString*)type completionNotificationName:(NSString *)completionNotificationName
{
    return [[HTDMManager sharedManager] searchNearbyPlacesFromLatitude:lat longitude:lng nearbyRadius:radius searchType:type completionNotificationName:completionNotificationName];
}

- (id)livePlaceSearchWithQueryText:(NSString*)queryText fromLatitude:(float)lat longitude:(float)lng nearbyRadius:(NSUInteger)radius completionNotificationName:(NSString *)completionNotificationName;
{
    return [[HTDMManager sharedManager] livePlaceSearchWithQueryText:queryText fromLatitude:lat longitude:lng nearbyRadius:radius completionNotificationName:completionNotificationName];
}

- (id)serviceAreaFieldsWithPostalCode:(NSString*)postalCode completionNotificationName:(NSString *)completionNotificationName;
{
    return [[HTDMManager sharedManager] serviceAreaFieldsWithPostalCode:postalCode completionNotificationName:completionNotificationName];
}

- (id)directionsOfJourneyWithStartingLocation:(NSString*)startingLocation endingLocation:(NSString*)endingLocation viaRouteLocaton:(NSString*)viaRouteLocation completionNotificationName:(NSString *)completionNotificationName;
{
    return [[HTDMManager sharedManager] directionsOfJourneyWithStartingLocation:startingLocation endingLocation:endingLocation viaRouteLocaton:viaRouteLocation completionNotificationName:completionNotificationName];
}

- (void)updateUserSelectedVehicleTypeTo:(NSString*)vehicleType
{
    [[HTDMManager sharedManager] updateUserSelectedVehicleTypeTo:vehicleType];
}

- (NSString*)userSelectedVehicleType
{
    return [[HTDMManager sharedManager] userSelectedVehicleType];
}

- (id)getCommonPlacesWithCompletionNotificationName:(NSString *)completionNotificationName
{
    return [[HTDMManager sharedManager] getCommonPlacesWithCompletionNotificationName:completionNotificationName];
}


@end
