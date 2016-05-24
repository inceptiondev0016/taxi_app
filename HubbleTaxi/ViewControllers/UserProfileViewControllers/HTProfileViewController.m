//
//  HTProfileViewController.m
//  HubbleTaxi
//
//  Created by Aamir Javed on 03/02/2014.
//  Copyright (c) 2014 Apponative. All rights reserved.
//

#import "HTProfileViewController.h"
#import "HTDPViewController.h"
#import "HTUserProfileManager.h"
#import "HTAccountViewController.h"
#import "HTActivityIndicatorView.h"
#import <QuartzCore/QuartzCore.h>
#import "HTDropDownView.h"


@interface HTProfileViewController ()<UIAlertViewDelegate,UITableViewDataSource,UITableViewDelegate,HTDropDownViewDelegate>
{
    
}
@property (nonatomic,retain)NSMutableDictionary *profileDictionary;
@property (nonatomic,retain)NSMutableArray *hobbiesArray;
@property (nonatomic,assign)NSUInteger dpBlobID;
@property (nonatomic,assign)BOOL isSelectingNameTitle;
@property (nonatomic,retain)UIMenuController *titleMenu;
@property (nonatomic,retain)NSArray *dropDwonTitlesArray;
@property (nonatomic,retain)HTDropDownView *titleDropDown;

@property (nonatomic, retain)HTActivityIndicatorView *dpActivityIdicatorView;
@property (nonatomic, retain)HTActivityIndicatorView *accountInfoActivityIdicatorView;

@property (weak, nonatomic) IBOutlet HTTableView *hobbiesTableView;
@property (weak, nonatomic) IBOutlet HTScrollView *profileScrollView;
@property (weak, nonatomic) IBOutlet HTButton *dpButton;
@property (weak, nonatomic) IBOutlet HTButton *accountInfoButton;
@property (weak, nonatomic) IBOutlet HTButton *nameTitleButton;
@property (weak, nonatomic) IBOutlet HTButton *saveButton;
@property (weak, nonatomic) IBOutlet HTButton *deleteHobbiesButton;
@property (weak, nonatomic) IBOutlet HTButton *addNewHobbyButton;

@property (weak, nonatomic) IBOutlet HTTextField *firstNameTF;
@property (weak, nonatomic) IBOutlet HTTextField *lastNameTF;
@property (weak, nonatomic) IBOutlet HTTextField *addressCountryTF;
@property (weak, nonatomic) IBOutlet HTTextField *addressPostCodeTF;
@property (weak, nonatomic) IBOutlet HTTextField *addressLine1TF;
@property (weak, nonatomic) IBOutlet HTTextField *addressLine2TF;
@property (weak, nonatomic) IBOutlet HTTextField *addressLine3TF;
@property (weak, nonatomic) IBOutlet HTTextField *addressCityTF;
@property (weak, nonatomic) IBOutlet HTTextField *addressStateTF;

@property (weak, nonatomic) IBOutlet HTLabel *phoneNumberlabel;
@property (weak, nonatomic) IBOutlet HTLabel *emailLabel;
@property (weak, nonatomic) IBOutlet HTLabel *addressLabel;

- (void)populateProfileViewWithDictionary:(NSDictionary*)profileDicionary;
- (void)populatePersonInfoWithDictionary:(NSDictionary*)personalInfo;
- (void)updateTextField:(HTTextField*)textfield withText:(NSString*)updatedText;
- (void)mrNameTitleSelected;
- (void)msNameTitleSelected;
- (void)uploadProfile;
- (void)downloadUserProfile;
- (void)downloadUserProfilePersonalInfo;
- (void)downloadDP;
- (void)showDPActivityIndicatorView;
- (void)hideDPActivityIndicatorView;

- (IBAction)deleteHobbiesButtonTouched:(HTButton *)sender;
- (IBAction)addNewHobbyButtonTouched:(HTButton *)sender;
- (IBAction)saveButtonTouched:(HTButton *)sender;
- (IBAction)dpButtonTouched:(HTButton *)sender;
- (IBAction)accountInfoButtonTouched:(HTButton *)sender;
- (IBAction)nameTitleButtonTouched:(HTButton *)sender;

