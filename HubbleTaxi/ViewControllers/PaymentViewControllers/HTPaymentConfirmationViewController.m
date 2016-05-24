//
//  HTPaymentConfirmationViewController.m
//  HubbleTaxi
//
//  Created by Aamir Javed on 22/04/2014.
//  Copyright (c) 2014 Apponative. All rights reserved.
//

#import "HTPaymentConfirmationViewController.h"
#import "HTPaymentMethodViewController.h"
#import "PTKView.h"
#import "STPToken.h"
#import "HTUserProfileManager.h"
#import <GoogleMaps/GoogleMaps.h>
#import "HTUserBookingsManager.h"
#import "HTPickupAndDestinationLocationViewController.h"
#import "HTDriverProfileViewController.h"
#import "Stripe.h"

@interface HTPaymentConfirmationViewController ()<UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet HTLabel *pageTitile;
@property (weak, nonatomic) IBOutlet HTLabel *pickupLocationlabel;
@property (weak, nonatomic) IBOutlet HTLabel *destinationLocationLabel;
@property (weak, nonatomic) IBOutlet HTLabel *dateTimeLabel;
@property (weak, nonatomic) IBOutlet HTLabel *priceLabel;
@property (weak, nonatomic) IBOutlet HTLabel *paymentMethodLabel;
@property (weak, nonatomic) IBOutlet HTLabel *vehicleTypeLabel;
@property (weak, nonatomic) IBOutlet HTButton *confirmButton;
@property (nonatomic,retain)HTPaymentInfo *paymentInfo;
@property (weak, nonatomic) IBOutlet HTView *confirmationPopup;
@property (weak, nonatomic) IBOutlet HTLabel *confirmationPopupDescription;
@property (weak, nonatomic) IBOutlet HTButton *confirmationEmailButton;
@property (weak, nonatomic) IBOutlet HTButton *confirmationOKButton;
@property (nonatomic, retain) STPToken *stripeToken;
@property (nonatomic,assign) NSInteger currentJobNumber;
@property (nonatomic,retain)NSString *emailAddress;
@property (nonatomic,retain)NSMutableArray *tokenArray;
@property (nonatomic,assign)BOOL shouldShowConfirmScreen;
@property (nonatomic,retain)NSDate *urgentBookingDateTime;

- (IBAction)confirmButtonTouched:(HTButton *)sender;
- (IBAction)confirmationEmailButtonTouched:(HTButton *)sender;
- (IBAction)confirmationOKButtonTouched:(HTButton *)sender;

- (void)populateViews;
- (void)sendConfirmationEmail;
- (void)boldLabel:(HTLabel*)label withRange:(NSRange)range;
- (void)updateAccountInfoWithEmail:(NSString*)email;
- (void)sendJobBookingRequest;
- (void)getAlreadyBookedCurrentJobs;
- (void)jobDetailsConfirmed;

- (void)onAcccountInfoUpdateResultNotification:(NSNotification*)notification;
- (void)onBookingJobCreationNotification:(NSNotification*)notification;
- (void)onIncrementJobNumberNotification:(NSNotification*)notification;
- (void)onAlreadyBookedCurrentJobsNotification:(NSNotification*)notification;

@end

