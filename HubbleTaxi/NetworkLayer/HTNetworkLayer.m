//
//  HTNetworkLayer.m
//  HubbleTaxi
//
//  Created by Aamir Javed on 30/01/2014.
//  Copyright (c) 2014 Apponative. All rights reserved.
//

#import "HTNetworkLayer.h"
#import "AFNetworking.h"
#import "HTDMManager.h"

@interface HTNetworkLayer()<QBActionStatusDelegate>
{
    
}

@end


@implementation HTNetworkLayer


#pragma mark - User Profile
- (NSObject<Cancelable>*)createApplicationSessionWithAppID:(NSUInteger)appID authorizationKey:(NSString*)authorizationKey authorizationSecret:(NSString*)authorizationSecret completionNotificationName:(NSString *)completionNotificationName
{
    [QBSettings setApplicationID:appID];
    [QBSettings setAuthorizationKey:authorizationKey];
    [QBSettings setAuthorizationSecret:authorizationSecret];
    [QBSettings useHTTPS:YES];
    
    return [QBAuth createSessionWithDelegate:self context:(__bridge void*)completionNotificationName];
}

- (void)sendSecretCode:(NSString *)secretCode toPhoneNumber:(NSString *)phoneNumber completionNotificationName:(NSString *)completionNotificationName
{
    //Send secret key to phone number
    NSString *getURLString = [NSString stringWithFormat:@"http://api.clickatell.com/http/sendmsg?user=Hubble&password=App0native..&api_id=3466007&from=HubbleGo&to=%@&text=Your HubbleGo activation code is: %@",phoneNumber,secretCode];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    getURLString = [getURLString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];

    [manager GET:getURLString parameters:nil success:nil failure:nil];//notification will be fired on success/failure [Custom implementation in AFNetworking]
}

- (NSObject<Cancelable>*)signupWithPhoneNumber:(NSString*)phoneNumber completionNotificationName:(NSString*)completionNotificationName
{
    QBUUser *currentUser = [QBUUser user];
    currentUser.phone = phoneNumber;
    currentUser.login = phoneNumber;
    currentUser.password = kQBDefaultPassword;
    currentUser.website = [HTUtility currentDeviceID];
    currentUser.tags = [NSMutableArray arrayWithObject:kUserTypeCustomerString];
    return [QBUsers signUp:currentUser delegate:self context:(__bridge void*)completionNotificationName];
}

- (NSObject<Cancelable>*)userWithPhoneNumber:(NSString*)phoneNumber completionNotificationName:(NSString*)completionNotificationName
{
    return [QBUsers userWithLogin:phoneNumber delegate:self context:(__bridge void*)completionNotificationName];
}

- (NSObject<Cancelable>*)loginWithPhoneNumber:(NSString*)phoneNumber completionNotificationName:(NSString*)completionNotificationName
{
    return [QBUsers logInWithUserLogin:phoneNumber password:kQBDefaultPassword delegate:self context:(__bridge void*)completionNotificationName];
}

- (NSObject<Cancelable>*)logoutCurrentUserWithCompletionNotificationName:(NSString *)completionNotificationName
{
    return [QBUsers logOutWithDelegate:self context:(__bridge void*)completionNotificationName];
}

- (NSObject<Cancelable>*)uploadDPWithInfoDictionary:(NSDictionary*)dpInfoDictionary completionNotificationName:(NSString*)completionNotificationName
{
    id blobID = [dpInfoDictionary objectForKey:kLoggedInUserDPBlobIDKey];
    NSData *dpImageData = [dpInfoDictionary objectForKey:kDPImageDataKey];
    NSString *fileName = @"DP Image";
    NSString *contentType = @"image/png";
    if ([blobID integerValue]) {
        QBCBlob *blob = [QBCBlob blob];
        blob.ID = [blobID integerValue];
        blob.name = fileName;
        blob.contentType = contentType;
        return [QBContent TUpdateFileWithData:dpImageData file:blob delegate:self context:(__bridge void*)completionNotificationName];
    }else
    {
       return  [QBContent TUploadFile:dpImageData fileName:fileName contentType:contentType  isPublic:NO delegate:self context:(__bridge void*)completionNotificationName];
    }
    return nil;
}

