//
//  HTPaymentMethodViewController.m
//  HubbleTaxi
//
//  Created by Aamir Javed on 22/04/2014.
//  Copyright (c) 2014 Apponative. All rights reserved.
//

#import "HTPaymentMethodViewController.h"
#import "PTKView.h"
#import "HTPaymentConfirmationViewController.h"
#import "HTUserProfileManager.h"
#import "HTUserPaymentManager.h"
#import "PTKTextField.h"

@interface HTPaymentMethod : NSObject
@property(nonatomic,retain)NSString* methodName;
@property (nonatomic,retain)UIImage* methodIcon;
@end

@implementation HTLocationInfo
@end

@implementation HTPaymentMethod
@end

@implementation HTPaymentInfo
@end

@interface HTPaymentMethodViewController ()<UITableViewDataSource,UITableViewDelegate, PTKViewDelegate,UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet HTLabel *pageTitleLabel;
@property (weak, nonatomic) IBOutlet HTTableView *paymentMethodSelectionTableView;
@property (strong, nonatomic) NSMutableArray* paymentMethodsArray;
@property (weak, nonatomic) IBOutlet HTView *cardInfoContainerView;
@property (weak, nonatomic) IBOutlet HTTextField *emailTF;
@property (weak, nonatomic) IBOutlet PTKView *stripeCardView;
@property (weak, nonatomic) IBOutlet HTLabel *storeCardDetailsLabel;
@property (weak, nonatomic) IBOutlet UISwitch *storeCardDetailsSwitch;
@property (weak, nonatomic) IBOutlet HTButton *cancelButton;
@property (weak, nonatomic) IBOutlet HTButton *payButton;
@property (nonatomic, assign) BOOL isValidCardInfoEntered;
@property (nonatomic,retain)HTPaymentInfo *paymentInfo;

- (IBAction)cancelButtonTouched:(HTButton *)sender;
- (IBAction)payButtonTouched:(HTButton *)sender;

- (void)navigateToPaymentConfirmationPage;
- (void)uploadAccountInfo;
- (void)updatePaymentMethods;
- (void)addPaymentMethod:(NSString*)paymentMethodName icon:(UIImage*)icon;

- (void)onAcccountInfoUpdateResultNotification:(NSNotification*)notification;
@end

@implementation HTPaymentMethodViewController

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
        self.paymentMethodsArray = [[NSMutableArray alloc] init];
        [self updatePaymentMethods];
    }
    return self;
}



- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.paymentMethodSelectionTableView.tableFooterView = [[UIView alloc] init];
    _stripeCardView.delegate = self;
    self.isValidCardInfoEntered = NO;
    self.view.backgroundColor = [UIColor colorWithRed:207/255.0 green:211/255.0 blue:203/255.0 alpha:1];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [_paymentMethodSelectionTableView reloadData];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.stripeCardView endEditing:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark- Action methods
- (IBAction)cancelButtonTouched:(HTButton *)sender
{
    _cardInfoContainerView.hidden = YES;
}

- (IBAction)payButtonTouched:(HTButton *)sender
{
    if (_emailTF.text.length) {
        if ([HTUtility isEmailValidWithString:_emailTF.text])
        {
            if (_isValidCardInfoEntered)
            {
                NSString *oldEmail = [[[HTUserProfileManager sharedManager] currentUserProfile] objectForKey:kLoggedInUserEmailKey];
                if (oldEmail.length == 0 || (oldEmail.length>0 && ![oldEmail isEqualToString:_emailTF.text])) {
                    [self uploadAccountInfo];
                }else
                {
                    [self navigateToPaymentConfirmationPage];
                }
            }else
            {
                [HTUtility showInfo:@"Please enter a valid card information"];
            }
        }else
        {
            [HTUtility showInfo:kAccountInfoEmailNotValidString];
        }
    }else
    {
        [HTUtility showInfo:kAccountInfoEmailMissingString];
    }
}