@implementation HTPaymentConfirmationViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithPaymentInfo:(HTPaymentInfo*)paymentInfo
{
    self = [super init];
    if (self) {
        // Custom initialization
        self.paymentInfo = paymentInfo;
        self.tokenArray = [[NSMutableArray alloc] init];
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.shouldShowConfirmScreen = YES;
    [self populateViews];
    self.view.backgroundColor = [UIColor colorWithRed:207/255.0 green:211/255.0 blue:203/255.0 alpha:1];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark- Action methods
- (IBAction)confirmButtonTouched:(HTButton *)sender
{
    BOOL isUrgentJobSelected = false;
    for (NSDateComponents *dateComponents in _paymentInfo.pickupDatesArray)
    {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"HH:mm"];
        NSString *bookingTimeString = [_paymentInfo.dateTimeString isEqualToString:@"Now"]?[dateFormatter stringFromDate:[NSDate date]]:[_paymentInfo.dateTimeString substringFromIndex:_paymentInfo.dateTimeString.length-5];
        
        NSDateComponents *components;
        NSInteger hours;
        NSTimeInterval timeInterval = [bookingTimeString substringWithRange:NSMakeRange(0,2)].floatValue*60*60+[bookingTimeString substringWithRange:NSMakeRange(3, 2)].floatValue*60;
        NSDate *bookingDate = [[[NSCalendar currentCalendar] dateFromComponents:dateComponents] dateByAddingTimeInterval:timeInterval];
        components = [[NSCalendar currentCalendar] components: NSHourCalendarUnit
                                                     fromDate:[NSDate date]  toDate: bookingDate options: 0];
        hours = [components hour];
        if (hours<2) {
            isUrgentJobSelected = YES;
            self.urgentBookingDateTime = bookingDate;
        }
    }
    if (isUrgentJobSelected) {
        [self getAlreadyBookedCurrentJobs];
    }else
    {
        [self jobDetailsConfirmed];
    }
}

- (IBAction)confirmationEmailButtonTouched:(HTButton *)sender
{
    NSDictionary *profileDictionary = [[HTUserProfileManager sharedManager] currentUserProfile];
    NSString *email = [profileDictionary objectForKey:kLoggedInUserEmailKey];
    if (email.length>0) {
        [self sendConfirmationEmail];
    }else{
        //Ask for new email address
        UIAlertView *alrertView = [[UIAlertView alloc] initWithTitle:kAppName message:@"Enter your email address here" delegate:self cancelButtonTitle:kCancelString otherButtonTitles:kAddString, nil];
        alrertView.alertViewStyle = UIAlertViewStylePlainTextInput;
        alrertView.tag = kPaymentConfirmationEmailInputViewTag;
        [alrertView show];
    }
}

- (IBAction)confirmationOKButtonTouched:(HTButton *)sender
{
    [HTUtility appDelegate].window.rootViewController = [[UINavigationController alloc] initWithRootViewController:[[HTDriverProfileViewController alloc] init]];
    [HTUtility appDelegate].requestRideNavController = [[UINavigationController alloc] initWithRootViewController:[[HTPickupAndDestinationLocationViewController alloc] init]];
}

#pragma mark-  Custom methods
- (void)populateViews
{
    self.pickupLocationlabel.text = [NSString stringWithFormat:@"Pickup from: %@",_paymentInfo.pickupFromAddress];
    self.destinationLocationLabel.text = [NSString stringWithFormat:@"Destination: %@",_paymentInfo.noDestinationYet?kPaymentMethodNoDestinationSelectedString:_paymentInfo.destinationAddress];
    self.dateTimeLabel.text = [NSString stringWithFormat:@"Date-time: %@",_paymentInfo.dateTimeString];
    self.priceLabel.text = [NSString stringWithFormat:@"Price: %@",_paymentInfo.noDestinationYet?kPaymentMethodNoDestinationSelectedString:_paymentInfo.priceString];
    self.paymentMethodLabel.text = [NSString stringWithFormat:@"Payment method: %@",_paymentInfo.paymentMethod];
    self.vehicleTypeLabel.text = [NSString stringWithFormat:@"Vehicle type: %@",_paymentInfo.vehicleType];
    
    [self boldLabel:_pickupLocationlabel withRange:NSMakeRange(0, 12)];
    [self boldLabel:_destinationLocationLabel withRange:NSMakeRange(0, 12)];
    [self boldLabel:_dateTimeLabel withRange:NSMakeRange(0, 10)];
    [self boldLabel:_priceLabel withRange:NSMakeRange(0, 6)];
    [self boldLabel:_paymentMethodLabel withRange:NSMakeRange(0, 15)];
    [self boldLabel:_vehicleTypeLabel withRange:NSMakeRange(0, 13)];
}

- (void)sendConfirmationEmail
{
    NSDictionary *profileDictionary = [[HTUserProfileManager sharedManager] currentUserProfile];
    NSString *firstName = [profileDictionary objectForKey:kLoggedInUserFirstNameKey];
    NSString *lastName = [profileDictionary objectForKey:kLoggedInUserLastNameKey];
    NSString *email = [profileDictionary objectForKey:kLoggedInUserEmailKey];
    
    [self showFullScreenAcitvityIndicatorView];
    NSDateFormatter *dateformatter = [[NSDateFormatter alloc] init];
    [dateformatter setDateFormat:@"HH:MMa EE dd MMM YYYY"];
    NSString *receiptTimeString = [dateformatter stringFromDate:[NSDate date]];
    receiptTimeString = [NSString stringWithFormat:@"%@ <br> %@",[receiptTimeString substringToIndex:7],[receiptTimeString substringFromIndex:7]];
    
    NSString *viaString = _paymentInfo.viaLocationInfoArray.count?@"":@"None";
    for (HTLocationInfo *viaLocation in _paymentInfo.viaLocationInfoArray) {
        viaString = [NSString stringWithFormat:@"%@%d. %@ <br>",viaString,[_paymentInfo.viaLocationInfoArray indexOfObject:viaLocation]+1,viaLocation.addressString];
    }
    NSString *pickupTimeString = [_paymentInfo.dateTimeString isEqualToString:@"Now"]?receiptTimeString:_paymentInfo.dateTimeString;
    [PFCloud callFunctionInBackground:@"sendConfirmationEmail" withParameters:@{
                                                                                @"to":email,
                                                                                @"receiptTime":receiptTimeString,
                                                                                @"receiptNumber":[NSString stringWithFormat:@"GE%d",_currentJobNumber-786],
                                                                                @"rideNumber":[NSString stringWithFormat:@"%d",_currentJobNumber],
                                                                                @"personBilled":[NSString stringWithFormat:@"%@ %@",firstName,lastName],
                                                                                @"pickupLocation":_paymentInfo.pickupFromAddress,
                                                                                @"pickupTime":pickupTimeString,
                                                                                @"vehicleType":_paymentInfo.vehicleType,
                                                                                @"destinationLocation":_paymentInfo.destinationAddress,
                                                                                @"price":_paymentInfo.priceString,
                                                                                @"paymentMethod":_paymentInfo.paymentMethod,
                                                                                @"name":firstName,
                                                                                @"viaPoints":viaString
                                                                                } block:^(id object, NSError *error) {
                                                                                    dispatch_async(dispatch_get_main_queue(), ^{
                                                                                        if (error) {
                                                                                            UIAlertView *networkErrorAlertView = [[UIAlertView alloc] initWithTitle:kAppName message:kNetworkErrorString delegate:self cancelButtonTitle:kCancelString otherButtonTitles:kTryAgainString, nil];
                                                                                            networkErrorAlertView.tag = kNetworkErrorStringViewTag;
                                                                                            [networkErrorAlertView show];
                                                                                        }else
                                                                                        {
                                                                                            //                [HTUtility showInfo:@"Booking confirmation email has been sent successfully."];
                                                                                            
                                                                                            [HTUtility appDelegate].window.rootViewController = [[UINavigationController alloc] initWithRootViewController:[[HTDriverProfileViewController alloc] init]];
                                                                                            [HTUtility appDelegate].requestRideNavController = [[UINavigationController alloc] initWithRootViewController:[[HTPickupAndDestinationLocationViewController alloc] init]];
                                                                                        }
                                                                                    });
                                                                                }];
}

- (void)boldLabel:(HTLabel*)label withRange:(NSRange)range
{
    label.textColor  = [UIColor grayColor];
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:label.text];
    [attributedString addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:17] range:range];
    [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:range];
    label.attributedText = attributedString;
}

