//
//  HTAppDelegate.h
//  HubbleTaxi
//
//  Created by Aamir Javed on 30/01/2014.
//  Copyright (c) 2014 Apponative. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HTAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic,retain)UINavigationController *currentRideNavController;
@property (nonatomic,retain)UINavigationController *requestRideNavController;
@property (nonatomic,retain)UINavigationController *profileNavController;
@property (nonatomic,retain)UINavigationController *bookingsNavController;


@end
