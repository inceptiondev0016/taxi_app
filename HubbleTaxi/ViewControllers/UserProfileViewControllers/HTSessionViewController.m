//
//  HTSessionViewController.m
//  HubbleTaxi
//
//  Created by Aamir Javed on 07/02/2014.
//  Copyright (c) 2014 Apponative. All rights reserved.
//

#import "HTSessionViewController.h"
#import "HTUserProfileManager.h"
#import "HTGetStartedViewController.h"
#import "HTUserBookingsManager.h"

@interface HTSessionViewController ()
@property (weak, nonatomic) IBOutlet HTLabel *creatingSessionDescriotionLabel;

- (void)createApplicationSession;
- (void)createUserSession;
- (void)showTryAgainSessionViewWithTag:(int)tag;
- (void)updateUserCurrentDevice;
- (void)currentBookingOrder;

- (void)onApplicationSessionResultNotification:(NSNotification*)notification;
- (void)onUserSessionResultNotification:(NSNotification*)notification;
- (void)onCurrentBookingOrderResultNotification:(NSNotification*)notification;

@end

@implementation HTSessionViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self createApplicationSession];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Custom methods
- (void)createApplicationSession
{
    [self showFullScreenAcitvityIndicatorView];
    [HTUtility addNotificationObserver:self selector:@selector(onApplicationSessionResultNotification:) forNotificationWithName:kApplicationSessionResultNotificationName];
    id networkOjbect = [[HTUserProfileManager sharedManager] createApplicationSessionWithCompletionNotificationName:kApplicationSessionResultNotificationName];
    [self performingNetworkCallWithObject:networkOjbect forNotificationName:kApplicationSessionResultNotificationName];
}

- (void)createUserSession
{
    [self showFullScreenAcitvityIndicatorView];
    [HTUtility addNotificationObserver:self selector:@selector(onUserSessionResultNotification:) forNotificationWithName:kUserSessionResultNotificationName];
    id networkOjbect = [[HTUserProfileManager sharedManager] createUserSessionWithCompletionNotificationName:kUserSessionResultNotificationName];
    [self performingNetworkCallWithObject:networkOjbect forNotificationName:kApplicationSessionResultNotificationName];
}

- (void)showTryAgainSessionViewWithTag:(int)tag
{
    UIAlertView *tryAgainSessionView = [[UIAlertView alloc] initWithTitle:@"Connection Problem" message:kUnableToCreateSessionTryAgainString delegate:self cancelButtonTitle:kTryAgainString otherButtonTitles:nil, nil];
    tryAgainSessionView.tag = tag;
    [tryAgainSessionView show];
}

- (void)updateUserCurrentDevice
{
    [self showFullScreenAcitvityIndicatorView];
    [HTUtility addNotificationObserver:self selector:@selector(onAcccountInfoUpdateResultNotification:) forNotificationWithName:kAccountInfoUpdateResultNotificationName];
    id userID = [[[HTUserProfileManager sharedManager] currentUserProfile] objectForKey:kLoggedInUserIDKey];
    NSDictionary *accountInfoDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                           [HTUtility currentDeviceID], kLoggedInUserDeviceKey,
                                           userID,kLoggedInUserIDKey,nil];
    id networkOjbect = [[HTUserProfileManager sharedManager] updateAccountInfoWithDictionay:accountInfoDictionary completionNotificationName:kAccountInfoUpdateResultNotificationName];
    [self performingNetworkCallWithObject:networkOjbect forNotificationName:kAccountInfoUpdateResultNotificationName];
}

- (void)currentBookingOrder
{
    [self showFullScreenAcitvityIndicatorView];
    [HTUtility addNotificationObserver:self selector:@selector(onCurrentBookingOrderResultNotification:) forNotificationWithName:kBookingOrderRestultNotificationName];
    id networkOjbect = [[HTUserBookingsManager sharedManager] currentbookingOrderWithCompletionNotificationName:kBookingOrderRestultNotificationName];
    [self performingNetworkCallWithObject:networkOjbect forNotificationName:kBookingOrderRestultNotificationName];
}

#pragma mark - Notification Methods

