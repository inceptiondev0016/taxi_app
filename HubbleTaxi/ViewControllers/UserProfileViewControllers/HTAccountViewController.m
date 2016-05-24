//
//  HTAccountViewController.m
//  HubbleTaxi
//
//  Created by Aamir Javed on 12/02/2014.
//  Copyright (c) 2014 Apponative. All rights reserved.
//

#import "HTAccountViewController.h"
#import "HTUserProfileManager.h"

@interface HTAccountViewController ()
@property (weak, nonatomic) IBOutlet HTTextField *phoneNumberTF;
@property (weak, nonatomic) IBOutlet HTTextField *emailTF;
@property (weak, nonatomic) IBOutlet HTButton *saveButton;

- (IBAction)saveButtonTouched:(HTButton *)sender;

- (void)uploadAccountInfo;

- (void)onAcccountInfoUpdateResultNotification:(NSNotification*)notification;
@end

@implementation HTAccountViewController

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
    _phoneNumberTF.text = _phoneNumberString;
    if (_emailString) {
        _emailTF.text = _emailString;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Custom methods
- (IBAction)saveButtonTouched:(HTButton *)sender {
    if (_emailTF.text.length < 1) {
        [HTUtility showInfo:kAccountInfoEmailMissingString];
    }else{
        if (![HTUtility isEmailValidWithString:_emailTF.text]) {
            [HTUtility showInfo:kAccountInfoEmailNotValidString];
        }else{
            //Email is valid, save account info
            [self uploadAccountInfo];
        }
    }
}

- (void)uploadAccountInfo
{
    [self showFullScreenAcitvityIndicatorView];
    __block HTSessionRenew *sessionRenew = [[HTSessionRenew alloc] init];
    [self.renewSessionObjectsArray addObject:sessionRenew];
    [sessionRenew renewSessionWithCallbackBlock:^(bool succeeded, bool isLogout) {
        [self hideFullScreenAcitvityIndicatorView];
        [self.renewSessionObjectsArray removeObject:sessionRenew];
        sessionRenew = nil;
        if (isLogout) {
            [self forceLogoutCurrentUser];
        }else
        {
            if (succeeded)
            {
                [self showFullScreenAcitvityIndicatorView];
                [HTUtility addNotificationObserver:self selector:@selector(onAcccountInfoUpdateResultNotification:) forNotificationWithName:kAccountInfoUpdateResultNotificationName];
                id userID = [[[HTUserProfileManager sharedManager] currentUserProfile] objectForKey:kLoggedInUserIDKey];
                NSDictionary *accountInfoDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                                       _emailTF.text, kLoggedInUserEmailKey,
                                                       userID,kLoggedInUserIDKey,
                                                       _phoneNumberTF.text,kLoggedInUserPhoneNumberKey, nil];
                id networkOjbect = [[HTUserProfileManager sharedManager] updateAccountInfoWithDictionay:accountInfoDictionary completionNotificationName:kAccountInfoUpdateResultNotificationName];
                [self performingNetworkCallWithObject:networkOjbect forNotificationName:kAccountInfoUpdateResultNotificationName];
            }else
            {
                //Handled in renewSession class
            }
        }
    }];
}


- (IBAction)navigateBack:(HTButton *)sender
{
    NSDictionary *accountInfoDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                           _emailString.length>0?_emailString:@"", kLoggedInUserEmailKey,
                                           _phoneNumberString,kLoggedInUserPhoneNumberKey, nil];
    [HTUtility postNotificationWithName:kAccountInfoChangedNotificationName userInfo:accountInfoDictionary];
}

#pragma mark - Notification methods
- (void)onAcccountInfoUpdateResultNotification:(NSNotification*)notification
{
    [self hideFullScreenAcitvityIndicatorView];
    [HTUtility removeNotificationObserver:self withNotificationName:notification.name];
    [self networkCallFinishedForNotificationName:notification.name];
    NSDictionary *profileUploadResultDictionary = [notification userInfo];
    BOOL success = [[profileUploadResultDictionary objectForKey:kResponseSuccessKey] boolValue];
    if (success)
    {
        self.phoneNumberString = _phoneNumberTF.text;
        self.emailString = _emailTF.text;
       // [HTUtility showInfo:kProfileUploadingSuccessfulString];
        [self navigateBack:nil];
    }else{
        //Show try again view for uploading profile
        UIAlertView *profileUploadingFailedView = [[UIAlertView alloc] initWithTitle:@"Update Failed" message:kProfileUploadingFailedTryAgainString delegate:self cancelButtonTitle:kCancelString otherButtonTitles:@"Save Again", nil];
        profileUploadingFailedView.tag = kAccountInfoUploadingFailedTryAgainStringViewTag;
        [profileUploadingFailedView show];
    }

}

#pragma mark- Alert delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag == kAccountInfoUploadingFailedTryAgainStringViewTag) {
        if (buttonIndex == 1) {
            [self uploadAccountInfo];
        }
    }
}
@end
