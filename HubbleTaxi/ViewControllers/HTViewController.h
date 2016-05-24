//
//  HTViewController.h
//  HubbleTaxi
//
//  Created by Aamir Javed on 30/01/2014.
//  Copyright (c) 2014 Apponative. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum
{
    screenPositionCenterX,
    screenPositionOutsideLeftX,
    screenPositionOutsideRightX,
    screenPositionOutsideBottomY
}ScreenPosition;


@interface HTViewController : UIViewController<UITextFieldDelegate,UITextViewDelegate>
{
    
}
@property (nonatomic, weak) IBOutlet HTButton *navigateBackButton;
@property (weak, nonatomic) IBOutlet HTButton *logoButton;
@property (nonatomic,retain) NSMutableDictionary *objectsPerformingNetworkRequest;
@property (nonatomic,retain) NSMutableArray *renewSessionObjectsArray;
@property (nonatomic,retain) HTImageView *topBarIV;

- (IBAction)navigateBack:(HTButton*)sender;
- (IBAction)playLogoButtonAnimations:(HTButton *)sender;

- (void)resetSubViews;
- (void)navigateForwardTo:(UIViewController*)toViewController;
- (void)showFullScreenAcitvityIndicatorView;
- (void)hideFullScreenAcitvityIndicatorView;
- (void)performingNetworkCallWithObject:(id)networkObject forNotificationName:(NSString*)notificationName;
- (void)networkCallFinishedForNotificationName:(NSString*)notificationName;
- (void)moveView:(UIView*)view toScreenPositon:(ScreenPosition)screenPosition;
- (void)forceLogoutCurrentUser;
- (void)logoutCurrentUser;
- (UIView*)adjustViewForNonRetina:(UIView*)view;
- (void)endEditing:(BOOL)end;
- (BOOL)isMenuActive;
- (void)showMenuInactiveMessage;
@end
