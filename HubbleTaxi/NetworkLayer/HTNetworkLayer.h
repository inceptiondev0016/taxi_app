//
//  HTNetworkLayer.h
//  HubbleTaxi
//
//  Created by Aamir Javed on 30/01/2014.
//  Copyright (c) 2014 Apponative. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HTNetworkLayer : NSObject

#pragma mark - User Profile
- (NSObject<Cancelable>*)createApplicationSessionWithAppID:(NSUInteger)appID authorizationKey:(NSString*)authorizationKey authorizationSecret:(NSString*)authorizationSecret completionNotificationName:(NSString*)completionNotificationName;
- (NSObject<Cancelable>*)loginWithPhoneNumber:(NSString*)phoneNumber completionNotificationName:(NSString*)completionNotificationName;
- (void)sendSecretCode:(NSString*)secretCode toPhoneNumber:(NSString*)phoneNumber completionNotificationName:(NSString*)completionNotificationName;
- (NSObject<Cancelable>*)userWithPhoneNumber:(NSString*)phoneNumber completionNotificationName:(NSString*)completionNotificationName;
- (NSObject<Cancelable>*)signupWithPhoneNumber:(NSString*)phoneNumber completionNotificationName:(NSString*)completionNotificationName;
- (NSObject<Cancelable>*)logoutCurrentUserWithCompletionNotificationName:(NSString*)completionNotificationName;
- (NSObject<Cancelable>*)uploadDPWithInfoDictionary:(NSDictionary*)dpInfoDictionary completionNotificationName:(NSString*)completionNotificationName;
- (NSObject<Cancelable>*)downloadDPImageWithBlobID:(NSUInteger)blobID completionNotificationName:(NSString*)completionNotificationName;
- (NSObject<Cancelable>*)updateAccountInfoWithDictionay:(NSDictionary*)profileDictionary completionNotificationName:(NSString*)completionNotificationName;
- (NSObject<Cancelable>*)updatePersonInformationWithDictionary:(NSDictionary*)profileDictionary completionNotificationName:(NSString*)completionNotificationName;
- (NSObject<Cancelable>*)downloadPersonalInformationWithUserID:(NSInteger)userID completionNotificationName:(NSString*)completionNotificationName;
- (NSObject<Cancelable>*)downlaodDriverProfileWithDriverID:(NSString*)driverID completionNotificationName:(NSString*)completionNotificationName;
- (NSObject<Cancelable>*)getDriverAvailableNearToLocation:(NSString*)locationString completionNotificationName:(NSString *)completionNotificationName;

#pragma mark - User Location
- (id)locationAgainstAddress:(NSString*)address inLocality:(NSString*)locality gmapServerAPIKey:(NSString*)serverAPIKey completionNotificationName:(NSString *)completionNotificationName;
- (id)searchNearbyPlacesFromLatitude:(float)lat longitude:(float)lng nearbyRadius:(NSUInteger)radius searchType:(NSString*)type serverAPIKey:(NSString*)serverAPIKey completionNotificationName:(NSString *)completionNotificationName;
- (id)livePlaceSearchWithQueryText:(NSString*)queryText fromLatitude:(float)lat longitude:(float)lng nearbyRadius:(NSUInteger)radius serverAPIKey:(NSString*)serverAPIKey completionNotificationName:(NSString *)completionNotificationName;
- (NSObject<Cancelable>*)serviceAreaFieldsWithPostalCode:(NSString*)postalCode completionNotificationName:(NSString *)completionNotificationName;
- (id)directionsOfJourneyWithStartingLocation:(NSString*)startingLocation endingLocation:(NSString*)endingLocation viaRouteLocaton:(NSString*)viaRouteLocation serverAPIKey:(NSString*)serverAPIKey completionNotificationName:(NSString *)completionNotificationName;
- (NSObject<Cancelable>*)getCommonPlacesWithCompletionNotificationName:(NSString *)completionNotificationName;

#pragma mark- User Booking
- (NSObject<Cancelable>*)bookingOrderWithUserId:(NSUInteger)userID completionNotificationName:(NSString*)completionNotificationName;
- (NSObject<Cancelable>*)bookingOrderWithJobID:(NSString*)jobID completionNotificationName:(NSString*)completionNotificationName;
- (NSObject<Cancelable>*)updateJobRatingWithInfo:(NSDictionary*)jobRatingDictionary withJobID:(NSString*)jobID userID:(NSUInteger)userID completionNotificationName:(NSString*)completionNotificationName;
- (NSObject<Cancelable>*)createBookingJobs:(NSArray*)bookingJobs withUserId:(NSUInteger)userID completionNotificationName:(NSString*)completionNotificationName;
- (NSObject<Cancelable>*)futureBookingsWithUserId:(NSUInteger)userID completionNotificationName:(NSString*)completionNotificationName;
- (NSObject<Cancelable>*)cancelFutureBookingWithJobID:(NSString*)jobID completionNotificationName:(NSString*)completionNotificationName;
- (NSObject<Cancelable>*)incrementJobNumberBy:(NSInteger)incrementBy withCompletionNotificationName:(NSString*)completionNotificationName;
- (NSObject<Cancelable>*)sendCustomerInstruction:(NSString*)instrcutionString toDriverWithJobID:(NSString*)jobID completionNotificationName:(NSString*)completionNotificationName;
- (NSObject<Cancelable>*)logJobWithUserID:(NSUInteger)userID jobID:(NSString*)jobID addedBy:(NSString*)addedBy notes:(NSString*)notes type:(NSString*)type;
- (NSObject<Cancelable>*)getAlreadyBookedJobsWithinBookingTime:(NSDate*)bookingTime customerId:(NSUInteger)customerID completionNotificationName:(NSString*)completionNotificationName;

@end