- (NSObject<Cancelable>*)downloadDPImageWithBlobID:(NSUInteger)blobID completionNotificationName:(NSString*)completionNotificationName;
{
    return [QBContent TDownloadFileWithBlobID:blobID delegate:self context:(__bridge void*)completionNotificationName];
}

- (NSObject<Cancelable>*)updateAccountInfoWithDictionay:(NSDictionary*)profileDictionary completionNotificationName:(NSString*)completionNotificationName
{
    QBUUser *currentUser = [QBUUser user];
    currentUser.ID = [[profileDictionary objectForKey:kLoggedInUserIDKey] integerValue];
    NSUInteger blobID = [[profileDictionary objectForKey:kLoggedInUserDPBlobIDKey] integerValue];
    if (blobID) {
        currentUser.blobID = blobID;
    }
    NSString *email = [profileDictionary objectForKey:kLoggedInUserEmailKey];
    if (email) {
        currentUser.email = email;
    }
    NSString *deviceID = [profileDictionary objectForKey:kLoggedInUserDeviceKey];
    if (deviceID) {
        currentUser.website = deviceID;
    }
    return [QBUsers updateUser:currentUser delegate:self context:(__bridge void*)completionNotificationName];
}

- (NSObject<Cancelable>*)updatePersonInformationWithDictionary:(NSDictionary*)profileDictionary completionNotificationName:(NSString*)completionNotificationName
{
    QBCOCustomObject *personalInfoObject = [QBCOCustomObject customObject];
    personalInfoObject.className = @"UserProfile";
    personalInfoObject.userID = [[profileDictionary objectForKey:kLoggedInUserIDKey] integerValue];
    NSString *nameTitle = [profileDictionary objectForKey:kLoggedInUserTitleKey];
    NSString *firstName = [profileDictionary objectForKey:kLoggedInUserFirstNameKey];
    NSString *lastName = [profileDictionary objectForKey:kLoggedInUserLastNameKey];
    NSString *addressCountry = [profileDictionary objectForKey:kLoggedInUserAddressCountryKey];
    NSString *addressPostCode = [profileDictionary objectForKey:kLoggedInUserAddressPostCodeKey];
    NSString *addressLine1 = [profileDictionary objectForKey:kLoggedInUserAddressLine1Key];
    NSString *addressLine2 = [profileDictionary objectForKey:kLoggedInUserAddressLine2Key];
    NSString *addressLine3 = [profileDictionary objectForKey:kLoggedInUserAddressLine3Key];
    NSString *addressCity = [profileDictionary objectForKey:kLoggedInUserAddressCityKey];
    NSString *addressState = [profileDictionary objectForKey:kLoggedInUserAddressStateKey];
    NSString *gender = [profileDictionary objectForKey:kLoggedInUserGenderKey];
    NSString *birthday = [profileDictionary objectForKey:kLoggedInUserBirthdayKey];
    NSArray *facebookPageLikes = [profileDictionary objectForKey:kLoggedInUserFacebookPageLikesKey];
    
    NSArray *hobbies = [profileDictionary objectForKey:kLoggedInUserHobbiesKey];

    NSMutableDictionary *fieldsDictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       nameTitle,kProfilePersonalInfoTableTitleKey,
                                       firstName, kProfilePersonalInfoTableFirstNameKey,
                                       lastName, kProfilePersonalInfoTableLastNameKey,
                                       addressCountry, kProfilePersonalInfoTableAddressCountryKey,
                                             addressPostCode, kProfilePersonalInfoTableAddressPostCodeKey,
                                             addressLine1, kProfilePersonalInfoTableAddressLine1Key,
                                             addressLine2, kProfilePersonalInfoTableAddressLine2Key,
                                             addressLine3, kProfilePersonalInfoTableAddressLine3Key,
                                             addressCity, kProfilePersonalInfoTableAddressCityKey,
                                             addressState, kProfilePersonalInfoTableAddressStateKey,
                                       hobbies,kProfilePersonalInfoTableHobbiesKey
                                       , nil];
    if(gender)
    {
        [fieldsDictionary setObject:gender forKey:kLoggedInUserGenderKey];
    }
    if (birthday) {
        [fieldsDictionary setObject:birthday forKey:kLoggedInUserBirthdayKey];
    }
    if (facebookPageLikes) {
        [fieldsDictionary setObject:facebookPageLikes forKey:kLoggedInUserFacebookPageLikesKey];
    }
    personalInfoObject.fields = fieldsDictionary;
    
    NSString *ID = [profileDictionary objectForKey:kLoggedInUserPersonInfoObjectIDKey];
    if (ID.length > 0) {
        personalInfoObject.ID = ID;
        return [QBCustomObjects updateObject:personalInfoObject delegate:self context:(__bridge void*)completionNotificationName];
    }else
    {
        return [QBCustomObjects createObject:personalInfoObject delegate:self context:(__bridge void*)completionNotificationName];
    }
    return nil;
}

