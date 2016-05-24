//
//  HTUserProfileManager.h
//  HubbleTaxi
//
//  Created by Aamir Javed on 30/01/2014.
//  Copyright (c) 2014 Apponative. All rights reserved.
//

#import "HTManager.h"

@interface HTUserProfileManager : HTManager
{
    
}

+ (HTUserProfileManager*)sharedManager;

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
- (id)logoutCurrentuserWithCompletionNotificationName:(NSString*)completionNotificationName;
- (NSDictionary*)currentUserProfile;
- (id)uploadDPImage:(UIImage*)dpImage completionNotificationName:(NSString*)completionNotificationName;
- (id)downloadDpImageWithCompletionNotificationName:(NSString*)completionNotificationName;
- (id)updateAccountInfoWithDictionay:(NSDictionary*)profileDictionary completionNotificationName:(NSString*)completionNotificationName;
- (id)updatePersonInformationWithDictionary:(NSDictionary*)profileDictionary completionNotificationName:(NSString*)completionNotificationName;
- (id)downloadPersonalInformationWithCompletionNotificationName:(NSString*)completionNotificationName;
- (id)downlaodDriverProfileWithDriverID:(NSString*)driverID completionNotificationName:(NSString*)completionNotificationName;
- (id)getDriverAvailableNearToLocation:(NSString*)locationString completionNotificationName:(NSString *)completionNotificationName;
- (void)removeAllDataOfCurrentLoggedInUser;

@end
