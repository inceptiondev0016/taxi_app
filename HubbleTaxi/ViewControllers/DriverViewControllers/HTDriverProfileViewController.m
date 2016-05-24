//
//  HTDriverProfileViewController.m
//  HubbleTaxi
//
//  Created by Aamir Javed on 25/06/2014.
//  Copyright (c) 2014 Apponative. All rights reserved.
//

#import "HTDriverProfileViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "HTUserProfileManager.h"
#import "HTUserBookingsManager.h"
#import <GoogleMaps/GoogleMaps.h>
#import "HTCallDriverViewController.h"
#import "HTUserBookingsManager.h"
#import "HTUserLocationManager.h"
#import "HTDestinationReachedViewController.h"

@interface HTDriverProfileViewController ()<UIAlertViewDelegate,CLLocationManagerDelegate>
@property (weak, nonatomic) IBOutlet HTImageView *dpImageView;
@property (weak, nonatomic) IBOutlet HTLabel *nameLabel;
@property (weak, nonatomic) IBOutlet HTTextView *bioTextView;
@property (nonatomic, retain)IBOutletCollection(HTImageView)NSArray *ratingImages;
@property (nonatomic,retain)NSString* currentDriverID;
@property (weak, nonatomic) IBOutlet UIView *viewToShowMap;
@property (nonatomic, retain) GMSMapView *mapView;
@property (nonatomic,retain)GMSMarker *vehicleMarker;
@property (nonatomic,retain)NSTimer *driverLocationRefreshTimer;
@property (weak, nonatomic) IBOutlet HTLabel *vehicleMakeNModelLabel;
@property (weak, nonatomic) IBOutlet HTLabel *vehicleRegistrationNoLabel;
@property (weak, nonatomic) IBOutlet HTButton *nextButton;
@property (nonatomic,retain)NSMutableDictionary *driverProfileDictionary;
@property (weak, nonatomic) IBOutlet HTLabel *timeLabel;
@property (weak, nonatomic) IBOutlet HTTextField *driverMessageTF;
@property (weak, nonatomic) IBOutlet HTTextField *customerInstructionTF;
@property (nonatomic,retain) id directionsOfJourneyRequestObject;
@property (nonatomic,assign)CLLocationCoordinate2D pickupLocationCoordinates;
@property (nonatomic,assign)BOOL isCurrentJobAlreadyFound;
@property (nonatomic, retain)CLLocationManager *locationManager;

- (IBAction)nextButtonTouched:(HTButton *)sender;
- (void)currentBookingOrder;
- (void)downloadCurrentDriverProfile;
- (void)configureMapView;
- (void)updateEstimatedTimeToReachAtPickupLocation;
- (NSString*)timeStringFromTimeSentence:(NSString*)completeTimeString;

- (void)onCurrentBookingOrderResultNotification:(NSNotification*)notification;
- (void)onCurrentDriverProfileDownloadResultNotification:(NSNotification*)notification;
- (void)onSendCustomerInstuctionsToDriverResultNotification:(NSNotification*)notification;
- (void)onDirectionsOfJourneyReceivedRestultNotification:(NSNotification*)notification;

@end

