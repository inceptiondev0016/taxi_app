//
//  HTDMManager.m
//  HubbleTaxi
//
//  Created by Aamir Javed on 30/01/2014.
//  Copyright (c) 2014 Apponative. All rights reserved.
//

#import "HTDMManager.h"
#import "HTNetworkLayer.h"
#import "HTPermanentStorageDM.h"

static HTDMManager *_sharedManager;
@interface HTDMManager()
{
    
}
@property (nonatomic,retain)HTNetworkLayer *networkLayer;
@property (nonatomic,retain)NSString *currentSecretCode;

- (void)setNotNilObject:(id)object toDictionary:(NSMutableDictionary*)dictionary forKey:(NSString*)key;

- (void)onLogoutResultNotification:(NSNotification*)notification;
- (void)onLoginResultNotification:(NSNotification*)notification;
- (void)onPersonalInformationUpdateResultNotification:(NSNotification*)notification;
- (void)onPersonalInformationDownloadResultNotification:(NSNotification*)notification;
- (void)onDPUpdateResultNotification:(NSNotification*)notification;
- (void)onAcccountInfoUpdateResultNotification:(NSNotification*)notification;
@end


@implementation HTDMManager


+ (HTDMManager*)sharedManager
{
    if(!_sharedManager)
    {
        _sharedManager = [[HTDMManager alloc] init];
        _sharedManager.networkLayer = [[HTNetworkLayer alloc] init];
    }
    return _sharedManager;
}

- (NSString*)dmNotificationNameForNormalNoticationName:(NSString*)notificationName
{
    return [notificationName stringByAppendingString:@"DM"];
}

#pragma mark- User Profile
- (BOOL)userProfileExists
{
    NSDictionary *userProfile = [HTPermanentStorageDM getObjectForApplicationLevelUniqueKey:kLoggedInUserKey];
    BOOL profileExists = NO;
    if ([userProfile objectForKey:kLoggedInUserIDKey] && [userProfile objectForKey:kLoggedInUserDPBlobIDKey]) {
        profileExists = YES;
    }
    return profileExists;
}

- (BOOL)isProfileUpdateNeeded
{
    NSDictionary *userProfile = [HTPermanentStorageDM getObjectForApplicationLevelUniqueKey:kLoggedInUserKey];
    BOOL updateNeeded = YES;
    if ([userProfile objectForKey:kLoggedInUserPersonInfoObjectIDKey]) {
        updateNeeded = NO;
    }
    return updateNeeded;
}

- (id)createApplicationSessionWithCompletionNotificationName:(NSString*)completionNotificationName
{
    return [_networkLayer createApplicationSessionWithAppID:kQBAppID authorizationKey:kQBAuthorizationKeyString authorizationSecret:kQBAuthorizationSecretString completionNotificationName:completionNotificationName];
}

- (id)createUserSessionWithCompletionNotificationName:(NSString*)completionNotificationName
{
    NSDictionary *userProfileDictionary = [HTPermanentStorageDM getObjectForApplicationLevelUniqueKey:kLoggedInUserKey];

    return [self loginWithPhoneNumber:[userProfileDictionary objectForKey:kLoggedInUserPhoneNumberKey] completionNotificationName:completionNotificationName];
}

- (void)sendSecretCodeToPhoneNumber:(NSString*)phoneNumber completionNotificationName:(NSString *)completionNotificationName
{
    //Generate a four digit random number
    int randomNumber8Digit = 1000 + arc4random()%8999;
    _sharedManager.currentSecretCode = [NSString stringWithFormat:@"%d",randomNumber8Digit];

    [_networkLayer sendSecretCode:_currentSecretCode toPhoneNumber:phoneNumber completionNotificationName:completionNotificationName];
}

- (NSString *)currentSecretCode
{
    return _currentSecretCode;
}

- (void)saveDPImagePermanentally:(UIImage*)dpImage
{
    if (dpImage) {
        NSData *imageData = UIImagePNGRepresentation(dpImage);
        NSMutableDictionary *profileDictionary = [NSMutableDictionary dictionaryWithDictionary:[_sharedManager currentUserProfile]];
        [profileDictionary setObject:imageData forKey:kLoggedInUserDPImageIDKey];
        [HTPermanentStorageDM storeObject:profileDictionary forApplicationLevelUniqueKey:kLoggedInUserKey];
    }
}
- (UIImage*)getDpImage
{
    NSMutableDictionary *profileDictionary = [NSMutableDictionary dictionaryWithDictionary:[_sharedManager currentUserProfile]];
    NSData *imageData = [profileDictionary objectForKey:kLoggedInUserDPImageIDKey];
    UIImage *image = nil;
    if (imageData) {
        image = [[UIImage alloc] initWithData:imageData];
    }
    return image;
}