- (void)onMenuWillShowNotification:(NSNotification*)notification;
- (void)onMenuWillHideNotification:(NSNotification*)notification;
- (void)onDownloadDPResultNotification:(NSNotification*)notification;
- (void)onPersonalInformationUpdateResultNotification:(NSNotification*)notification;
- (void)onPersonalInformationDownloadResultNotification:(NSNotification*)notification;
- (void)onAccountInfoChangedNotification:(NSNotification*)notification;
- (void)onDPChangedNotification:(NSNotification*)notification;

@end

@implementation HTProfileViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.dropDwonTitlesArray = @[@"Mr",@"Mrs",@"Miss",@"Ms",@"Dr"];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
   // _profileScrollView.contentSize = CGSizeMake(_profileScrollView.contentSize.width, _hobbiesTableView.frame.origin.y+_hobbiesTableView.frame.size.height);
    _profileScrollView.contentSize = CGSizeMake(_profileScrollView.contentSize.width, _addressStateTF.frame.origin.y+_addressStateTF.frame.size.height);

    [_profileScrollView flashScrollIndicators];
    [self downloadUserProfile];
    
    UIMenuItem *mr = [[UIMenuItem alloc] initWithTitle:kMrTitleString action:@selector(mrNameTitleSelected)];
    UIMenuItem *ms = [[UIMenuItem alloc] initWithTitle:kMsTitleString action:@selector(msNameTitleSelected)];
    self.titleMenu = [UIMenuController sharedMenuController];
    [_titleMenu setMenuItems:[NSArray arrayWithObjects:mr,ms, nil]];
    _titleMenu.arrowDirection = UIMenuControllerArrowLeft;
    
    self.titleDropDown = [[HTDropDownView alloc] initWithFrame:CGRectMake(_nameTitleButton.frame.origin.x, _nameTitleButton.frame.origin.y+_nameTitleButton.frame.size.height, _nameTitleButton.frame.size.width, _nameTitleButton.frame.size.height*6)];
    _titleDropDown.dropDownTextsArray = _dropDwonTitlesArray;
    _titleDropDown.dropDownDelegate = self;
    [self.profileScrollView addSubview:_titleDropDown];
    _titleDropDown.hidden = YES;
    
    self.dpButton.layer.cornerRadius = self.dpButton.frame.size.width/2;
    self.dpButton.layer.borderColor = [[UIColor clearColor] CGColor];
    self.dpButton.layer.masksToBounds = YES;
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [HTUtility addNotificationObserver:self selector:@selector(onMenuWillShowNotification:) forNotificationWithName:UIMenuControllerWillShowMenuNotification];
    [HTUtility addNotificationObserver:self selector:@selector(onMenuWillHideNotification:) forNotificationWithName:UIMenuControllerWillHideMenuNotification];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [HTUtility removeNotificationObserver:self withNotificationName:UIMenuControllerWillShowMenuNotification];
    [HTUtility removeNotificationObserver:self withNotificationName:UIMenuControllerWillHideMenuNotification];
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)canBecomeFirstResponder
{
    return _isSelectingNameTitle;//only if user is selecting title
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender
{
    //only if user is selecting title
    return _isSelectingNameTitle && [super canPerformAction:action withSender:sender];
}

#pragma mark- Custom methods

- (void)populateProfileViewWithDictionary:(NSDictionary*)profileDicionary
{
    self.dpBlobID = [[profileDicionary objectForKey:kLoggedInUserDPBlobIDKey] integerValue];
    UIImage *dpImage = [[HTUserProfileManager sharedManager] getDpImage];
    if (dpImage) {
        [self.dpButton setBackgroundImage:dpImage forState:UIControlStateNormal];
    }else{
        [self downloadDP];
    }
    _phoneNumberlabel.text = [profileDicionary objectForKey:kLoggedInUserPhoneNumberKey];
    NSString *emailString = [profileDicionary objectForKey:kLoggedInUserEmailKey];
    if (emailString) {
        _emailLabel.text = emailString;
    }
}

- (void)populatePersonInfoWithDictionary:(NSDictionary*)personalInfo
{
    NSString *title = [personalInfo objectForKey:kLoggedInUserTitleKey];
    if (title.length>0) {
        [_nameTitleButton setTitle:title forState:UIControlStateNormal];
        _nameTitleButton.tag = 2;//just update tag to any number except 1, 1 is default
    }
    [self updateTextField:_firstNameTF withText:[personalInfo objectForKey:kLoggedInUserFirstNameKey]];
    [self updateTextField:_lastNameTF withText:[personalInfo objectForKey:kLoggedInUserLastNameKey]];
    [self updateTextField:_addressCountryTF withText:[personalInfo objectForKey:kLoggedInUserAddressCountryKey]];
    [self updateTextField:_addressPostCodeTF withText:[personalInfo objectForKey:kLoggedInUserAddressPostCodeKey]];
    [self updateTextField:_addressLine1TF withText:[personalInfo objectForKey:kLoggedInUserAddressLine1Key]];
    [self updateTextField:_addressLine2TF withText:[personalInfo objectForKey:kLoggedInUserAddressLine2Key]];
    [self updateTextField:_addressLine3TF withText:[personalInfo objectForKey:kLoggedInUserAddressLine3Key]];
    [self updateTextField:_addressCityTF withText:[personalInfo objectForKey:kLoggedInUserAddressCityKey]];
    [self updateTextField:_addressStateTF withText:[personalInfo objectForKey:kLoggedInUserAddressStateKey]];
    
    id hobbies = [personalInfo objectForKey:kLoggedInUserHobbiesKey];
    if ([hobbies isKindOfClass:NSArray.class]) {
        if (hobbies) {
            self.hobbiesArray = [NSMutableArray arrayWithArray:hobbies];
            [_hobbiesTableView reloadData];
        }else
        {
            self.hobbiesArray = [[NSMutableArray alloc] init];
        }
    }else
    {
        self.hobbiesArray = [[NSMutableArray alloc] init];
    }
}

- (void)updateTextField:(HTTextField*)textfield withText:(NSString*)updatedText
{
    if (updatedText) {
        textfield.text = updatedText;
    }
    //else default placeholder string should appear
}

- (IBAction)saveButtonTouched:(HTButton *)sender {
    [self uploadProfile];
}

- (IBAction)dpButtonTouched:(HTButton *)sender {
    HTDPViewController *dpVC = [[HTDPViewController alloc] init];
    dpVC.dpImage = _dpButton.currentBackgroundImage;
    [HTUtility addNotificationObserver:self selector:@selector(onDPChangedNotification:) forNotificationWithName:kDPChangedNotificationName];
    [self navigateForwardTo:dpVC];
}

- (IBAction)accountInfoButtonTouched:(HTButton *)sender {
    HTAccountViewController *accountVC = [[HTAccountViewController alloc] init];
    accountVC.phoneNumberString = _phoneNumberlabel.text;
    accountVC.emailString = _emailLabel.text;
    
    [HTUtility addNotificationObserver:self selector:@selector(onAccountInfoChangedNotification:) forNotificationWithName:kAccountInfoChangedNotificationName];
    [self navigateForwardTo:accountVC];
}

- (IBAction)nameTitleButtonTouched:(HTButton *)sender
{
    _titleDropDown.hidden = !_titleDropDown.hidden;

//    self.isSelectingNameTitle = YES;
//    [_titleMenu setTargetRect:sender.frame inView:sender.superview];
//    [self becomeFirstResponder];
//    [_titleMenu setMenuVisible:YES animated:YES];
}

- (void)mrNameTitleSelected
{
    _nameTitleButton.tag = 2;//just update tag to any number except 1, 1 is default
    [_nameTitleButton setTitle:kMrTitleString forState:UIControlStateNormal];
}
- (void)msNameTitleSelected
{
    _nameTitleButton.tag = 2;//just update tag to any number except 1, 1 is default
    [_nameTitleButton setTitle:kMsTitleString forState:UIControlStateNormal];
}

- (void)downloadUserProfile
{
    NSDictionary *profileDictionary = [[HTUserProfileManager sharedManager] currentUserProfile];
    if ([profileDictionary objectForKey:kLoggedInUserPersonInfoObjectIDKey]) {
        [self populatePersonInfoWithDictionary:profileDictionary];
    }else{
        [self downloadUserProfilePersonalInfo];
    }
    [self populateProfileViewWithDictionary:profileDictionary];
}

- (void)downloadUserProfilePersonalInfo
{
    [self showFullScreenAcitvityIndicatorView];
    __block HTSessionRenew *sessionRenew = [[HTSessionRenew alloc] init];
    [self.renewSessionObjectsArray addObject:sessionRenew];
    [sessionRenew renewSessionWithCallbackBlock:^(bool succeeded, bool isLogout) {
        [self hideFullScreenAcitvityIndicatorView];
        [self.renewSessionObjectsArray removeObject:sessionRenew];
        sessionRenew  = nil;
        if (isLogout) {
            [self forceLogoutCurrentUser];
        }else
        {
            if (succeeded)
            {
                [self showFullScreenAcitvityIndicatorView];
                [HTUtility addNotificationObserver:self selector:@selector(onPersonalInformationDownloadResultNotification:) forNotificationWithName:kProfilePersonalInfoDownloadNotificationName];
                id networkOjbect = [[HTUserProfileManager sharedManager] downloadPersonalInformationWithCompletionNotificationName:kProfilePersonalInfoDownloadNotificationName];
                [self performingNetworkCallWithObject:networkOjbect forNotificationName:kProfilePersonalInfoDownloadNotificationName];
            }else
            {
                //Handled in renewSession class
            }
        }
    }];
}


- (void)uploadProfile
{
    if(_nameTitleButton.tag == 1)
    {
        [HTUtility showInfo:kNameTitleMissingString];
    }
    else if(_firstNameTF.text.length < 1)
    {
        [HTUtility showInfo:kFirstNameMissingString];
    }
    else if(_lastNameTF.text.length < 1)
    {
        [HTUtility showInfo:kLastNameMissingString];
    }
    else{
        
        [self showFullScreenAcitvityIndicatorView];
        __block HTSessionRenew *sessionRenew = [[HTSessionRenew alloc] init];
        [self.renewSessionObjectsArray addObject:sessionRenew];
        [sessionRenew renewSessionWithCallbackBlock:^(bool succeeded, bool isLogout) {
            [self hideFullScreenAcitvityIndicatorView];
            [self.renewSessionObjectsArray removeObject:sessionRenew];
            sessionRenew  = nil;
            if (isLogout) {
                [self forceLogoutCurrentUser];
            }else
            {
                if (succeeded)
                {
                    [self showFullScreenAcitvityIndicatorView];
                    [HTUtility addNotificationObserver:self selector:@selector(onPersonalInformationUpdateResultNotification:) forNotificationWithName:kProfilePersonalInformationUpdateResultNotificationName];
                    NSMutableDictionary *userProfileDictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:_nameTitleButton.currentTitle,kLoggedInUserTitleKey,
                                                                  _firstNameTF.text,kLoggedInUserFirstNameKey,
                                                                  _lastNameTF.text, kLoggedInUserLastNameKey,
                                                                  [[[HTUserProfileManager sharedManager] currentUserProfile] objectForKey:kLoggedInUserIDKey],
                                                                  kLoggedInUserIDKey,
                                                                  nil];
                    [userProfileDictionary setObject:_addressCountryTF.text.length>0?_addressCountryTF.text:@"" forKey:kLoggedInUserAddressCountryKey];
                    [userProfileDictionary setObject:_addressPostCodeTF.text.length>0?_addressPostCodeTF.text:@"" forKey:kLoggedInUserAddressPostCodeKey];
                    [userProfileDictionary setObject:_addressLine1TF.text.length>0?_addressLine1TF.text:@"" forKey:kLoggedInUserAddressLine1Key];
                    [userProfileDictionary setObject:_addressLine2TF.text.length>0?_addressLine2TF.text:@"" forKey:kLoggedInUserAddressLine2Key];
                    [userProfileDictionary setObject:_addressLine3TF.text.length>0?_addressLine3TF.text:@"" forKey:kLoggedInUserAddressLine3Key];
                    [userProfileDictionary setObject:_addressCityTF.text.length>0?_addressCityTF.text:@"" forKey:kLoggedInUserAddressCityKey];
                    [userProfileDictionary setObject:_addressStateTF.text.length>0?_addressStateTF.text:@"" forKey:kLoggedInUserAddressStateKey];
                    
                    [userProfileDictionary setObject:_hobbiesArray?_hobbiesArray:[[NSArray alloc] init] forKey:kLoggedInUserHobbiesKey];
                    NSString *personalInfoIDObject = [[[HTUserProfileManager sharedManager] currentUserProfile] objectForKey:kLoggedInUserPersonInfoObjectIDKey];
                    [userProfileDictionary setObject:personalInfoIDObject.length>0?personalInfoIDObject:@"" forKey:kLoggedInUserPersonInfoObjectIDKey];
                    

                    id networkOjbect = [[HTUserProfileManager sharedManager] updatePersonInformationWithDictionary:userProfileDictionary completionNotificationName:kProfilePersonalInformationUpdateResultNotificationName];
                    [self performingNetworkCallWithObject:networkOjbect forNotificationName:kProfilePersonalInformationUpdateResultNotificationName];
                }else
                {
                    //Handled in renewSession class
                }
            }
        }];
    }
}