@implementation HTDriverProfileViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.locationManager = [[CLLocationManager alloc] init];
        if ([self.locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
            [self.locationManager requestAlwaysAuthorization];
        }
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.driverLocationRefreshTimer = nil;
    
    // Do any additional setup after loading the view from its nib.
    self.view.backgroundColor = [UIColor colorWithRed:1 green:147/255.0 blue:0 alpha:1];
    [self configureMapView];
    self.dpImageView.layer.cornerRadius = self.dpImageView.frame.size.width/2;
    self.dpImageView.layer.borderColor = [[UIColor clearColor] CGColor];
    self.dpImageView.layer.masksToBounds = YES;
    [self currentBookingOrder];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.locationManager.delegate = self;
    BOOL isLocationServicesEnabled = [CLLocationManager locationServicesEnabled];
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    if (!isLocationServicesEnabled || status != kCLAuthorizationStatusAuthorizedAlways) {
        [HTUtility showInfo:kEnableLocationServices];
        [self navigateBack:nil];
    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [_driverLocationRefreshTimer invalidate];
    self.driverLocationRefreshTimer = nil;
    [_directionsOfJourneyRequestObject cancelAllOperations];
    self.directionsOfJourneyRequestObject = nil;
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    NSLog(@"Driver Profile DEalloc");
}

- (void)invalidateTimers
{
    [HTUtility removeNotificationObserver:self withNotificationName:nil];
    [_driverLocationRefreshTimer invalidate];
    self.driverLocationRefreshTimer = nil;
}


- (IBAction)nextButtonTouched:(HTButton *)sender
{
    HTDriverInfo *driverInfo = [[HTDriverInfo alloc] init];
    driverInfo.driverName = _nameLabel.text;
    driverInfo.vehicleMakeNModel = _vehicleMakeNModelLabel.text;
    driverInfo.vehicleRegNo = _vehicleRegistrationNoLabel.text;
    NSString *bio = _driverProfileDictionary[@"bio-description"];
    driverInfo.driverBio = [bio isKindOfClass:[NSString class]]?bio:@"";
    driverInfo.driverDp = _dpImageView.image;
    NSString *telephone = _driverProfileDictionary[@"telephone"];
    driverInfo.driverPhoneNo = [telephone isKindOfClass:[NSString class]]?telephone:@"";
    NSString *timeToPickup = [self timeStringFromTimeSentence:_timeLabel.text];
    if ([timeToPickup isEqualToString:@"-"]) {
        driverInfo.timeToPickupString = @"";
    }else
    {
        driverInfo.timeToPickupString = [NSString stringWithFormat:@"%d Minute%@ till arrival",timeToPickup.integerValue,timeToPickup.integerValue>1?@"s":@""];
    }
    driverInfo.currentLocationCoordinates = _vehicleMarker.position;
    driverInfo.driverMessageString = _driverMessageTF.text;
    driverInfo.customerInstructionString = _customerInstructionTF.text;
    driverInfo.isInstructionEnabled = _customerInstructionTF.enabled;
    
    HTCallDriverViewController *callDriverVC = [[HTCallDriverViewController alloc] initWithDriverInfo:driverInfo];
    callDriverVC.driverProfileRef = self;
    [self navigateForwardTo:callDriverVC];
}

#pragma mark- Custom methods

- (void)currentBookingOrder
{
    if (!_isCurrentJobAlreadyFound) {
        [self showFullScreenAcitvityIndicatorView];
    }
    __block HTSessionRenew *sessionRenew = [[HTSessionRenew alloc] init];
    [self.renewSessionObjectsArray addObject:sessionRenew];
    [sessionRenew renewSessionWithCallbackBlock:^(bool succeeded, bool isLogout) {
        [self hideFullScreenAcitvityIndicatorView];
        [self.renewSessionObjectsArray removeObject:sessionRenew];
        sessionRenew = nil;
        if (isLogout) {
            [self forceLogoutCurrentUser];
        }else
        {
            if (succeeded)
            {
                if (!_isCurrentJobAlreadyFound) {
                    [self showFullScreenAcitvityIndicatorView];
                }
                 [HTUtility addNotificationObserver:self selector:@selector(onCurrentBookingOrderResultNotification:) forNotificationWithName:kBookingOrderRestultNotificationName];
                 id networkOjbect = [[HTUserBookingsManager sharedManager] currentbookingOrderWithCompletionNotificationName:kBookingOrderRestultNotificationName];
                 [self performingNetworkCallWithObject:networkOjbect forNotificationName:kBookingOrderRestultNotificationName];
            }else
            {
                //Handled in renewSession class
            }
        }
    }];
}

- (void)downloadCurrentDriverProfile
{
    if (!_vehicleMarker && !_isCurrentJobAlreadyFound) {
        [self showFullScreenAcitvityIndicatorView];
    }
    __block HTSessionRenew *sessionRenew = [[HTSessionRenew alloc] init];
    [self.renewSessionObjectsArray addObject:sessionRenew];
    [sessionRenew renewSessionWithCallbackBlock:^(bool succeeded, bool isLogout) {
        [self hideFullScreenAcitvityIndicatorView];
        [self.renewSessionObjectsArray removeObject:sessionRenew];
        sessionRenew = nil;
        if (isLogout) {
            [self forceLogoutCurrentUser];
        }else
        {
            if (succeeded)
            {
                if (!_vehicleMarker && !_isCurrentJobAlreadyFound) {
                    [self showFullScreenAcitvityIndicatorView];
                }
                [HTUtility addNotificationObserver:self selector:@selector(onCurrentDriverProfileDownloadResultNotification:) forNotificationWithName:kCurrentDriverProfileDownloadRestultNotificationName];
                id networkOjbect = [[HTUserProfileManager sharedManager] downlaodDriverProfileWithDriverID:_currentDriverID completionNotificationName:kCurrentDriverProfileDownloadRestultNotificationName];
                [self performingNetworkCallWithObject:networkOjbect forNotificationName:kCurrentDriverProfileDownloadRestultNotificationName];
            }else
            {
                //Handled in renewSession class
            }
        }
    }];
}

- (void)configureMapView
{
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:0 longitude:0 zoom:kMapZoomValue];
    self.mapView = [GMSMapView mapWithFrame:_viewToShowMap.bounds camera:camera];
    [self.viewToShowMap addSubview:_mapView];
    _mapView.settings.consumesGesturesInView = NO;
    _mapView.myLocationEnabled = YES;
    _mapView.settings.myLocationButton = YES;
    
    _mapView.settings.compassButton = YES;
//TODO    _mapView.delegate = self;
}

