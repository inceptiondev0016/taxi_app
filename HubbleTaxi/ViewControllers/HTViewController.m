//
//  HTViewController.m
//  HubbleTaxi
//
//  Created by Aamir Javed on 30/01/2014.
//  Copyright (c) 2014 Apponative. All rights reserved.
//

#import "HTViewController.h"
#import "HTActivityIndicatorView.h"
#import "HTGetStartedViewController.h"
#import "HTMenuView.h"
#import <QuartzCore/QuartzCore.h>
#import "HTDriverProfileViewController.h"
#import "HTFutureBookingViewController.h"
#import "HTUserProfileManager.h"
#import "HTPickupAndDestinationLocationViewController.h"
#import "HTProfileViewController.h"

static int currentlySelectedMenuItemIndex = 4;
@interface HTViewController ()<HTMenuViewDelegate, UIWebViewDelegate>
{
    float _currentFirstResponderOriginYValue;
}
@property (nonatomic, retain)HTActivityIndicatorView *fullScreenActivityIndicatorView;
@property (nonatomic, retain)HTMenuView *menuTableView;
@property (nonatomic, retain)HTView *menuBgView;
@property (nonatomic, retain)NSArray *menuButtonTextsArray;
@property (nonatomic,assign)BOOL isOnPrivacyStatementScreen;

- (IBAction)menuButtonTouched:(HTButton*)sender;
- (IBAction)menuBgTapped:(UITapGestureRecognizer*)gesture;
- (IBAction)closeButtonTouchedForTnCWebView:(HTButton*)sender;
- (IBAction)privacyStatementButtonTouchedForTnCWebView:(HTButton*)sender;

- (void)showDefaultBackgroundTheme;
- (void)addTopBar;
- (void)showTnCWebView;
- (void)onKeyboardWillShowNotification:(NSNotification*)notification;
- (void)onKeyboardWillHideNotification:(NSNotification*)notification;
@end

@implementation HTViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.objectsPerformingNetworkRequest = [[NSMutableDictionary alloc] init];
        self.renewSessionObjectsArray = [[NSMutableArray alloc] init];
        self.menuButtonTextsArray = @[@"Current Ride",@"Request Ride",@"Profile",@"Bookings",@"",@"",@"T&C"];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationController.navigationBarHidden = YES;
    [self setNeedsStatusBarAppearanceUpdate];
	// Do any additional setup after loading the view.
    self.view.frame = [UIScreen mainScreen].bounds;//full screen
    [self showDefaultBackgroundTheme];
    [self addTopBar];
    [self resetSubViews];
}

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    
    [HTUtility addNotificationObserver:self selector:@selector(onKeyboardWillShowNotification:) forNotificationWithName:UIKeyboardWillShowNotification];
    [HTUtility addNotificationObserver:self selector:@selector(onKeyboardWillHideNotification:) forNotificationWithName:UIKeyboardWillHideNotification];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [HTUtility removeNotificationObserver:self withNotificationName:UIKeyboardWillShowNotification];
    [HTUtility removeNotificationObserver:self withNotificationName:UIKeyboardWillHideNotification];
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)dealloc
{
    //Cancel all network requets
    for (id networkRequestObject in [_objectsPerformingNetworkRequest allValues]) {
        if ([networkRequestObject conformsToProtocol:@protocol(Cancelable)]) {
            [networkRequestObject cancel];
        }
    }
    [HTUtility removeNotificationObserver:self withNotificationName:nil];//Remove against all notifications
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
}


#pragma mark- Action methods
- (void)menuButtonTouched:(HTButton *)sender
{
    if ([self isMenuActive]) {
        [_menuTableView animateWithHiden:!_menuTableView.hidden];
        _menuBgView.hidden = !_menuBgView.hidden;
        if (currentlySelectedMenuItemIndex != 4) {
            [self.menuTableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:currentlySelectedMenuItemIndex inSection:0] animated:NO scrollPosition:UITableViewScrollPositionTop];
        }
    }else
    {
        [self showMenuInactiveMessage];
    }
}

- (IBAction)menuBgTapped:(UITapGestureRecognizer*)gesture
{
    [self endEditing:YES];
}