- (NSObject<Cancelable>*)downloadPersonalInformationWithUserID:(NSInteger)userID completionNotificationName:(NSString*)completionNotificationName
{
    NSMutableDictionary *getRequest = [NSMutableDictionary dictionary];
    [getRequest setObject:[NSNumber numberWithLong:userID] forKey:@"user_id"];
    return [QBCustomObjects objectsWithClassName:@"UserProfile" extendedRequest:getRequest delegate:self context:(__bridge void*)completionNotificationName];
}

- (NSObject<Cancelable>*)downlaodDriverProfileWithDriverID:(NSString*)driverID completionNotificationName:(NSString*)completionNotificationName
{
    return [QBCustomObjects objectWithClassName:@"Drivers" ID:driverID delegate:self context:(__bridge void*)completionNotificationName];
}

- (NSObject<Cancelable>*)getDriverAvailableNearToLocation:(NSString*)locationString completionNotificationName:(NSString *)completionNotificationName
{
    NSMutableDictionary *getRequest = [NSMutableDictionary dictionary];
    [getRequest setObject:@"Online" forKey:@"driver_status"];
    [getRequest setObject:locationString forKey:@"location_coordinates[near]"];
    return [QBCustomObjects objectsWithClassName:@"Drivers" extendedRequest:getRequest delegate:self context:(__bridge void*)completionNotificationName];
}

#pragma mark - User Location
- (id)locationAgainstAddress:(NSString*)address inLocality:(NSString*)locality gmapServerAPIKey:(NSString*)serverAPIKey completionNotificationName:(NSString *)completionNotificationName
{
    NSString *componentFilteringString = [NSString stringWithFormat:@"&components=country:UK%@",locality.length>0?[NSString stringWithFormat:@"|locality:%@",[locality stringByReplacingOccurrencesOfString:@" " withString:@"%20"]]:@""];
    NSString *getURLString = [NSString stringWithFormat:@"https://maps.google.com/maps/api/geocode/json?address=%@&sensor=true%@&key=%@",[[address stringByReplacingOccurrencesOfString:@" " withString:@"+"] stringByReplacingOccurrencesOfString:@"\n" withString:@""],componentFilteringString,serverAPIKey];
    getURLString = [getURLString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];

    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:getURLString parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        //Success
        NSDictionary *addressDictionary = responseObject;
        NSArray *resultsArray = [addressDictionary objectForKey:@"results"];
        float lat = 0,lng = 0;
        if (resultsArray.count > 0)
        {
            NSDictionary *locationCoorDictionary = [[[resultsArray firstObject] objectForKey:@"geometry"] objectForKey:@"location"];
            lat = [[locationCoorDictionary objectForKey:@"lat"] floatValue];
            lng = [[locationCoorDictionary objectForKey:@"lng"] floatValue];
        }else
        {
            lat = 500;//any value greater than 180;
        }
        NSMutableDictionary *notifyDictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                 [NSNumber numberWithBool:YES],
                                                 kResponseSuccessKey,
                                                 [NSNumber numberWithFloat:lat],
                                                 kLatitudeKey,
                                                 [NSNumber numberWithFloat:lng],
                                                 kLongitudeKey
                                                 , nil];
        [HTUtility postNotificationWithName:completionNotificationName userInfo:notifyDictionary];

    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        //Failure
        NSMutableDictionary *notifyDictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                 [NSNumber numberWithBool:NO],
                                                 kResponseSuccessKey,
                                                 error?error.description:@"",
                                                 kResponseErrorKey
                                                 , nil];
        [HTUtility postNotificationWithName:completionNotificationName userInfo:notifyDictionary];

    }];
    return manager.operationQueue;
}