- (void)downloadDP
{
    [self showFullScreenAcitvityIndicatorView];
    __block HTSessionRenew *sessionRenew = [[HTSessionRenew alloc] init];
    [self.renewSessionObjectsArray addObject:sessionRenew];
    [sessionRenew renewSessionWithCallbackBlock:^(bool succeeded, bool isLogout) {
        [self hideFullScreenAcitvityIndicatorView];
        [self.renewSessionObjectsArray removeObject:sessionRenew];
        sessionRenew  = nil;
        if (isLogout) {
            [self forceLogoutCurrentUser];
        }else
        {
            if (succeeded)
            {
                [self showDPActivityIndicatorView];
                _dpButton.enabled = NO;
                [HTUtility addNotificationObserver:self selector:@selector(onDownloadDPResultNotification:) forNotificationWithName:kProfileDownloadDPResultNotificationName];
                id networkOjbect = [[HTUserProfileManager sharedManager] downloadDpImageWithCompletionNotificationName:kProfileDownloadDPResultNotificationName];
                [self performingNetworkCallWithObject:networkOjbect forNotificationName:kProfileDownloadDPResultNotificationName];
            }else
            {
                //Handled in renewSession class
            }
        }
    }];
}

- (void)showDPActivityIndicatorView
{
    self.dpActivityIdicatorView = [[HTActivityIndicatorView alloc] initWithFrame:self.dpButton.bounds];
    [self.dpButton addSubview:_dpActivityIdicatorView];
    [self.dpButton bringSubviewToFront:_dpActivityIdicatorView];
}