- (id)userWithPhoneNumber:(NSString*)phoneNumber completionNotificationName:(NSString*)completionNotificationName;
{
    return [_networkLayer userWithPhoneNumber:phoneNumber completionNotificationName:completionNotificationName];
}

- (id)signupWithPhoneNumber:(NSString*)phoneNumber completionNotificationName:(NSString*)completionNotificationName;
{
    return [_networkLayer signupWithPhoneNumber:phoneNumber completionNotificationName:completionNotificationName];
}

- (id)loginWithPhoneNumber:(NSString*)phoneNumber completionNotificationName:(NSString*)completionNotificationName
{
    [HTUtility addNotificationObserver:self selector:@selector(onLoginResultNotification:) forNotificationWithName:[_sharedManager dmNotificationNameForNormalNoticationName:completionNotificationName]];
    
    return [_networkLayer loginWithPhoneNumber:phoneNumber completionNotificationName:completionNotificationName];
}

- (id)logoutCurrentUserWithCompletionNotificationName:(NSString *)completionNotificationName
{
    [HTUtility addNotificationObserver:self selector:@selector(onLogoutResultNotification:) forNotificationWithName:[_sharedManager dmNotificationNameForNormalNoticationName:completionNotificationName]];
    return [_networkLayer logoutCurrentUserWithCompletionNotificationName:completionNotificationName];
}

- (NSDictionary*)currentUserProfile
{
    NSDictionary *userProfile = [HTPermanentStorageDM getObjectForApplicationLevelUniqueKey:kLoggedInUserKey];
    return userProfile;
}

- (id)uploadDPImage:(UIImage*)dpImage completionNotificationName:(NSString*)completionNotificationName
{
    [HTUtility addNotificationObserver:self selector:@selector(onDPUpdateResultNotification:) forNotificationWithName:[_sharedManager dmNotificationNameForNormalNoticationName:completionNotificationName]];
    NSData *fileData = UIImagePNGRepresentation(dpImage);
    NSMutableDictionary *dpInfoDictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                             fileData,kDPImageDataKey, nil];

    id blobID = [[_sharedManager currentUserProfile] objectForKey:kLoggedInUserDPBlobIDKey];
    if (blobID) {
        [dpInfoDictionary setObject:blobID forKey:kLoggedInUserDPBlobIDKey];
    }
    return [_networkLayer uploadDPWithInfoDictionary:dpInfoDictionary completionNotificationName:completionNotificationName];
}

- (id)downloadDpImageWithCompletionNotificationName:(NSString*)completionNotificationName;
{
    NSInteger blobID = [[[_sharedManager currentUserProfile] objectForKey:kLoggedInUserDPBlobIDKey] integerValue];
    return [_networkLayer downloadDPImageWithBlobID:blobID completionNotificationName:completionNotificationName];
}

- (id)updateAccountInfoWithDictionay:(NSDictionary*)profileDictionary completionNotificationName:(NSString*)completionNotificationName
{
    [HTUtility addNotificationObserver:self selector:@selector(onAcccountInfoUpdateResultNotification:) forNotificationWithName:[_sharedManager dmNotificationNameForNormalNoticationName:completionNotificationName]];
    return [_networkLayer updateAccountInfoWithDictionay:profileDictionary completionNotificationName:completionNotificationName];
}

- (id)updatePersonInformationWithDictionary:(NSDictionary*)profileDictionary completionNotificationName:(NSString*)completionNotificationName
{
    [HTUtility  addNotificationObserver:self selector:@selector(onPersonalInformationUpdateResultNotification:) forNotificationWithName:[_sharedManager dmNotificationNameForNormalNoticationName:completionNotificationName]];
    return [_networkLayer updatePersonInformationWithDictionary:profileDictionary completionNotificationName:completionNotificationName];
}

