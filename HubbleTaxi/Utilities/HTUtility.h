//
//  HTUtility.h
//  HubbleTaxi
//
//  Created by Aamir Javed on 30/01/2014.
//  Copyright (c) 2014 Apponative. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface HTUtility : NSObject


+ (HTAppDelegate*)appDelegate;
+ (void)showInfo:(NSString*)infoMessage;
+ (void)chageWindowRootViewControllerTo:(UIViewController*)toController withBackwardAnimation:(BOOL)isBackward;
+ (void)addNotificationObserver:(id)observer selector:(SEL)selector forNotificationWithName:(NSString*)notificationName;
+ (void)removeNotificationObserver:(id)observer withNotificationName:(NSString*)notificationName;
+ (void)postNotificationWithName:(NSString*)notificationName userInfo:(NSDictionary*)infoDictionary;
+ (BOOL)isEmailValidWithString:(NSString*)email;
+ (NSString*)currentDeviceID;
+ (UIImage*)halfSizedImageWithName:(NSString*)imageNamed;

@end
