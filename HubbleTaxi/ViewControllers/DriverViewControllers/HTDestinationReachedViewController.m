//
//  HTDestinationReachedViewController.m
//  HubbleTaxi
//
//  Created by Aamir Javed on 13/11/2014.
//  Copyright (c) 2014 Apponative. All rights reserved.
//

#import "HTDestinationReachedViewController.h"
#import "HTDriverRatingViewController.h"
#import "HTUserBookingsManager.h"

@interface HTDestinationReachedViewController ()<UIAlertViewDelegate>
@property (weak, nonatomic) IBOutlet HTLabel *journeyCostLabel;
@property (weak, nonatomic) IBOutlet HTLabel *additionalChargesLabel;
@property (weak, nonatomic) IBOutlet HTLabel *totalPriceLabel;
@property (nonatomic, retain)IBOutletCollection(HTButton)NSArray *tipButtons;
@property (nonatomic,retain)NSString *currentBookingJobID;
@property (nonatomic,retain)NSString *currentBookingRideNumber;
@property (nonatomic,assign)float journeyPriceValue;
@property (nonatomic,assign)float tipPercentValue;
@property (nonatomic,assign)float additionalChargesValue;
@property (nonatomic,assign)float totalPriceValue;
@property (nonatomic,weak) IBOutlet HTView *tipContainerView;
@property (nonatomic,retain)NSString *tokenID;
@property (weak, nonatomic) IBOutlet HTButton *payButton;
@property (weak, nonatomic) IBOutlet HTLabel *payLabel;
@property (nonatomic,assign)BOOL shouldHideLoading;

- (IBAction)tipButtonTouched:(HTButton *)sender;

- (void)currentBookingOrder;
- (void)updateTotalPriceLabel;
- (void)chargeCustomerCard;
- (void)paymentOK;
- (void)updateJob;

- (void)onJobRatingUpdateResultNotification:(NSNotification*)notification;
- (void)onCurrentBookingOrderResultNotification:(NSNotification*)notification;
@end

@implementation HTDestinationReachedViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithJobID:(NSString *)jobID
{
    self = [super init];
    if (self) {
        self.currentBookingJobID = jobID;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.view.backgroundColor = [UIColor colorWithRed:207/255.0 green:211/255.0 blue:203/255.0 alpha:1];
    self.tipContainerView.hidden=self.additionalChargesLabel.hidden = YES;
    self.payLabel.hidden = self.payButton.hidden = YES;
    [self currentBookingOrder];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark- Action methods
- (IBAction)tipButtonTouched:(HTButton *)sender
{
    for (int index = 0 ; index < _tipButtons.count; index++) {
        UIButton *tipButton = _tipButtons[index];
        tipButton.selected = tipButton.tag!= sender.tag?NO:!sender.selected;
    }
    self.tipPercentValue = sender.selected?sender.tag:0;
    [self updateTotalPriceLabel];
}

- (IBAction)payButtonTouched:(HTButton *)sender
{
    [self chargeCustomerCard];
}

#pragma mark- Custom methods

- (void)paymentOK
{
    float totalPrice = [[NSString stringWithFormat:@"%0.1f0",roundf(_totalPriceValue*10)/10] floatValue];
    HTDriverRating *driverRatingObj = [[HTDriverRating alloc] init];
    driverRatingObj.price = totalPrice;
    driverRatingObj.tokenID = _tokenID;
    driverRatingObj.tipValue = _tipPercentValue*_journeyPriceValue/100;
    driverRatingObj.jobID = _currentBookingJobID;
    driverRatingObj.isPaymentOK = _tokenID.length?YES:NO;
    driverRatingObj.jobRideNumber = _currentBookingRideNumber;
    [self navigateForwardTo:[[HTDriverRatingViewController alloc] initWithRatingObject:driverRatingObj]];
}

- (void)currentBookingOrder
{
    if (!_shouldHideLoading) {
        [self showFullScreenAcitvityIndicatorView];
    }
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
                if (!_shouldHideLoading) {
                    [self showFullScreenAcitvityIndicatorView];
                }
                [HTUtility addNotificationObserver:self selector:@selector(onCurrentBookingOrderResultNotification:) forNotificationWithName:kBookingOrderRestultNotificationName];
                id networkOjbect = [[HTUserBookingsManager sharedManager] bookingOrderWithJobID:_currentBookingJobID completionNotificationName:kBookingOrderRestultNotificationName];
                [self performingNetworkCallWithObject:networkOjbect forNotificationName:kBookingOrderRestultNotificationName];
            }else
            {
                //Handled in renewSession class
            }
        }
    }];
}