- (id)downloadPersonalInformationWithCompletionNotificationName:(NSString*)completionNotificationName
{
    [HTUtility addNotificationObserver:self selector:@selector(onPersonalInformationDownloadResultNotification:) forNotificationWithName:[_sharedManager dmNotificationNameForNormalNoticationName:completionNotificationName]];
    NSInteger userID = [[[_sharedManager currentUserProfile] objectForKey:kLoggedInUserIDKey] integerValue];
    return [_networkLayer downloadPersonalInformationWithUserID:userID completionNotificationName:completionNotificationName];
}

- (id)downlaodDriverProfileWithDriverID:(NSString*)driverID completionNotificationName:(NSString*)completionNotificationName
{
    return [_networkLayer downlaodDriverProfileWithDriverID:driverID completionNotificationName:completionNotificationName];
}

- (void)setNotNilObject:(id)object toDictionary:(NSMutableDictionary*)dictionary forKey:(NSString*)key
{
    if (object && key && object != [NSNull null]) {
        [dictionary setObject:object forKey:key];
    }
}

- (id)getDriverAvailableNearToLocation:(NSString*)locationString completionNotificationName:(NSString *)completionNotificationName
{
    return [_networkLayer getDriverAvailableNearToLocation:locationString completionNotificationName:completionNotificationName];
}

- (void)removeAllDataOfCurrentLoggedInUser
{
    [HTPermanentStorageDM removeObjectForApplicationLevelUniqueKey:kLoggedInUserKey];
}


#pragma mark- User Locaion
-(id)locationAgainstAddress:(NSString*)address inLocality:(NSString*)locality completionNotificationName:(NSString *)completionNotificationName
{
    return [_networkLayer locationAgainstAddress:address inLocality:locality gmapServerAPIKey:kGMServerAPIKey completionNotificationName:completionNotificationName];
}

- (id)searchNearbyPlacesFromLatitude:(float)lat longitude:(float)lng nearbyRadius:(NSUInteger)radius searchType:(NSString*)type completionNotificationName:(NSString *)completionNotificationName
{
    return [_networkLayer searchNearbyPlacesFromLatitude:lat longitude:lng nearbyRadius:radius searchType:type serverAPIKey:kGMServerAPIKey completionNotificationName:completionNotificationName];
}

- (id)livePlaceSearchWithQueryText:(NSString*)queryText fromLatitude:(float)lat longitude:(float)lng nearbyRadius:(NSUInteger)radius completionNotificationName:(NSString *)completionNotificationName;
{
    return [_networkLayer livePlaceSearchWithQueryText:queryText fromLatitude:lat longitude:lng nearbyRadius:radius serverAPIKey:kGMServerAPIKey completionNotificationName:completionNotificationName];
}

- (id)serviceAreaFieldsWithPostalCode:(NSString*)postalCode completionNotificationName:(NSString *)completionNotificationName;
{
    return [_networkLayer serviceAreaFieldsWithPostalCode:postalCode completionNotificationName:completionNotificationName];
}

- (id)directionsOfJourneyWithStartingLocation:(NSString*)startingLocation endingLocation:(NSString*)endingLocation viaRouteLocaton:(NSString*)viaRouteLocation completionNotificationName:(NSString *)completionNotificationName;
{
    return [_networkLayer directionsOfJourneyWithStartingLocation:startingLocation endingLocation:endingLocation viaRouteLocaton:viaRouteLocation serverAPIKey:kGMServerAPIKey completionNotificationName:completionNotificationName];
}

- (void)updateUserSelectedVehicleTypeTo:(NSString*)vehicleType
{
    if (vehicleType.length>0) {
        NSMutableDictionary *profileDictionary = [NSMutableDictionary dictionaryWithDictionary:[_sharedManager currentUserProfile]];
        [profileDictionary setObject:vehicleType forKey:kLoggedInUserSelectedVehicleTypeKey];
        [HTPermanentStorageDM storeObject:profileDictionary forApplicationLevelUniqueKey:kLoggedInUserKey];
    }
}

- (NSString*)userSelectedVehicleType
{
    NSMutableDictionary *profileDictionary = [NSMutableDictionary dictionaryWithDictionary:[_sharedManager currentUserProfile]];
    return [profileDictionary objectForKeyedSubscript:kLoggedInUserSelectedVehicleTypeKey];
}

- (id)getCommonPlacesWithCompletionNotificationName:(NSString *)completionNotificationName
{
    return [_networkLayer getCommonPlacesWithCompletionNotificationName:completionNotificationName];
}

