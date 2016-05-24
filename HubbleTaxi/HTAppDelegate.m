//
//  HTAppDelegate.m
//  HubbleTaxi
//
//  Created by Aamir Javed on 30/01/2014.
//  Copyright (c) 2014 Apponative. All rights reserved.
//

#import "HTAppDelegate.h"
#import "HTSessionViewController.h"
#import <GoogleMaps/GoogleMaps.h>
#import "HTPaymentMethodViewController.h"
#import <Parse/Parse.h>
#import "HTDriverRatingViewController.h"
#import "HTProfileViewController.h"
#import "HTPickupAndDestinationLocationViewController.h"
#import "HTDriverProfileViewController.h"
#import "HTFutureBookingViewController.h"
#import "Stripe.h"

@interface HTAppDelegate()
{
    
}
@property (nonatomic,assign)NSUInteger lastImageNumber;
@property (nonatomic,retain)HTImageView *bgImageView;
- (void)animateBackground;
@end

@implementation HTAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.rootViewController = [[HTSessionViewController alloc] init];
    int height = MAX([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
    self.bgImageView = [[HTImageView alloc] initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"background1_%d",height]]];
    CGRect frame = _bgImageView.frame;
    frame.size = self.window.frame.size;
    _bgImageView.frame = frame;
    HTView *dullView = [[HTView alloc] initWithFrame:_bgImageView.frame];
    dullView.backgroundColor = [UIColor blackColor];
    dullView.alpha = 0.3;
    [self.window insertSubview:dullView atIndex:0];
    [self.window insertSubview:_bgImageView atIndex:0];
    [NSTimer scheduledTimerWithTimeInterval:8.0 target:self selector:@selector(animateBackground) userInfo:nil repeats:YES];

    
    [GMSServices provideAPIKey:kGMAPIKey];
    [Stripe setDefaultPublishableKey:kStripePublishableKey];
    
    [Parse setApplicationId:kParseAppID clientKey:kParseClientKey];
    
    if ([[UIApplication sharedApplication] respondsToSelector:@selector(registerUserNotificationSettings:)]) {
        [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
    } else {
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound];
    }
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    
    self.currentRideNavController = [[UINavigationController alloc] initWithRootViewController:[[HTDriverProfileViewController alloc] init]];
    self.requestRideNavController = [[UINavigationController alloc] initWithRootViewController:[[HTPickupAndDestinationLocationViewController alloc] init]];
    self.profileNavController = [[UINavigationController alloc] initWithRootViewController:[[HTProfileViewController alloc] init]];
    self.bookingsNavController = [[UINavigationController alloc] initWithRootViewController:[[HTFutureBookingViewController alloc]init]];


    [self.window makeKeyAndVisible];
    return YES;
}
- (void)application:(UIApplication *)application
didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    // Store the deviceToken in the current Installation and save it to Parse.
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:deviceToken];
    [currentInstallation saveInBackground];
}

/***
 { "alert": "Driver has been reached", "badge": "0", "sound": "", "title": "Driver Reached", "jobid": "53ad1c0a535c12a93c006482", "customData": "Baseball News" } ***/
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    [PFPush handlePush:userInfo];
//
//    NSString *title= userInfo[@"title"];
//    if ([title isEqualToString:@"Destination Reached"]) {
//        HTDriverRatingViewController *driverRatingVC = [[HTDriverRatingViewController alloc] init];
//        driverRatingVC.jobID = [NSString stringWithFormat:@"%@",userInfo[@"jobid"]];
//        [self.window.rootViewController presentViewController:driverRatingVC animated:YES completion:nil];
//    }else{
//        [PFPush handlePush:userInfo];
//    }
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)animateBackground
{
    [UIView transitionWithView:self.bgImageView
                      duration:0.8f
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{
                        self.lastImageNumber++;
                        self.lastImageNumber= (_lastImageNumber)%5+1;
                        int height = MAX([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
                        self.bgImageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"background%lu_%d",(unsigned long)_lastImageNumber,height]];
                    }completion:NULL];
}
@end
