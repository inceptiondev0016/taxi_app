//
//  HTFutureBookingViewController.m
//  HubbleTaxi
//
//  Created by Aamir Javed on 13/08/2014.
//  Copyright (c) 2014 Apponative. All rights reserved.
//

#import "HTFutureBookingViewController.h"
#import "HTUserBookingsManager.h"
#import <GoogleMaps/GoogleMaps.h>
#import "HTUserLocationManager.h"

@interface HTFutureBookingViewController ()<UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet HTTableView *jobsTableView;
@property (nonatomic, retain)NSMutableArray *futureBookingsArray;
@property (weak, nonatomic) IBOutlet HTView *jobInfoView;
@property (weak, nonatomic) IBOutlet HTButton *cancelButton;
@property (weak, nonatomic) IBOutlet HTButton *mapButton;
@property (weak, nonatomic) IBOutlet HTButton *backButton;
@property (weak, nonatomic) IBOutlet HTLabel *rideNumberLabel;
@property (weak, nonatomic) IBOutlet HTLabel *bookingDateTimeLabel;
@property (weak, nonatomic) IBOutlet HTLabel *pickupLocationLabel;
@property (weak, nonatomic) IBOutlet HTLabel *destinationLocationLabel;
@property (weak, nonatomic) IBOutlet HTLabel *priceLabel;
@property (weak, nonatomic) IBOutlet HTLabel *vehicleType;
@property (weak, nonatomic) IBOutlet HTLabel *paymentMethod;
@property (weak, nonatomic) IBOutlet HTView *viewToShowMap;
@property (nonatomic, retain) GMSMapView *mapView;
@property (nonatomic,retain) id directionsOfJourneyRequestObject;
@property (nonatomic, retain) GMSPolyline *journeyPathPolylines;
@property (nonatomic, retain) NSMutableArray *markersArray;
@property (nonatomic, retain) NSMutableArray *markerPositionsArray;

- (IBAction)viewButtonTouched:(HTButton*)sender;
- (IBAction)cancelButtonTouched:(HTButton *)sender;
- (IBAction)mapButtonTouched:(HTButton *)sender;
- (IBAction)backButtonTouched:(HTButton *)sender;
- (void)downloadFutureBookingOrders;
- (void)cancelCurrentViewedJob;
- (void)configureMapView;
- (void)getRouteDirections;
- (CLLocationCoordinate2D)coordinatesFromLocationString:(NSString*)locationString;
- (void)boldLabel:(HTLabel*)label withRange:(NSRange)range;

- (void)onFutureBookingsDownloadResultNotification:(NSNotification*)notification;
- (void)onDirectionsOfJourneyReceivedRestultNotification:(NSNotification*)notification;
- (void)onFutureBookingCancelRestultNotification:(NSNotification*)notification;

@end

@implementation HTFutureBookingViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.markersArray = [[NSMutableArray alloc] init];
        self.markerPositionsArray = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.view.backgroundColor = [UIColor colorWithRed:207/255.0 green:211/255.0 blue:203/255.0 alpha:1];
    _jobInfoView.hidden = YES;
    _viewToShowMap.hidden = YES;
    [self configureMapView];
    [self downloadFutureBookingOrders];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark- Action Methods
- (IBAction)viewButtonTouched:(HTButton*)sender
{
    NSDictionary *viewedJobDictionary = _futureBookingsArray[sender.tag];
    _cancelButton.tag = _mapButton.tag = sender.tag;
    _jobInfoView.hidden = NO;
    _rideNumberLabel.text = [NSString stringWithFormat:@"Ride number: %@",viewedJobDictionary[@"jobNumber"]];
    NSString *bookingDate = viewedJobDictionary[@"booking_date"];
    _bookingDateTimeLabel.text = [[bookingDate stringByReplacingOccurrencesOfString:@"-" withString:@"/"] stringByReplacingOccurrencesOfString:@" " withString:@" - "];
    _pickupLocationLabel.text = [NSString stringWithFormat:@"From: %@",viewedJobDictionary[@"pickup_address1"]];
    _destinationLocationLabel.text = [NSString stringWithFormat:@"To: %@",viewedJobDictionary[@"destination_line1"]];
    _priceLabel.text = [NSString stringWithFormat:@"£%0.1f0",[viewedJobDictionary[@"final_price"] floatValue]];
    _vehicleType.text = [NSString stringWithFormat:@"Vehicle Type: %@",viewedJobDictionary[@"vehicle_type"]];
    _paymentMethod.text = [NSString stringWithFormat:@"Payment Method: %@",viewedJobDictionary[@"payment_method"]];
    
    [self boldLabel:_rideNumberLabel withRange:NSMakeRange(0, 12)];
    [self boldLabel:_pickupLocationLabel withRange:NSMakeRange(0, 5)];
    [self boldLabel:_destinationLocationLabel withRange:NSMakeRange(0, 3)];
    [self boldLabel:_priceLabel withRange:NSMakeRange(0, 1)];
    [self boldLabel:_vehicleType withRange:NSMakeRange(0, 13)];
    [self boldLabel:_paymentMethod withRange:NSMakeRange(0, 15)];
}