- (void)updateAccountInfoWithEmail:(NSString*)email;
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
                                                       email, kLoggedInUserEmailKey,
                                                       userID,kLoggedInUserIDKey,
                                                       nil];
                id networkOjbect = [[HTUserProfileManager sharedManager] updateAccountInfoWithDictionay:accountInfoDictionary completionNotificationName:kAccountInfoUpdateResultNotificationName];
                [self performingNetworkCallWithObject:networkOjbect forNotificationName:kAccountInfoUpdateResultNotificationName];
            }else
            {
                //Handled in renewSession class
            }
        }
    }];
}

- (void)sendJobBookingRequest
{
    NSMutableArray *jobsArray = [[NSMutableArray alloc] init];
    for (NSDateComponents *dateComponents in _paymentInfo.pickupDatesArray) {
        NSMutableDictionary *jobFields = [NSMutableDictionary dictionary];
        jobFields[@"booking_method"] = @"App";
        jobFields[@"job_status"] = @"Open";
        jobFields[@"jobNumber"] = [NSString stringWithFormat:@"GB%u",_currentJobNumber-[_paymentInfo.pickupDatesArray indexOfObject:dateComponents]];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"dd-MM-yyyy"];
        jobFields[@"job_create_date"] = [dateFormatter stringFromDate:[NSDate date]];
        [dateFormatter setDateFormat:@"HH:mm"];
        NSString *bookingTimeString = [_paymentInfo.dateTimeString isEqualToString:@"Now"]?[dateFormatter stringFromDate:[NSDate date]]:[_paymentInfo.dateTimeString substringFromIndex:_paymentInfo.dateTimeString.length-5];
        [dateFormatter setDateFormat:@"dd-MM-yyyy"];
        jobFields[@"booking_date"] = [NSString stringWithFormat:@"%@ %@",[dateFormatter stringFromDate:[[NSCalendar currentCalendar] dateFromComponents:dateComponents]], bookingTimeString];
        jobFields[@"multiple_booking_selected"] = _paymentInfo.pickupDatesArray.count>1?@"Yes":@"No";
        
        NSDateComponents *components;
        NSInteger hours;
        NSTimeInterval timeInterval = [bookingTimeString substringWithRange:NSMakeRange(0,2)].floatValue*60*60+[bookingTimeString substringWithRange:NSMakeRange(3, 2)].floatValue*60;
        components = [[NSCalendar currentCalendar] components: NSHourCalendarUnit
                                                     fromDate:[NSDate date]  toDate: [[[NSCalendar currentCalendar] dateFromComponents:dateComponents] dateByAddingTimeInterval:timeInterval] options: 0];
        hours = [components hour];
        
        if (hours<2) {
            jobFields[@"booking_type"] = @"urgent";
            self.shouldShowConfirmScreen = NO;
        }else
        {
            jobFields[@"booking_type"] = @"future";
        }
        NSDateFormatter *refDateFormatter = [[NSDateFormatter alloc] init];
        [refDateFormatter setDateFormat:@"dd-MM-yyyy HH:mm"];
        NSDate *refDate = [refDateFormatter dateFromString:kReferenceDateString];
        float seconds =  [[[[NSCalendar currentCalendar] dateFromComponents:dateComponents] dateByAddingTimeInterval:timeInterval] timeIntervalSinceDate:refDate];
        jobFields[@"bookingDateInSeconds"] = [NSNumber numberWithFloat:seconds];
        
        
        jobFields[@"vehicle_type"] = self.paymentInfo.vehicleType;
        
        //Pickup location
        jobFields[@"pickup_common"] = _paymentInfo.pickupLocationInfo.isCommonPlace?@"Yes":@"No";
        jobFields[@"pickup_address1"] = _paymentInfo.pickupLocationInfo.addressString;
        jobFields[@"pickup_address2"] = @"";
        jobFields[@"pickup_address_area"] = _paymentInfo.pickupLocationInfo.gmsAddress.administrativeArea?_paymentInfo.pickupLocationInfo.gmsAddress.administrativeArea:@"";
        jobFields[@"pickup_address_city"] = _paymentInfo.pickupLocationInfo.gmsAddress.locality?_paymentInfo.pickupLocationInfo.gmsAddress.locality:_paymentInfo.pickupLocationInfo.gmsAddress.subLocality?_paymentInfo.pickupLocationInfo.gmsAddress.subLocality:@"";
        jobFields[@"pickup_address_postcode"] = _paymentInfo.pickupLocationInfo.gmsAddress.postalCode?_paymentInfo.pickupLocationInfo.gmsAddress.postalCode:@"";
        jobFields[@"pickup_address_location"] = [[NSStringFromCGPoint(CGPointMake(_paymentInfo.pickupLocationInfo.gmsAddress.coordinate.latitude, _paymentInfo.pickupLocationInfo.gmsAddress.coordinate.longitude)) stringByReplacingOccurrencesOfString:@"{" withString:@""] stringByReplacingOccurrencesOfString:@"}" withString:@""];
        
        //destination location
        jobFields[@"destination_set"] = _paymentInfo.noDestinationYet?@"NO":@"Yes";
        if (!_paymentInfo.noDestinationYet) {
            jobFields[@"destination_common"] = _paymentInfo.destinationLocationInfo.isCommonPlace?@"Yes":@"No";
            jobFields[@"destination_line1"] = _paymentInfo.destinationLocationInfo.addressString;
            jobFields[@"destination_line2"] = @"";
            jobFields[@"destination_area"] =  _paymentInfo.destinationLocationInfo.gmsAddress.administrativeArea?_paymentInfo.destinationLocationInfo.gmsAddress.administrativeArea:@"";
            jobFields[@"destination_city"] = _paymentInfo.destinationLocationInfo.gmsAddress.locality?_paymentInfo.destinationLocationInfo.gmsAddress.locality:_paymentInfo.destinationLocationInfo.gmsAddress.subLocality?_paymentInfo.destinationLocationInfo.gmsAddress.subLocality:@"";
            jobFields[@"destination_postcode"] = _paymentInfo.destinationLocationInfo.gmsAddress.postalCode?_paymentInfo.destinationLocationInfo.gmsAddress.postalCode:@"";
            jobFields[@"destination_location"] =  [[NSStringFromCGPoint(CGPointMake(_paymentInfo.destinationLocationInfo.gmsAddress.coordinate.latitude, _paymentInfo.destinationLocationInfo.gmsAddress.coordinate.longitude)) stringByReplacingOccurrencesOfString:@"{" withString:@""] stringByReplacingOccurrencesOfString:@"}" withString:@""];
        }
        //Via points
        jobFields[@"via_point1_set"] = @"NO";
        jobFields[@"via_point2_set"] = @"NO";
        jobFields[@"via_point3_set"] = @"NO";
        jobFields[@"via_point4_set"] = @"NO";
        jobFields[@"via_point5_set"] = @"NO";
        for (HTLocationInfo *viaLocation in _paymentInfo.viaLocationInfoArray) {
            jobFields[[NSString stringWithFormat:@"via_point%d_set",[_paymentInfo.viaLocationInfoArray indexOfObject:viaLocation]+1]] = @"Yes";
            jobFields[[NSString stringWithFormat:@"via_point%d_common",[_paymentInfo.viaLocationInfoArray indexOfObject:viaLocation]+1]] = viaLocation.isCommonPlace?@"Yes":@"No";
            jobFields[[NSString stringWithFormat:@"via_point%d_line1",[_paymentInfo.viaLocationInfoArray indexOfObject:viaLocation]+1]] = viaLocation.addressString;
            jobFields[[NSString stringWithFormat:@"via_point%d_line2",[_paymentInfo.viaLocationInfoArray indexOfObject:viaLocation]+1]] = @"";
            jobFields[[NSString stringWithFormat:@"via_point%d_area",[_paymentInfo.viaLocationInfoArray indexOfObject:viaLocation]+1]] = viaLocation.gmsAddress.administrativeArea?viaLocation.gmsAddress.administrativeArea:@"";
            jobFields[[NSString stringWithFormat:@"via_point%d_city",[_paymentInfo.viaLocationInfoArray indexOfObject:viaLocation]+1]] = viaLocation.gmsAddress.locality?viaLocation.gmsAddress.locality:viaLocation.gmsAddress.subLocality?viaLocation.gmsAddress.subLocality:@"";
            jobFields[[NSString stringWithFormat:@"via_point%d_postcode",[_paymentInfo.viaLocationInfoArray indexOfObject:viaLocation]+1]] = viaLocation.gmsAddress.postalCode?viaLocation.gmsAddress.postalCode:@"";
            jobFields[[NSString stringWithFormat:@"via_point%d_location",[_paymentInfo.viaLocationInfoArray indexOfObject:viaLocation]+1]] =   [[NSStringFromCGPoint(CGPointMake(viaLocation.gmsAddress.coordinate.latitude, viaLocation.gmsAddress.coordinate.longitude)) stringByReplacingOccurrencesOfString:@"{" withString:@""] stringByReplacingOccurrencesOfString:@"}" withString:@""];
        }
        //Payment
        NSArray *priceComponents = [_priceLabel.text componentsSeparatedByString:@"£"];
        float priceValue = [[priceComponents lastObject] floatValue];
        NSString *priceString = [NSString stringWithFormat:@"%f",priceValue/_paymentInfo.pickupDatesArray.count];
        
        jobFields[@"price_set"] = jobFields[@"actual_price"]  = jobFields[@"final_price"] = priceString;
        jobFields[@"distance_travelled"] = [NSString stringWithFormat:@"%f Km",_paymentInfo.distanceTravelled];
        jobFields[@"payment_method"] = self.paymentInfo.paymentMethod;
        int index = [_paymentInfo.pickupDatesArray indexOfObject:dateComponents];
        if (index < _tokenArray.count) {
            self.stripeToken = _tokenArray[index];
        }
        jobFields[@"card_token_id"] = _stripeToken.tokenId?_stripeToken.tokenId:@"";
        jobFields[@"email_confirmation"] = _confirmationEmailButton.selected?@"Yes":@"No";
        jobFields[@"facebook_share"] = self.paymentInfo.journeySharedOnFB?@"Yes":@"No";
        jobFields[@"firm_assigned"] = self.paymentInfo.assignedToFirm;
        
        NSDictionary *profileDictionary = [[HTUserProfileManager sharedManager] currentUserProfile];
        NSNumber *blobID = [profileDictionary objectForKey:kLoggedInUserDPBlobIDKey];
        if (blobID) {
            jobFields[@"customer_blob_id"] = blobID;
        }
        
        
        [jobsArray addObject:jobFields];
    }
    
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self showFullScreenAcitvityIndicatorView];
    });
    
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
                if (_currentJobNumber)
                {
                    [self showFullScreenAcitvityIndicatorView];
                    [HTUtility addNotificationObserver:self selector:@selector(onBookingJobCreationNotification:) forNotificationWithName:kBookingJobCreationNotificationName];
                    id networkOjbect = [[HTUserBookingsManager sharedManager] createBookingJobs:jobsArray completionNotificationName:kBookingJobCreationNotificationName];
                    [self performingNetworkCallWithObject:networkOjbect forNotificationName:kBookingJobCreationNotificationName];
                }else
                {
                    [self showFullScreenAcitvityIndicatorView];
                    [HTUtility addNotificationObserver:self selector:@selector(onIncrementJobNumberNotification:) forNotificationWithName:kIncrementJobNumberNotificationName];
                    id networkOjbect = [[HTUserBookingsManager sharedManager] incrementJobNumberBy:_paymentInfo.pickupDatesArray.count withCompletionNotificationName:kIncrementJobNumberNotificationName];
                    [self performingNetworkCallWithObject:networkOjbect forNotificationName:kIncrementJobNumberNotificationName];
                }
            }else
            {
                //Handled in renewSession class
            }
        }
    }];
}