- (id)searchNearbyPlacesFromLatitude:(float)lat longitude:(float)lng nearbyRadius:(NSUInteger)radius searchType:(NSString*)type serverAPIKey:(NSString*)serverAPIKey completionNotificationName:(NSString *)completionNotificationName
{
    
    NSString *getURLString = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=%f,%f&sensor=true",lat,lng];
    if (type.length>0) {
        getURLString = [getURLString stringByAppendingString:[NSString stringWithFormat:@"&rankby=distance&types=%@",type]];
    }
    else{
        getURLString = [getURLString stringByAppendingString:[NSString stringWithFormat:@"&radius=%lu",(unsigned long)radius]];
    }
    getURLString = [getURLString stringByAppendingString:[NSString stringWithFormat:@"&key=%@",serverAPIKey]];
    getURLString = [getURLString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];

    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:getURLString parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject)
    {
        //Success
        NSArray *searchedPlaces = [responseObject objectForKey:@"results"];
        NSMutableDictionary *notifyDictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                 [NSNumber numberWithBool:YES],
                                                 kResponseSuccessKey,
                                                 searchedPlaces.count>0?searchedPlaces:@"",
                                                 kSearchedPlacesKey
                                                 , nil];
        [HTUtility postNotificationWithName:completionNotificationName userInfo:notifyDictionary];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        //Failure
        NSMutableDictionary *notifyDictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                 [NSNumber numberWithBool:NO],
                                                 kResponseSuccessKey,
                                                 error?error.description:@"",
                                                 kResponseErrorKey
                                                 , nil];
        [HTUtility postNotificationWithName:completionNotificationName userInfo:notifyDictionary];
    }];
    
    return manager.operationQueue;
}

- (id)livePlaceSearchWithQueryText:(NSString*)queryText fromLatitude:(float)lat longitude:(float)lng nearbyRadius:(NSUInteger)radius serverAPIKey:(NSString*)serverAPIKey completionNotificationName:(NSString *)completionNotificationName
{
    NSString *localSearchString = radius==0?@"":[NSString stringWithFormat:@"&location=%f,%f&radius=%lu",lat,lng,(unsigned long)radius];
    NSString *getURLString = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/textsearch/json?query=%@%@&sensor=true&key=%@",[[queryText stringByReplacingOccurrencesOfString:@" " withString:@"%20"] stringByReplacingOccurrencesOfString:@"\n" withString:@""],localSearchString,serverAPIKey];
    getURLString = [getURLString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];

    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:getURLString parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         //Success
         NSArray *searchedPlaces = [responseObject objectForKey:@"results"];
         NSMutableDictionary *notifyDictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                  [NSNumber numberWithBool:YES],
                                                  kResponseSuccessKey,
                                                  searchedPlaces.count>0?searchedPlaces:@"",
                                                  kSearchedPlacesKey
                                                  , nil];
         [HTUtility postNotificationWithName:completionNotificationName userInfo:notifyDictionary];
     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         //Failure
         NSMutableDictionary *notifyDictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                  [NSNumber numberWithBool:NO],
                                                  kResponseSuccessKey,
                                                  error?error.code==-999?kCancelString:error.description:@"",
                                                  kResponseErrorKey
                                                  , nil];
         [HTUtility postNotificationWithName:completionNotificationName userInfo:notifyDictionary];
     }];
    
    return manager.operationQueue;
}

- (NSObject<Cancelable>*)serviceAreaFieldsWithPostalCode:(NSString*)postalCode completionNotificationName:(NSString *)completionNotificationName;
{
    NSMutableDictionary *getRequest = [NSMutableDictionary dictionary];
    [getRequest setObject:postalCode forKey:kServiceAreaPostalCodeKey];
    return [QBCustomObjects objectsWithClassName:@"ServiceArea" extendedRequest:getRequest delegate:self context:(__bridge void*)completionNotificationName];
}