#pragma mark- User Booking
- (id)currentbookingOrderWithcompletionNotificationName:(NSString*)completionNotificationName
{
    NSInteger userID = [[[_sharedManager currentUserProfile] objectForKey:kLoggedInUserIDKey] integerValue];
    return [_networkLayer bookingOrderWithUserId:userID completionNotificationName:completionNotificationName];
}

- (id)bookingOrderWithJobID:(NSString*)jobID completionNotificationName:(NSString*)completionNotificationName
{
    return [_networkLayer bookingOrderWithJobID:jobID completionNotificationName:completionNotificationName];
}


- (id)updateJobRatingWithInfo:(NSDictionary*)jobRatingDictionary withJobID:(NSString*)jobID completionNotificationName:(NSString*)completionNotificationName
{
    NSInteger userID = [[[_sharedManager currentUserProfile] objectForKey:kLoggedInUserIDKey] integerValue];
    return [_networkLayer updateJobRatingWithInfo:jobRatingDictionary withJobID:jobID userID:userID completionNotificationName:completionNotificationName];
}

-(id)createBookingJobs:(NSArray *)bookingJobs completionNotificationName:(NSString *)completionNotificationName
{
    NSInteger userID = [[[_sharedManager currentUserProfile] objectForKey:kLoggedInUserIDKey] integerValue];
    return [_networkLayer createBookingJobs:bookingJobs withUserId:userID completionNotificationName:completionNotificationName];
}

- (id)futureBookingsWithCompletionNotificationName:(NSString*)completionNotificationName
{
    NSInteger userID = [[[_sharedManager currentUserProfile] objectForKey:kLoggedInUserIDKey] integerValue];
    return [_networkLayer futureBookingsWithUserId:userID completionNotificationName:completionNotificationName];
}

- (id)cancelFutureBookingWithJobID:(NSString *)jobID completionNotificationName:(NSString *)completionNotificationName
{
    return [_networkLayer cancelFutureBookingWithJobID:jobID completionNotificationName:completionNotificationName];
}

- (id)incrementJobNumberBy:(NSInteger)incrementBy withCompletionNotificationName:(NSString*)completionNotificationName;
{
    return [_networkLayer incrementJobNumberBy:incrementBy withCompletionNotificationName:completionNotificationName];
}

- (id)sendCustomerInstruction:(NSString*)instrcutionString toDriverWithJobID:(NSString*)jobID completionNotificationName:(NSString*)completionNotificationName
{
    return [_networkLayer sendCustomerInstruction:instrcutionString toDriverWithJobID:jobID completionNotificationName:completionNotificationName];
}

- (id)logJobWithJobID:(NSString*)jobID rideNumber:(NSString*)rideNumber notes:(NSString*)notes type:(NSString*)type
{
    NSDictionary *userProfile = [_sharedManager currentUserProfile];
    NSInteger userID = [[userProfile objectForKey:kLoggedInUserIDKey] integerValue];
    NSString *title = [userProfile objectForKey:kLoggedInUserTitleKey];
    NSString *firstName = [userProfile objectForKey:kLoggedInUserFirstNameKey];
    NSString *lastName = [userProfile objectForKey:kLoggedInUserLastNameKey];
    NSString *fullName = [NSString stringWithFormat:@"%@ %@ %@",title,firstName,lastName];
    NSString *addedBy = [NSString stringWithFormat:@"Customer: %@ (GB-%ld)",fullName,(long)userID];
    return [_networkLayer logJobWithUserID:userID jobID:jobID addedBy:addedBy notes:notes type:type];
}

- (id)getAlreadyBookedJobsWithinBookingTime:(NSDate*)bookingTime completionNotificationName:(NSString*)completionNotificationName
{
    NSDictionary *userProfile = [_sharedManager currentUserProfile];
    NSInteger userID = [[userProfile objectForKey:kLoggedInUserIDKey] integerValue];
    return [_networkLayer getAlreadyBookedJobsWithinBookingTime:bookingTime customerId:userID completionNotificationName:completionNotificationName];
}

