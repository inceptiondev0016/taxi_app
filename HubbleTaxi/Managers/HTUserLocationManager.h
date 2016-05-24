//
//  HTUserLocationManager.h
//  HubbleTaxi
//
//  Created by Aamir Javed on 30/01/2014.
//  Copyright (c) 2014 Apponative. All rights reserved.
//

#import "HTManager.h"

@interface HTUserLocationManager : HTManager

+ (HTUserLocationManager *)sharedManager;
-(id)locationAgainstAddress:(NSString*)address inLocality:(NSString*)locality completionNotificationName:(NSString *)completionNotificationName;
- (id)searchNearbyPlacesFromLatitude:(float)lat longitude:(float)lng nearbyRadius:(NSUInteger)radius searchType:(NSString*)type completionNotificationName:(NSString *)completionNotificationName;
- (id)livePlaceSearchWithQueryText:(NSString*)queryText fromLatitude:(float)lat longitude:(float)lng nearbyRadius:(NSUInteger)radius completionNotificationName:(NSString *)completionNotificationName;
- (id)serviceAreaFieldsWithPostalCode:(NSString*)postalCode completionNotificationName:(NSString *)completionNotificationName;
- (id)directionsOfJourneyWithStartingLocation:(NSString*)startingLocation endingLocation:(NSString*)endingLocation viaRouteLocaton:(NSString*)viaRouteLocation completionNotificationName:(NSString *)completionNotificationName;
- (void)updateUserSelectedVehicleTypeTo:(NSString*)vehicleType;
- (NSString*)userSelectedVehicleType;
- (id)getCommonPlacesWithCompletionNotificationName:(NSString *)completionNotificationName;
@end
