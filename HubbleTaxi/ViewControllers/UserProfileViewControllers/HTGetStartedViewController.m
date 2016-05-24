//
//  HTGetStartedViewController.m
//  HubbleTaxi
//
//  Created by Aamir Javed on 30/01/2014.
//  Copyright (c) 2014 Apponative. All rights reserved.
//

#import "HTGetStartedViewController.h"
#import "HTUserProfileManager.h"
#include <QuartzCore/QuartzCore.h>
#import "HTInfoView.h"
#import "HTUserBookingsManager.h"

@interface HTGetStartedViewController ()<UIAlertViewDelegate>
{

}
@property (nonatomic, assign) BOOL isFreshUser;
@property (nonatomic,assign) NSInteger dpBlobID;
@property (weak, nonatomic) IBOutlet HTTextField *phoneNumberTF;
@property (weak, nonatomic) IBOutlet HTButton *getStartedButton;
@property (weak, nonatomic) IBOutlet HTButton *countryCodeButton;
@property (nonatomic,retain)HTImageView *phoneIcon;

- (IBAction)getStartedButtonTouched:(HTButton *)sender;
- (IBAction)countryCodeButtonTouched:(HTButton *)sender;

- (void)showCodeAcceptingView;
- (void)checkWhetherUserAlreadySignedUp;
- (void)loginCurentSignedUpUser;
- (void)uploadDefaultDP;
- (void)updateAccountInfo;
- (NSString*)phoneNumberString;
- (void)downloadUserProfilePersonalInfo;
- (void)updateUserCurrentDevice;
- (void)sendSignupRequest;
- (void)currentBookingOrder;

- (void)onSecretKeySendingNotification:(NSNotification*)notification;
- (void)onSignupResultNotification:(NSNotification*)notification;
- (void)onLoginResultNotification:(NSNotification*)notification;
- (void)onUserAlreadyExistsResultsNotification:(NSNotification*)notification;
- (void)onUploadDPResultNotification:(NSNotification*)notification;
- (void)onAcccountInfoUpdateResultNotification:(NSNotification*)notification;
- (void)onPersonalInformationDownloadResultNotification:(NSNotification*)notification;
- (void)onDeviceInfoUpdateResultNotification:(NSNotification*)notification;
- (void)onSecretCodeEnteredNotification:(NSNotification*)notification;
- (void)onCurrentBookingOrderResultNotification:(NSNotification *)notification;
@end

@implementation HTGetStartedViewController

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
    self.phoneIcon = [[HTImageView alloc] initWithImage:[UIImage imageNamed:@"phoneicon.png"]];
    [self adjustViewForNonRetina:_phoneIcon];
    [self.phoneNumberTF setLeftView:_phoneIcon];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//Called automatically from super |HTViewController| viewDidLoad
- (void)resetSubViews
{
    
}

#pragma mark - Button Actions

- (IBAction)getStartedButtonTouched:(HTButton *)sender
{
    if (!_phoneNumberTF.text.length) {
        [HTUtility showInfo:kPhoneNumberMissingString];
    }
    else
    {
        if ([self.phoneNumberTF.text isEqualToString:TestingPhoneNumber]) {
            [self checkWhetherUserAlreadySignedUp];
        }else{
            //All fields are filled
            [self showFullScreenAcitvityIndicatorView];
            [HTUtility addNotificationObserver:self selector:@selector(onSecretKeySendingNotification:) forNotificationWithName:kCTSecretCodeSendingResultNotificationName];
            NSString *phoneNumberForSecretCode = [[self phoneNumberString] substringFromIndex:1];
            [[HTUserProfileManager sharedManager] sendSecretCodeToPhoneNumber:phoneNumberForSecretCode completionNotificationName:kCTSecretCodeSendingResultNotificationName];
        }
    }
}

- (IBAction)countryCodeButtonTouched:(HTButton *)sender {
}

#pragma mark - Custom methods

- (void)showCodeAcceptingView
{
    [HTUtility addNotificationObserver:self selector:@selector(onSecretCodeEnteredNotification:) forNotificationWithName:kSecretCodeEnteredNotificationName];
    HTInfoView *infoView = [[HTInfoView alloc] initWithSecretCode:[[HTUserProfileManager sharedManager] currentSecretCode] toMobNumber:[self phoneNumberString]];
    [infoView show];
}