- (id)directionsOfJourneyWithStartingLocation:(NSString*)startingLocation endingLocation:(NSString*)endingLocation viaRouteLocaton:(NSString*)viaRouteLocation serverAPIKey:(NSString*)serverAPIKey completionNotificationName:(NSString *)completionNotificationName;
{
    NSString *viaRoute = @"";
    if (viaRouteLocation.length>0) {
        viaRoute = [NSString stringWithFormat:@"&waypoints=%@",viaRouteLocation];
        viaRoute = [viaRoute stringByReplacingOccurrencesOfString:@" " withString:@""];
        viaRoute = [viaRoute stringByReplacingOccurrencesOfString:@"\n" withString:@""];        
    }
    NSString *getURLString = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/directions/json?origin=%@&destination=%@%@&sensor=true&key=%@",startingLocation,endingLocation,viaRoute,serverAPIKey];
    getURLString = [getURLString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];

    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:getURLString parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         //Success
         NSArray *directionRoutes = [responseObject objectForKey:@"routes"];
         NSMutableDictionary *notifyDictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                  [NSNumber numberWithBool:YES],
                                                  kResponseSuccessKey,
                                                  directionRoutes.count>0?directionRoutes:[NSArray array],
                                                  kMapDirectionsKey
                                                  , nil];
         [HTUtility postNotificationWithName:completionNotificationName userInfo:notifyDictionary];
     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         //Failure
         NSMutableDictionary *notifyDictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                  [NSNumber numberWithBool:NO],
                                                  kResponseSuccessKey,
                                                  error?error.code==-999?kCancelString:error.description:@"",
                                                  kResponseErrorKey
                                                  , nil];
         [HTUtility postNotificationWithName:completionNotificationName userInfo:notifyDictionary];
     }];
    
    return manager.operationQueue;
}

- (NSObject<Cancelable>*)getCommonPlacesWithCompletionNotificationName:(NSString *)completionNotificationName
{
    return [QBCustomObjects objectsWithClassName:@"CommonPlaces" delegate:self context:(__bridge void*)completionNotificationName];
}

#pragma mark- User Booking
- (NSObject<Cancelable>*)bookingOrderWithUserId:(NSUInteger)userID completionNotificationName:(NSString*)completionNotificationName
{
    NSMutableDictionary *getRequest = [NSMutableDictionary dictionary];
  //  [getRequest setObject:@"Driver-En-Route,Reached-Pickup,Authorising-payment" forKey:@"job_status[or]"];
    [getRequest setObject:@"urgent" forKey:@"booking_type"];
    [getRequest setObject:@"Yes" forKey:@"processOk[ne]"];
    [getRequest setObject:@"Completed,No Show,Cancelled" forKey:@"job_status[nin]"];
    [getRequest setObject:[NSNumber numberWithLong:userID] forKey:@"customer_id"];
    return [QBCustomObjects objectsWithClassName:@"Jobs_dispatch" extendedRequest:getRequest delegate:self context:(__bridge void*)completionNotificationName];
}

- (NSObject<Cancelable>*)bookingOrderWithJobID:(NSString*)jobID completionNotificationName:(NSString*)completionNotificationName
{
    NSMutableDictionary *getRequest = [NSMutableDictionary dictionary];
    [getRequest setObject:jobID forKey:@"_id"];

    return [QBCustomObjects objectsWithClassName:@"Jobs_dispatch" extendedRequest:getRequest delegate:self context:(__bridge void*)completionNotificationName];
}


- (NSObject<Cancelable>*)updateJobRatingWithInfo:(NSDictionary*)jobRatingDictionary withJobID:(NSString*)jobID userID:(NSUInteger)userID completionNotificationName:(NSString*)completionNotificationName;
{
    QBCOCustomObject *jobObject = [QBCOCustomObject customObject];
    jobObject.className = @"Jobs_dispatch";
    jobObject.ID = jobID;
    NSMutableDictionary *jobDictionary = [NSMutableDictionary dictionaryWithDictionary:jobRatingDictionary];
    jobDictionary[@"customer_id"] = [NSNumber numberWithInteger:userID];
    jobObject.fields = jobDictionary;
    return [QBCustomObjects updateObject:jobObject delegate:self context:(__bridge void*)completionNotificationName];
}

- (NSObject<Cancelable>*)createBookingJobs:(NSArray*)bookingJobs withUserId:(NSUInteger)userID completionNotificationName:(NSString*)completionNotificationName
{
    NSMutableArray *customObjcts = [[NSMutableArray alloc] init];
    for (NSMutableDictionary *fields in bookingJobs) {
        QBCOCustomObject *jobObject = [QBCOCustomObject customObject];
        jobObject.className = @"Jobs_dispatch";
        jobObject.userID = userID;
        [fields setObject:[NSNumber numberWithInteger:userID] forKey:@"customer_id"];
        jobObject.fields = fields;
        [customObjcts addObject:jobObject];
    }
    return [QBCustomObjects createObjects:customObjcts className:@"Jobs_dispatch" delegate:self context:(__bridge void*)completionNotificationName];
}

