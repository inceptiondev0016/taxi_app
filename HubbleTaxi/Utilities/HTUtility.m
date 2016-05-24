//
//  HTUtility.m
//  HubbleTaxi
//
//  Created by Aamir Javed on 30/01/2014.
//  Copyright (c) 2014 Apponative. All rights reserved.
//

#import "HTUtility.h"
#import "HTInfoView.h"

@implementation HTUtility


+ (HTAppDelegate*)appDelegate
{
    return [UIApplication sharedApplication].delegate;
}

+ (void)showInfo:(NSString*)infoMessage
{
    dispatch_async(dispatch_get_main_queue(), ^{
        HTInfoView *infoView = [[HTInfoView alloc] initWithMessage:infoMessage];
        [infoView show];
    });
}

+ (void)chageWindowRootViewControllerTo:(UIViewController*)toController withBackwardAnimation:(BOOL)isBackwar
{
    HTAppDelegate *appdelegate = [HTUtility appDelegate];
    UIViewController *oldVC = appdelegate.window.rootViewController;
    appdelegate.window.rootViewController = toController;
    [toController.view addSubview:oldVC.view];
    
    CGRect screenFrame = [UIScreen mainScreen].bounds;
    
    CGRect oldViewFrame = oldVC.view.frame;
    oldViewFrame.origin.x = screenFrame.size.width * (isBackwar?1:-1);
    oldVC.view.frame = oldViewFrame;
    
    CGRect toViewFrame = toController.view.frame;
    toViewFrame.origin.x = screenFrame.size.width * (isBackwar?-1:1);
    toController.view.frame = toViewFrame;
    
    [UIView animateWithDuration:0.4 animations:^{
        CGRect toViewFrame = toController.view.frame;
        toViewFrame.origin.x = 0;
        toController.view.frame = toViewFrame;
    } completion:^(BOOL finished) {
        [oldVC.view removeFromSuperview];
    }];
}

+ (void)addNotificationObserver:(id)observer selector:(SEL)selector forNotificationWithName:(NSString *)notificationName
{
    [[NSNotificationCenter defaultCenter] addObserver:observer selector:selector name:notificationName object:nil];
}

+ (void)removeNotificationObserver:(id)observer withNotificationName:(NSString *)notificationName
{
    if (notificationName) {
        [[NSNotificationCenter defaultCenter] removeObserver:observer name:notificationName object:nil];
    }else
    {
        [[NSNotificationCenter defaultCenter] removeObserver:observer];
    }
}

+ (void)postNotificationWithName:(NSString*)notificationName userInfo:(NSDictionary*)infoDictionary
{
    [[NSNotificationCenter defaultCenter] postNotificationName:notificationName object:nil userInfo:infoDictionary];
}

+ (BOOL)isEmailValidWithString:(NSString*)email
{
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:email];
}

+ (NSString*)currentDeviceID
{
    NSUUID *uuid = [[UIDevice currentDevice] identifierForVendor];
    return [uuid UUIDString];
}

+ (UIImage*)halfSizedImageWithName:(NSString*)imageNamed
{
    UIImage *originalImage = [UIImage imageNamed:imageNamed];
    // scaling set to 2.0 makes the image 1/2 the size.
    UIImage *scaledImage = [UIImage imageWithCGImage:[originalImage CGImage]
                                               scale:(originalImage.scale * 2.0)
                                         orientation:(originalImage.imageOrientation)];
    return scaledImage;
}

@end