- (void)getAlreadyBookedCurrentJobs
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
                [HTUtility addNotificationObserver:self selector:@selector(onAlreadyBookedCurrentJobsNotification:) forNotificationWithName:kGetAlreadyBookedCurrentJobsNotificationName];
                id networkOjbect = [[HTUserBookingsManager sharedManager] getAlreadyBookedJobsWithinBookingTime:_urgentBookingDateTime completionNotificationName:kGetAlreadyBookedCurrentJobsNotificationName];
                [self performingNetworkCallWithObject:networkOjbect forNotificationName:kGetAlreadyBookedCurrentJobsNotificationName];
            }else
            {
                //Handled in renewSession class
            }
        }
    }];
}

- (void)jobDetailsConfirmed
{
    if (self.paymentInfo.cardCharginView)
    {
        //Pay by card
        
        [self showFullScreenAcitvityIndicatorView];
        
        STPCard *card = [[STPCard alloc] init];
        card.number = self.paymentInfo.cardCharginView.cardNumber.string;
        card.expMonth = self.paymentInfo.cardCharginView.cardExpiry.month;
        card.expYear = self.paymentInfo.cardCharginView.cardExpiry.year;
        card.cvc = self.paymentInfo.cardCharginView.cardCVC.string;
        [Stripe createTokenWithCard:card
                         completion:^(STPToken *token, NSError *error) {
                             if (error) {
                                 dispatch_async(dispatch_get_main_queue(), ^{
                                     [self hideFullScreenAcitvityIndicatorView];
                                     [HTUtility showInfo:@"We are unable to process your card. Make sure you have entered valid card details."];
                                 });
                             } else {
                                 [_tokenArray addObject:token];
                                 if (_tokenArray.count == _paymentInfo.pickupDatesArray.count) {
                                     dispatch_async(dispatch_get_main_queue(), ^{
                                         [self hideFullScreenAcitvityIndicatorView];
                                         [self sendJobBookingRequest];
                                     });
                                 }else
                                 {
                                     [self jobDetailsConfirmed];
                                 }
                                 
                             }
                             dispatch_async(dispatch_get_main_queue(), ^{
                                 [self hideFullScreenAcitvityIndicatorView];
                             });
                         }];
        
        
    }else{
        //pay by cash
        [self sendJobBookingRequest];
    }
}