- (IBAction)cancelButtonTouched:(HTButton *)sender
{
    UIAlertView *confirmationView = [[UIAlertView alloc] initWithTitle:kAppName message:@"Are you sure, you want to cancel this job" delegate:self cancelButtonTitle:@"Do Nothing" otherButtonTitles:@"Cancel Job", nil];
    confirmationView.tag = kJobCancelConfirmationViewTag;
    [confirmationView show];
    
}

- (IBAction)mapButtonTouched:(HTButton *)sender
{
    _viewToShowMap.hidden = NO;
    [self getRouteDirections];
}

- (IBAction)backButtonTouched:(HTButton *)sender {
    _jobInfoView.hidden = _viewToShowMap.hidden;
    _viewToShowMap.hidden = YES;
}

#pragma mark- Custom methods
- (void)downloadFutureBookingOrders
{
    [self showFullScreenAcitvityIndicatorView];
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
                [self showFullScreenAcitvityIndicatorView];
                [HTUtility addNotificationObserver:self selector:@selector(onFutureBookingsDownloadResultNotification:) forNotificationWithName:kFutureBookingDownloadResultNotificationName];
                id networkOjbect = [[HTUserBookingsManager sharedManager] futureBookingsWithCompletionNotificationName:kFutureBookingDownloadResultNotificationName];
                [self performingNetworkCallWithObject:networkOjbect forNotificationName:kFutureBookingDownloadResultNotificationName];
            }else
            {
                //Handled in renewSession class
            }
        }
    }];
}

- (void)cancelCurrentViewedJob
{
    [self showFullScreenAcitvityIndicatorView];
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
                [self showFullScreenAcitvityIndicatorView];
                [HTUtility addNotificationObserver:self selector:@selector(onFutureBookingCancelRestultNotification:) forNotificationWithName:kFutureBookingCancelResultNotificationName];
                NSString *jobID = _futureBookingsArray[_cancelButton.tag][@"jobID"];
                id networkOjbect = [[HTUserBookingsManager sharedManager] cancelFutureBookingWithJobID:jobID completionNotificationName:kFutureBookingCancelResultNotificationName];
                [self performingNetworkCallWithObject:networkOjbect forNotificationName:kFutureBookingCancelResultNotificationName];
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
    _mapView.settings.compassButton = YES;
}

- (void)getRouteDirections
{
    [self showFullScreenAcitvityIndicatorView];
    _journeyPathPolylines.map = nil;
    for (int index=0 ; index < _markersArray.count; index++) {
        GMSMarker *marker = _markersArray[index];
        marker.map = nil;
    }
    [_markersArray removeAllObjects];
    [_markerPositionsArray removeAllObjects];
    [_directionsOfJourneyRequestObject cancelAllOperations];
    [HTUtility addNotificationObserver:self selector:@selector(onDirectionsOfJourneyReceivedRestultNotification:) forNotificationWithName:kDirectionsOfJourneyReceivedRestultNotificationName];

    NSDictionary *viewedJobDictionary = _futureBookingsArray[_mapButton.tag];
    CLLocationCoordinate2D picupLocation = [self coordinatesFromLocationString:viewedJobDictionary[@"pickup_address_location"]];
    CLLocationCoordinate2D destinationLocation = [self coordinatesFromLocationString:viewedJobDictionary[@"destination_location"]];
    [_markerPositionsArray addObject:[[CLLocation alloc] initWithLatitude:picupLocation.latitude longitude:picupLocation.longitude]];
    [_markerPositionsArray addObject:[[CLLocation alloc] initWithLatitude:destinationLocation.latitude longitude:destinationLocation.longitude]];

    if (![viewedJobDictionary[@"destination_location"] isKindOfClass:[NSString class]]) {
        destinationLocation = picupLocation;
    }
    NSString *viaRouteString = nil;
    CLLocationCoordinate2D viaLocation;
    for (int index=1; index<=5; index++) {
        viaLocation = [self coordinatesFromLocationString:viewedJobDictionary[[NSString stringWithFormat:@"via_point%d_location",index]]];
        if (![viewedJobDictionary[@"destination_location"] isKindOfClass:[NSString class]] && [viewedJobDictionary[[NSString stringWithFormat:@"via_point%d_location",index]] isKindOfClass:[NSString class]]){
            destinationLocation = viaLocation;
        }
        if ((int)viaLocation.latitude != 0 && (int)viaLocation.longitude != 0 ) {
            [_markerPositionsArray addObject:[[CLLocation alloc] initWithLatitude:viaLocation.latitude longitude:viaLocation.longitude]];
            NSString *oneViaPointString = [NSString stringWithFormat:@"via:%f,%f",viaLocation.latitude,viaLocation.longitude];
            if (viaRouteString) {
                viaRouteString = [viaRouteString stringByAppendingString:[NSString stringWithFormat:@"|%@",oneViaPointString]];
            }else
            {
                viaRouteString = oneViaPointString;
            }
        }
    }
    
    
    self.directionsOfJourneyRequestObject = [[HTUserLocationManager sharedManager] directionsOfJourneyWithStartingLocation:[NSString stringWithFormat:@"%f,%f",picupLocation.latitude,picupLocation.longitude] endingLocation:[NSString stringWithFormat:@"%f,%f",destinationLocation.latitude,destinationLocation.longitude] viaRouteLocaton:viaRouteString completionNotificationName:kDirectionsOfJourneyReceivedRestultNotificationName];
}