- (void)updateTotalPriceLabel
{
    self.totalPriceValue = _journeyPriceValue*(1+_tipPercentValue/100)+_additionalChargesValue;
    self.totalPriceLabel.text = [NSString stringWithFormat:@"£%0.1f0",roundf(_totalPriceValue*10)/10];
}

- (void)chargeCustomerCard
{
    [self showFullScreenAcitvityIndicatorView];
    int priceToCharge = roundf(_totalPriceValue*10)*10;
    if (_totalPriceValue > 0) {
        [PFCloud callFunctionInBackground:@"charge" withParameters:@{@"amount":[NSString stringWithFormat:@"%d",priceToCharge],@"token":_tokenID, @"jobDescription":[NSString stringWithFormat:@"Job number: %@",_currentBookingRideNumber]} block:^(id object, NSError *error) {
            [self hideFullScreenAcitvityIndicatorView];
            if (object && !error) {
                [[HTUserBookingsManager sharedManager] logJobWithJobID:_currentBookingJobID rideNumber:_currentBookingRideNumber notes:[NSString stringWithFormat:@"Card:£%0.1f0",roundf(_totalPriceValue*10)/10] type:@"Payment Received"];
                [self updateJob];
            }else
            {
                [[HTUserBookingsManager sharedManager] logJobWithJobID:_currentBookingJobID rideNumber:_currentBookingRideNumber notes:[NSString stringWithFormat:@"Card:£%0.1f0",roundf(_totalPriceValue*10)/10] type:@"Failed Payment Attempt"];
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:kAppName message:@"We are unable to process your card. Make sure you have entered valid card details." delegate:self cancelButtonTitle:kCancelString otherButtonTitles:kTryAgainString, nil];
                alertView.tag = kChargeUserCardFailedViewTag;
                [alertView show];
            }
        }];
    }else{
        [[HTUserBookingsManager sharedManager] logJobWithJobID:_currentBookingJobID rideNumber:_currentBookingRideNumber notes:[NSString stringWithFormat:@"Card:£%0.1f0",roundf(_totalPriceValue*10)/10] type:@"Payment Received"];
        [self updateJob];
    }
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
                jobRatingDictionary[@"tip_given"] = [NSString stringWithFormat:@"%0.1f0",roundf(_tipPercentValue*_journeyPriceValue/100*10)/10];
                float totalPrice = [[NSString stringWithFormat:@"%0.1f0",roundf(_totalPriceValue*10)/10] floatValue];
                jobRatingDictionary[@"final_price"] = [NSString stringWithFormat:@"%0.1f0",roundf(totalPrice*10)/10];
                jobRatingDictionary[@"customerInstruction"] = @"Payment Ok";
                jobRatingDictionary[@"payment_status"] = @"Payment Ok";
                
                id networkOjbect = [[HTUserBookingsManager sharedManager] updateJobRatingWithInfo:jobRatingDictionary withJobID:_currentBookingJobID completionNotificationName:kJobRatingUpdateRestultNotificationName];
                [self performingNetworkCallWithObject:networkOjbect forNotificationName:kJobRatingUpdateRestultNotificationName];
            }else
            {
                //Handled in renewSession class
            }
        }
    }];
}

