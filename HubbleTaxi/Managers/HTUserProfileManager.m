//
//  HTUserProfileManager.m
//  HubbleTaxi
//
//  Created by Aamir Javed on 30/01/2014.
//  Copyright (c) 2014 Apponative. All rights reserved.
//

#import "HTUserProfileManager.h"
#import "HTDMManager.h"
static HTUserProfileManager *_sharedManager;

@implementation HTUserProfileManager



+ (HTUserProfileManager *)sharedManager
{
    if (!_sharedManager) {
        _sharedManager = [[HTUserProfileManager alloc] init];
    }
    return _sharedManager;
}

- (BOOL)userProfileExists
{
    return [[HTDMManager sharedManager] userProfileExists];
}

- (BOOL)isProfileUpdateNeeded
{
    return [[HTDMManager sharedManager] isProfileUpdateNeeded];
}

- (id)createApplicationSessionWithCompletionNotificationName:(NSString*)completionNotificationName
{
    return [[HTDMManager sharedManager] createApplicationSessionWithCompletionNotificationName:completionNotificationName];
}

-(id)createUserSessionWithCompletionNotificationName:(NSString*)completionNotificationName
{
    return [[HTDMManager sharedManager] createUserSessionWithCompletionNotificationName:completionNotificationName];
}

- (void)sendSecretCodeToPhoneNumber:(NSString *)phoneNumber completionNotificationName:(NSString *)completionNotificationName
{
    [[HTDMManager sharedManager] sendSecretCodeToPhoneNumber:phoneNumber completionNotificationName:completionNotificationName];
}

- (NSString*)currentSecretCode
{
    return [[HTDMManager sharedManager] currentSecretCode];
}

- (void)saveDPImagePermanentally:(UIImage*)dpImage
{
    [[HTDMManager sharedManager] saveDPImagePermanentally:dpImage];
}
- (UIImage*)getDpImage
{
    return [[HTDMManager sharedManager] getDpImage];
}

- (id)userWithPhoneNumber:(NSString*)phoneNumber completionNotificationName:(NSString*)completionNotificationName
{
    return [[HTDMManager sharedManager] userWithPhoneNumber:phoneNumber completionNotificationName:completionNotificationName];
}

- (id)signupWithPhoneNumber:(NSString*)phoneNumber completionNotificationName:(NSString*)completionNotificationName;
{
    return [[HTDMManager sharedManager] signupWithPhoneNumber:phoneNumber completionNotificationName:completionNotificationName];
}

- (id)loginWithPhoneNumber:(NSString*)phoneNumber completionNotificationName:(NSString*)completionNotificationName
{
    return [[HTDMManager sharedManager] loginWithPhoneNumber:phoneNumber completionNotificationName:completionNotificationName];
}

- (id)logoutCurrentuserWithCompletionNotificationName:(NSString *)completionNotificationName
{
    return [[HTDMManager sharedManager] logoutCurrentUserWithCompletionNotificationName:completionNotificationName];
}

- (NSDictionary*)currentUserProfile
{
    return [[HTDMManager sharedManager] currentUserProfile];
}

- (id)uploadDPImage:(UIImage*)dpImage completionNotificationName:(NSString*)completionNotificationName
{
    return [[HTDMManager sharedManager] uploadDPImage:dpImage completionNotificationName:completionNotificationName];
}

- (id)downloadDpImageWithCompletionNotificationName:(NSString*)completionNotificationName;
{
    return [[HTDMManager sharedManager] downloadDpImageWithCompletionNotificationName:completionNotificationName];
}

- (id)updateAccountInfoWithDictionay:(NSDictionary*)profileDictionary completionNotificationName:(NSString*)completionNotificationName
{
    return [[HTDMManager sharedManager] updateAccountInfoWithDictionay:profileDictionary completionNotificationName:completionNotificationName];
}

- (id)updatePersonInformationWithDictionary:(NSDictionary*)profileDictionary completionNotificationName:(NSString*)completionNotificationName
{
    return [[HTDMManager sharedManager] updatePersonInformationWithDictionary:profileDictionary completionNotificationName:completionNotificationName];
}

- (id)downloadPersonalInformationWithCompletionNotificationName:(NSString*)completionNotificationName
{
    return [[HTDMManager sharedManager] downloadPersonalInformationWithCompletionNotificationName:completionNotificationName];
}

- (id)downlaodDriverProfileWithDriverID:(NSString*)driverID completionNotificationName:(NSString*)completionNotificationName
{
    return [[HTDMManager sharedManager] downlaodDriverProfileWithDriverID:driverID completionNotificationName:completionNotificationName];
}

- (id)getDriverAvailableNearToLocation:(NSString*)locationString completionNotificationName:(NSString *)completionNotificationName
{
    return [[HTDMManager sharedManager] getDriverAvailableNearToLocation:locationString completionNotificationName:completionNotificationName];
}

- (void)removeAllDataOfCurrentLoggedInUser
{
    [[HTDMManager sharedManager] removeAllDataOfCurrentLoggedInUser];
}


@end