- (CLLocationCoordinate2D )coordinatesFromLocationString:(NSString *)locationString
{
    CLLocationCoordinate2D coordinates;
    if ([locationString isKindOfClass:[NSString class]] && locationString.length > 0) {
        NSArray *locationElements= [locationString componentsSeparatedByString:@","];
        if (locationElements.count > 1) {
            coordinates = CLLocationCoordinate2DMake([locationElements[0] doubleValue], [locationElements[1] doubleValue]);
        }
    }
    return coordinates;
}

- (void)boldLabel:(HTLabel*)label withRange:(NSRange)range
{
    label.textColor  = [UIColor blackColor];
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:label.text];
    [attributedString addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:17] range:range];
    [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:range];
    label.attributedText = attributedString;
}

#pragma mark- TableView methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _futureBookingsArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString* CellID = @"Jobs_Cell_ID";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellID];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellID];
        cell.backgroundColor = [UIColor clearColor];
        HTButton *viewButton = [[HTButton alloc] initWithFrame:CGRectMake(110, 10, 100, 20)];
        [viewButton setTitle:@"View" forState:UIControlStateNormal];
        [viewButton setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
        [viewButton addTarget:self action:@selector(viewButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
        [viewButton setTitleColor:[UIColor colorWithRed:133/255.0 green:133/255.0 blue:132/255.0 alpha:1] forState:UIControlStateNormal];
        cell.accessoryView = viewButton;
    }
    NSString *title = _futureBookingsArray[indexPath.row][@"booking_date"];
    cell.textLabel.text = [[title stringByReplacingOccurrencesOfString:@"-" withString:@"/"] stringByReplacingOccurrencesOfString:@" " withString:@" - "];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"From: %@",_futureBookingsArray[indexPath.row][@"pickup_address1"]];
    cell.accessoryView.tag = indexPath.row;
    
    return cell;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [_futureBookingsArray removeObjectAtIndex:indexPath.row];
        [_jobsTableView reloadData];
    }
}

#pragma mark- Notification methods
- (void)onFutureBookingsDownloadResultNotification:(NSNotification *)notification
{
    [self hideFullScreenAcitvityIndicatorView];
    [HTUtility removeNotificationObserver:self withNotificationName:notification.name];
    [self networkCallFinishedForNotificationName:notification.name];
    NSDictionary *futureBookingsDictionary = [notification userInfo];
    BOOL success = [[futureBookingsDictionary objectForKey:kResponseSuccessKey] boolValue];
    if (success)
    {
        NSArray *futureBookings = futureBookingsDictionary[kJobObjectFieldsKey];
        if ([futureBookings isKindOfClass:[NSArray class]] && futureBookings.count > 0) {
            self.futureBookingsArray = [NSMutableArray arrayWithArray:futureBookings];
            [_jobsTableView reloadData];
        }else
        {
            [HTUtility showInfo:@"You do not have any future bookings"];
        }
    }else{
        UIAlertView *futureBookingDownloadFailedView = [[UIAlertView alloc] initWithTitle:kAppName message:@"Unable to download your future bookings now" delegate:self cancelButtonTitle:kCancelString otherButtonTitles:kTryAgainString, nil];
        futureBookingDownloadFailedView.tag = kFutureBookingDownloadFailedTryAgainViewTag;
        [futureBookingDownloadFailedView show];
    }
}