- (void)closeButtonTouchedForTnCWebView:(HTButton *)sender
{
    if (self.isOnPrivacyStatementScreen) {
        self.isOnPrivacyStatementScreen = NO;
        [[[self.view viewWithTag:555] viewWithTag:777] setHidden:NO];
        [[[self.view viewWithTag:555] viewWithTag:888] setHidden:YES];
    }else
    {
        [[self.view viewWithTag:555] removeFromSuperview];
    }
}

- (IBAction)privacyStatementButtonTouchedForTnCWebView:(HTButton*)sender
{
    self.isOnPrivacyStatementScreen = YES;
    [[[self.view viewWithTag:555] viewWithTag:777] setHidden:YES];
    [[[self.view viewWithTag:555] viewWithTag:888] setHidden:NO];
}


#pragma mark - Custom methods

- (void)showDefaultBackgroundTheme
{
    self.view.backgroundColor = [UIColor clearColor];
}

- (void)addTopBar
{
    NSString *topBarImageName = [[[NSStringFromClass([self class]) stringByReplacingOccurrencesOfString:@"HT" withString:@"topbar_"] stringByReplacingOccurrencesOfString:@"ViewController" withString:@""] lowercaseString];
    UIImage *topBarImage = [UIImage imageNamed:topBarImageName];
    if (topBarImage) {
        self.topBarIV = [[HTImageView alloc] initWithImage:topBarImage];
        [self adjustViewForNonRetina:_topBarIV];
        [self.view addSubview:_topBarIV];
        HTButton *menuButton = [HTButton buttonWithType:UIButtonTypeCustom];
        [menuButton setBackgroundImage:[UIImage imageNamed:@"btn_menu.png"] forState:UIControlStateNormal];
        [menuButton addTarget:self action:@selector(menuButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
        menuButton.frame = CGRectMake(10, 22, 45, 28);
        [self.view addSubview:menuButton];
        
        self.menuBgView = [[HTView alloc] initWithFrame:CGRectMake(0, 64, self.view.frame.size.width, self.view.frame.size.height-64)];
        _menuBgView.backgroundColor = [UIColor clearColor];
        _menuBgView.userInteractionEnabled = YES;
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(menuBgTapped:)];
        [_menuBgView addGestureRecognizer:tapGesture];
        
        self.menuTableView = [[HTMenuView alloc] initWithFrame:CGRectMake(0, 64, self.view.frame.size.width*3/4.0, self.view.frame.size.height-64)];
        self.menuTableView.layer.borderColor = [UIColor colorWithRed:252/255.0 green:151/255.0 blue:9/255.0 alpha:1].CGColor;
        self.menuTableView.layer.borderWidth = 3.0;
        self.menuTableView.menuDelegate = self;
        self.menuTableView.menuButtonsTextsArray = _menuButtonTextsArray;
        [self.view addSubview:_menuBgView];
        [self.view addSubview:_menuTableView];
        _menuTableView.hidden = YES;
        _menuBgView.hidden = YES;
        [_menuTableView animateWithHiden:YES];
    }
}

- (void)showTnCWebView
{
    UIView *webViewBGView = [[UIView alloc] initWithFrame:CGRectMake(0, 20, 320, self.view.frame.size.height-20)];
    webViewBGView.tag = 555;
    [self.view addSubview:webViewBGView];
    
    UIWebView *tncWebView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, 320, self.view.frame.size.height-20)];
    NSURL *tncUrl = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"TnC" ofType:@"html"] isDirectory:NO];
    NSURLRequest *requestObj = [NSURLRequest requestWithURL:tncUrl];
    [tncWebView loadRequest:requestObj];
    [webViewBGView addSubview:tncWebView];
    tncWebView.delegate = self;
    tncWebView.tag = 777;
    
    UIWebView *psWebView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, 320, self.view.frame.size.height-20)];
    NSURL *psUrl = [NSURL URLWithString:@"https://www.iubenda.com/privacy-policy/795849/full-legal"];
    NSURLRequest *requestObj1 = [NSURLRequest requestWithURL:psUrl];
    [psWebView loadRequest:requestObj1];
    [webViewBGView addSubview:psWebView];
    psWebView.delegate = self;
    psWebView.tag = 888;
    psWebView.hidden = YES;

    
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [spinner setCenter:webViewBGView.center];
    [spinner startAnimating];
    [spinner setTag:666];
    [webViewBGView addSubview:spinner];
    
    UIButton *tncCrosButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [tncCrosButton setBackgroundImage:[UIImage imageNamed:@"btn_cross.png"] forState:UIControlStateNormal];
    tncCrosButton.frame = CGRectMake(281, 5, 33, 28);
    [tncCrosButton addTarget:self action:@selector(closeButtonTouchedForTnCWebView:) forControlEvents:UIControlEventTouchUpInside];
    [tncWebView addSubview:tncCrosButton];
    
    UIButton *psCrossButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [psCrossButton setBackgroundImage:[UIImage imageNamed:@"btn_cross.png"] forState:UIControlStateNormal];
    psCrossButton.frame = CGRectMake(281, 5, 33, 28);
    [psCrossButton addTarget:self action:@selector(closeButtonTouchedForTnCWebView:) forControlEvents:UIControlEventTouchUpInside];
    [psWebView addSubview:psCrossButton];
    
    UIButton *privacyStmntBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [privacyStmntBtn setBackgroundImage:[UIImage imageNamed:@"btn_privacyStatement.png"] forState:UIControlStateNormal];
    privacyStmntBtn.frame = CGRectMake(200, 40, 118, 33);
    [privacyStmntBtn addTarget:self action:@selector(privacyStatementButtonTouchedForTnCWebView:) forControlEvents:UIControlEventTouchUpInside];
    [tncWebView addSubview:privacyStmntBtn];

}