#pragma mark- Alert view delegates
- (BOOL)alertViewShouldEnableFirstOtherButton:(UIAlertView *)alertView
{
    if (alertView.tag == kPaymentConfirmationEmailInputViewTag)
    {
        
        NSString *email = [alertView textFieldAtIndex:0].text;
        if (email.length < 1) {
            return NO;
        }
    }
    return YES;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == kPaymentConfirmationEmailInputViewTag) {
        if (buttonIndex == 1) {
            NSString *email = [alertView textFieldAtIndex:0].text;
            if ([HTUtility isEmailValidWithString:email]) {
                self.emailAddress = email;
                [self updateAccountInfoWithEmail:email];
            }else
            {
                [HTUtility showInfo:kAccountInfoEmailNotValidString];
            }
        }
    }
    else if (alertView.tag == kJobBookingFailedTryAgainViewTag)
    {
        if (buttonIndex == 1) {
            [self sendJobBookingRequest];
        }
    }
    else if (alertView.tag == kNetworkErrorStringViewTag)
    {
        if (buttonIndex ==1) {
            [self sendConfirmationEmail];
        }
    }
    else if (alertView.tag == kAccountInfoUploadingFailedTryAgainStringViewTag)
    {
        if (buttonIndex == 1) {
            [self updateAccountInfoWithEmail:_emailAddress];
        }
    }else if (alertView.tag == kGetAlreadyBookedCurrentJobsFailedViewTag)
    {
        if (buttonIndex==1) {
            [self getAlreadyBookedCurrentJobs];
        }
    }else if (alertView.tag == kGetAlreadyBookedCurrentJobsExistsViewTag)
    {
        [self confirmationOKButtonTouched:nil];
    }
}