- (void)checkWhetherUserAlreadySignedUp
{
    [self showFullScreenAcitvityIndicatorView];
    [HTUtility addNotificationObserver:self selector:@selector(onUserAlreadyExistsResultsNotification:) forNotificationWithName:kUserAlreadyExistsResultNotificationName];
    id networkOjbect = [[HTUserProfileManager sharedManager] userWithPhoneNumber:[self phoneNumberString] completionNotificationName:kUserAlreadyExistsResultNotificationName];
    [self performingNetworkCallWithObject:networkOjbect forNotificationName:kUserAlreadyExistsResultNotificationName];
}

- (void)loginCurentSignedUpUser
{
    [self showFullScreenAcitvityIndicatorView];
    [HTUtility addNotificationObserver:self selector:@selector(onLoginResultNotification:) forNotificationWithName:kLoginResultNotificationName];
    
    id networkOjbect = [[HTUserProfileManager sharedManager] loginWithPhoneNumber:[self phoneNumberString] completionNotificationName:kLoginResultNotificationName];
    [self performingNetworkCallWithObject:networkOjbect forNotificationName:kLoginResultNotificationName];
}

- (void)uploadDefaultDP
{
    [self showFullScreenAcitvityIndicatorView];
    [HTUtility addNotificationObserver:self selector:@selector(onUploadDPResultNotification:) forNotificationWithName:kProfileUploadDPResultNotificationName];
    id networkOjbect = [[HTUserProfileManager sharedManager] uploadDPImage:[UIImage imageNamed:@"profile_dp_default.png"] completionNotificationName:kProfileUploadDPResultNotificationName];
    [self performingNetworkCallWithObject:networkOjbect forNotificationName:kProfileUploadDPResultNotificationName];
}

- (void)updateAccountInfo
{
    [self showFullScreenAcitvityIndicatorView];
    [HTUtility addNotificationObserver:self selector:@selector(onAcccountInfoUpdateResultNotification:) forNotificationWithName:kAccountInfoUpdateResultNotificationName];
    id userID = [[[HTUserProfileManager sharedManager] currentUserProfile] objectForKey:kLoggedInUserIDKey];
    NSDictionary *accountsDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                        userID,kLoggedInUserIDKey,
                                        [NSNumber numberWithLong:_dpBlobID],kLoggedInUserDPBlobIDKey, nil];
    id networkOjbect = [[HTUserProfileManager sharedManager] updateAccountInfoWithDictionay:accountsDictionary completionNotificationName:kAccountInfoUpdateResultNotificationName];
    [self performingNetworkCallWithObject:networkOjbect forNotificationName:kAccountInfoUpdateResultNotificationName];
}

- (NSString*)phoneNumberString
{
    NSRange range = [_phoneNumberTF.text rangeOfString:@"^0*" options:NSRegularExpressionSearch];
    NSString *phoneNumberWithoutLeadingZeros = [_phoneNumberTF.text stringByReplacingCharactersInRange:range withString:@""];
    return [NSString stringWithFormat:@"%@%@",_countryCodeButton.currentTitle,phoneNumberWithoutLeadingZeros];
}

- (void)downloadUserProfilePersonalInfo
{
    [self showFullScreenAcitvityIndicatorView];
    [HTUtility addNotificationObserver:self selector:@selector(onPersonalInformationDownloadResultNotification:) forNotificationWithName:kProfilePersonalInfoDownloadNotificationName];
    id networkOjbect = [[HTUserProfileManager sharedManager] downloadPersonalInformationWithCompletionNotificationName:kProfilePersonalInfoDownloadNotificationName];
    [self performingNetworkCallWithObject:networkOjbect forNotificationName:kProfilePersonalInfoDownloadNotificationName];
}

- (void)updateUserCurrentDevice
{
    [self showFullScreenAcitvityIndicatorView];
    [HTUtility addNotificationObserver:self selector:@selector(onDeviceInfoUpdateResultNotification:) forNotificationWithName:kAccountInfoUpdateResultNotificationName];
    id userID = [[[HTUserProfileManager sharedManager] currentUserProfile] objectForKey:kLoggedInUserIDKey];
    NSDictionary *accountInfoDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                           [HTUtility currentDeviceID], kLoggedInUserDeviceKey,
                                           userID,kLoggedInUserIDKey,nil];
    id networkOjbect = [[HTUserProfileManager sharedManager] updateAccountInfoWithDictionay:accountInfoDictionary completionNotificationName:kAccountInfoUpdateResultNotificationName];
    [self performingNetworkCallWithObject:networkOjbect forNotificationName:kAccountInfoUpdateResultNotificationName];
}

- (void)sendSignupRequest
{
    [self showFullScreenAcitvityIndicatorView];
    [HTUtility addNotificationObserver:self selector:@selector(onSignupResultNotification:) forNotificationWithName:kGetStartedResultNotificationName];
    id networkOjbect = [[HTUserProfileManager sharedManager] signupWithPhoneNumber:[self phoneNumberString] completionNotificationName:kGetStartedResultNotificationName];
    [self performingNetworkCallWithObject:networkOjbect forNotificationName:kGetStartedResultNotificationName];
}

