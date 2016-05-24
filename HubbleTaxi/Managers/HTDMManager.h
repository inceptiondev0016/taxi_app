//
//  HTDMManager.h
//  HubbleTaxi
//
//  Created by Aamir Javed on 30/01/2014.
//  Copyright (c) 2014 Apponative. All rights reserved.
//

#import "HTManager.h"

@interface HTDMManager : HTManager


+ (HTDMManager*)sharedManager;

//Notification name is changed so that DM got notified before other objects are notified against same event. Network layer first fires notification for DM then for other objects
- (NSString*)dmNotificationNameForNormalNoticationName:(NSString*)notificationName;

#pragma mark- User Profile
- (BOOL)userProfileExists;
- (BOOL)isProfileUpdateNeeded;
- (id)createApplicationSessionWithCompletionNotificationName:(NSString*)completionNotificationName;
- (id)createUserSessionWithCompletionNotificationName:(NSString*)completionNotificationName;
- (void)sendSecretCodeToPhoneNumber:(NSString*)phoneNumber completionNotificationName:(NSString*)completionNotificationName;
- (NSString*)currentSecretCode;
- (void)saveDPImagePermanentally:(UIImage*)dpImage;
- (UIImage*)getDpImage;
- (id)userWithPhoneNumber:(NSString*)phoneNumber completionNotificationName:(NSString*)completionNotificationName;
- (id)signupWithPhoneNumber:(NSString*)phoneNumber completionNotificationName:(NSString*)completionNotificationName;
- (id)loginWithPhoneNumber:(NSString*)phoneNumber completionNotificationName:(NSString*)completionNotificationName;
- (id)logoutCurrentUserWithCompletionNotificationName:(NSString*)completionNotificationName;
- (NSDictionary*)currentUserProfile;
- (id)uploadDPImage:(UIImage*)dpImage completionNotificationName:(NSString*)completionNotificationName;
- (id)downloadDpImageWithCompletionNotificationName:(NSString*)completionNotificationName;
- (id)updateAccountInfoWithDictionay:(NSDictionary*)profileDictionary completionNotificationName:(NSString*)completionNotificationName;
- (id)updatePersonInformationWithDictionary:(NSDictionary*)profileDictionary completionNotificationName:(NSString*)completionNotificationName;
- (id)downloadPersonalInformationWithCompletionNotificationName:(NSString*)completionNotificationName;
- (id)downlaodDriverProfileWithDriverID:(NSString*)driverID completionNotificationName:(NSString*)completionNotificationName;
- (id)getDriverAvailableNearToLocation:(NSString*)locationString completionNotificationName:(NSString *)completionNotificationName;
- (void)removeAllDataOfCurrentLoggedInUser;

#pragma mark- User Location
-(id)locationAgainstAddress:(NSString*)address inLocality:(NSString*)locality completionNotificationName:(NSString *)completionNotificationName;
- (id)searchNearbyPlacesFromLatitude:(float)lat longitude:(float)lng nearbyRadius:(NSUInteger)radius searchType:(NSString*)type completionNotificationName:(NSString *)completionNotificationName;
- (id)livePlaceSearchWithQueryText:(NSString*)queryText fromLatitude:(float)lat longitude:(float)lng nearbyRadius:(NSUInteger)radius completionNotificationName:(NSString *)completionNotificationName;
- (id)serviceAreaFieldsWithPostalCode:(NSString*)postalCode completionNotificationName:(NSString *)completionNotificationName;
- (id)directionsOfJourneyWithStartingLocation:(NSString*)startingLocation endingLocation:(NSString*)endingLocation viaRouteLocaton:(NSString*)viaRouteLocation completionNotificationName:(NSString *)completionNotificationName;
- (void)updateUserSelectedVehicleTypeTo:(NSString*)vehicleType;
- (NSString*)userSelectedVehicleType;
- (id)getCommonPlacesWithCompletionNotificationName:(NSString *)completionNotificationName;


#pragma mark- User Booking
- (id)currentbookingOrderWithcompletionNotificationName:(NSString*)completionNotificationName;
- (id)bookingOrderWithJobID:(NSString*)jobID completionNotificationName:(NSString*)completionNotificationName;
- (id)updateJobRatingWithInfo:(NSDictionary*)jobRatingDictionary withJobID:(NSString*)jobID completionNotificationName:(NSString*)completionNotificationName;
-(id)createBookingJobs:(NSArray *)bookingJobs completionNotificationName:(NSString *)completionNotificationName;
- (id)futureBookingsWithCompletionNotificationName:(NSString*)completionNotificationName;
- (id)cancelFutureBookingWithJobID:(NSString*)jobID completionNotificationName:(NSString*)completionNotificationName;
- (id)incrementJobNumberBy:(NSInteger)incrementBy withCompletionNotificationName:(NSString*)completionNotificationName;
- (id)sendCustomerInstruction:(NSString*)instrcutionString toDriverWithJobID:(NSString*)jobID completionNotificationName:(NSString*)completionNotificationName;
- (id)logJobWithJobID:(NSString*)jobID rideNumber:(NSString*)rideNumber notes:(NSString*)notes type:(NSString*)type;
- (id)getAlreadyBookedJobsWithinBookingTime:(NSDate*)bookingTime completionNotificationName:(NSString*)completionNotificationName;

#pragma mark- User Payment
- (void)saveCardWithNumberString:(NSString*)cardNumberString CVCString:(NSString*)cvcString expiryString:(NSString*)expiryString;
- (void)deleteCardWithCardIndex:(NSUInteger)cardIndex;
@end