#pragma mark- User Payment
- (void)saveCardWithNumberString:(NSString*)cardNumberString CVCString:(NSString*)cvcString expiryString:(NSString*)expiryString
{
    NSMutableDictionary *profileDictionary = [NSMutableDictionary dictionaryWithDictionary:[_sharedManager currentUserProfile]];
    NSArray *existingUserCards = [profileDictionary objectForKey:kLoggedInUserCardsKey];
    NSMutableArray *updatedUserCards = existingUserCards.count>0?[[NSMutableArray alloc] initWithArray:existingUserCards]:[[NSMutableArray alloc] init];
    
    NSArray *duplicateCards = [updatedUserCards valueForKey:kLoggedInUserCardNumberKey];
    if (![duplicateCards containsObject:cardNumberString]) {
        
        NSDictionary *cardInfo = [NSDictionary dictionaryWithObjectsAndKeys:cardNumberString,kLoggedInUserCardNumberKey,cvcString,kLoggedInUserCardCVCKey,expiryString,kLoggedInUserCardExpiryKey, nil];
        [updatedUserCards addObject:cardInfo];
        [profileDictionary setObject:updatedUserCards forKey:kLoggedInUserCardsKey];
        [HTPermanentStorageDM storeObject:profileDictionary forApplicationLevelUniqueKey:kLoggedInUserKey];
    }else
    {
        //Duplicate card, no need to save it again
    }
}

- (void)deleteCardWithCardIndex:(NSUInteger)cardIndex
{
    NSMutableDictionary *profileDictionary = [NSMutableDictionary dictionaryWithDictionary:[_sharedManager currentUserProfile]];
    NSArray *existingUserCards = [profileDictionary objectForKey:kLoggedInUserCardsKey];
    NSMutableArray *updatedUserCards = existingUserCards.count>0?[[NSMutableArray alloc] initWithArray:existingUserCards]:[[NSMutableArray alloc] init];
    if (cardIndex < updatedUserCards.count)
    {
        [updatedUserCards removeObjectAtIndex:cardIndex];
        [profileDictionary setObject:updatedUserCards forKey:kLoggedInUserCardsKey];
        [HTPermanentStorageDM storeObject:profileDictionary forApplicationLevelUniqueKey:kLoggedInUserKey];
    }else
    {
        //No card exists or card is already removed
    }
}

#pragma mark - notificaion methods

- (void)onLoginResultNotification:(NSNotification*)notification;
{
    [HTUtility removeNotificationObserver:self withNotificationName:notification.name];
    NSDictionary *notifyDictionary = [notification userInfo];
    BOOL success = [[notifyDictionary objectForKey:kResponseSuccessKey] boolValue];
    if (success)
    {
        //User session created successfully, save user's profile data [it may be on signup page]
        QBUUser *user = [[notification userInfo] objectForKey:kLoginResultUserKey];
        NSDictionary *currentProfile = [_sharedManager currentUserProfile];
        NSMutableDictionary *userProfileDictionary = Nil;
        if (currentProfile) {
            userProfileDictionary = [NSMutableDictionary dictionaryWithDictionary:currentProfile];
        }
        else{
            userProfileDictionary = [[NSMutableDictionary alloc] init];
        }
        [userProfileDictionary setObject:[NSNumber numberWithLong:user.ID] forKey:kLoggedInUserIDKey];
        [userProfileDictionary setObject:user.phone forKey:kLoggedInUserPhoneNumberKey];
        [userProfileDictionary setObject:[NSNumber numberWithLong:user.blobID] forKey:kLoggedInUserDPBlobIDKey];

        if (user.email) {
            [userProfileDictionary setObject:user.email forKey:kLoggedInUserEmailKey];
        }
        [HTPermanentStorageDM storeObject:userProfileDictionary forApplicationLevelUniqueKey:kLoggedInUserKey];
        PFInstallation *currentInstallation = [PFInstallation currentInstallation];
        currentInstallation[kLoggedInUserIDKey] = [[HTDMManager sharedManager] currentUserProfile][kLoggedInUserIDKey];
        [currentInstallation saveInBackground];

    }else{
        //login failed don't save any data
    }
}

- (void)onLogoutResultNotification:(NSNotification*)notification
{
    [HTUtility removeNotificationObserver:self withNotificationName:notification.name];
    NSDictionary *notifyDictionary = [notification userInfo];
    BOOL success = [[notifyDictionary objectForKey:kResponseSuccessKey] boolValue];
    if (success)
    {
        //logout successdul remove user's profile data
        [HTPermanentStorageDM removeObjectForApplicationLevelUniqueKey:kLoggedInUserKey];
    }else{
        //logout failed don't remove any data
    }
}