- (void)currentBookingOrder
{
    [self showFullScreenAcitvityIndicatorView];
    [HTUtility addNotificationObserver:self selector:@selector(onCurrentBookingOrderResultNotification:) forNotificationWithName:kBookingOrderRestultNotificationName];
    id networkOjbect = [[HTUserBookingsManager sharedManager] currentbookingOrderWithCompletionNotificationName:kBookingOrderRestultNotificationName];
    [self performingNetworkCallWithObject:networkOjbect forNotificationName:kBookingOrderRestultNotificationName];
}

#pragma mark - Notification methods

- (void)onSignupResultNotification:(NSNotification*)notification
{
    [self hideFullScreenAcitvityIndicatorView];
    [HTUtility removeNotificationObserver:self withNotificationName:notification.name];
    [self networkCallFinishedForNotificationName:notification.name];
    NSDictionary *singupResultDictionary = [notification userInfo];
    BOOL success = [[singupResultDictionary objectForKey:kResponseSuccessKey] boolValue];
    if (success)
    {
        self.isFreshUser = YES;
        [self loginCurentSignedUpUser];
    }else{
        //signup failed
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:kAppName message:kGetStartedRequestUnSuccessfulString delegate:self cancelButtonTitle:kCancelString otherButtonTitles:kTryAgainString, nil];
        alertView.tag = kGetStartedRequestUnSuccessfulViewTag;
        [alertView show];
    }
}

- (void)onSecretKeySendingNotification:(NSNotification *)notification
{
    [HTUtility removeNotificationObserver:self withNotificationName:notification.name];
    if (isSMSOnTest) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self hideFullScreenAcitvityIndicatorView];
            [self showCodeAcceptingView];
        });
    }else
    {
        NSData *clickatellResponseData = [[notification userInfo] objectForKey:kCTSecretCodeSendingResultKey];
        NSString *clickatellResponseString = [[NSString alloc] initWithData:clickatellResponseData encoding:1];
        if (clickatellResponseString.length > 3 && [[clickatellResponseString substringToIndex:3] isEqualToString:@"ID:"]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self hideFullScreenAcitvityIndicatorView];
                [self showCodeAcceptingView];
            });
        }else
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self hideFullScreenAcitvityIndicatorView];
                UIAlertView *invalidPhoneNumberAlertView = [[UIAlertView alloc] initWithTitle:kAppName message:kCTUnableToSendSMSTryAgainString delegate:nil cancelButtonTitle:@"Re-enter Number" otherButtonTitles:nil, nil];
                [invalidPhoneNumberAlertView show];
            });
        }
    }
}

- (void)onLoginResultNotification:(NSNotification *)notification
{
    [self hideFullScreenAcitvityIndicatorView];
    [HTUtility removeNotificationObserver:self withNotificationName:notification.name];
    [self networkCallFinishedForNotificationName:notification.name];
    NSDictionary *loginResultDictionary = [notification userInfo];
    BOOL success = [[loginResultDictionary objectForKey:kResponseSuccessKey] boolValue];
    if (success)
    {
        //Singup is succesful, checked by logging in successfully
        [self updateUserCurrentDevice];
    }else{
        //Show try again view for login
        UIAlertView *loginFailedInfoView = [[UIAlertView alloc] initWithTitle:kAppName message:kLoginRequestFailedAfterGetStartedString delegate:self cancelButtonTitle:kTryAgainString otherButtonTitles:nil, nil];
        loginFailedInfoView.tag = kLoginRequestFailedAfterGetStartedStringViewTag;
        [loginFailedInfoView show];
    }

}

- (void)onUserAlreadyExistsResultsNotification:(NSNotification *)notification
{
    [self hideFullScreenAcitvityIndicatorView];
    [HTUtility removeNotificationObserver:self withNotificationName:notification.name];
    [self networkCallFinishedForNotificationName:notification.name];
    NSDictionary *userAlreadyExistsDictionary = [notification userInfo];
    BOOL success = [[userAlreadyExistsDictionary objectForKey:kResponseSuccessKey] boolValue];
    if (success)
    {
        //User already exists
        [self loginCurentSignedUpUser];
    }else{
        
        if ([[userAlreadyExistsDictionary objectForKey:kResponseStatusKey] integerValue] == 404) {
            //user does not exists so signup
            [self sendSignupRequest];
        }
        else{
            //Netword error
            UIAlertView *networkErrorInfoView = [[UIAlertView alloc] initWithTitle:kAppName message:kNetworkErrorString delegate:self cancelButtonTitle:kTryAgainString otherButtonTitles:nil, nil];
            networkErrorInfoView.tag = kNetworkErrorStringViewTag;
            [networkErrorInfoView show];
        }
    }
}