- (void)resetSubViews
{
    //SubClasses will override this method to reset their SubViews, It will be called from viewDidLoad automativally
}

- (void)navigateBack:(HTButton*)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)navigateForwardTo:(UIViewController *)toViewController
{
    CATransition* transition = [CATransition animation];
    transition.duration = kDefaultViewMovingAnimtionTime;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    transition.type = kCATransitionMoveIn; //kCATransitionMoveIn; //, kCATransitionPush, kCATransitionReveal, kCATransitionFade
    transition.subtype = kCATransitionFromRight; //kCATransitionFromLeft, kCATransitionFromRight, kCATransitionFromTop, kCATransitionFromBottom
    [self.navigationController.view.layer addAnimation:transition forKey:nil];
    [self.navigationController pushViewController:toViewController animated:NO];
}

- (IBAction)playLogoButtonAnimations:(HTButton *)sender
{
    
}

- (void)showFullScreenAcitvityIndicatorView
{
    [self hideFullScreenAcitvityIndicatorView];
    self.fullScreenActivityIndicatorView = [[HTActivityIndicatorView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:_fullScreenActivityIndicatorView];
    [self.view bringSubviewToFront:_fullScreenActivityIndicatorView];
}

- (void)hideFullScreenAcitvityIndicatorView
{
    [_fullScreenActivityIndicatorView removeFromSuperview];
    self.fullScreenActivityIndicatorView = nil;
}

- (void)performingNetworkCallWithObject:(id)networkObject forNotificationName:(NSString*)notificationName
{
    if (networkObject && notificationName) {
        [self.objectsPerformingNetworkRequest setObject:networkObject forKey:notificationName];
    }
    //else ignore
}

- (void)networkCallFinishedForNotificationName:(NSString*)notificationName
{
    [self.objectsPerformingNetworkRequest removeObjectForKey:notificationName];
}

- (void)moveView:(UIView*)view toScreenPositon:(ScreenPosition)screenPosition
{
    switch (screenPosition) {
        case screenPositionCenterX:
        {
            view.center = CGPointMake(self.view.center.x, view.center.y);
        }
            break;
        case screenPositionOutsideLeftX:
        {
            CGRect frame = view.frame;
            frame.origin.x = -self.view.frame.size.width;
            view.frame = frame;
        }
            break;
        case screenPositionOutsideRightX:
        {
            CGRect frame = view.frame;
            frame.origin.x = +self.view.frame.size.width;
            view.frame = frame;
        }
            break;
        case screenPositionOutsideBottomY:
        {
            CGRect frame = view.frame;
            frame.origin.y = +self.view.frame.size.height;
            view.frame = frame;
        }
            break;
            
        default:
            break;
    }
}

- (void)forceLogoutCurrentUser
{
    [HTUtility showInfo:@"You are logged out from here because you logged in on another device"];
    [self logoutCurrentUser];
}

- (void)logoutCurrentUser
{
    [HTUtility appDelegate].currentRideNavController = [[UINavigationController alloc] initWithRootViewController:[[HTDriverProfileViewController alloc] init]];
    [HTUtility appDelegate].requestRideNavController = [[UINavigationController alloc] initWithRootViewController:[[HTPickupAndDestinationLocationViewController alloc] init]];
    [HTUtility appDelegate].profileNavController = [[UINavigationController alloc] initWithRootViewController:[[HTProfileViewController alloc] init]];
    [HTUtility appDelegate].bookingsNavController = [[UINavigationController alloc] initWithRootViewController:[[HTFutureBookingViewController alloc]init]];
    [[HTUserProfileManager sharedManager] removeAllDataOfCurrentLoggedInUser];
    HTGetStartedViewController *signupVC = [[HTGetStartedViewController alloc] init];
    [HTUtility chageWindowRootViewControllerTo:signupVC withBackwardAnimation:YES];
}

- (UIView*)adjustViewForNonRetina:(UIView*)view
{
    CGRect frame = view.frame;
    frame.size = CGSizeMake(frame.size.width/2, frame.size.height/2);
    view.frame = frame;
    return view;
}

- (void)endEditing:(BOOL)end
{
    [_menuTableView animateWithHiden:YES];
    _menuBgView.hidden = YES;
    [self.view endEditing:end];
}

- (BOOL)isMenuActive
{
    return YES;
}

- (void)showMenuInactiveMessage
{
    //Override it for custom messages
}

#pragma mark - Touch event methods

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self endEditing:YES];
}