#pragma mark- Custom methods
- (void)navigateToPaymentConfirmationPage
{
    _cardInfoContainerView.hidden = YES;
    if (_storeCardDetailsSwitch.isOn)
    {
        //TODO change it
        
        [[HTUserPaymentManager sharedManager] saveCardWithNumberString:_stripeCardView.cardNumberField.text CVCString:_stripeCardView.cardCVCField.text expiryString:_stripeCardView.cardExpiryField.text];
        
        //TODO if needed
       // [[HTUserPaymentManager sharedManager] saveCardWithNumberString:_stripeCardView.cardNumber.string CVCString:_stripeCardView.cardCVC.string expiryString:_stripeCardView.paymentView.cardExpiry.formattedString];
        [self updatePaymentMethods];
    }

    UITableViewCell *cell = [_paymentMethodSelectionTableView cellForRowAtIndexPath:[_paymentMethodSelectionTableView indexPathForSelectedRow]];
    self.paymentInfo.cardCharginView = nil;
    self.paymentInfo.paymentMethod = cell.textLabel.text;
    
    if ([self.paymentInfo.paymentMethod isEqualToString:kPaymentMethodPayByCashString]) {
        //Pay by cash
    }
    else if ([self.paymentInfo.paymentMethod isEqualToString: kPaymentMethodPayUsingNewCardString])
    {
        //New card
        PTKView *cardChargingView = [[PTKView alloc] init];
        cardChargingView.cardNumberField.text = [PTKTextField textByRemovingUselessSpacesFromString:_stripeCardView.cardNumberField.text];
        cardChargingView.cardCVCField.text = [PTKTextField textByRemovingUselessSpacesFromString:_stripeCardView.cardCVCField.text];
        cardChargingView.cardExpiryField.text = [PTKTextField textByRemovingUselessSpacesFromString:_stripeCardView.cardExpiryField.text];

        self.paymentInfo.cardCharginView = cardChargingView;
        
    }else
    {
        //Already registered cards
        NSDictionary *profileDictionary = [[HTUserProfileManager sharedManager] currentUserProfile];
        NSArray *userCards = [profileDictionary objectForKey:kLoggedInUserCardsKey];
        NSUInteger currentSelectedIndex = [_paymentMethodSelectionTableView indexPathForSelectedRow].row - kOffsetRowsForCardNumbersInTableView;
        if ( currentSelectedIndex < userCards.count) {
            PTKView *cardChargingView = [[PTKView alloc] init];
            NSDictionary *dictionary = [userCards objectAtIndex:currentSelectedIndex];
            cardChargingView.cardNumberField.text = [PTKTextField textByRemovingUselessSpacesFromString:[dictionary objectForKey:kLoggedInUserCardNumberKey]];
            cardChargingView.cardCVCField.text = [PTKTextField textByRemovingUselessSpacesFromString:[dictionary objectForKey:kLoggedInUserCardCVCKey]];
            cardChargingView.cardExpiryField.text = [PTKTextField textByRemovingUselessSpacesFromString:[dictionary objectForKey:kLoggedInUserCardExpiryKey]];
            self.paymentInfo.cardCharginView = cardChargingView;
        }
    }
    
    self.paymentInfo.paymentMethod = @"Cash";
    if (![cell.textLabel.text isEqualToString:kPaymentMethodPayByCashString]) {
        //self.paymentInfo.paymentMethod = [NSString stringWithFormat:@"VIA CARD XXXX XXXX XXXX %@",self.paymentInfo.cardCharginView.paymentView.cardNumber.last4];
        self.paymentInfo.paymentMethod = @"Card";
    }
    HTPaymentConfirmationViewController *paymentConfirmVC = [[HTPaymentConfirmationViewController alloc] initWithPaymentInfo:_paymentInfo];
    [self navigateForwardTo:paymentConfirmVC];
}

