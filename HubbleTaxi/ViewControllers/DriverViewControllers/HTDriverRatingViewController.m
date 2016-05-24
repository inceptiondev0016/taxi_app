//
//  HTDriverRatingViewController.m
//  HubbleTaxi
//
//  Created by Aamir Javed on 02/07/2014.
//  Copyright (c) 2014 Apponative. All rights reserved.
//

#import "HTDriverRatingViewController.h"
#import "HTUserBookingsManager.h"
#import <Social/Social.h>
#import <MessageUI/MessageUI.h>
#import "HTUserLocationManager.h"

@implementation HTDriverRating
@end

@interface HTDriverRatingViewController ()<UIAlertViewDelegate,UITextViewDelegate,MFMailComposeViewControllerDelegate>
@property (weak, nonatomic) IBOutlet HTButton *submitButton;
@property (nonatomic, retain)IBOutletCollection(HTImageView)NSArray *ratingImages;
@property (nonatomic,retain)HTDriverRating *driverRatingObj;
@property (weak, nonatomic) IBOutlet HTView *shareFeedbackConatinerView;
@property (weak, nonatomic) IBOutlet HTTextView *complaintBoxTV;
@property (weak, nonatomic) IBOutlet HTImageView *complaintBoxIV;
@property (weak, nonatomic) IBOutlet HTButton *fbButton;
@property (weak, nonatomic) IBOutlet HTView *dragView;
@property (nonatomic,assign)NSUInteger currentRating;


- (void)updateJob;
- (void)showAlertViewWithTag:(NSInteger)tag;
- (IBAction)submitButtonTouched:(HTButton *)sender;
- (IBAction)ratingPanGestureRecognized:(UIPanGestureRecognizer*)panGesture;
- (IBAction)ratingTapGestureRecognized:(UITapGestureRecognizer*)tapGesture;

- (void)onJobRatingUpdateResultNotification:(NSNotification*)notification;
@end

@implementation HTDriverRatingViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithRatingObject:(HTDriverRating *)driverRating
{
    self = [super init];
    if (self) {
        self.driverRatingObj = driverRating;
        self.currentRating = 5;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.view.backgroundColor = [UIColor colorWithRed:207/255.0 green:211/255.0 blue:203/255.0 alpha:1];
    NSUInteger currentRating = _currentRating;
    for (int index = 0; index < MIN(currentRating, self.ratingImages.count) && currentRating>0; index++) {
        HTImageView *ratingImageView = self.ratingImages[index];
        ratingImageView.image = [UIImage imageNamed:@"filled_star.png"];
    }
    self.shareFeedbackConatinerView.hidden = currentRating<=3;
    self.complaintBoxTV.hidden = self.complaintBoxIV.hidden = currentRating>3;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark- Action methods
- (IBAction)submitButtonTouched:(HTButton *)sender
{
    [self updateJob];
}

- (IBAction)ratingPanGestureRecognized:(UIPanGestureRecognizer*)panGesture
{
    CGPoint touchPoint = [panGesture locationInView:panGesture.view];
    [self updateRatingWithTouchAtPoint:touchPoint];
    if (panGesture.state ==  UIGestureRecognizerStateEnded) {
        [self ratingGiven];
    }
}

- (IBAction)ratingTapGestureRecognized:(UITapGestureRecognizer*)tapGesture
{
    CGPoint touchPoint = [tapGesture locationInView:tapGesture.view];
    [self updateRatingWithTouchAtPoint:touchPoint];
    [self ratingGiven];
}

- (IBAction)twitterButtonTouched:(HTButton *)sender
{
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter])
    {
        SLComposeViewController *composeController = [SLComposeViewController
                                                      composeViewControllerForServiceType:SLServiceTypeTwitter];
        [composeController setInitialText:[NSString stringWithFormat:@"I am using HubbleGo services. Download from iTunes and have fun. https://itunes.com"]];
        [composeController addImage:[UIImage imageNamed:@"Icon.png"]];
        [self presentViewController:composeController
                           animated:YES completion:nil];
        
    }else{
        [HTUtility showInfo:@"There is no Twitter acounts configured. You can add or create a Twitter account in your device Settings"];
    }
}

- (IBAction)fbButtonTouched:(HTButton *)sender
{
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook])
    {
        SLComposeViewController *composeController = [SLComposeViewController
                                                      composeViewControllerForServiceType:SLServiceTypeFacebook];
        [composeController setInitialText:[NSString stringWithFormat:@"I am using HubbleGo services. Download from iTunes and have fun. https://itunes.com"]];
        [composeController addImage:[UIImage imageNamed:@"Icon.png"]];
        [self presentViewController:composeController
                           animated:YES completion:nil];
        sender.selected = YES;
        
    }else{
        [HTUtility showInfo:@"There is no Facebook acounts configured. You can add or create a Facebook account in your device Settings"];
    }
}

- (IBAction)emailButtonTouched:(HTButton *)sender
{
    MFMailComposeViewController *mailController = [[MFMailComposeViewController alloc] init];
    mailController.mailComposeDelegate = self;
    [mailController setMessageBody:@"I am using HubbleGo services. Download from iTunes and have fun. https://itunes.com" isHTML:NO];
    [mailController addAttachmentData:UIImageJPEGRepresentation([UIImage imageNamed:@"Icon.png"], 1) mimeType:@"image" fileName:@"Icon"];
    [self presentViewController:mailController animated:YES completion:^{
        
    }];
}