- (NSObject<Cancelable>*)futureBookingsWithUserId:(NSUInteger)userID completionNotificationName:(NSString*)completionNotificationName
{
    NSMutableDictionary *getRequest = [NSMutableDictionary dictionary];
    [getRequest setObject:@"future" forKey:@"booking_type"];
    [getRequest setObject:@"booking_date" forKey:@"sort_desc"];
    [getRequest setObject:[NSNumber numberWithLong:userID] forKey:@"customer_id"];
    return [QBCustomObjects objectsWithClassName:@"Jobs_dispatch" extendedRequest:getRequest delegate:self context:(__bridge void*)completionNotificationName];
}

- (NSObject<Cancelable>*)cancelFutureBookingWithJobID:(NSString*)jobID completionNotificationName:(NSString*)completionNotificationName
{
    QBCOCustomObject *jobObject = [QBCOCustomObject customObject];
    jobObject.className = @"Jobs_dispatch";
    jobObject.ID = jobID;
    jobObject.fields = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"Cancelled", @"job_status", @"Cancelled", @"booking_type",nil];
    return [QBCustomObjects updateObject:jobObject delegate:self context:(__bridge void*)completionNotificationName];
}

- (NSObject<Cancelable>*)incrementJobNumberBy:(NSInteger)incrementBy withCompletionNotificationName:(NSString*)completionNotificationName;
{
    NSMutableDictionary *getRequest = [NSMutableDictionary dictionary];
    [getRequest setObject:[NSNumber numberWithInteger:incrementBy] forKey:@"inc[jobNumber]"];
    QBCOCustomObject *jobObject = [QBCOCustomObject customObject];
    jobObject.className = @"JobNumber";
    jobObject.ID = @"540d8bdb535c12357a1059a6";
    jobObject.fields = getRequest;
    return [QBCustomObjects updateObject:jobObject delegate:self context:(__bridge void*)completionNotificationName];
}

- (NSObject<Cancelable>*)sendCustomerInstruction:(NSString*)instrcutionString toDriverWithJobID:(NSString*)jobID completionNotificationName:(NSString*)completionNotificationName
{
    NSMutableDictionary *getRequest = [NSMutableDictionary dictionary];
    [getRequest setObject:instrcutionString forKey:@"customerInstruction"];
    QBCOCustomObject *jobObject = [QBCOCustomObject customObject];
    jobObject.className = @"Jobs_dispatch";
    jobObject.ID = jobID;
    jobObject.fields = getRequest;
    return [QBCustomObjects updateObject:jobObject delegate:self context:(__bridge void*)completionNotificationName];
}

- (NSObject<Cancelable>*)logJobWithUserID:(NSUInteger)userID jobID:(NSString*)jobID addedBy:(NSString*)addedBy notes:(NSString*)notes type:(NSString*)type
{
    //job id, created
    QBCOCustomObject *jobObject = [QBCOCustomObject customObject];
    jobObject.className = @"Logs";
    jobObject.userID = userID;
    jobObject.fields = [NSMutableDictionary dictionaryWithDictionary:@{@"customer_id": [NSNumber numberWithInteger:userID],@"added_by":addedBy,@"job_id":jobID,@"notes":notes,@"type":type}];
    return [QBCustomObjects createObject:jobObject delegate:self context:@"jobLog"];
}