- (void)updateEstimatedTimeToReachAtPickupLocation
{
    [_directionsOfJourneyRequestObject cancelAllOperations];
    [HTUtility addNotificationObserver:self selector:@selector(onDirectionsOfJourneyReceivedRestultNotification:) forNotificationWithName:kDirectionsOfJourneyReceivedRestultNotificationName];

    self.directionsOfJourneyRequestObject = [[HTUserLocationManager sharedManager] directionsOfJourneyWithStartingLocation:[NSString stringWithFormat:@"%f,%f",_vehicleMarker.position.latitude,_vehicleMarker.position.longitude] endingLocation:[NSString stringWithFormat:@"%f,%f",_pickupLocationCoordinates.latitude,_pickupLocationCoordinates.longitude] viaRouteLocaton:nil completionNotificationName:kDirectionsOfJourneyReceivedRestultNotificationName];
}

- (NSString*)timeStringFromTimeSentence:(NSString*)completeTimeString
{
    NSInteger time = 0;
    NSString *timeString = @"-";
    BOOL success = [[NSScanner scannerWithString:completeTimeString] scanInteger:&time];
    if (success && time)
    {
        timeString = [NSString stringWithFormat:@"%ld",(long)time];
    }
    return timeString;
}

#pragma mark- Notification methods
- (void)onCurrentBookingOrderResultNotification:(NSNotification*)notification
{
    [self hideFullScreenAcitvityIndicatorView];
    [HTUtility removeNotificationObserver:self withNotificationName:notification.name];
    [self networkCallFinishedForNotificationName:notification.name];
    NSDictionary *currentBookingResultDictionary = [notification userInfo];
    BOOL success = [[currentBookingResultDictionary objectForKey:kResponseSuccessKey] boolValue];
    if (success)
    {
        NSArray *bookingOrders = currentBookingResultDictionary[kJobObjectFieldsKey];
        if ([bookingOrders isKindOfClass:[NSArray class]] && bookingOrders.count > 0) {
            NSDictionary *currentBookingOrder = bookingOrders[0];
            NSString *pickupLocationString = currentBookingOrder[@"pickup_address_location"];
            NSArray *pickupCoords = [pickupLocationString componentsSeparatedByString:@","];
            self.pickupLocationCoordinates = pickupCoords.count>1?CLLocationCoordinate2DMake([pickupCoords[0] doubleValue], [pickupCoords[1] doubleValue]):CLLocationCoordinate2DMake(0, 0);
            NSString *jobStatus = currentBookingOrder[@"job_status"];
            if (![jobStatus isKindOfClass:[NSString class]]) {
                jobStatus = @"";
            }
            //  [getRequest setObject:@",," forKey:@"job_status[or]"];

            BOOL isJobAssigned = [jobStatus isEqualToString:@"Driver-En-Route"] || [jobStatus isEqualToString:@"Reached-Pickup"] || [jobStatus isEqualToString:@"Authorising-payment"];
            if ([currentBookingOrder[kDriverIDKey] isKindOfClass:[NSString class]] && isJobAssigned) {
                self.vehicleMarker = nil;
                self.currentBookingJobID = currentBookingOrder[@"jobID"];
                self.currentBookingRideNumber = currentBookingOrder[@"jobNumber"];
               // [_driverMessageTF setText:@"Driver Assigned and En Route"];
                NSString *customerInstructionString = currentBookingOrder[@"customerInstruction"];
                if ([customerInstructionString isKindOfClass:[NSString class]]) {
                    self.customerInstructionTF.text = customerInstructionString;
                }
                
                self.currentDriverID = currentBookingOrder[kDriverIDKey] ;
                self.customerInstructionTF.enabled = YES;
                [self downloadCurrentDriverProfile];
                [_driverLocationRefreshTimer invalidate];
                self.driverLocationRefreshTimer = [NSTimer scheduledTimerWithTimeInterval:kDriverRefreshTime target:self selector:@selector(downloadCurrentDriverProfile) userInfo:nil repeats:YES];
            }else
            {
                if (!_vehicleMarker) {
                    self.vehicleMarker = [GMSMarker markerWithPosition:_pickupLocationCoordinates];
                    _vehicleMarker.icon = [HTUtility halfSizedImageWithName:@"location_a_green"];
                    _vehicleMarker.map = _mapView;
                }
                self.isCurrentJobAlreadyFound = YES;
                [_vehicleMarker setPosition:_pickupLocationCoordinates];
                [_mapView animateToLocation:_pickupLocationCoordinates];
                [_driverMessageTF setText:@"Assigning Driver"];
                [self performSelector:@selector(currentBookingOrder) withObject:nil afterDelay:kDriverRefreshTime];
            }
        }
        else
        {
            [HTUtility showInfo:@"You do not have any current job. Please create a job from Request Ride menu"];
        }
    }else{
        //Show try again view for get current booking order
        UIAlertView *bookingOrderResultFailedView = [[UIAlertView alloc] initWithTitle:kAppName message:@"Unable to load your current booking order right now" delegate:self cancelButtonTitle:kCancelString otherButtonTitles:kTryAgainString, nil];
        bookingOrderResultFailedView.tag = kBookingOrderFailedTryAgainViewTag;
        [bookingOrderResultFailedView show];
    }
}

