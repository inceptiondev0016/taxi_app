//
//  HTSessionRenew.m
//  HubbleTaxi
//
//  Created by Aamir Javed on 21/05/2014.
//  Copyright (c) 2014 Apponative. All rights reserved.
//

#import "HTSessionRenew.h"
#import "HTUserProfileManager.h"

@interface HTSessionRenew()<UIAlertViewDelegate>
@property (nonatomic,retain)id networkOjbect;

- (void)createApplicationSession;
- (void)createUserSession;
- (void)showNetworkErrorAlert;
- (void)onApplicationSessionResultNotification:(NSNotification*)notification;
- (void)onLoginResultNotification:(NSNotification*)notification;
@end

@implementation HTSessionRenew

- (void)renewSessionWithCallbackBlock:(void (^)(bool succeeded, bool isLogout))callbackBlock
{
    self.sessionRenewCallBackBlock = callbackBlock;
    [self createApplicationSession];
}

- (void)createApplicationSession
{
    [HTUtility addNotificationObserver:self selector:@selector(onApplicationSessionResultNotification:) forNotificationWithName:kApplicationSessionResultNotificationName];
    self.networkOjbect = [[HTUserProfileManager sharedManager] createApplicationSessionWithCompletionNotificationName:kApplicationSessionResultNotificationName];
}

- (void)createUserSession
{
    NSString *phoneNumber = [[[HTUserProfileManager sharedManager] currentUserProfile] objectForKey:kLoggedInUserPhoneNumberKey];
    [HTUtility addNotificationObserver:self selector:@selector(onLoginResultNotification:) forNotificationWithName:kLoginResultNotificationName];
    self.networkOjbect = [[HTUserProfileManager sharedManager] loginWithPhoneNumber:phoneNumber completionNotificationName:kLoginResultNotificationName];
}

- (void)showNetworkErrorAlert
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:kAppName message:kNetworkErrorString delegate:self cancelButtonTitle:kCancelString otherButtonTitles:kTryAgainString, nil];
    alertView.tag = kNetworkErrorStringViewTag;
    [alertView show];
}

- (void)onApplicationSessionResultNotification:(NSNotification*)notification
{
    self.networkOjbect = nil;
    [HTUtility removeNotificationObserver:self withNotificationName:notification.name];
    BOOL success = [[[notification userInfo] objectForKey:kResponseSuccessKey] boolValue];
    if (success) {
        [self createUserSession];
    }else{
        [self showNetworkErrorAlert];
    }
}


- (void)onLoginResultNotification:(NSNotification*)notification
{
    self.networkOjbect = nil;
    [HTUtility removeNotificationObserver:self withNotificationName:notification.name];
    NSDictionary *notifyDictionary = [notification userInfo];
    BOOL success = [[notifyDictionary objectForKey:kResponseSuccessKey] boolValue];

    if (success) {
        QBUUser *user = [[notification userInfo] objectForKey:kLoginResultUserKey];
        NSRange currentDeviceUUIDRange = [user.website rangeOfString:[HTUtility currentDeviceID]];
        if (user.website && currentDeviceUUIDRange.location != NSNotFound) {
            self.sessionRenewCallBackBlock(success,false);
        }else
        {
            //logout automatically
            self.sessionRenewCallBackBlock(success,true);
        }

    }else
    {
        [self showNetworkErrorAlert];
    }
}

- (void)dealloc
{
    if ([_networkOjbect conformsToProtocol:@protocol(Cancelable)]) {
        [_networkOjbect cancel];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == kNetworkErrorStringViewTag) {
        if (buttonIndex == 0) {
            self.sessionRenewCallBackBlock(false,false);
        }else
        {
            [self createApplicationSession];
        }
    }
}
@end