- (void)uploadAccountInfo
{
    
    [self showFullScreenAcitvityIndicatorView];
    __block HTSessionRenew *sessionRenew = [[HTSessionRenew alloc] init];
    [self.renewSessionObjectsArray addObject:sessionRenew];
    [sessionRenew renewSessionWithCallbackBlock:^(bool succeeded, bool isLogout) {
        [self hideFullScreenAcitvityIndicatorView];
        [self.renewSessionObjectsArray removeObject:sessionRenew];
        sessionRenew  = nil;
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
                                                       _emailTF.text, kLoggedInUserEmailKey,
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

- (void)updatePaymentMethods
{
    NSString *priceValue = _paymentInfo.noDestinationYet?kPaymentMethodNoDestinationSelectedString:_paymentInfo.priceString;
    
    [self.paymentMethodsArray removeAllObjects];
    [self  addPaymentMethod:priceValue icon:nil];
    
    NSDictionary *profileDictionary = [[HTUserProfileManager sharedManager] currentUserProfile];
    NSArray *existingUserCards = [profileDictionary objectForKey:kLoggedInUserCardsKey];
    NSArray *cardNumbers = [existingUserCards valueForKey:kLoggedInUserCardNumberKey];
    NSString *last4DigitsString = nil;
    for (NSString *cardNumberString in cardNumbers)
    {
        if (cardNumberString.length>4) {
            last4DigitsString = [NSString stringWithFormat:@"XXXX XXXX XXXX %@",[cardNumberString substringFromIndex:cardNumberString.length-4]];
        }
        PTKCardType cardType = [PTKCardNumber cardNumberWithString:cardNumberString].cardType;
        NSString *cardIconName = cardType == PTKCardTypeMasterCard?@"mastercardicon":@"visaicon";
        cardIconName = cardType == PTKCardTypeAmex?@"amexicon":cardIconName;
        [self addPaymentMethod:last4DigitsString icon:[HTUtility halfSizedImageWithName:cardIconName]];
    }
    
    [self addPaymentMethod:kPaymentMethodPayUsingNewCardString icon:[HTUtility halfSizedImageWithName:@"addnewcard.png"]];
    [self addPaymentMethod:kPaymentMethodPayByCashString icon:[HTUtility halfSizedImageWithName:@"payviacash.png"]];
}

- (void)addPaymentMethod:(NSString*)paymentMethodName icon:(UIImage*)icon
{
    HTPaymentMethod *paymentMethod = [[HTPaymentMethod alloc] init];
    paymentMethod.methodName = paymentMethodName;
    paymentMethod.methodIcon = icon;
    [_paymentMethodsArray addObject:paymentMethod];
}


#pragma mark- Table View methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _paymentMethodsArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString* cellIdentifier = @"PaymentMethodCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
        cell.backgroundColor = [UIColor clearColor];
    }
    HTPaymentMethod *paymentMethod = [_paymentMethodsArray objectAtIndex:indexPath.row];
    
    cell.textLabel.text = paymentMethod.methodName;
    cell.imageView.image = paymentMethod.methodIcon;
    [tableView setSeparatorInset:UIEdgeInsetsZero];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if ([cell.textLabel.text isEqualToString:kPaymentMethodPayUsingNewCardString]) {
        NSString *email = [[[HTUserProfileManager sharedManager] currentUserProfile] objectForKey:kLoggedInUserEmailKey];
        if (email.length) {
            [_emailTF setText:email];
        }
        _cardInfoContainerView.hidden = NO;
    }else
    {
        [self navigateToPaymentConfirmationPage];
    }
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    return indexPath.row;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (indexPath.row ==0 || [cell.textLabel.text isEqualToString:kPaymentMethodPayByCashString] || [cell.textLabel.text isEqualToString:kPaymentMethodPayUsingNewCardString])
    {
        return UITableViewCellEditingStyleNone;
    }
    return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(editingStyle == UITableViewCellEditingStyleDelete)
    {
        [_paymentMethodsArray removeObjectAtIndex:indexPath.row];
        [self.paymentMethodSelectionTableView reloadData];
        [[HTUserPaymentManager sharedManager] deleteCardWithCardIndex:indexPath.row-kOffsetRowsForCardNumbersInTableView];
        self.paymentMethodSelectionTableView.editing = NO;
    }
}


#pragma mark- Stripe methods

- (void)paymentView:(PTKView *)paymentView withCard:(PTKCard *)card isValid:(BOOL)valid
{
    self.isValidCardInfoEntered = NO;
    if (valid) {
        PTKCardType cardType = paymentView.cardNumber.cardType;
        if (cardType == PTKCardTypeVisa || cardType == PTKCardTypeMasterCard || cardType == PTKCardTypeAmex) {
            self.isValidCardInfoEntered = YES;
        }
        else
        {
            [HTUtility showInfo:@"This card type is not supported yet. Please try Visa, Master or American Express for now"];
        }
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
        [self navigateToPaymentConfirmationPage];
    }else{
        //Show try again view for uploading profile
        UIAlertView *profileUploadingFailedView = [[UIAlertView alloc] initWithTitle:kAppName message:kNetworkErrorString delegate:self cancelButtonTitle:kCancelString otherButtonTitles:kTryAgainString, nil];
        profileUploadingFailedView.tag = kAccountInfoUploadingFailedTryAgainStringViewTag;
        [profileUploadingFailedView show];
    }
}

#pragma mark- Alert view methods
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == kAccountInfoUploadingFailedTryAgainStringViewTag) {
        if (buttonIndex == 1) {
            [self uploadAccountInfo];
        }
    }
}

#pragma mark- gestures
- (IBAction)paymentMethodsRightSwipeRecognized:(UISwipeGestureRecognizer *)sender
{
    [self navigateBack:nil];
}


@end