- (void)onCurrentDriverProfileDownloadResultNotification:(NSNotification *)notification
{
    [self hideFullScreenAcitvityIndicatorView];
    [HTUtility removeNotificationObserver:self withNotificationName:notification.name];
    [self networkCallFinishedForNotificationName:notification.name];
    NSDictionary *currentDriverProfileResultDictionary = [notification userInfo];
    BOOL success = [[currentDriverProfileResultDictionary objectForKey:kResponseSuccessKey] boolValue];
    if (success)
    {
        self.driverProfileDictionary = currentDriverProfileResultDictionary[kDriverObjectFieldsKey];
        
        if (_vehicleMarker)
        {
            NSArray *locationCoordinates = _driverProfileDictionary[@"location-coordinates"];
            CLLocationCoordinate2D driverLocation;
            if ([locationCoordinates isKindOfClass:[NSArray class]] && locationCoordinates.count > 1)
            {
                driverLocation = CLLocationCoordinate2DMake([locationCoordinates[1] doubleValue], [locationCoordinates[0] doubleValue]);
                [_mapView animateToLocation:driverLocation];
                [self.vehicleMarker setPosition:driverLocation];
            }
        }else{
            NSString *fullName = [NSString stringWithFormat:@"%@ %@",_driverProfileDictionary[@"first-name"],_driverProfileDictionary[@"last-name"]];
            NSString *bio = _driverProfileDictionary[@"bio-description"];
            self.nameLabel.text = [fullName isKindOfClass:[NSString class]]?fullName:@"";
            self.bioTextView.text = [bio isKindOfClass:[NSString class]]?bio:@"";
            NSString *vehicleMake = _driverProfileDictionary[@"driver-vehicle-make"];
            self.vehicleMakeNModelLabel.text = [vehicleMake isKindOfClass:[NSString class]]?vehicleMake:@"";
            NSString *vehicleRegNum =  _driverProfileDictionary[@"driver-vehicle-reg"];
            self.vehicleRegistrationNoLabel.text =  [vehicleRegNum isKindOfClass:[NSString class]]?vehicleRegNum:@"";
           NSArray *locationCoordinates = _driverProfileDictionary[@"location-coordinates"];
            CLLocationCoordinate2D driverLocation;
            if ([locationCoordinates isKindOfClass:[NSArray class]] && locationCoordinates.count > 1)
            {
                driverLocation = CLLocationCoordinate2DMake([locationCoordinates[1] doubleValue], [locationCoordinates[0] doubleValue]);
                [_mapView animateToLocation:driverLocation];
            }
            
            if (!_vehicleMarker && !_isCurrentJobAlreadyFound) {
                [self showFullScreenAcitvityIndicatorView];
            }
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                NSData *imageData = nil;
                if ([_driverProfileDictionary[@"driver-image"] isKindOfClass:[NSString class]] && _driverProfileDictionary[@"driver-image"]) {
                    NSURL *url = [NSURL URLWithString:_driverProfileDictionary[@"driver-image"]];
                    imageData = [NSData dataWithContentsOfURL:url];
                }
                NSData *vehicleImageData = [NSData dataWithContentsOfURL:[NSURL URLWithString: [_driverProfileDictionary[@"driver-vehicle-image"] isKindOfClass:[NSString class]]?_driverProfileDictionary[@"driver-vehicle-image"]:nil]];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self hideFullScreenAcitvityIndicatorView];
                    if (imageData) {
                        self.dpImageView.image = [UIImage imageWithData:imageData];
                    }
                    self.vehicleMarker = [GMSMarker markerWithPosition:driverLocation];
                    if (vehicleImageData) {
                        _vehicleMarker.icon = [UIImage imageWithData:vehicleImageData scale:5];
                    }else
                    {
                        _vehicleMarker.icon = [HTUtility halfSizedImageWithName:@"taxi.png"];
                    }
                    _vehicleMarker.map = _mapView;
                });
            });
            int rating = 0;
            for (int index = 0; index < MIN(rating, self.ratingImages.count); index++) {
                HTImageView *ratingImageView = self.ratingImages[index];
                ratingImageView.image = [UIImage imageNamed:@"filled_star.png"];
            }
        }
        
        HTDriverInfo *driverInfo = [[HTDriverInfo alloc] init];
        driverInfo.driverName = _nameLabel.text;
        driverInfo.vehicleMakeNModel = _vehicleMakeNModelLabel.text;
        driverInfo.vehicleRegNo = _vehicleRegistrationNoLabel.text;
        NSString *bio = _driverProfileDictionary[@"bio-description"];
        driverInfo.driverBio = [bio isKindOfClass:[NSString class]]?bio:@"";
        driverInfo.driverDp = _dpImageView.image;
        NSString *telephone = _driverProfileDictionary[@"telephone"];
        driverInfo.driverPhoneNo = [telephone isKindOfClass:[NSString class]]?telephone:@"";
        driverInfo.currentLocationCoordinates = _vehicleMarker.position;
        driverInfo.driverMessageString = _driverMessageTF.text;
        driverInfo.customerInstructionString = _customerInstructionTF.text;
        driverInfo.isInstructionEnabled = _customerInstructionTF.enabled;
        NSString *timeToPickup = [self timeStringFromTimeSentence:_timeLabel.text];
        if ([timeToPickup isEqualToString:@"-"]) {
            driverInfo.timeToPickupString = @"";
        }else
        {
            driverInfo.timeToPickupString = [NSString stringWithFormat:@"%d Minute%@ till arrival",timeToPickup.integerValue,timeToPickup.integerValue>1?@"s":@""];
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:@"OnDriverProfileChangedNotificationName" object:nil userInfo:@{@"driverInfo": driverInfo}];
        
        [self updateEstimatedTimeToReachAtPickupLocation];
        
        NSString *driverMessage = _driverProfileDictionary[@"driverMessage"];
        if ([driverMessage isKindOfClass:[NSString class]]) {
            self.driverMessageTF.text = driverMessage;
            if ([driverMessage isEqualToString:@"Destination Reached"]) {
                
                [_driverLocationRefreshTimer invalidate];
                self.driverLocationRefreshTimer = nil;
                [self navigateForwardTo:[[HTDestinationReachedViewController alloc] initWithJobID:_currentBookingJobID]];
            }
        }
    }else{
        //Show try again view for get current booking order
        if (!_vehicleMarker) {
            [_driverLocationRefreshTimer invalidate];
            self.driverLocationRefreshTimer = nil;
            UIAlertView *driverProfileResultFailedView = [[UIAlertView alloc] initWithTitle:kAppName message:@"Unable to download current driver profile right now" delegate:self cancelButtonTitle:kCancelString otherButtonTitles:kTryAgainString, nil];
            driverProfileResultFailedView.tag = kCurrentDriverProfileDownladFailedTryAgainViewTag;
            [driverProfileResultFailedView show];
        }
    }
}