#pragma mark- Notification methods
- (void)onAcccountInfoUpdateResultNotification:(NSNotification*)notification
{
    [self hideFullScreenAcitvityIndicatorView];
    [HTUtility removeNotificationObserver:self withNotificationName:notification.name];
    [self networkCallFinishedForNotificationName:notification.name];
    NSDictionary *profileUploadResultDictionary = [notification userInfo];
    BOOL success = [[profileUploadResultDictionary objectForKey:kResponseSuccessKey] boolValue];
    if (success)
    {
        [self sendConfirmationEmail];
    }else{
        //Show try again view for uploading profile
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:kAppName message:kNetworkErrorString delegate:self cancelButtonTitle:kCancelString otherButtonTitles:kTryAgainString, nil];
        alertView.tag = kAccountInfoUploadingFailedTryAgainStringViewTag;
        [alertView show];
    }
}

- (void)onBookingJobCreationNotification:(NSNotification*)notification
{
    [self hideFullScreenAcitvityIndicatorView];
    [HTUtility removeNotificationObserver:self withNotificationName:notification.name];
    [self networkCallFinishedForNotificationName:notification.name];
    NSDictionary *profileUploadResultDictionary = [notification userInfo];
    BOOL success = [[profileUploadResultDictionary objectForKey:kResponseSuccessKey] boolValue];
    if (success)
    {
        NSArray *array = profileUploadResultDictionary[@"JobObjectFieldsKey"];
        if (_shouldShowConfirmScreen) {
            if ([array isKindOfClass:[NSArray class]] && array.count > 0 ) {
                NSString *jobNumber = array[0][@"jobNumber"];
                if ([jobNumber isKindOfClass:[NSString class]]) {
                    _confirmationPopupDescription.text = [NSString stringWithFormat:@"Reference:\n%@",jobNumber];
                }
            }
            self.topBarIV.image = [UIImage imageNamed:@"topbar_rideconfimed.png"];
            _confirmationPopup.hidden = NO;
        }else
        {
            [self confirmationOKButtonTouched:nil];
        }
        
        if ([array isKindOfClass:[NSArray class]] && array.count > 0 )
        {
            NSString *jobId = array[0][@"jobID"];
            NSString *rideNumber = array[0][@"jobNumber"];
            NSString *notes = [NSString stringWithFormat:@"Ride Number: %@",rideNumber];
            [[HTUserBookingsManager sharedManager] logJobWithJobID:jobId rideNumber:rideNumber notes:notes type:@"Ride Created"];
        }
    }else{
        UIAlertView *jobBookingFailedView = [[UIAlertView alloc] initWithTitle:kAppName message:@"We are unable to create a booking job for you right now" delegate:self cancelButtonTitle:kCancelString otherButtonTitles:kTryAgainString, nil];
        jobBookingFailedView.tag = kJobBookingFailedTryAgainViewTag;
        [jobBookingFailedView show];
    }
}

