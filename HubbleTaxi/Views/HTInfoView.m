//
//  HTInfoView.m
//  HubbleTaxi
//
//  Created by Aamir Javed on 12/08/2014.
//  Copyright (c) 2014 Apponative. All rights reserved.
//

#import "HTInfoView.h"
@interface HTInfoView()<UITextFieldDelegate>
@property (nonatomic,weak)HTTextField *secretCodeTF;
- (void)infoViewButtonTouched:(HTButton*)sender;
- (void)getStartedButtonTouched:(HTButton*)sender;
@end

@implementation HTInfoView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (id)initWithMessage:(NSString *)message
{
    self = [super initWithFrame:[HTUtility appDelegate].window.bounds];
    if (self) {
        HTView *backgroundView = [[HTView alloc] initWithFrame:CGRectMake(0, 0, 300, 200)];
        self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.4];
        [self addSubview:backgroundView];
        backgroundView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.8];
        backgroundView.layer.masksToBounds = NO;
        backgroundView.layer.cornerRadius = 8; // if you like rounded corners
        backgroundView.layer.borderColor = [UIColor grayColor].CGColor;
        backgroundView.layer.borderWidth = 2;
        backgroundView.center = CGPointMake([UIScreen mainScreen].bounds.size.width/2, [UIScreen mainScreen].bounds.size.height/2);
        CGRect frame = backgroundView.frame;
        HTLabel *titleLabel = [[HTLabel alloc] initWithFrame:CGRectMake(0,0, 200, 30)];
        titleLabel.center = CGPointMake(frame.size.width/2,40);
        titleLabel.text = kAppName;
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.font = [UIFont boldSystemFontOfSize:30];
        titleLabel.textColor = [UIColor whiteColor];
        [backgroundView addSubview:titleLabel];
        HTLabel *messageLabel = [[HTLabel alloc] initWithFrame:CGRectMake(frame.size.width/2, 40, 250, 200)];
        messageLabel.center = CGPointMake(frame.size.width/2,frame.size.height/2);
        messageLabel.text = message;
        messageLabel.numberOfLines = 0;
        titleLabel.textAlignment = NSTextAlignmentCenter;
        messageLabel.textColor = [UIColor whiteColor];
        [backgroundView addSubview:messageLabel];
        
        HTButton *okButton = [HTButton buttonWithType:UIButtonTypeCustom];
        [okButton setBackgroundImage:[[UIImage imageNamed:@"buttonplane.png"] stretchableImageWithLeftCapWidth:14 topCapHeight:14] forState:UIControlStateNormal];
        okButton.frame = CGRectMake(0, 0, 250, 40);
        [okButton setTitle:@"OK" forState:UIControlStateNormal];
        [okButton.titleLabel setFont:[UIFont boldSystemFontOfSize:20]];
        okButton.center = CGPointMake(frame.size.width/2, frame.size.height - 30);
        [okButton addTarget:self action:@selector(infoViewButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
        [backgroundView addSubview:okButton];
    }
    return self;
}

- (id)initWithSecretCode:(NSString*)secretCode toMobNumber:(NSString *)mobileNumber
{
    self = [super initWithFrame:[HTUtility appDelegate].window.bounds];
    if (self) {
        HTView *backgroundView = [[HTView alloc] initWithFrame:CGRectMake(0, 0, 300, 300)];
        self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.4];
        [self addSubview:backgroundView];
        backgroundView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.8];
        backgroundView.layer.masksToBounds = NO;
        backgroundView.layer.cornerRadius = 8; // if you like rounded corners
        backgroundView.layer.borderColor = [UIColor grayColor].CGColor;
        backgroundView.layer.borderWidth = 2;
        backgroundView.center = CGPointMake([UIScreen mainScreen].bounds.size.width/2, [UIScreen mainScreen].bounds.size.height/2-70);
        CGRect frame = backgroundView.frame;
        
        HTImageView *logoIV = [[HTImageView alloc] initWithImage:[HTUtility halfSizedImageWithName:@"logo.png"]];
        logoIV.center = CGPointMake(backgroundView.center.x-10, logoIV.frame.size.height/2+10);
        [backgroundView addSubview:logoIV];
        
        HTLabel *messageLabel = [[HTLabel alloc] initWithFrame:CGRectMake(frame.size.width/2, 40, 250, 200)];
        messageLabel.center = CGPointMake(frame.size.width/2,frame.size.height/2);
        if (isSMSOnTest) {
            messageLabel.text = [NSString stringWithFormat:kCTSecrectCodeIsSentToYouPhoneString,[NSString stringWithFormat:@"%@ [%@]",mobileNumber,secretCode]];
        }else
        {
            messageLabel.text = [NSString stringWithFormat:kCTSecrectCodeIsSentToYouPhoneString,mobileNumber];
        }
        messageLabel.numberOfLines = 0;
        messageLabel.textAlignment = NSTextAlignmentCenter;
        messageLabel.textColor = [UIColor whiteColor];
        [backgroundView addSubview:messageLabel];
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:messageLabel.text];
        [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor orangeColor] range:[messageLabel.text rangeOfString:mobileNumber]];
        messageLabel.attributedText = attributedString;
        
        HTTextField *secretCodeTF = [[HTTextField alloc] initWithFrame:CGRectMake(25, 200, 250, 41)];
        [secretCodeTF setPlaceholder:@"Pop in secret code here"];
        [secretCodeTF setFont:[UIFont systemFontOfSize:15]];
        [secretCodeTF setBackground:[HTUtility halfSizedImageWithName:@"tf_phonenumber.png"]];
        secretCodeTF.keyboardType = UIKeyboardTypeNumberPad;
        secretCodeTF.spellCheckingType = UITextSpellCheckingTypeNo;
        secretCodeTF.autocorrectionType = UITextAutocorrectionTypeNo;
        [secretCodeTF setDelegate:self];
        [backgroundView addSubview:secretCodeTF];
        self.secretCodeTF = secretCodeTF;
        
        HTButton *cancelButton = [HTButton buttonWithType:UIButtonTypeCustom];
        [cancelButton setBackgroundImage:[HTUtility halfSizedImageWithName:@"btn_cancel.png"] forState:UIControlStateNormal];
        cancelButton.frame = CGRectMake(10, 250, 116, 32);
        [backgroundView addSubview:cancelButton];
        
        HTButton *getStartedButton = [HTButton buttonWithType:UIButtonTypeCustom];
        [getStartedButton setBackgroundImage:[HTUtility halfSizedImageWithName:@"btn_getstarted_small.png"] forState:UIControlStateNormal];
        getStartedButton.frame = CGRectMake(174, 250, 116, 32);
        [backgroundView addSubview:getStartedButton];

        [cancelButton addTarget:self action:@selector(infoViewButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
        [getStartedButton addTarget:self action:@selector(getStartedButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

- (void)show
{
    [[HTUtility appDelegate].window addSubview:self];
}

- (void)infoViewButtonTouched:(HTButton*)sender
{
    [self removeFromSuperview];
}

- (void)getStartedButtonTouched:(HTButton *)sender
{
    [HTUtility postNotificationWithName:kSecretCodeEnteredNotificationName userInfo:@{@"secretCode":_secretCodeTF.text}];
    [self infoViewButtonTouched:nil];
}

#pragma mark- Text field delegate methods
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self endEditing:YES];
}
@end
