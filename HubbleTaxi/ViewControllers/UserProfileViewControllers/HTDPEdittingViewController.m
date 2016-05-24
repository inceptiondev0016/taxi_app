//
//  HTDPEdittingViewController.m
//  HubbleTaxi
//
//  Created by Aamir Javed on 16/07/2014.
//  Copyright (c) 2014 Apponative. All rights reserved.
//

#import "HTDPEdittingViewController.h"

@interface HTDPEdittingViewController ()<UIGestureRecognizerDelegate>
@property (weak, nonatomic) IBOutlet HTImageView *dpImageView;
@property (weak, nonatomic) IBOutlet HTImageView *dpImageViewOriginal;

@property (nonatomic) CGFloat circleRadius;
@property (nonatomic) CGPoint circleCenter;

@property (nonatomic, weak) CAShapeLayer *maskLayer;
@property (nonatomic, weak) CAShapeLayer *circleLayer;

@property (nonatomic, weak) UIPinchGestureRecognizer *pinchGesture;
@property (nonatomic, weak) UIPanGestureRecognizer   *panGesture;

- (IBAction)doneButtonTouched:(HTButton *)sender;

- (void)updateCirclePathAtLocation:(CGPoint)location radius:(CGFloat)radius;
- (void)handlePan:(UIPanGestureRecognizer *)gesture;
- (void)handlePinch:(UIPinchGestureRecognizer *)gesture;
@end

@implementation HTDPEdittingViewController

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
    if (_dpImage) {
        [_dpImageView setImage:_dpImage];
        [_dpImageViewOriginal setImage:_dpImage];
        [_dpImageViewOriginal.layer setOpacity:0.5];
        _dpImageViewOriginal.layer.borderWidth = 2.0;
        _dpImageViewOriginal.layer.borderColor = [[UIColor blackColor] CGColor];
    }
    
    // create layer mask for the image
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    self.dpImageView.layer.mask = maskLayer;
    self.maskLayer = maskLayer;
    
    // create shape layer for circle we'll draw on top of image (the boundary of the circle)
    CAShapeLayer *circleLayer = [CAShapeLayer layer];
    circleLayer.lineWidth = 3.0;
    circleLayer.fillColor = [[UIColor clearColor] CGColor];
    circleLayer.strokeColor = [[UIColor orangeColor] CGColor];
    circleLayer.lineDashPattern = @[@6, @2];
    [self.dpImageView.layer addSublayer:circleLayer];
    self.circleLayer = circleLayer;
    
    // create circle path
    [self updateCirclePathAtLocation:CGPointMake(self.dpImageView.bounds.size.width / 2.0, self.dpImageView.bounds.size.height / 2.0) radius:68];
    
    // create pan gesture
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    pan.delegate = self;
    [self.view addGestureRecognizer:pan];
    self.dpImageView.userInteractionEnabled = YES;
    self.panGesture = pan;
    
    // create pan gesture
    UIPinchGestureRecognizer *pinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinch:)];
    pinch.delegate = self;
    [self.view addGestureRecognizer:pinch];
    self.pinchGesture = pinch;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark- Action methods
- (IBAction)doneButtonTouched:(HTButton *)sender
{
    CGFloat scale  = [[self.dpImageView.window screen] scale];
    CGFloat radius = self.circleRadius * scale;
    CGPoint center = CGPointMake(self.circleCenter.x * scale, self.circleCenter.y * scale);
    CGRect frame = CGRectMake(center.x - radius,
                              center.y - radius,
                              radius * 2.0,
                              radius * 2.0);
    
    // temporarily remove the circleLayer
    CALayer *circleLayer = self.circleLayer;
    [self.circleLayer removeFromSuperlayer];
    // render the clipped image
    UIGraphicsBeginImageContextWithOptions(self.dpImageView.frame.size, NO, 0.0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    if ([self.dpImageView respondsToSelector:@selector(drawViewHierarchyInRect:afterScreenUpdates:)])
    {
        // if iOS 7, just draw it
        [self.dpImageView drawViewHierarchyInRect:self.dpImageView.bounds afterScreenUpdates:YES];
    }
    else
    {
        // if pre iOS 7, manually clip it
        CGContextAddArc(context, self.circleCenter.x, self.circleCenter.y, self.circleRadius, 0, M_PI * 2.0, YES);
        CGContextClip(context);
        [self.dpImageView.layer renderInContext:context];
    }
    
    // capture the image and close the context
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    // add the circleLayer back
    [self.dpImageView.layer addSublayer:circleLayer];
    
    // crop the image
    CGImageRef imageRef = CGImageCreateWithImageInRect([image CGImage], frame);
    UIImage *croppedImage = [UIImage imageWithCGImage:imageRef];
    
    NSDictionary *infoDictionary = [NSDictionary dictionaryWithObject:croppedImage forKey:kDPCroppedImageKey];
    [HTUtility postNotificationWithName:kdpCroppedNotificationName userInfo:infoDictionary];
}

- (void)navigateBack:(HTButton *)sender
{
    [HTUtility postNotificationWithName:kdpCroppedNotificationName userInfo:nil];
}

#pragma mark- Custom methods
- (void)updateCirclePathAtLocation:(CGPoint)location radius:(CGFloat)radius
{
    if (CGRectContainsPoint(_dpImageView.bounds, location) && radius<_dpImageView.frame.size.width/2) {
        self.circleCenter = location;
        self.circleRadius = radius;
        
        UIBezierPath *path = [UIBezierPath bezierPath];
        [path addArcWithCenter:self.circleCenter
                        radius:self.circleRadius
                    startAngle:0.0
                      endAngle:M_PI * 2.0
                     clockwise:YES];
        self.maskLayer.path = [path CGPath];
        self.circleLayer.path = [path CGPath];
    }else{
        NSLog(@"Outside");
    }
}

#pragma mark - Gesture recognizers
- (void)handlePan:(UIPanGestureRecognizer *)gesture
{
    static CGPoint oldCenter;
    CGPoint tranlation = [gesture translationInView:gesture.view];
    
    if (gesture.state == UIGestureRecognizerStateBegan)
    {
        oldCenter = self.circleCenter;
    }
    CGPoint newCenter = CGPointMake(oldCenter.x + tranlation.x, oldCenter.y + tranlation.y);
    [self updateCirclePathAtLocation:newCenter radius:self.circleRadius];
}

- (void)handlePinch:(UIPinchGestureRecognizer *)gesture
{
    static CGFloat oldRadius;
    CGFloat scale = [gesture scale];
    if (gesture.state == UIGestureRecognizerStateBegan)
    {
        oldRadius = self.circleRadius;
    }
    CGFloat newRadius = oldRadius * scale;
    [self updateCirclePathAtLocation:self.circleCenter radius:newRadius];
}


#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    if ((gestureRecognizer == self.panGesture   && otherGestureRecognizer == self.pinchGesture) ||
        (gestureRecognizer == self.pinchGesture && otherGestureRecognizer == self.panGesture))
    {
        return YES;
    }
    return NO;
}

@end