- (NSObject<Cancelable>*)getAlreadyBookedJobsWithinBookingTime:(NSDate*)bookingTime customerId:(NSUInteger)customerID completionNotificationName:(NSString*)completionNotificationName
{
    NSDateFormatter *refDateFormatter = [[NSDateFormatter alloc] init];
    [refDateFormatter setDateFormat:@"dd-MM-yyyy HH:mm"];
    NSDate *refDate = [refDateFormatter dateFromString:kReferenceDateString];

    NSNumber *maxDateTime = [NSNumber numberWithFloat:[[bookingTime dateByAddingTimeInterval:2*60*60] timeIntervalSinceDate:refDate]];
    NSNumber *minDateTime =[NSNumber numberWithFloat:[[bookingTime dateByAddingTimeInterval:-2*60*60] timeIntervalSinceDate:refDate]];
    
    
    NSMutableDictionary *getRequest = [NSMutableDictionary dictionary];
    [getRequest setObject:@"urgent" forKey:@"booking_type"];
    [getRequest setObject:@"Completed,No Show,Cancelled" forKey:@"job_status[nin]"];
    [getRequest setObject:maxDateTime forKey:@"bookingDateInSeconds[lt]"];
    [getRequest setObject:minDateTime forKey:@"bookingDateInSeconds[gt]"];


    [getRequest setObject:[NSNumber numberWithLong:customerID] forKey:@"customer_id"];
    return [QBCustomObjects objectsWithClassName:@"Jobs_dispatch" extendedRequest:getRequest delegate:self context:(__bridge void*)completionNotificationName];
}

#pragma mark - Quickblox delegate methods