- (void)onApplicationSessionResultNotification:(NSNotification*)notification
{
    [self hideFullScreenAcitvityIndicatorView];
    [self networkCallFinishedForNotificationName:notification.name];
    [HTUtility removeNotificationObserver:self withNotificationName:notification.name];
    BOOL success = [[[notification userInfo] objectForKey:kResponseSuccessKey] boolValue];
    if (success) {
        if([[HTUserProfileManager sharedManager] userProfileExists])
        {
            [self createUserSession];
        }
        else
        {
            HTGetStartedViewController *signupVC = [[HTGetStartedViewController alloc] init];
            [HTUtility chageWindowRootViewControllerTo:signupVC withBackwardAnimation:NO];
        }
    }else{
        //Show Try again info popup
        [self showTryAgainSessionViewWithTag:kUnableToCreateApplicationSessionStringInfoViewTag];
    }
}

- (void)onUserSessionResultNotification:(NSNotification*)notification
{
    [self hideFullScreenAcitvityIndicatorView];
    [self networkCallFinishedForNotificationName:notification.name];
    [HTUtility removeNotificationObserver:self withNotificationName:notification.name];
    BOOL success = [[[notification userInfo] objectForKey:kResponseSuccessKey] boolValue];
    if (success) {
        [self updateUserCurrentDevice];
    }else{
        //Show Try again info popup
        [self showTryAgainSessionViewWithTag:kUnableToCreateUserSessionStringInfoViewTag];
    }
}

- (void)onAcccountInfoUpdateResultNotification:(NSNotification*)notification
{
    [self hideFullScreenAcitvityIndicatorView];
    [HTUtility removeNotificationObserver:self withNotificationName:notification.name];
    [self networkCallFinishedForNotificationName:notification.name];
    NSDictionary *profileUploadResultDictionary = [notification userInfo];
    BOOL success = [[profileUploadResultDictionary objectForKey:kResponseSuccessKey] boolValue];
    if (success)
    {
        BOOL isFreshUser = [[HTUserProfileManager sharedManager] isProfileUpdateNeeded];
        if (isFreshUser) {
            [HTUtility chageWindowRootViewControllerTo:[HTUtility appDelegate].profileNavController withBackwardAnimation:NO];
        }else
        {
            [self currentBookingOrder];
        }
//        [HTUtility chageWindowRootViewControllerTo:navController withBackwardAnimation:NO];
    }else{
        //Show try again view for uploading profile
        [self showTryAgainSessionViewWithTag:kAccountInfoUploadingFailedTryAgainStringViewTag];
    }
}

- (void)onCurrentBookingOrderResultNotification:(NSNotification *)notification
{
    [self hideFullScreenAcitvityIndicatorView];
    [HTUtility removeNotificationObserver:self withNotificationName:notification.name];
    [self networkCallFinishedForNotificationName:notification.name];
    NSDictionary *currentBookingResultDictionary = [notification userInfo];
    BOOL success = [[currentBookingResultDictionary objectForKey:kResponseSuccessKey] boolValue];
    if (success)
    {
        NSArray *bookingOrders = currentBookingResultDictionary[kJobObjectFieldsKey];
        if ([bookingOrders isKindOfClass:[NSArray class]] && bookingOrders.count > 0)
        {
            [HTUtility chageWindowRootViewControllerTo:[HTUtility appDelegate].currentRideNavController withBackwardAnimation:NO];
        }
        else
        {
            [HTUtility chageWindowRootViewControllerTo:[HTUtility appDelegate].requestRideNavController withBackwardAnimation:NO];
        }
    }else{
        //Show try again view for get current booking order
        [self showTryAgainSessionViewWithTag:kBookingOrderFailedTryAgainViewTag];
    }
}

#pragma mark - Infoview delegate methods
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == kUnableToCreateApplicationSessionStringInfoViewTag) {
        [self createApplicationSession];
    }
    else if(alertView.tag == kUnableToCreateUserSessionStringInfoViewTag){
        [self createUserSession];
    }else if (alertView.tag == kAccountInfoUploadingFailedTryAgainStringViewTag)
    {
        [self updateUserCurrentDevice];
    }else if (alertView.tag == kBookingOrderFailedTryAgainViewTag)
    {
        [self currentBookingOrder];
    }
}

@end