#pragma mark - Text Field Delegate Methods

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    _currentFirstResponderOriginYValue = [textField.superview convertPoint:textField.frame.origin toView:nil].y;
    return TRUE;
}

#pragma mark - Notification methods
- (void)onKeyboardWillShowNotification:(NSNotification *)notification
{
    [UIView animateWithDuration:kDefaultViewMovingAnimtionTime animations:^{
        float defaultTFHeiht = 40;
        float keyboardHeight = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size.height;
        float keyboardOriginYValue = self.view.frame.size.height - keyboardHeight;
        if ((_currentFirstResponderOriginYValue+defaultTFHeiht) > keyboardOriginYValue) {
            CGRect frame = self.view.frame;
            frame.origin.y -= (_currentFirstResponderOriginYValue+defaultTFHeiht) - keyboardOriginYValue;
            self.view.frame = frame;
        }
    } completion:^(BOOL finished) {
        //Nothing
    }];
}

- (void)onKeyboardWillHideNotification:(NSNotification *)notification
{
    [UIView animateWithDuration:kDefaultViewMovingAnimtionTime animations:^{
        CGRect frame = self.view.frame;
        frame.origin.y = 0;
        self.view.frame = frame;
    } completion:^(BOOL finished) {
        //Nothing
    }];
}


#pragma mark- Menu Delegate methods
- (void)menuItemSelectedAtIndex:(NSInteger)index
{
    currentlySelectedMenuItemIndex = index;
    switch (index) {
        case 0:
        {
            NSArray *viewControllers = [(UINavigationController*)[HTUtility appDelegate].window.rootViewController viewControllers];
            if (viewControllers.count > 0) {
                HTDriverProfileViewController *driverProfileVC = viewControllers[0];
                if ([driverProfileVC respondsToSelector:@selector(invalidateTimers)]) {
                    [driverProfileVC invalidateTimers];
                }
            }
            [HTUtility appDelegate].window.rootViewController = [[UINavigationController alloc] initWithRootViewController:[[HTDriverProfileViewController alloc] init]];
        }
            break;
        case 1:
            [HTUtility appDelegate].window.rootViewController = [HTUtility appDelegate].requestRideNavController;
            break;
        case 2:
            [HTUtility appDelegate].window.rootViewController = [HTUtility appDelegate].profileNavController;
            break;
        case 3:
            [HTUtility appDelegate].window.rootViewController = [[UINavigationController alloc] initWithRootViewController:[[HTFutureBookingViewController alloc]init]];
            break;
        case 6:
            [self showTnCWebView];
            break;
        default:
            break;
    }
    [self endEditing:YES];
    NSLog(@"Touched at Index %d with name %@",index,_menuButtonTextsArray[index]);
}

#pragma mark- Webview delegate methods
- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [[[self.view viewWithTag:555] viewWithTag:666] setHidden:NO];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [[[self.view viewWithTag:555] viewWithTag:666] setHidden:YES];
}

@end