- (void)hideDPActivityIndicatorView
{
    [_dpActivityIdicatorView removeFromSuperview];
    self.dpActivityIdicatorView = nil;
}

- (BOOL)isMenuActive
{
    return (![[HTUserProfileManager sharedManager] isProfileUpdateNeeded]);
}

- (void)showMenuInactiveMessage
{
    [HTUtility showInfo:kUpdateProfileInfoBeforeProceedingString];
}

- (IBAction)deleteHobbiesButtonTouched:(HTButton *)sender {
    sender.selected = !sender.selected;
    [_hobbiesTableView setEditing:!_hobbiesTableView.editing animated:YES];
}

- (IBAction)addNewHobbyButtonTouched:(HTButton *)sender {
    UIAlertView *addNewHobbyView = [[UIAlertView alloc] initWithTitle:kAppName message:kAddHobbyString delegate:self cancelButtonTitle:kCancelString otherButtonTitles:kAddString, nil];
    addNewHobbyView.alertViewStyle = UIAlertViewStylePlainTextInput;
    addNewHobbyView.tag = kAddHobbyStringViewTag;
    [addNewHobbyView show];
}

#pragma mark- Dropdown Methods
- (void)dropDownItemSelectedAtIndex:(NSInteger)index
{
    [_nameTitleButton setTitle:_dropDwonTitlesArray[index] forState:UIControlStateNormal];
    _nameTitleButton.tag = 2;//just update tag to any number except 1, 1 is default
    _titleDropDown.hidden = YES;
}