- (void)onSendCustomerInstuctionsToDriverResultNotification:(NSNotification*)notification
{
    [self hideFullScreenAcitvityIndicatorView];
    [HTUtility removeNotificationObserver:self withNotificationName:notification.name];
    [self networkCallFinishedForNotificationName:notification.name];
    NSDictionary *currentBookingResultDictionary = [notification userInfo];
    BOOL success = [[currentBookingResultDictionary objectForKey:kResponseSuccessKey] boolValue];
    if (success)
    {
        //Instruction posted successfully
        [[HTUserBookingsManager sharedManager] logJobWithJobID:_currentBookingJobID rideNumber:_currentBookingRideNumber notes:[NSString stringWithFormat:@"Message: %@",_customerInstructionTF.text] type:@"Message Sent to Driver"];
    }else{
        //Show try again view
        UIAlertView *instructionNotPostedTryAgainView = [[UIAlertView alloc] initWithTitle:kAppName message:@"Unable to send your instructions to driver. Please try again" delegate:self cancelButtonTitle:kCancelString otherButtonTitles:kTryAgainString, nil];
        instructionNotPostedTryAgainView.tag = kSendCustomerInstructionsToDriverFailedViewTag;
        [instructionNotPostedTryAgainView show];
    }
}

- (void)onDirectionsOfJourneyReceivedRestultNotification:(NSNotification*)notification
{
    _directionsOfJourneyRequestObject = nil;
    NSDictionary *notifyDictionary = [notification userInfo];
    BOOL success = [[notifyDictionary objectForKeyedSubscript:kResponseSuccessKey] boolValue];
    if (success) {
        [HTUtility removeNotificationObserver:self withNotificationName:notification.name];
        NSArray *directionsArray = [notifyDictionary objectForKey:kMapDirectionsKey];
        if (directionsArray.count < 1) {
            self.timeLabel.text = @"-";
        }else
        {
            NSDictionary *directionDictionary = directionsArray.count>0?[directionsArray firstObject]:nil;
            NSArray *directionLegs = [directionDictionary objectForKey:@"legs"];
            NSDictionary *durationDictionary = directionLegs.count>0?[[directionLegs firstObject] objectForKey:@"duration"]:nil;
            NSNumber *duration = [durationDictionary objectForKey:@"value"];
            dispatch_async(dispatch_get_main_queue(), ^{
                int timeValue = ceil(duration.doubleValue/60);
                if (timeValue > 200) {
                    self.timeLabel.text = @"-";
                }else
                {
                    [_timeLabel setText:[NSString stringWithFormat:@"%d Min%@",timeValue,timeValue>1?@"s":@""]];
                }
            });
        }
    }
    else{
        NSString *errorString = [notifyDictionary objectForKey:kResponseErrorKey];
        if (![errorString isEqualToString:kCancelString]) {
            [HTUtility removeNotificationObserver:self withNotificationName:notification.name];
        }
    }
}