- (void)onUploadDPResultNotification:(NSNotification*)notification
{
    [self hideFullScreenAcitvityIndicatorView];
    [HTUtility removeNotificationObserver:self withNotificationName:notification.name];
    [self networkCallFinishedForNotificationName:notification.name];
    NSDictionary *dpUploadResultDictionary = [notification userInfo];
    BOOL success = [[dpUploadResultDictionary objectForKey:kResponseSuccessKey] boolValue];
    if (success)
    {
        self.dpBlobID = [[dpUploadResultDictionary objectForKey:kLoggedInUserDPBlobIDKey] integerValue];
        [[HTUserProfileManager sharedManager] saveDPImagePermanentally:[UIImage imageNamed:@"profile_dp_default.png"]];
        [self updateAccountInfo];
    }else{
        //Show try again view for uploading dp
        UIAlertView *dpUploadingFailedView = [[UIAlertView alloc] initWithTitle:kAppName message:kLoginRequestFailedAfterGetStartedString delegate:self cancelButtonTitle:kTryAgainString otherButtonTitles:nil, nil];
        dpUploadingFailedView.tag = kDPUploadingFailedTryAgainStringViewTag;
        [dpUploadingFailedView show];
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
        [HTUtility chageWindowRootViewControllerTo:[HTUtility appDelegate].profileNavController withBackwardAnimation:NO];
    }else{
        //Show try again view for uploading profile
        UIAlertView *profileUploadingFailedView = [[UIAlertView alloc] initWithTitle:kAppName message:kLoginRequestFailedAfterGetStartedString delegate:self cancelButtonTitle:kTryAgainString otherButtonTitles:nil, nil];
        profileUploadingFailedView.tag = kAccountInfoUploadingFailedTryAgainStringViewTag;
        [profileUploadingFailedView show];
    }
    
}

- (void)onPersonalInformationDownloadResultNotification:(NSNotification*)notification
{
    [self hideFullScreenAcitvityIndicatorView];
    [HTUtility removeNotificationObserver:self withNotificationName:notification.name];
    [self networkCallFinishedForNotificationName:notification.name];
    NSDictionary *personalInfoDonwloadResultDictionary = [notification userInfo];
    BOOL success = [[personalInfoDonwloadResultDictionary objectForKey:kResponseSuccessKey] boolValue];
    if (success)
    {
        BOOL isFreshUser = [[HTUserProfileManager sharedManager] isProfileUpdateNeeded];
        if (isFreshUser) {
            [HTUtility chageWindowRootViewControllerTo:[HTUtility appDelegate].profileNavController withBackwardAnimation:NO];
        }else
        {
            [self currentBookingOrder];
        }
    }else{
        //Show try again downloading personal info
        UIAlertView *personalInfoDonwloadTryAgainView = [[UIAlertView alloc] initWithTitle:@"Connection Problem" message:kUnableToCreateSessionTryAgainString delegate:self cancelButtonTitle:kTryAgainString otherButtonTitles:nil, nil];
        personalInfoDonwloadTryAgainView.tag = kProfilePersonalInfoDownloadingFailedTryAgainStringViewTag;
        [personalInfoDonwloadTryAgainView show];
    }
}

- (void)onDeviceInfoUpdateResultNotification:(NSNotification*)notification
{
    [self hideFullScreenAcitvityIndicatorView];
    [HTUtility removeNotificationObserver:self withNotificationName:notification.name];
    [self networkCallFinishedForNotificationName:notification.name];
    NSDictionary *profileUploadResultDictionary = [notification userInfo];
    BOOL success = [[profileUploadResultDictionary objectForKey:kResponseSuccessKey] boolValue];
    if (success)
    {
        if (_isFreshUser) {
            [self uploadDefaultDP];
        }else{
            [self downloadUserProfilePersonalInfo];
        }
    }else{
        //Show try again view for uploading profile
        UIAlertView *tryAgainSessionView = [[UIAlertView alloc] initWithTitle:@"Connection Problem" message:kUnableToCreateSessionTryAgainString delegate:self cancelButtonTitle:kTryAgainString otherButtonTitles:nil, nil];
        tryAgainSessionView.tag = kDeviceInfoUploadingFailedTryAgainStringViewTag;
        [tryAgainSessionView show];
    }
}