#pragma mark- notification methods

- (void)onDownloadDPResultNotification:(NSNotification*)notification
{
    [self hideDPActivityIndicatorView];
    [HTUtility removeNotificationObserver:self withNotificationName:notification.name];
    [self networkCallFinishedForNotificationName:notification.name];
    _dpButton.enabled = YES;
    NSDictionary *dpDownloadResultDictionary = [notification userInfo];
    BOOL success = [[dpDownloadResultDictionary objectForKey:kResponseSuccessKey] boolValue];
    if (success)
    {
        UIImage *dpImageDownloaded = [dpDownloadResultDictionary objectForKey:kLoggedInUserDPImageIDKey];
        if (dpImageDownloaded) {
            [_dpButton setBackgroundImage:dpImageDownloaded forState:UIControlStateNormal];
            [[HTUserProfileManager sharedManager] saveDPImagePermanentally:dpImageDownloaded];
        }
    }else{
        //Show try again view for downloading dp
        UIAlertView *dpDownloadingFailedView = [[UIAlertView alloc] initWithTitle:@"Image Failed" message:kDPDownloadingFailedTryAgainString delegate:self cancelButtonTitle:kCancelString otherButtonTitles:kTryAgainString, nil];
        dpDownloadingFailedView.tag = kDPDownloadingFailedTryAgainStringViewTag;
        [dpDownloadingFailedView show];
    }
}

