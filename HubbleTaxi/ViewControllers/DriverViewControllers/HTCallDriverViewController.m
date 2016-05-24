//
//  HTCallDriverViewController.m
//  HubbleTaxi
//
//  Created by Aamir Javed on 03/11/2014.
//  Copyright (c) 2014 Apponative. All rights reserved.
//

#import "HTCallDriverViewController.h"
#import <GoogleMaps/GoogleMaps.h>
#import "HTUserBookingsManager.h"

@implementation HTDriverInfo
@end

@interface HTCallDriverViewController ()<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet HTButton *callDriverButton;
@property (weak, nonatomic) IBOutlet HTImageView *driverDpIV;
@property (weak, nonatomic) IBOutlet HTLabel *driverName;
@property (weak, nonatomic) IBOutlet HTLabel *vehicleMakeNModel;
@property (weak, nonatomic) IBOutlet HTLabel *vehicleRegNumber;
@property (weak, nonatomic) IBOutlet HTTextView *driverBio;
@property (nonatomic,retain)HTDriverInfo *driverInfo;
@property (weak, nonatomic) IBOutlet HTLabel *timeLabel;
@property (weak, nonatomic) IBOutlet HTLabel *currentLocationLabel;
@property (weak, nonatomic) IBOutlet HTTextField *driverMessageTF;
@property (weak, nonatomic) IBOutlet HTTextField *customerInstructionTF;

- (void)populateView;
- (IBAction)callDriverButtonTouched:(HTButton *)sender;
- (void)onDriverProfileChangedNotification:(NSNotification*)notification;
@end

@implementation HTCallDriverViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithDriverInfo:(HTDriverInfo *)driverInfo
{
    self = [super init];
    if (self) {
        self.driverInfo = driverInfo;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.view.backgroundColor = [UIColor whiteColor];
    self.driverDpIV.layer.cornerRadius = self.driverDpIV.frame.size.width/2;
    self.driverDpIV.layer.borderColor = [[UIColor clearColor] CGColor];
    self.driverDpIV.layer.masksToBounds = YES;
    [self populateView];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onDriverProfileChangedNotification:) name:@"OnDriverProfileChangedNotificationName" object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
#pragma mark- Custome methods
- (void)populateView
{
    self.driverName.text = _driverInfo.driverName;
    self.driverBio.text = _driverInfo.driverBio;
    if (_driverInfo.driverDp) {
        self.driverDpIV.image = _driverInfo.driverDp;
    }
    self.vehicleMakeNModel.text = _driverInfo.vehicleMakeNModel;
    self.vehicleRegNumber.text = _driverInfo.vehicleRegNo;
    self.timeLabel.text = _driverInfo.timeToPickupString;
    self.driverMessageTF.text = _driverInfo.driverMessageString;
    if (!_customerInstructionTF.isFirstResponder) {
        self.customerInstructionTF.text = _driverInfo.customerInstructionString;
    }
    self.customerInstructionTF.enabled = _driverInfo.isInstructionEnabled;
    self.currentLocationLabel.text = @"Currently;----";
    [[GMSGeocoder geocoder] reverseGeocodeCoordinate:_driverInfo.currentLocationCoordinates completionHandler:^(GMSReverseGeocodeResponse *response, NSError *error)
     {
         if (!error && response.results.count > 0)
         {
             GMSAddress *address = response.firstResult;
             NSString *completeAddress = address.lines.count>0?[address.lines firstObject]:@"";
             self.currentLocationLabel.text = [NSString stringWithFormat:@"Currently;%@",completeAddress];
         }
    }];
}

- (IBAction)callDriverButtonTouched:(HTButton *)sender {
    NSString *phoneStr = [[NSString alloc] initWithFormat:@"tel://%@",_driverInfo.driverPhoneNo];
    NSURL *phoneURL = [[NSURL alloc] initWithString:phoneStr];
    UIDevice *device = [UIDevice currentDevice];
    if ([[device model] isEqualToString:@"iPhone"] ) {
        if ([[UIApplication sharedApplication] canOpenURL:phoneURL]) {
            [[UIApplication sharedApplication] openURL:phoneURL];
            [[HTUserBookingsManager sharedManager] logJobWithJobID:_driverProfileRef.currentBookingJobID rideNumber:_driverProfileRef.currentBookingRideNumber notes:@"" type:@"Customr Rang Driver"];
        }else
        {
            [HTUtility showInfo:@"It seams that driver's phone number is not correct. We are unable to make a call on it"];
        }
    }
    else
    {
        [HTUtility showInfo:@"It seams that driver's phone number is not correct. We are unable to make a call on it"];
    }
}

#pragma mark- Notification
- (void)onDriverProfileChangedNotification:(NSNotification *)notification
{
    NSDictionary *userInfo = notification.userInfo;
    self.driverInfo = userInfo[@"driverInfo"];
    [self populateView];
}

#pragma mark- Text field methods
- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if ([_driverProfileRef respondsToSelector:@selector(textFieldDidEndEditing:)]) {
        [_driverProfileRef textFieldDidEndEditing:textField];
    }
}
@end