- (void)onPersonalInformationUpdateResultNotification:(NSNotification*)notification
{
    
    [HTUtility removeNotificationObserver:self withNotificationName:notification.name];
    NSDictionary *notifyDictionary = [notification userInfo];
    BOOL success = [[notifyDictionary objectForKey:kResponseSuccessKey] boolValue];
    if (success)
    {
        //User updation successfull
        QBCOCustomObject *profilePersonInfoObject = [notifyDictionary objectForKey:kProfilePersonalInformationKey];
        NSMutableDictionary *userProfileDictionary = [NSMutableDictionary dictionaryWithDictionary:[_sharedManager currentUserProfile]];
        [userProfileDictionary setObject:profilePersonInfoObject.ID forKey:kLoggedInUserPersonInfoObjectIDKey];
        
        NSDictionary *fieldsDictioanry = profilePersonInfoObject.fields;
        [self setNotNilObject:[fieldsDictioanry objectForKey:kProfilePersonalInfoTableTitleKey] toDictionary:userProfileDictionary forKey:kLoggedInUserTitleKey];
        [self setNotNilObject:[fieldsDictioanry objectForKey:kProfilePersonalInfoTableFirstNameKey] toDictionary:userProfileDictionary forKey:kLoggedInUserFirstNameKey];
        [self setNotNilObject:[fieldsDictioanry objectForKey:kProfilePersonalInfoTableLastNameKey] toDictionary:userProfileDictionary forKey:kLoggedInUserLastNameKey];
        [self setNotNilObject:[fieldsDictioanry objectForKey:kProfilePersonalInfoTableAddressCountryKey] toDictionary:userProfileDictionary forKey:kLoggedInUserAddressCountryKey];
        [self setNotNilObject:[fieldsDictioanry objectForKey:kProfilePersonalInfoTableAddressPostCodeKey] toDictionary:userProfileDictionary forKey:kLoggedInUserAddressPostCodeKey];
        [self setNotNilObject:[fieldsDictioanry objectForKey:kProfilePersonalInfoTableAddressLine1Key] toDictionary:userProfileDictionary forKey:kLoggedInUserAddressLine1Key];
        [self setNotNilObject:[fieldsDictioanry objectForKey:kProfilePersonalInfoTableAddressLine2Key] toDictionary:userProfileDictionary forKey:kLoggedInUserAddressLine2Key];
        [self setNotNilObject:[fieldsDictioanry objectForKey:kProfilePersonalInfoTableAddressLine3Key] toDictionary:userProfileDictionary forKey:kLoggedInUserAddressLine3Key];
        [self setNotNilObject:[fieldsDictioanry objectForKey:kProfilePersonalInfoTableAddressCityKey] toDictionary:userProfileDictionary forKey:kLoggedInUserAddressCityKey];
        [self setNotNilObject:[fieldsDictioanry objectForKey:kProfilePersonalInfoTableAddressStateKey] toDictionary:userProfileDictionary forKey:kLoggedInUserAddressStateKey];
        
        [self setNotNilObject:[fieldsDictioanry objectForKey:kProfilePersonalInfoTableHobbiesKey] toDictionary:userProfileDictionary forKey:kLoggedInUserHobbiesKey];

        [HTPermanentStorageDM storeObject:userProfileDictionary forApplicationLevelUniqueKey:kLoggedInUserKey];
    }else{
        //updation failed don't save any data
    }
}

