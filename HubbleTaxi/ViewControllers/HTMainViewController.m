//
//  HTMainViewController.m
//  HubbleTaxi
//
//  Created by Aamir Javed on 03/02/2014.
//  Copyright (c) 2014 Apponative. All rights reserved.
//

#import "HTMainViewController.h"
#import "HTProfileViewController.h"
#import "HTUserProfileManager.h"
#import "HTGetStartedViewController.h"
#import "HTPickupAndDestinationLocationViewController.h"
#import <Social/Social.h>
#import <Accounts/Accounts.h>
#import "HTSessionRenew.h"
#import "HTDriverProfileViewController.h"
#import "HTFutureBookingViewController.h"

@interface HTMainViewController ()
@property(nonatomic,retain)HTSessionRenew *sessionRenew;

- (IBAction)profileButtonTouched:(HTButton *)sender;
- (IBAction)logoutButtonTouched:(UIButton *)sender;
- (IBAction)bookingButtonTouched:(HTButton *)sender;
- (IBAction)inviteFbButtonTouched:(HTButton *)sender;
- (IBAction)driverButtonTouched:(HTButton *)sender;
- (IBAction)futureButtonTouched:(HTButton *)sender;

@end

@implementation HTMainViewController

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
    if (_isFreshUser) {
        [self profileButtonTouched:nil];
        self.isFreshUser = NO;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)profileButtonTouched:(HTButton *)sender {
    HTProfileViewController *profileVC = [[HTProfileViewController alloc] init];
    [self navigateForwardTo:profileVC];
}

- (IBAction)logoutButtonTouched:(UIButton *)sender
{
    [self logoutCurrentUser];
}

- (IBAction)bookingButtonTouched:(HTButton *)sender {
    HTPickupAndDestinationLocationViewController *pickupVC = [[HTPickupAndDestinationLocationViewController alloc] init];
    [self navigateForwardTo:pickupVC];
}

- (IBAction)inviteFbButtonTouched:(HTButton *)sender
{
       if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook])
       {
            SLComposeViewController *composeController = [SLComposeViewController
                                                          composeViewControllerForServiceType:SLServiceTypeFacebook];
            [composeController setInitialText:[NSString stringWithFormat:@"Hi Friends, I am using Hubble Go services. Download from iTunes and have fun. https://itunes.com"]];
            [composeController addImage:[UIImage imageNamed:@"Icon.png"]];
            [self presentViewController:composeController
                               animated:YES completion:nil];
            
    }else{
        [HTUtility showInfo:@"There is no Facebook acounts configured. You can add or create a Facebook account in your device Settings"];
    }
}

- (IBAction)driverButtonTouched:(HTButton *)sender
{
    [self navigateForwardTo:[[HTDriverProfileViewController alloc] init]];
}

- (IBAction)futureButtonTouched:(HTButton *)sender
{
    [self navigateForwardTo:[[HTFutureBookingViewController alloc] init]];
}
@end