#pragma mark- Custom methods

- (void)updateRatingWithTouchAtPoint:(CGPoint)touchPoint
{
    self.currentRating = 0;
    HTImageView *ratingImageView = nil;
    for (int index = 0; index < self.ratingImages.count; index++) {
        ratingImageView = self.ratingImages[index];
        ratingImageView.image = [UIImage imageNamed:@"unfilled_star.png"];
    }
    
    int rating = ceilf(1.0*touchPoint.x/ratingImageView.frame.size.width);
    for (int index = 0; index < MIN(rating, self.ratingImages.count) && rating>0; index++)
    {
        HTImageView *ratingImageView = self.ratingImages[index];
        ratingImageView.image = [UIImage imageNamed:@"filled_star.png"];
        self.currentRating = index+1;
    }
}

- (void)ratingGiven
{
    NSUInteger currentRating = _currentRating;
    for (int index = 0; index < MIN(currentRating, self.ratingImages.count) && currentRating>0; index++) {
        HTImageView *ratingImageView = self.ratingImages[index];
        ratingImageView.image = [UIImage imageNamed:@"filled_star.png"];
    }
    self.shareFeedbackConatinerView.hidden = currentRating<=3;
    self.complaintBoxTV.hidden = self.complaintBoxIV.hidden = currentRating>3;
}

- (void)updateJob
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
                [HTUtility addNotificationObserver:self selector:@selector(onJobRatingUpdateResultNotification:) forNotificationWithName:kJobRatingUpdateRestultNotificationName];
                NSMutableDictionary *jobRatingDictionary = [[NSMutableDictionary alloc] init];
                jobRatingDictionary[@"rating_given"] = [NSString stringWithFormat:@"%lu",(unsigned long)_currentRating];
                jobRatingDictionary[@"processOk"] = @"Yes";
                jobRatingDictionary[@"facebook_share"] = _fbButton.selected?@"Yes":@"No";
//                if (_driverRatingObj.isPaymentOK) {
//                    jobRatingDictionary[@"customerInstruction"] = @"Payment Ok";
//                    jobRatingDictionary[@"payment_status"] = @"Payment Ok";
//                }
                if (!_complaintBoxIV.hidden && _complaintBoxTV.text.length>0 && ![_complaintBoxTV.text isEqualToString:@"Tell us what went wrong and we promise to improve for next time"]) {
                    jobRatingDictionary[@"customerFeedback"] = _complaintBoxTV.text;
                }
                id networkOjbect = [[HTUserBookingsManager sharedManager] updateJobRatingWithInfo:jobRatingDictionary withJobID:_driverRatingObj.jobID completionNotificationName:kJobRatingUpdateRestultNotificationName];
                [self performingNetworkCallWithObject:networkOjbect forNotificationName:kJobRatingUpdateRestultNotificationName];
            }else
            {
                //Handled in renewSession class
            }
        }
    }];
}

- (void)showAlertViewWithTag:(NSInteger)tag
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:kAppName message:@"Unable to rate driver right now. Please try again" delegate:self cancelButtonTitle:kCancelString otherButtonTitles:kTryAgainString, nil];
    alertView.tag = tag;
    [alertView show];
}

#pragma mark- Notification methods
- (void)onJobRatingUpdateResultNotification:(NSNotification*)notification
{
    [self hideFullScreenAcitvityIndicatorView];
    [HTUtility removeNotificationObserver:self withNotificationName:notification.name];
    [self networkCallFinishedForNotificationName:notification.name];
    NSDictionary *jobRatingUpdateDictionary = [notification userInfo];
    BOOL success = [[jobRatingUpdateDictionary objectForKey:kResponseSuccessKey] boolValue];
    if (success)
    {
        NSString *notes = _complaintBoxTV.hidden?[NSString stringWithFormat:@"Stars:%d",_currentRating]:[NSString stringWithFormat:@"Stars:%d Comment:%@",_currentRating,_complaintBoxTV.text];
        [[HTUserBookingsManager sharedManager] logJobWithJobID:_driverRatingObj.jobID rideNumber:_driverRatingObj.jobRideNumber notes:notes type:@"Rating Received"];
        [HTUtility showInfo:@"Thanks for rating"];
        [HTUtility appDelegate].window.rootViewController = [HTUtility appDelegate].requestRideNavController;
    }else{
        [self showAlertViewWithTag:kJobRatingUpdateFailedTryAgainViewTag];
    }
}

#pragma mark- AlertView methods
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == kJobRatingUpdateFailedTryAgainViewTag) {
        if (buttonIndex == 1) {
            [self updateJob];
        }
    }
}

#pragma mark- Textview methods
- (void)textViewDidBeginEditing:(UITextView *)textView
{
    if ([textView.text isEqualToString:@"Tell us what went wrong and we promise to improve for next time"]) {
        textView.text = @"";
    }
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    if (textView.text.length ==0) {
        textView.text = @"Tell us what went wrong and we promise to improve for next time";
    }
}

#pragma mark- Mail delegate methods
- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