- (void)completedWithResult:(Result *)result context:(void *)contextInfo
{
    NSMutableDictionary *notifyDictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                             [NSNumber numberWithBool:result.success],
                                             kResponseSuccessKey,
                                             result.errors.count>0?result.errors[0]:@"",
                                             kResponseErrorKey,
                                             [NSNumber numberWithLong:result.status],
                                             kResponseStatusKey
                                             , nil];
    if (result.success)
    {
        if ([result isMemberOfClass:QBUUserLogInResult.class] || [result isMemberOfClass:QBUUserResult.class])
        {
            QBUUser *user = ((QBUUserResult*)result).user;
            if ([user.tags containsObject:kUserTypeCustomerString]) {
                [notifyDictionary setObject:user?user:@"" forKey:kLoginResultUserKey];
            }else
            {
                [notifyDictionary setObject:[NSNumber numberWithBool:FALSE] forKey:kResponseSuccessKey];
            }
        }
        else if ([result isMemberOfClass:QBCFileDownloadTaskResult.class])
        {
            UIImage *image = [UIImage imageWithData:((QBCFileDownloadTaskResult*)result).file];
            [notifyDictionary setObject:image forKey:kLoggedInUserDPImageIDKey];
        }
        else if([result isMemberOfClass:QBCFileUploadTaskResult.class])
        {
            NSInteger blobID = ((QBCFileUploadTaskResult*)result).uploadedBlob.ID;
            [notifyDictionary setObject:[NSNumber numberWithLong:blobID] forKey:kLoggedInUserDPBlobIDKey];
        }
        else if ([result isMemberOfClass:QBCOCustomObjectResult.class])
        {
            QBCOCustomObject *customObject = ((QBCOCustomObjectResult*)result).object;
            if ([customObject.className isEqualToString:@"Drivers"])
            {
                [notifyDictionary setObject:customObject.fields?customObject.fields:[NSDictionary dictionary] forKey:kDriverObjectFieldsKey];
            }else if ([customObject.className isEqualToString:@"JobNumber"])
            {
                [notifyDictionary setObject:customObject.fields?customObject.fields:[NSDictionary dictionary] forKey:kJobNumberObjectKey];
            }
            else
            {
                [notifyDictionary setObject:customObject?customObject:@"" forKey:kProfilePersonalInformationKey];
            }
        }
        else if ([result isMemberOfClass:QBCOCustomObjectPagedResult.class])
        {
            NSArray *customObjects = ((QBCOCustomObjectPagedResult*)result).objects;
            if (customObjects.count > 0)
            {
                QBCOCustomObject *customObject = [customObjects firstObject];
                if ([customObject.className isEqualToString:@"UserProfile"])
                {
                    QBCOCustomObject *personalInfoObject = customObject;
                    NSString *nameTitle = [personalInfoObject.fields objectForKey:kProfilePersonalInfoTableTitleKey];
                    NSString *firstName = [personalInfoObject.fields objectForKey:kProfilePersonalInfoTableFirstNameKey];
                    NSString *lastName = [personalInfoObject.fields objectForKey:kProfilePersonalInfoTableLastNameKey];
                    NSString *addressCountry = [personalInfoObject.fields objectForKey:kProfilePersonalInfoTableAddressCountryKey];
                    NSString *addressPostCode = [personalInfoObject.fields objectForKey:kProfilePersonalInfoTableAddressPostCodeKey];
                    NSString *addressLine1 = [personalInfoObject.fields objectForKey:kProfilePersonalInfoTableAddressLine1Key];
                    NSString *addressLine2 = [personalInfoObject.fields objectForKey:kProfilePersonalInfoTableAddressLine2Key];
                    NSString *addressLine3 = [personalInfoObject.fields objectForKey:kProfilePersonalInfoTableAddressLine3Key];
                    NSString *addressCity = [personalInfoObject.fields objectForKey:kProfilePersonalInfoTableAddressCityKey];
                    NSString *addressState = [personalInfoObject.fields objectForKey:kProfilePersonalInfoTableAddressStateKey];
                    
                    NSArray *hobbies = [personalInfoObject.fields objectForKey:kProfilePersonalInfoTableHobbiesKey];
                    NSMutableDictionary *personalInfoDictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                                   personalInfoObject.ID,kLoggedInUserPersonInfoObjectIDKey,
                                                                   nameTitle, kLoggedInUserTitleKey,
                                                                   firstName, kLoggedInUserFirstNameKey,
                                                                   lastName, kLoggedInUserLastNameKey,
                                                                   [addressCountry isKindOfClass:NSString.class] && addressCountry.length>0?addressCountry:@"", kLoggedInUserAddressCountryKey,
                                                                   [addressPostCode isKindOfClass:NSString.class] && addressPostCode.length>0?addressPostCode:@"", kLoggedInUserAddressPostCodeKey,
                                                                   [addressLine1 isKindOfClass:NSString.class] && addressLine1.length>0?addressLine1:@"", kLoggedInUserAddressLine1Key,
                                                                   [addressLine2 isKindOfClass:NSString.class] && addressLine2.length>0?addressLine2:@"", kLoggedInUserAddressLine2Key,
                                                                   [addressLine3 isKindOfClass:NSString.class] && addressLine3.length>0?addressLine3:@"", kLoggedInUserAddressLine3Key,
                                                                   [addressCity isKindOfClass:NSString.class] && addressCity.length>0?addressCity:@"", kLoggedInUserAddressCityKey,
                                                                   [addressState isKindOfClass:NSString.class] && addressState.length>0?addressState:@"", kLoggedInUserAddressStateKey,
                                                                   
                                                                   [hobbies isKindOfClass:NSArray.class] && hobbies.count>0?hobbies:@"",kLoggedInUserHobbiesKey,
                                                                   nil];
                    [notifyDictionary setObject:personalInfoDictionary forKey:kProfilePersonalInformationKey];
                }
                else if ([customObject.className isEqualToString:@"ServiceArea"])
                {
                    [notifyDictionary setObject:customObject.fields?customObject.fields:[NSDictionary dictionary] forKey:kServiceAreaObjectsKey];
                }
                else if ([customObject.className isEqualToString:@"CommonPlaces"])
                {
                    NSArray *customObjectFieldsArray = [customObjects valueForKey:@"fields"];
                    [notifyDictionary setObject:customObjectFieldsArray forKey:kCommonPlacesObjectsKey];
                }
                else if ([customObject.className isEqualToString:@"Jobs_dispatch"])
                {
                    NSArray *customObjectFieldsArray = [customObjects valueForKey:@"fields"];
                    for (QBCOCustomObject *localCustomeObj in customObjects) {
                        NSDictionary *customObjDictionary = customObjectFieldsArray[[customObjects indexOfObject:localCustomeObj]];
                        [customObjDictionary setValue:localCustomeObj.ID forKey:@"jobID"];
                    }
                    [notifyDictionary setObject:customObjectFieldsArray forKey:kJobObjectFieldsKey];
                }
                else if ([customObject.className isEqualToString:@"Drivers"])
                {
                    [notifyDictionary setObject:customObject.fields?customObject.fields:[NSDictionary dictionary] forKey:kDriverObjectFieldsKey];
                }
            }
        }
    }
    
    NSString *notificationName = (__bridge NSString *)(contextInfo);
    NSString *dmNoticationName = [[HTDMManager sharedManager] dmNotificationNameForNormalNoticationName:notificationName];
    //First tell DM to update its data then tell to other objects
    [HTUtility postNotificationWithName:dmNoticationName userInfo:notifyDictionary];
    [HTUtility postNotificationWithName:notificationName userInfo:notifyDictionary];
}

@end
