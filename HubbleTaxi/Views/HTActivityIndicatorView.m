//
//  HTActivityIndicatorView.m
//  HubbleTaxi
//
//  Created by Aamir Javed on 13/02/2014.
//  Copyright (c) 2014 Apponative. All rights reserved.
//

#import "HTActivityIndicatorView.h"

@interface HTActivityIndicatorView()
{
    
}
@property (nonatomic, retain)HTImageView *spinnerImageView;
@property (nonatomic,assign)BOOL isAnimationStopped;

- (void)playFullCircleAnimation;
@end

@implementation HTActivityIndicatorView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect
 {
 // Drawing code
 }
 */

- (void)playFullCircleAnimation
{
    [UIView beginAnimations:@"FullCircleAnimation" context:nil];
    [UIView setAnimationDuration:0.4];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationCurve:UIViewAnimationCurveLinear];
    CGFloat currentAngleInRadians = atan2f(_spinnerImageView.transform.b, _spinnerImageView.transform.a);
    _spinnerImageView.transform = CGAffineTransformMakeRotation(currentAngleInRadians + M_PI-0.1);
    if (!_isAnimationStopped) {
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDidStopSelector:@selector(playFullCircleAnimation)];
    }
    [UIView commitAnimations];
}

- (void)willMoveToSuperview:(UIView *)newSuperview
{
    [super willMoveToSuperview:newSuperview];
    self.isAnimationStopped = NO;
    if (!newSuperview) {
        self.isAnimationStopped = YES;
    }else
    {
        if (!_spinnerImageView)
        {
            self.spinnerImageView = [[HTImageView alloc] initWithImage:[UIImage imageNamed:@"circular_spinner.png"] highlightedImage:nil];
            self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
            _spinnerImageView.center = CGPointMake(self.frame.size.width/2,self.frame.size.height/2);
            [self addSubview:_spinnerImageView];
            
            [self playFullCircleAnimation];
        }
    }
}

@end