#pragma mark- AlertView methods
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == kBookingOrderFailedTryAgainViewTag) {
        if (buttonIndex == 1) {
            [self currentBookingOrder];
        }
    }
    else if (alertView.tag == kCurrentDriverProfileDownladFailedTryAgainViewTag) {
        if (buttonIndex == 1) {
            [self downloadCurrentDriverProfile];
            [_driverLocationRefreshTimer invalidate];
            self.driverLocationRefreshTimer = [NSTimer scheduledTimerWithTimeInterval:kDriverRefreshTime target:self selector:@selector(downloadCurrentDriverProfile) userInfo:nil repeats:YES];
        }
    }else if (alertView.tag == kSendCustomerInstructionsToDriverFailedViewTag)
    {
        if (buttonIndex==1) {
            [self textFieldDidEndEditing:_customerInstructionTF];
        }
    }
}

#pragma mark- Textfield methods
- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if (textField != _driverMessageTF && textField.text.length > 0) {
        _customerInstructionTF.text = textField.text;
        __block HTSessionRenew *sessionRenew = [[HTSessionRenew alloc] init];
        [self.renewSessionObjectsArray addObject:sessionRenew];
        [sessionRenew renewSessionWithCallbackBlock:^(bool succeeded, bool isLogout) {
            [self.renewSessionObjectsArray removeObject:sessionRenew];
            sessionRenew = nil;
            if (isLogout) {
                [self forceLogoutCurrentUser];
            }else
            {
                if (succeeded)
                {
                    [HTUtility addNotificationObserver:self selector:@selector(onSendCustomerInstuctionsToDriverResultNotification:) forNotificationWithName:kSendCustomerInstructionsToDriverRestultNotificationName];
                    id networkOjbect = [[HTUserBookingsManager sharedManager] sendCustomerInstruction:textField.text toDriverWithJobID:_currentBookingJobID completionNotificationName:kSendCustomerInstructionsToDriverRestultNotificationName];
                    [self performingNetworkCallWithObject:networkOjbect forNotificationName:kSendCustomerInstructionsToDriverRestultNotificationName];
                }else
                {
                    //Handled in renewSession class
                }
            }
        }];
    }
}

#pragma mark- Location manager methods
// Location Manager Delegate Methods
- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status{
    if (status != kCLAuthorizationStatusAuthorizedAlways) {
        [HTUtility showInfo:kEnableLocationServices];
    }
}

@end
