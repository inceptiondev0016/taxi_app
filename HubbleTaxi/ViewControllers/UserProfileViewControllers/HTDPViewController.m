//
//  HTDPViewController.m
//  HubbleTaxi
//
//  Created by Aamir Javed on 12/02/2014.
//  Copyright (c) 2014 Apponative. All rights reserved.
//

#import "HTDPViewController.h"
#import "HTUserProfileManager.h"
#import "HTDPEdittingViewController.h"

@interface HTDPViewController ()<UIImagePickerControllerDelegate,UINavigationControllerDelegate>
{
}
@property (nonatomic,assign)NSUInteger dpBlobID;
@property (weak, nonatomic) IBOutlet HTLabel *dpDescriptionLabel;
@property (weak, nonatomic) IBOutlet HTButton *dpEditButton;
@property (weak, nonatomic) IBOutlet HTButton *saveButton;
@property (weak, nonatomic) IBOutlet HTButton *dpButton;
@property (weak, nonatomic) IBOutlet HTView *actionsheetView;
@property (weak, nonatomic) IBOutlet HTLabel *actionSheetLabel;
@property (weak, nonatomic) IBOutlet HTButton *editCurrentPicButton;
@property (weak, nonatomic) IBOutlet HTButton *chooseFromPhotosButton;
@property (weak, nonatomic) IBOutlet HTButton *takeFromCameraButton;
@property (weak, nonatomic) IBOutlet HTButton *actionsheetCancelButton;

- (IBAction)dpEditButtonTouched:(HTButton *)sender;
- (IBAction)saveButtonTouched:(HTButton *)sender;
- (IBAction)actionsheetButtonTouched:(HTButton *)sender;

- (void)uploadDP;
- (void)navigateBackWithUpdatedDP;

- (void)onDPCroppedNotification:(NSNotification*)notification;
- (void)onUploadDPResultNotification:(NSNotification*)notification;
@end

@implementation HTDPViewController

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
    self.dpButton.layer.cornerRadius = self.dpButton.frame.size.width/2;
    self.dpButton.layer.borderColor = [[UIColor clearColor] CGColor];
    self.dpButton.layer.masksToBounds = YES;
    if (_dpImage) {
        [_dpButton setBackgroundImage:_dpImage forState:UIControlStateNormal];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Custom methods
- (IBAction)dpEditButtonTouched:(HTButton *)sender
{
    [_actionsheetView setHidden:NO];
    [self moveView:_actionsheetView toScreenPositon:screenPositionOutsideBottomY];
    [UIView animateWithDuration:kDefaultViewMovingAnimtionTime animations:^{
        _actionsheetView.center = CGPointMake(_actionsheetView.center.x, self.view.center.y);
    } completion:^(BOOL finished) {
    }];
}

- (IBAction)saveButtonTouched:(HTButton *)sender
{
    [self uploadDP];
}

- (IBAction)actionsheetButtonTouched:(HTButton *)sender
{
    int buttonIndex = sender.tag;
    switch (buttonIndex) {
        case 0:
        {
            HTDPEdittingViewController *dpEditVC = [[HTDPEdittingViewController alloc] init];
            dpEditVC.dpImage = _dpImage;
            [HTUtility addNotificationObserver:self selector:@selector(onDPCroppedNotification:) forNotificationWithName:kdpCroppedNotificationName];
            [self navigateForwardTo:dpEditVC];
        }
            break;
        case 1:
        {
            if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
                UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
                imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                imagePickerController.delegate = self;
                [self presentViewController:imagePickerController animated:YES completion:nil];
            }else
            {
                [HTUtility showInfo:kPhotosNotAvailableString];
            }
        }
            break;
        case 2:
        {
            if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
                UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
                imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
                imagePickerController.delegate = self;
                [self presentViewController:imagePickerController animated:YES completion:nil];
            }else
            {
                [HTUtility showInfo:kCameraNotAvailableString];
            }
        }
            break;
            
        default:
            break;
    }
    [UIView animateWithDuration:kDefaultViewMovingAnimtionTime animations:^{
        [self moveView:_actionsheetView toScreenPositon:screenPositionOutsideBottomY];
    } completion:^(BOOL finished) {
    }];
}

- (void)uploadDP
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
                [HTUtility addNotificationObserver:self selector:@selector(onUploadDPResultNotification:) forNotificationWithName:kProfileUploadDPResultNotificationName];
                id networkOjbect = [[HTUserProfileManager sharedManager] uploadDPImage:_dpButton.currentBackgroundImage completionNotificationName:kProfileUploadDPResultNotificationName];
                [self performingNetworkCallWithObject:networkOjbect forNotificationName:kProfileUploadDPResultNotificationName];
            }else
            {
                //Handled in renewSession class
            }
        }
    }];
}

- (IBAction)navigateBack:(HTButton *)sender
{
    [HTUtility postNotificationWithName:kDPChangedNotificationName userInfo:nil];
}

- (void)navigateBackWithUpdatedDP
{
    NSDictionary *dpDictioary = [NSDictionary dictionaryWithObject:_dpImage forKey:kDPCroppedImageKey];
    [HTUtility postNotificationWithName:kDPChangedNotificationName userInfo:dpDictioary];
}

#pragma mark- ImagePicker delegate methods
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [self dismissViewControllerAnimated:NO completion:nil];
    
    UIImage *image = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
    HTDPEdittingViewController *dpEditVC = [[HTDPEdittingViewController alloc] init];
    dpEditVC.dpImage = image;
    [HTUtility addNotificationObserver:self selector:@selector(onDPCroppedNotification:) forNotificationWithName:kdpCroppedNotificationName];
    [self navigateForwardTo:dpEditVC];
}


#pragma mark- notification methods

- (void)onDPCroppedNotification:(NSNotification*)notification
{
    [HTUtility removeNotificationObserver:self withNotificationName:notification.name];
    [super navigateBack:nil];
    UIImage *croppedImage = [[notification userInfo] objectForKey:kDPCroppedImageKey];
    if (croppedImage) {
        self.dpImage = croppedImage;
        [_dpButton  setBackgroundImage:croppedImage forState:UIControlStateNormal];
    }
    //else image cropping cancelled
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
        [[HTUserProfileManager sharedManager] saveDPImagePermanentally:_dpButton.currentBackgroundImage];
        [self navigateBackWithUpdatedDP];//updated dp will be sent through notification
       // [HTUtility showInfo:kDPUploadingSuccessfulString];
    }else{
        //Show try again view for uploading dp
        UIAlertView *dpUploadingFailedView = [[UIAlertView alloc] initWithTitle:@"Upload Failed" message:kDPUploadingFailedTryAgainString delegate:self cancelButtonTitle:kCancelString otherButtonTitles:@"Save Again", nil];
        dpUploadingFailedView.tag = kDPUploadingFailedTryAgainStringViewTag;
        [dpUploadingFailedView show];
    }
}

#pragma mark- Alert delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag == kDPUploadingFailedTryAgainStringViewTag) {
        if (buttonIndex == 1) {
            [self uploadDP];
        }
    }
}

@end