- (void)onPersonalInformationUpdateResultNotification:(NSNotification*)notification
{
    [self hideFullScreenAcitvityIndicatorView];
    [HTUtility removeNotificationObserver:self withNotificationName:notification.name];
    [self networkCallFinishedForNotificationName:notification.name];
    NSDictionary *profileUploadResultDictionary = [notification userInfo];
    BOOL success = [[profileUploadResultDictionary objectForKey:kResponseSuccessKey] boolValue];
    if (success)
    {
        //[HTUtility showInfo:kProfileUploadingSuccessfulString];
       // [self navigateBack:nil];
        [HTUtility appDelegate].window.rootViewController = [HTUtility appDelegate].requestRideNavController;
    }else{
        //Show try again view for uploading profile
        UIAlertView *profileUploadingFailedView = [[UIAlertView alloc] initWithTitle:@"Update Failed" message:kProfileUploadingFailedTryAgainString delegate:self cancelButtonTitle:kCancelString otherButtonTitles:@"Save Again", nil];
        profileUploadingFailedView.tag = kPersonalInfoUploadingFailedTryAgainStringViewTag;
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
        NSDictionary *personalInfo = [personalInfoDonwloadResultDictionary objectForKey:kProfilePersonalInformationKey];
        [self populatePersonInfoWithDictionary:personalInfo];
        
    }else{
        //Show try again downloading personal info
        UIAlertView *personalInfoDonwloadTryAgainView = [[UIAlertView alloc] initWithTitle:@"Network Problem" message:kProfilePersonalInfoDownloadingFailedTryAgainString delegate:self cancelButtonTitle:kCancelString otherButtonTitles:kTryAgainString, nil];
        personalInfoDonwloadTryAgainView.tag = kProfilePersonalInfoDownloadingFailedTryAgainStringViewTag;
        [personalInfoDonwloadTryAgainView show];
    }
}