#pragma mark- Notification methods
- (void)onCurrentBookingOrderResultNotification:(NSNotification*)notification
{
    [self hideFullScreenAcitvityIndicatorView];
    [HTUtility removeNotificationObserver:self withNotificationName:notification.name];
    [self networkCallFinishedForNotificationName:notification.name];
    NSDictionary *currentBookingResultDictionary = [notification userInfo];
    BOOL success = [[currentBookingResultDictionary objectForKey:kResponseSuccessKey] boolValue];
    if (success)
    {
        NSArray *bookingOrders = currentBookingResultDictionary[kJobObjectFieldsKey];
        if ([bookingOrders isKindOfClass:[NSArray class]] && bookingOrders.count > 0) {
            NSDictionary *currentBookingOrder = bookingOrders[0];
            self.currentBookingJobID = currentBookingOrder[@"jobID"];
            self.currentBookingRideNumber = currentBookingOrder[@"jobNumber"];
            NSString *finalPriceString = currentBookingOrder[@"final_price"];
            self.journeyPriceValue = [finalPriceString isKindOfClass:[NSString class]]?[finalPriceString floatValue]:0;
            NSString *additionalChargesString = currentBookingOrder[@"additional_charges"];
            self.additionalChargesValue = [additionalChargesString isKindOfClass:[NSString class]]?[additionalChargesString floatValue]:0;
            self.additionalChargesLabel.hidden = !_additionalChargesValue;
            NSString *tokenID = currentBookingOrder[@"card_token_id"];
            self.tokenID = [tokenID isKindOfClass:[NSString class]]?tokenID:nil;
            BOOL isCardUsed = _tokenID.length;
            self.tipContainerView.hidden = !isCardUsed;
            self.payButton.hidden = !isCardUsed;
            self.payLabel.hidden = isCardUsed;
            
            self.additionalChargesLabel.text = [NSString stringWithFormat:@"Additional charges: £%0.1f0",roundf(_additionalChargesValue*10)/10];
            self.journeyCostLabel.text = [NSString stringWithFormat:@"Journey cost: £%0.1f0",roundf(_journeyPriceValue*10)/10];

            [self updateTotalPriceLabel];
            
            NSString *paymentStatus = currentBookingOrder[@"payment_status"];
            if (![paymentStatus isKindOfClass:[NSString class]]) {
                paymentStatus = @"";
            }
            if (!isCardUsed) {
                if (![paymentStatus isEqualToString:@"Payment Ok"]) {
                    self.shouldHideLoading = YES;
                    [self performSelector:@selector(currentBookingOrder) withObject:nil afterDelay:kDriverRefreshTime];
                }else
                {
                    [self paymentOK];
                }
            }
        }
        else
        {
            [HTUtility showInfo:@"You do not have any current job. Please create a job from Request Ride menu"];
        }
    }else{
        //Show try again view for get current booking order
        UIAlertView *bookingOrderResultFailedView = [[UIAlertView alloc] initWithTitle:kAppName message:@"Unable to load your current booking order right now" delegate:self cancelButtonTitle:kCancelString otherButtonTitles:kTryAgainString, nil];
        bookingOrderResultFailedView.tag = kBookingOrderFailedTryAgainViewTag;
        [bookingOrderResultFailedView show];
    }
}

- (void)onJobRatingUpdateResultNotification:(NSNotification*)notification
{
    [self hideFullScreenAcitvityIndicatorView];
    [HTUtility removeNotificationObserver:self withNotificationName:notification.name];
    [self networkCallFinishedForNotificationName:notification.name];
    NSDictionary *jobRatingUpdateDictionary = [notification userInfo];
    BOOL success = [[jobRatingUpdateDictionary objectForKey:kResponseSuccessKey] boolValue];
    if (success)
    {
        [self paymentOK];
    }else{
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:kAppName message:@"Unable to update job status right now. Please try again" delegate:self cancelButtonTitle:kCancelString otherButtonTitles:kTryAgainString, nil];
        alertView.tag = kJobRatingUpdateFailedTryAgainViewTag;
        [alertView show];
    }
}

#pragma mark- Alertview methods
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == kChargeUserCardFailedViewTag) {
        if (buttonIndex == 1) {
            [self chargeCustomerCard];
        }
    }else if(alertView.tag == kBookingOrderFailedTryAgainViewTag)
    {
        if (buttonIndex == 1) {
            [self currentBookingOrder];
        }
    }else if (alertView.tag == kJobRatingUpdateFailedTryAgainViewTag)
    {
        if (buttonIndex == 1) {
            [self updateJob];
        }
    }
}

@end