- (void)onPersonalInformationDownloadResultNotification:(NSNotification*)notification
{
    [HTUtility removeNotificationObserver:self withNotificationName:notification.name];
    NSDictionary *notifyDictionary = [notification userInfo];
    BOOL success = [[notifyDictionary objectForKey:kResponseSuccessKey] boolValue];
    if (success)
    {
        NSMutableDictionary *profileDictionary = [NSMutableDictionary dictionaryWithDictionary:[_sharedManager currentUserProfile]];
        NSString *profilePersonalInfoObjectID = [[notifyDictionary  objectForKey:kProfilePersonalInformationKey] objectForKey:kLoggedInUserPersonInfoObjectIDKey];
        if (profilePersonalInfoObjectID) {
            [profileDictionary setObject:profilePersonalInfoObjectID forKey:kLoggedInUserPersonInfoObjectIDKey];
            NSDictionary *fieldsDictioanry =  [notifyDictionary  objectForKey:kProfilePersonalInformationKey];
            NSMutableDictionary *userProfileDictionary = profileDictionary;
            [self setNotNilObject:[fieldsDictioanry objectForKey:kLoggedInUserTitleKey] toDictionary:userProfileDictionary forKey:kLoggedInUserTitleKey];
            [self setNotNilObject:[fieldsDictioanry objectForKey:kLoggedInUserFirstNameKey] toDictionary:userProfileDictionary forKey:kLoggedInUserFirstNameKey];
            [self setNotNilObject:[fieldsDictioanry objectForKey:kLoggedInUserLastNameKey] toDictionary:userProfileDictionary forKey:kLoggedInUserLastNameKey];
            [self setNotNilObject:[fieldsDictioanry objectForKey:kLoggedInUserAddressCountryKey] toDictionary:userProfileDictionary forKey:kLoggedInUserAddressCountryKey];
            [self setNotNilObject:[fieldsDictioanry objectForKey:kLoggedInUserAddressPostCodeKey] toDictionary:userProfileDictionary forKey:kLoggedInUserAddressPostCodeKey];
            [self setNotNilObject:[fieldsDictioanry objectForKey:kLoggedInUserAddressLine1Key] toDictionary:userProfileDictionary forKey:kLoggedInUserAddressLine1Key];
            [self setNotNilObject:[fieldsDictioanry objectForKey:kLoggedInUserAddressLine2Key] toDictionary:userProfileDictionary forKey:kLoggedInUserAddressLine2Key];
            [self setNotNilObject:[fieldsDictioanry objectForKey:kLoggedInUserAddressLine3Key] toDictionary:userProfileDictionary forKey:kLoggedInUserAddressLine3Key];
            [self setNotNilObject:[fieldsDictioanry objectForKey:kLoggedInUserAddressCityKey] toDictionary:userProfileDictionary forKey:kLoggedInUserAddressCityKey];
            [self setNotNilObject:[fieldsDictioanry objectForKey:kLoggedInUserAddressStateKey] toDictionary:userProfileDictionary forKey:kLoggedInUserAddressStateKey];
            
            [self setNotNilObject:[fieldsDictioanry objectForKey:kLoggedInUserHobbiesKey] toDictionary:userProfileDictionary forKey:kLoggedInUserHobbiesKey];

            
            [HTPermanentStorageDM storeObject:profileDictionary forApplicationLevelUniqueKey:kLoggedInUserKey];
        }
    }
    else{
        //No data to save
    }
}

- (void)onDPUpdateResultNotification:(NSNotification*)notification
{
    [HTUtility removeNotificationObserver:self withNotificationName:notification.name];
    NSDictionary *notifyDictionary = [notification userInfo];
    BOOL success = [[notifyDictionary objectForKey:kResponseSuccessKey] boolValue];
    if (success)
    {
        id BlobID = [notifyDictionary objectForKey:kLoggedInUserDPBlobIDKey];
        if (BlobID) {
            NSMutableDictionary *profileDictionary = [NSMutableDictionary dictionaryWithDictionary: [_sharedManager currentUserProfile]];
            [profileDictionary setObject:BlobID forKey:kLoggedInUserDPBlobIDKey];
            [HTPermanentStorageDM storeObject:profileDictionary forApplicationLevelUniqueKey:kLoggedInUserKey];
        }
    }
    else{
        //No data to save
    }
}

- (void)onAcccountInfoUpdateResultNotification:(NSNotification*)notification
{
    [HTUtility removeNotificationObserver:self withNotificationName:notification.name];
    NSDictionary *profileUploadResultDictionary = [notification userInfo];
    BOOL success = [[profileUploadResultDictionary objectForKey:kResponseSuccessKey] boolValue];
    if (success)
    {
        QBUUser *user = [[notification userInfo] objectForKey:kLoginResultUserKey];
        NSMutableDictionary *userProfileDictionary = [NSMutableDictionary dictionaryWithDictionary:[_sharedManager currentUserProfile]];
        [userProfileDictionary setObject:[NSNumber numberWithLong:user.ID] forKey:kLoggedInUserIDKey];
        [userProfileDictionary setObject:user.phone forKey:kLoggedInUserPhoneNumberKey];
        [userProfileDictionary setObject:[NSNumber numberWithLong:user.blobID] forKey:kLoggedInUserDPBlobIDKey];
        
        if (user.email) {
            [userProfileDictionary setObject:user.email forKey:kLoggedInUserEmailKey];
        }
        [HTPermanentStorageDM storeObject:userProfileDictionary forApplicationLevelUniqueKey:kLoggedInUserKey];
    }else{
        //Updation failed, no data to save
    }
}

@end