- (void)onAccountInfoChangedNotification:(NSNotification*)notification
{
    [HTUtility removeNotificationObserver:self withNotificationName:notification.name];
    NSDictionary *accountInfo = [notification userInfo];
    NSString *phoneNumber = [accountInfo objectForKey:kLoggedInUserPhoneNumberKey];
    NSString *emailAddress = [accountInfo objectForKey:kLoggedInUserEmailKey];
    if (phoneNumber) {
        _phoneNumberlabel.text = phoneNumber;
    }
    if (emailAddress) {
        _emailLabel.text = emailAddress;
    }
    [self navigateBack:nil];
}

- (void)onDPChangedNotification:(NSNotification*)notification
{
    [self navigateBack:nil];
    [HTUtility removeNotificationObserver:self withNotificationName:notification.name];
    NSDictionary *dpDictioary = [notification userInfo];
    UIImage *changedImage = [dpDictioary objectForKey:kDPCroppedImageKey];
    if (changedImage) {
        [_dpButton setBackgroundImage:changedImage forState:UIControlStateNormal];
    }
}

- (void)onMenuWillShowNotification:(NSNotification*)notification
{
    self.isSelectingNameTitle = YES;
}

- (void)onMenuWillHideNotification:(NSNotification*)notification
{
    self.isSelectingNameTitle = NO;
}

#pragma mark-


- (IBAction)navigateBack:(HTButton *)sender
{
    if (![[HTUserProfileManager sharedManager] isProfileUpdateNeeded]) {
        [HTUtility removeNotificationObserver:self withNotificationName:nil];
        [super navigateBack:sender];
    }else{
        if(sender)
        {
            [HTUtility showInfo:kUpdateProfileInfoBeforeProceedingString];
        }else{
            [super navigateBack:sender];
        }
    }
}


#pragma mark- Alert delegate

- (BOOL)alertViewShouldEnableFirstOtherButton:(UIAlertView *)alertView
{
    if (alertView.tag == kAddHobbyStringViewTag) {
        UITextField *newHobbyTF = [alertView textFieldAtIndex:0];
        return [newHobbyTF.text stringByReplacingOccurrencesOfString:@" " withString:@""].length > 0;
    }
    return YES;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag == kDPDownloadingFailedTryAgainStringViewTag) {
        if (buttonIndex == 1) {
            [self downloadDP];
        }
    }
    else if (alertView.tag == kPersonalInfoUploadingFailedTryAgainStringViewTag) {
        if (buttonIndex == 1) {
            [self uploadProfile];
        }
    }
    else if (alertView.tag == kProfilePersonalInfoDownloadingFailedTryAgainStringViewTag)
    {
        if (buttonIndex == 1) {
            [self downloadUserProfilePersonalInfo];
        }
    }
    else if (alertView.tag == kAddHobbyStringViewTag) {
        if (buttonIndex == 1) {
            UITextField *newHobbyTF = [alertView textFieldAtIndex:0];
            [_hobbiesArray addObject:newHobbyTF.text];
            [_hobbiesTableView insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow: _hobbiesArray.count-1 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
        }
    }
}

#pragma mark - TableView methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _hobbiesArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellID = @"CELL_ID";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
        cell.backgroundColor = [UIColor clearColor];
    }
    cell.textLabel.text = [_hobbiesArray objectAtIndex:indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(editingStyle == UITableViewCellEditingStyleDelete)
    {
        [_hobbiesArray removeObjectAtIndex:indexPath.row];
        [_hobbiesTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

#pragma mark- Gesture methods
- (IBAction)tabGestureRecognized:(UITapGestureRecognizer*)gesture
{
    if (gesture.view == _profileScrollView) {
        [self endEditing:YES];
    }
}

@end