- (void)onDirectionsOfJourneyReceivedRestultNotification:(NSNotification*)notification
{
    [self hideFullScreenAcitvityIndicatorView];
    _directionsOfJourneyRequestObject = nil;
    NSDictionary *notifyDictionary = [notification userInfo];
    [HTUtility removeNotificationObserver:self withNotificationName:notification.name];
    BOOL success = [[notifyDictionary objectForKeyedSubscript:kResponseSuccessKey] boolValue];
    if (success) {
        NSArray *directionsArray = [notifyDictionary objectForKey:kMapDirectionsKey];
        NSDictionary *directionDictionary = directionsArray.count>0?[directionsArray firstObject]:nil;
        NSString *polylineString = [directionDictionary objectForKey:@"overview_polyline"][@"points"];
        
        self.journeyPathPolylines = [GMSPolyline polylineWithPath:[GMSPath pathFromEncodedPath:polylineString]];
        
        
        NSDictionary *viewedJobDictionary = _futureBookingsArray[_mapButton.tag];
        CLLocationCoordinate2D picupLocation = [self coordinatesFromLocationString:viewedJobDictionary[@"pickup_address_location"]];
       
        for (CLLocation *location in _markerPositionsArray) {
            GMSMarker *marker = [GMSMarker markerWithPosition:location.coordinate];
            int index = [_markerPositionsArray indexOfObject:location];
            NSArray *markers = @[@"location_a_green.png",@"location_b_red.png",@"location_v1_red.png",@"location_v2_red.png",@"location_v3_red.png",@"location_v4_red.png",@"location_v5_red.png"];
            marker.icon = index < markers.count?[HTUtility halfSizedImageWithName:markers[index]]:[GMSMarker markerImageWithColor:[UIColor grayColor]];
            marker.map = _mapView;
            [_markersArray addObject:marker];
        }
        
        _journeyPathPolylines.strokeWidth = 5.0f;
        _journeyPathPolylines.geodesic = YES;
        _journeyPathPolylines.strokeColor = [UIColor redColor];
        _journeyPathPolylines.map = _mapView;
        [_mapView animateToLocation:picupLocation];
    }
    else{
        UIAlertView *directionsFailedView = [[UIAlertView alloc] initWithTitle:kAppName message:@"We are not able to get direction of your joueny" delegate:self cancelButtonTitle:kCancelString otherButtonTitles:kTryAgainString, nil];
        directionsFailedView.tag = kJourneyDirectionsDownloadFailedViewTag;
        [directionsFailedView show];
    }
}

- (void)onFutureBookingCancelRestultNotification:(NSNotification*)notification
{
    [self hideFullScreenAcitvityIndicatorView];
    [HTUtility removeNotificationObserver:self withNotificationName:notification.name];
    [self networkCallFinishedForNotificationName:notification.name];
    NSDictionary *futureBookingsDictionary = [notification userInfo];
    BOOL success = [[futureBookingsDictionary objectForKey:kResponseSuccessKey] boolValue];
    if (success)
    {
        NSString *jobID = _futureBookingsArray[_cancelButton.tag][@"jobID"];
        NSString *jobRideNumber = _futureBookingsArray[_cancelButton.tag][@"jobNumber"];

        [[HTUserBookingsManager sharedManager] logJobWithJobID:jobID rideNumber:jobRideNumber notes:@"" type:@"Ride Cancelled"];
        [self backButtonTouched:nil];
        [_futureBookingsArray removeObjectAtIndex:_cancelButton.tag];
        [_jobsTableView reloadData];
    }else{
        UIAlertView *futureBookingCancelFailedView = [[UIAlertView alloc] initWithTitle:kAppName message:@"Unable to cancel your future bookings" delegate:self cancelButtonTitle:kCancelString otherButtonTitles:kTryAgainString, nil];
        futureBookingCancelFailedView.tag = kFutureBookingCancelFailedViewTag;
        [futureBookingCancelFailedView show];
    }
}

#pragma mark- AlertView methods
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == kFutureBookingDownloadFailedTryAgainViewTag) {
        if (buttonIndex == 1) {
            [self downloadFutureBookingOrders];
        }
    }
    else if (alertView.tag == kJobCancelConfirmationViewTag){
        if (buttonIndex == 1) {
            [self cancelCurrentViewedJob];
        }
    }
    else if (alertView.tag == kJourneyDirectionsDownloadFailedViewTag)
    {
        if (buttonIndex == 1) {
            [self getRouteDirections];
        }
    }
    else if (alertView.tag == kFutureBookingCancelFailedViewTag)
    {
        if (buttonIndex == 1) {
            [self cancelCurrentViewedJob];
        }
    }
}


@end