- (void)onIncrementJobNumberNotification:(NSNotification*)notification
{
    [self hideFullScreenAcitvityIndicatorView];
    [HTUtility removeNotificationObserver:self withNotificationName:notification.name];
    [self networkCallFinishedForNotificationName:notification.name];
    NSDictionary *jobDictionary = [notification userInfo];
    BOOL success = [[jobDictionary objectForKey:kResponseSuccessKey] boolValue];
    if (success)
    {
        self.currentJobNumber = [jobDictionary[kJobNumberObjectKey][@"jobNumber"] integerValue];
        [self sendJobBookingRequest];
    }else{
        UIAlertView *jobBookingFailedView = [[UIAlertView alloc] initWithTitle:kAppName message:@"We are unable to create a booking job for you right now" delegate:self cancelButtonTitle:kCancelString otherButtonTitles:kTryAgainString, nil];
        jobBookingFailedView.tag = kJobBookingFailedTryAgainViewTag;
        [jobBookingFailedView show];
    }
}

- (void)onAlreadyBookedCurrentJobsNotification:(NSNotification *)notification
{
    [self hideFullScreenAcitvityIndicatorView];
    [HTUtility removeNotificationObserver:self withNotificationName:notification.name];
    [self networkCallFinishedForNotificationName:notification.name];
    NSDictionary *jobDictionary = [notification userInfo];
    BOOL success = [[jobDictionary objectForKey:kResponseSuccessKey] boolValue];
    if (success)
    {
        NSArray *jobs = jobDictionary[kJobObjectFieldsKey];
        if ([jobs isKindOfClass:[NSArray class]] && jobs.count>0) {
            UIAlertView *jobAlreadyBookedView = [[UIAlertView alloc] initWithTitle:kAppName message:@"Oops, it appears that you already have an active ride. Please have a look at that instead." delegate:self cancelButtonTitle:kOKString otherButtonTitles:nil, nil];
            jobAlreadyBookedView.tag = kGetAlreadyBookedCurrentJobsExistsViewTag;
            [jobAlreadyBookedView show];
        }else
        {
            [self jobDetailsConfirmed];
        }
    }else{
        UIAlertView *jobGettingFailedView = [[UIAlertView alloc] initWithTitle:kAppName message:kNetworkErrorString delegate:self cancelButtonTitle:kCancelString otherButtonTitles:kTryAgainString, nil];
        jobGettingFailedView.tag = kGetAlreadyBookedCurrentJobsFailedViewTag;
        [jobGettingFailedView show];
    }
}

@end