- (void)onSecretCodeEnteredNotification:(NSNotification *)notification
{
    [HTUtility removeNotificationObserver:self withNotificationName:notification.name];
    NSDictionary *notifyDictionary = [notification userInfo];
    NSString *secretCode = notifyDictionary[@"secretCode"];
    NSString *currentSecretCode = [[HTUserProfileManager sharedManager] currentSecretCode];
    if ([secretCode isEqualToString:currentSecretCode])
    {
        [self checkWhetherUserAlreadySignedUp];
    }
    else{
        UIAlertView *codeDoesNotMatchInfoView = [[UIAlertView alloc] initWithTitle:kAppName message:kCTSecretCodeDoesNotMatchToUserEnteredString delegate:self cancelButtonTitle:kCancelString otherButtonTitles:@"Re-enter Code",kSendAnotherCodeString, nil];
        codeDoesNotMatchInfoView.tag = kCTSecretCodeDoesNotMatchToUserEnteredStringInfoViewTag;
        [codeDoesNotMatchInfoView show];
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
        UIAlertView *tryAgainSessionView = [[UIAlertView alloc] initWithTitle:@"Connection Problem" message:kUnableToCreateSessionTryAgainString delegate:self cancelButtonTitle:kTryAgainString otherButtonTitles:nil, nil];
        tryAgainSessionView.tag = kBookingOrderFailedTryAgainViewTag;
        [tryAgainSessionView show];
    }
}

#pragma mark - Alertview delegate methods
- (BOOL)alertViewShouldEnableFirstOtherButton:(UIAlertView *)alertView
{
    if (alertView.tag == kCTSecretCodeIsSentToYourPhoneStringInfoViewTag) {
        UITextField *codeTF = [alertView textFieldAtIndex:0];
        return codeTF.text.length > 0;
    }
    return YES;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == kCTSecretCodeIsSentToYourPhoneStringInfoViewTag)
    {
        if (buttonIndex == 1) {
            UITextField *codeTF = [alertView textFieldAtIndex:0];
            NSString *currentSecretCode = [[HTUserProfileManager sharedManager] currentSecretCode];
            if ([codeTF.text isEqualToString:currentSecretCode])
            {
                [self checkWhetherUserAlreadySignedUp];
            }
            else{
                UIAlertView *codeDoesNotMatchInfoView = [[UIAlertView alloc] initWithTitle:kAppName message:kCTSecretCodeDoesNotMatchToUserEnteredString delegate:self cancelButtonTitle:kCancelString otherButtonTitles:@"Re-enter Code",kSendAnotherCodeString, nil];
                codeDoesNotMatchInfoView.tag = kCTSecretCodeDoesNotMatchToUserEnteredStringInfoViewTag;
                [codeDoesNotMatchInfoView show];
            }
        }
    }
    else if (alertView.tag == kCTSecretCodeDoesNotMatchToUserEnteredStringInfoViewTag)
    {
        if (buttonIndex == 1) {
            [self showCodeAcceptingView];
        }else if (buttonIndex == 2)
        {
            [self getStartedButtonTouched:nil];
        }
    }
    else if (alertView.tag == kLoginRequestFailedAfterGetStartedStringViewTag)
    {
        [self loginCurentSignedUpUser];
    }
    else if (alertView.tag == kNetworkErrorStringViewTag)
    {
        [self checkWhetherUserAlreadySignedUp];
    }
    else if (alertView.tag == kDPUploadingFailedTryAgainStringViewTag)
    {
        [self uploadDefaultDP];
    }
    else if (alertView.tag == kAccountInfoUploadingFailedTryAgainStringViewTag)
    {
        [self updateAccountInfo];
    }
    else if (alertView.tag == kProfilePersonalInfoDownloadingFailedTryAgainStringViewTag)
    {
        [self downloadUserProfilePersonalInfo];
    }else if (alertView.tag == kDeviceInfoUploadingFailedTryAgainStringViewTag)
    {
        [self updateUserCurrentDevice];
    }
    else if (alertView.tag == kGetStartedRequestUnSuccessfulViewTag)
    {
        [self sendSignupRequest];
    }
    else if (alertView.tag == kBookingOrderFailedTryAgainViewTag)
    {
        [self currentBookingOrder];
    }
}


#pragma mark- Textfield methods
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString *finalString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    if (finalString.length == 0) {
        [self.phoneNumberTF setLeftView:_phoneIcon];
    }else
    {
        [self.phoneNumberTF setLeftView:[[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, 5)]];
    }
    return YES;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField
{
    [self.phoneNumberTF setLeftView:_phoneIcon];
    return YES;
}
@end
