//
//  HTPickupLocationViewController.m
//  HubbleTaxi
//
//  Created by Aamir Javed on 26/02/2014.
//  Copyright (c) 2014 Apponative. All rights reserved.
//

#import "HTPickupAndDestinationLocationViewController.h"
#import <GoogleMaps/GoogleMaps.h>
#import "HTPlacesViewController.h"
#import "HTUserLocationManager.h"
#import "HTUserProfileManager.h"
#import "CKCalendarView.h"
#import <Social/Social.h>
#import "HTPaymentMethodViewController.h"

@interface HTLocation : NSObject
@property (nonatomic,assign)CLLocationCoordinate2D coordinates;
@property (nonatomic,retain)NSString *address;
@property (nonatomic,retain)NSString *postalCode;
@property (nonatomic,retain)GMSAddress *gmsAddress;
@property (nonatomic,assign)BOOL isCommonPlace;
@end
@implementation HTLocation
@end

@interface HTJourney : NSObject
@property (nonatomic,retain)HTLocation *pickupLocation;
@property (nonatomic,retain)HTLocation *destinationLocation;
@property (nonatomic,retain)NSMutableArray *viaRoutesArray; //Array of HTLocation objects
@property (nonatomic,assign)BOOL journeySharedOnFB;
@property (nonatomic,assign)double distanceTravelled;
@end
@implementation HTJourney
- (id)init
{
    self = [super init];
    if (self) {
        self.pickupLocation = [[HTLocation alloc] init];
        self.destinationLocation = [[HTLocation alloc] init];
        NSMutableArray *routesArray = [[NSMutableArray alloc] init];
        for (int index = 0; index < kMaximumViaPointsInAJourney; index ++) {
            [routesArray addObject:[[HTLocation alloc] init]];
        }
        self.viaRoutesArray = routesArray;
    }
    return self;
}
@end

@interface HTPickupAndDestinationLocationViewController ()<GMSMapViewDelegate,UIAlertViewDelegate,UIPickerViewDataSource,UIPickerViewDelegate,CKCalendarDelegate,CLLocationManagerDelegate>
{
}
@property (weak, nonatomic) IBOutlet HTView *viewToShowMap;
@property (weak, nonatomic) IBOutlet HTButton *pickupLocationNextButton;
@property (nonatomic, retain) HTPlacesViewController *placesVC;
@property (weak, nonatomic) IBOutlet HTButton *advanceSearchButton;
@property (weak, nonatomic) IBOutlet HTButton *destinationBackButton;
@property (weak, nonatomic) IBOutlet HTView *pickupLocationView;
@property (weak, nonatomic) IBOutlet HTView *destinationLocationView;
@property (weak, nonatomic) IBOutlet HTLabel *screenDescriptionLabel;
@property (weak, nonatomic) IBOutlet HTLabel *priceLabel;
@property (weak, nonatomic) IBOutlet HTButton *noDestinationYetButton;
@property (nonatomic, retain) GMSMapView *mapView;
@property (weak, nonatomic) IBOutlet HTTextField *locationAddressTF;
@property (weak, nonatomic) IBOutlet HTImageView *locationArrow;
@property (nonatomic, assign)BOOL isLocationUpdated;
@property (weak, nonatomic) IBOutlet HTTextField *locationNumberTF;
@property (nonatomic, retain) NSString *updateLocationKVContext;
@property (nonatomic, assign) CLLocationCoordinate2D latestIdleCameraPosition;
@property (nonatomic, assign) CLLocationCoordinate2D lastSearchedLocationOnMap;
@property (nonatomic,retain) id addressToLocationRequestObject;
@property (nonatomic,retain) id directionsOfJourneyRequestObject;
@property (nonatomic,retain)HTJourney *userJourney;
@property (nonatomic, retain)GMSAddress *currentSelectedGMAddress;
@property (nonatomic, assign)BOOL isSelectedAddressInServicesArea;
@property (nonatomic,retain)UIAlertView *noServiceAreaInfoView;
@property (weak, nonatomic) IBOutlet HTButton *vehicleSelectionButton;
@property (weak, nonatomic) IBOutlet HTView *vehicleSelectionPopupView;
@property (weak, nonatomic) IBOutlet HTView *vehicleSelectionContainerView;
@property (weak, nonatomic) IBOutlet HTButton *vehicleSelectionCancelButton;
@property (weak, nonatomic) IBOutlet HTButton *vehicleSelectionOKButton;
@property (weak, nonatomic) IBOutlet UIPickerView *vehicleSelectionPickerView;
@property (weak, nonatomic) IBOutlet HTLabel *vehicleSelectionViewTitle;
@property (weak, nonatomic) IBOutlet HTLabel *vehicleSelectionVehicleNameLabel;
@property (weak, nonatomic) IBOutlet HTLabel *vehicleSelectionVehicleDescriptionLabel;
@property (nonatomic,retain)NSDictionary *serviceAreaDictionaryForSelectedPostCode;
@property (nonatomic, assign)BOOL isFetchingServiceAreaFields;
@property (nonatomic, assign)BOOL isUpdatingJourneyPrice;
@property (weak, nonatomic) IBOutlet HTView *calendarPopupView;
@property (weak, nonatomic) IBOutlet HTView *calendarContainerView;
@property (weak, nonatomic) IBOutlet HTLabel *calendarDescriptionLabel;
@property (weak, nonatomic) IBOutlet CKCalendarView *calendarView;
@property (weak, nonatomic) IBOutlet HTButton *calendarViewCancelButton;
@property (weak, nonatomic) IBOutlet HTButton *calendarViewOKButton;
@property (nonatomic, retain) NSMutableArray *selectedDatesArray;
@property (weak, nonatomic) IBOutlet UIDatePicker *timePickerView;
@property (weak, nonatomic) IBOutlet HTButton *viaRouteButton;
@property (weak, nonatomic) IBOutlet HTView *viaRouteContainerView;
@property (weak, nonatomic) IBOutlet HTView *viaScreenOfScreenContainerView;
@property (weak, nonatomic) IBOutlet HTButton *viaOfScreenCancelButton;
@property (weak, nonatomic) IBOutlet HTButton *viaOfScreenNextButton;
@property (weak, nonatomic) IBOutlet HTButton *viaRouteCancelButton;
@property (weak, nonatomic) IBOutlet HTButton *viaOfScreenBackButton;
@property (weak, nonatomic) IBOutlet HTButton *viaRouteBackButton;
@property (weak, nonatomic) IBOutlet HTButton *viaRouteNextButton;
@property (weak, nonatomic) IBOutlet HTButton *shareOnFbButton;
@property (weak, nonatomic) IBOutlet HTButton *selectDateTimeButton;
@property (nonatomic, assign) int nearbyServiceAreaFindingTryNumber;
@property (nonatomic, assign) BOOL isFindingNearbyServiceArea;
@property (nonatomic, retain)NSDate *pickupTime;
@property (nonatomic, assign)int currentViaRouteNumber;
@property (weak, nonatomic) IBOutlet HTButton *destinationNextButton;
@property (nonatomic,retain)NSMutableArray *markersArray;
@property (nonatomic,assign)BOOL shouldNumberAddressRemainAsSearched;
@property (weak, nonatomic) IBOutlet HTLabel *estPickupTimeLabel;
@property (nonatomic, retain)GMSMarker *pickupLocationMarker;
@property (nonatomic, retain)GMSMarker *destinationLocationMarker;
@property (nonatomic, retain)NSMutableArray *viaMarkerArray;
@property (nonatomic, retain)CLLocationManager *locationManager;
@property (nonatomic,assign)BOOL shouldLoadView;

- (IBAction)locatemeButtonTouched:(HTButton *)sender;
- (IBAction)pickupLocationNextButtonTouched:(HTButton *)sender;
- (IBAction)advanceSearchButtonTouched:(HTButton *)sender;
- (IBAction)destinationBackButtonTouched:(HTButton *)sender;
- (IBAction)noDestinationYetButtonTouched:(HTButton *)sender;
- (IBAction)vehicleSelectionButtonTouched:(HTButton *)sender;
- (IBAction)vehicleSeclectionCancelButtonTouched:(HTButton *)sender;
- (IBAction)vehicleSelectionOKButtonTouched:(HTButton *)sender;
- (IBAction)calendarViewCancelButtonTouched:(HTButton *)sender;
- (IBAction)calendarViewOKButtonTouched:(HTButton *)sender;
- (IBAction)viaRouteButtonTouched:(HTButton *)sender;
- (IBAction)viaRouteCancelButtonTouched:(HTButton *)sender;
- (IBAction)viaRouteBackButtonTouched:(HTButton *)sender;
- (IBAction)viaRouteNextButtonTouched:(HTButton *)sender;
- (IBAction)shareOnFbButtonTouched:(HTButton *)sender;
- (IBAction)selectDateTimeButtonTouched:(HTButton *)sender;
- (IBAction)destinationNextButtonTouched:(HTButton *)sender;

- (void)configureMapView;
- (void)populateCommonPlaces;
- (void)moveMapToLocation:(CLLocationCoordinate2D)location;
- (void)changeViewToDestinationLocationFromPickupLocationScreen;
- (void)changeViewToDestinationLocationFromViaRouteScreen;
- (void)changeViewToPickupLocationScreen;
- (void)changeViewToViaRouteNumber:(int)viaRouteNumber;
- (void)updateJourneyPriceValue;
- (void)mapLocationChangedToAddress:(GMSAddress*)address;
- (BOOL)isOnPickupLocationScreen;
- (BOOL)isOnDestinationLocationScreen;
- (void)resetVehicleSelectionButton;
- (void)changeVehicleTypeTo:(NSString*)vehichleType;
- (BOOL)isPickupTimeInRushHours:(NSArray*)rushHours;
- (void)showNoServicesPopup;
- (void)selectTodaysDate;
- (void)findServiceAreaNearby;
- (int)existingViaRoutesCount;
- (NSString*)houseNumberStringFromAddress:(NSString*)completeAddress;
- (NSString*)completeAddressString;
- (void)updateMarkersVisibility;
- (void)updateMinimumDateValue;
- (void)updateLocationIcon:(BOOL)isSearchComplete;
- (void)updatePickupTime;
- (void)updateLocationMarkers;
- (void)updateViaMarkersWithUserOnViaNumber:(int)viaNumber;

- (void)onSearchedPlaceSelectedNotification:(NSNotification*)notification;
- (void)onAddressToLocationResultNotification:(NSNotification*)notification;
- (void)onServiceAreaFieldsFetchRestultNotification:(NSNotification*)notification;
- (void)onDirectionsOfJourneyReceivedRestultNotification:(NSNotification*)notification;
- (void)onCommonPlacesRestultNotification:(NSNotification*)notification;
- (void)onGetDriverNearbyRestultNotification:(NSNotification*)notification;
- (void)onMapTappedWithGesture:(UITapGestureRecognizer*)gesture;
- (void)onMapPannedWithGesture:(UIPanGestureRecognizer*)gesture;
@end

@implementation HTPickupAndDestinationLocationViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.updateLocationKVContext = @"updatedLocation";
        self.userJourney = [[HTJourney alloc] init];
        self.selectedDatesArray = [[NSMutableArray alloc] init];
        self.markersArray = [[NSMutableArray alloc] init];
        self.pickupTime = [NSDate date];
        self.viaMarkerArray = [[NSMutableArray alloc] init];
        [self selectTodaysDate];
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
    // Do any additional setup after loading the view from its nib.
    self.shouldLoadView = YES;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.locationManager.delegate = self;

    if (_shouldLoadView) {
        
        [self configureMapView];
        
        [self moveView:_destinationLocationView toScreenPositon:screenPositionOutsideRightX];
        [self moveView:_viaRouteContainerView toScreenPositon:screenPositionOutsideRightX];
        [self moveView:_viaScreenOfScreenContainerView toScreenPositon:screenPositionOutsideRightX];
        self.currentViaRouteNumber = 1;
        [self changeViewToPickupLocationScreen];
        
        _calendarView.delegate = self;
        _calendarView.backgroundColor = [UIColor colorWithRed:140/255.0 green:144/255.0 blue:145/255.0 alpha:1];
        [self.view bringSubviewToFront:_viaRouteButton];
        self.shouldLoadView = NO;
    }
    _locationArrow.center = CGPointMake( _viewToShowMap.center.x,  _viewToShowMap.center.y-_locationArrow.frame.size.height/2);
    BOOL isLocationServicesEnabled = [CLLocationManager locationServicesEnabled];
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    if (!isLocationServicesEnabled || status != kCLAuthorizationStatusAuthorizedAlways) {
        [HTUtility showInfo:kEnableLocationServices];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [_mapView addObserver:self
               forKeyPath:NSStringFromSelector(@selector(myLocation))
                  options:NSKeyValueObservingOptionNew
                  context:(__bridge void*)_updateLocationKVContext];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [_mapView removeObserver:self forKeyPath:NSStringFromSelector(@selector(myLocation)) context:(__bridge void*)_updateLocationKVContext];
}

- (void)dealloc
{
    if ([_addressToLocationRequestObject respondsToSelector:@selector(cancelAllOperations)]) {
        [_addressToLocationRequestObject cancelAllOperations];
    }
}

#pragma mark - Action methods

- (IBAction)locatemeButtonTouched:(HTButton *)sender {
    [_mapView animateToLocation:_mapView.myLocation.coordinate];
}

- (IBAction)pickupLocationNextButtonTouched:(HTButton *)sender
{
    if (!_vehicleSelectionButton.selected) {
        [HTUtility showInfo:@"Please select vehicle type for the journey."];
    }
    else if (_selectedDatesArray.count<1){
        [HTUtility showInfo:@"Please select date for the journey."];
    }
    else{
        HTLocation *viaLocation = [_userJourney.viaRoutesArray firstObject];
        if (viaLocation.address.length > 0) {
            self.currentViaRouteNumber = 1;
            [self changeViewToViaRouteNumber:_currentViaRouteNumber];
        }
        else
        {
            [self changeViewToDestinationLocationFromPickupLocationScreen];
        }
    }
}

- (IBAction)advanceSearchButtonTouched:(HTButton *)sender
{
    [HTUtility addNotificationObserver:self selector:@selector(onSearchedPlaceSelectedNotification:) forNotificationWithName:kSearchedPlaceSelectedNotificationName];
    self.placesVC = [[HTPlacesViewController alloc] initWithUserLocation:_mapView.myLocation.coordinate];
    //[self setModalPresentationStyle:UIModalPresentationCurrentContext];
    //[self.navigationController setModalPresentationStyle:UIModalPresentationCurrentContext];
    [self presentViewController:_placesVC animated:YES completion:nil];
}

- (IBAction)destinationBackButtonTouched:(HTButton *)sender
{
    if (_isUpdatingJourneyPrice) {
        [HTUtility showInfo:kWaitWhileGettingLocationInfoString];
    }
    else if ([_priceLabel.text isEqualToString:kPriceNoService])
    {
        [self showNoServicesPopup];
    }
    else{
        int existingViaPointsCount = [self existingViaRoutesCount];
        if (existingViaPointsCount > 0 )
        {
            [self changeViewToViaRouteNumber:existingViaPointsCount];
        }else
        {
            [self changeViewToPickupLocationScreen];
        }
    }
}

- (IBAction)destinationNextButtonTouched:(HTButton *)sender
{
    BOOL canNavigateNext = NO;
    if (_noDestinationYetButton.selected)
    {
        canNavigateNext = YES;
    }
    else{
        if (_isUpdatingJourneyPrice)
        {
            [HTUtility showInfo:kWaitWhileGettingLocationInfoString];
        }
        else if ([_priceLabel.text isEqualToString:kPriceNoService])
        {
            [self showNoServicesPopup];
        }
        else
        {
            canNavigateNext = YES;
        }
    }
    if (canNavigateNext)
    {
        HTPaymentInfo *paymentInfo = [[HTPaymentInfo alloc] init];
        NSArray *priceComponents = [_priceLabel.text componentsSeparatedByString:@"£"];
        float singleDayPrice = [[priceComponents lastObject] floatValue];
        paymentInfo.priceString = [NSString stringWithFormat:@"£%0.1f0",singleDayPrice*_selectedDatesArray.count];
        paymentInfo.noDestinationYet = _noDestinationYetButton.selected;
        paymentInfo.pickupFromAddress = _userJourney.pickupLocation.address;
        paymentInfo.destinationAddress = _userJourney.destinationLocation.address;
        paymentInfo.dateTimeString = _selectDateTimeButton.currentTitle;
        paymentInfo.vehicleType = _vehicleSelectionButton.currentTitle;
        paymentInfo.pickupDatesArray = _selectedDatesArray;
        
        HTLocationInfo *pickupLocationInfo = [[HTLocationInfo alloc] init];
        pickupLocationInfo.gmsAddress = _userJourney.pickupLocation.gmsAddress;
        pickupLocationInfo.addressString = _userJourney.pickupLocation.address;
        pickupLocationInfo.isCommonPlace = _userJourney.pickupLocation.isCommonPlace;
        paymentInfo.pickupLocationInfo = pickupLocationInfo;
        HTLocationInfo *destinationLocationInfo = [[HTLocationInfo alloc] init];
        destinationLocationInfo.gmsAddress = _userJourney.destinationLocation.gmsAddress;
        destinationLocationInfo.addressString = _userJourney.destinationLocation.address;
        destinationLocationInfo.isCommonPlace = _userJourney.destinationLocation.isCommonPlace;
        paymentInfo.destinationLocationInfo = destinationLocationInfo;
        
        NSMutableArray *viaRoutes = [[NSMutableArray alloc] init];
        for (HTLocation *viaRoute in _userJourney.viaRoutesArray) {
            if (viaRoute.address.length > 0) {
                HTLocationInfo *locationInfo = [[HTLocationInfo alloc] init];
                locationInfo.addressString = viaRoute.address;
                locationInfo.gmsAddress = viaRoute.gmsAddress;
                locationInfo.isCommonPlace = viaRoute.isCommonPlace;
                [viaRoutes addObject:locationInfo];
            }
        }
        paymentInfo.viaLocationInfoArray = viaRoutes;
        
        NSArray *allocatedToFirms = _serviceAreaDictionaryForSelectedPostCode[kServiceAreaAllocatedToFirmsKey];
        NSString *firmName = allocatedToFirms[[_serviceAreaDictionaryForSelectedPostCode[kServiceAreaVehicleTypesKey] indexOfObject:[_vehicleSelectionButton currentTitle]]];
        paymentInfo.assignedToFirm = firmName;
        paymentInfo.journeySharedOnFB = _userJourney.journeySharedOnFB;
        paymentInfo.distanceTravelled = _userJourney.distanceTravelled;
        
        [self navigateForwardTo:[[HTPaymentMethodViewController alloc] initWithPaymentInfo:paymentInfo]];
    }
    _noDestinationYetButton.selected = NO;
}

- (IBAction)noDestinationYetButtonTouched:(HTButton *)sender
{
    _noDestinationYetButton.selected = YES;
    [self destinationNextButtonTouched:nil];
}

- (IBAction)vehicleSelectionButtonTouched:(HTButton *)sender
{
    if (!_isFetchingServiceAreaFields && _serviceAreaDictionaryForSelectedPostCode.allValues.count>0) {
        _vehicleSelectionPopupView.hidden = NO;
        [_vehicleSelectionPickerView reloadAllComponents];
        
        NSArray *vehicles = [_serviceAreaDictionaryForSelectedPostCode objectForKey:kServiceAreaVehicleTypesKey];
        NSString *userOldVehicleType = [[HTUserLocationManager sharedManager] userSelectedVehicleType];
        NSUInteger selectedVehicleIndex = [vehicles indexOfObject:userOldVehicleType];
        selectedVehicleIndex = selectedVehicleIndex < vehicles.count? selectedVehicleIndex:vehicles.count>0?0:selectedVehicleIndex;
        if (selectedVehicleIndex < vehicles.count) {
            [_vehicleSelectionVehicleNameLabel setText:[[_serviceAreaDictionaryForSelectedPostCode objectForKey:kServiceAreaVehicleTypesKey] objectAtIndex:selectedVehicleIndex]];
            NSString *vehicleDescription = [[_serviceAreaDictionaryForSelectedPostCode objectForKey:kServiceAreaVehicleDescriptionsKey] objectAtIndex:selectedVehicleIndex];
            [_vehicleSelectionVehicleDescriptionLabel setText:[vehicleDescription stringByReplacingOccurrencesOfString:kCommaAlternateString withString:@","]];
            [_vehicleSelectionPickerView selectRow:selectedVehicleIndex inComponent:0 animated:NO];
        }
    }
    else
    {
        if (_isFetchingServiceAreaFields) {
            [HTUtility showInfo:kWaitWhileGettingLocationInfoString];
        }else{
            [HTUtility showInfo:@"Currently there is no vehicle in your selected area. You need to change your pickup location."];
        }
    }
}
- (IBAction)vehicleSeclectionCancelButtonTouched:(HTButton *)sender
{
    _vehicleSelectionPopupView.hidden = YES;
}

- (IBAction)vehicleSelectionOKButtonTouched:(HTButton *)sender
{
    HTLabel *carNameLabel = (HTLabel*)[_vehicleSelectionPickerView viewForRow:[_vehicleSelectionPickerView selectedRowInComponent:0] forComponent:0];
    if(carNameLabel.text.length>0)
    {
        [[HTUserLocationManager sharedManager] updateUserSelectedVehicleTypeTo:carNameLabel.text];
        [self changeVehicleTypeTo:carNameLabel.text];
    }else
    {
        [self resetVehicleSelectionButton];
    }
    _vehicleSelectionPopupView.hidden = YES;
}

- (IBAction)selectDateTimeButtonTouched:(HTButton *)sender
{
    [self updateMinimumDateValue];
    _calendarPopupView.hidden = NO;
}

- (IBAction)calendarViewCancelButtonTouched:(HTButton *)sender
{
    [_selectedDatesArray removeAllObjects];
    [self selectTodaysDate];
    [_calendarView reloadData];
    [_selectDateTimeButton setTitle:@"Now" forState:UIControlStateNormal];
    [_calendarDescriptionLabel setText:@"You have selected one date"];
    _calendarPopupView.hidden = YES;
}

- (IBAction)calendarViewOKButtonTouched:(HTButton *)sender
{
    if (_selectedDatesArray.count>0) {
        NSDateComponents *dateComponents = [_selectedDatesArray firstObject];
        NSString *dateTimeString = [NSString stringWithFormat:@"%ld/%ld/%ld",(long)dateComponents.day,(long)dateComponents.month,(long)dateComponents.year];
        if (_selectedDatesArray.count==1) {
            NSDate *selectedDate = [[NSCalendar currentCalendar] dateFromComponents:dateComponents];
            NSDate *today = [[NSCalendar currentCalendar] dateFromComponents:[[NSCalendar currentCalendar] components:NSCalendarUnitDay|NSCalendarUnitMonth|NSCalendarUnitYear fromDate:[ NSDate date]]];
            NSTimeInterval secondsBetween = [selectedDate timeIntervalSinceDate:today];
            int numberOfDays = secondsBetween / 86400;//24*60*60 = 86400
            if (numberOfDays == 0) {
                dateTimeString = @"Today";
            }else if (numberOfDays == 1)
            {
                dateTimeString = @"Tomorrow";
            }
        }
        dateTimeString = _selectedDatesArray.count > 1?@"Multiple Dates":dateTimeString;
        self.pickupTime = _timePickerView.date;
        NSDateComponents *timeComponents = [[NSCalendar currentCalendar] components:kCFCalendarUnitHour| kCFCalendarUnitMinute fromDate:_timePickerView.date];
        
        NSString *buttonTitle = [NSString stringWithFormat:@"%@ - %02ld:%02ld",dateTimeString,(long)timeComponents.hour,(long)timeComponents.minute];
        [_selectDateTimeButton setTitle:buttonTitle forState:UIControlStateNormal];
    }else{
        [self selectTodaysDate];
        [_calendarView reloadData];
        [_selectDateTimeButton setTitle:@"Now" forState:UIControlStateNormal];
    }
    _calendarPopupView.hidden = YES;
}

- (IBAction)viaRouteButtonTouched:(HTButton *)sender
{
    if (_isUpdatingJourneyPrice) {
        [HTUtility showInfo:kWaitWhileGettingLocationInfoString];
    }
    else if ([_priceLabel.text isEqualToString:kPriceNoService])
    {
        [self showNoServicesPopup];
    }
    else
    {
        int existingViaPointsCount = [self existingViaRoutesCount];
        if (existingViaPointsCount < kMaximumViaPointsInAJourney) {
            [self changeViewToViaRouteNumber:existingViaPointsCount+1];
        }else
        {
            [HTUtility showInfo:[NSString stringWithFormat:@"You can use maximum of %d via points.",kMaximumViaPointsInAJourney]];
        }
    }
}

- (IBAction)viaRouteCancelButtonTouched:(HTButton *)sender
{
    HTLocation *currentViaLocation = [_userJourney.viaRoutesArray objectAtIndex:_currentViaRouteNumber-1];
    int existingViaPointsCount = [self existingViaRoutesCount];
    if (existingViaPointsCount > 0) {
        [_userJourney.viaRoutesArray exchangeObjectAtIndex:_currentViaRouteNumber-1 withObjectAtIndex:existingViaPointsCount-1];
    }
    currentViaLocation.address = nil;
    
    _screenDescriptionLabel.text = kDestinationLocationTitleString;
    _viaRouteButton.hidden = NO;
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:_userJourney.destinationLocation.coordinates.latitude longitude:_userJourney.destinationLocation.coordinates.longitude zoom:kMapZoomValue];
    [self mapView:_mapView idleAtCameraPosition:camera];
    [_mapView animateToCameraPosition:camera];
    
    [self moveView:_destinationLocationView toScreenPositon:screenPositionCenterX];
    __block float oldViaScreenOriginY = _viaRouteContainerView.frame.origin.y;
    [UIView animateWithDuration:kDefaultViewMovingAnimtionTime animations:^{
        [self moveView:_viaRouteContainerView toScreenPositon:screenPositionOutsideBottomY];
    } completion:^(BOOL finished) {
        CGRect frame = _viaRouteContainerView.frame;
        frame.origin.y = oldViaScreenOriginY;
        _viaRouteContainerView.frame = frame;
        _viaRouteContainerView.hidden = YES;
    }];
}

- (IBAction)viaRouteBackButtonTouched:(HTButton *)sender
{
    if (_isUpdatingJourneyPrice) {
        [HTUtility showInfo:kWaitWhileGettingLocationInfoString];
    }
    else if ([_priceLabel.text isEqualToString:kPriceNoService])
    {
        [self showNoServicesPopup];
    }
    else
    {
        if (_currentViaRouteNumber > 1 )
        {
            [self changeViewToViaRouteNumber:_currentViaRouteNumber-1];
        }else
        {
            [self changeViewToPickupLocationScreen];
        }
    }
}

- (IBAction)viaRouteNextButtonTouched:(HTButton *)sender
{
    if (_isUpdatingJourneyPrice) {
        [HTUtility showInfo:kWaitWhileGettingLocationInfoString];
    }else if ([_priceLabel.text isEqualToString:kPriceNoService])
    {
        [self showNoServicesPopup];
    }
    else
    {
        int existingViaPointsCount = [self existingViaRoutesCount];
        if (_currentViaRouteNumber < existingViaPointsCount )
        {
            [self changeViewToViaRouteNumber:_currentViaRouteNumber+1];
        }else
        {
            [self changeViewToDestinationLocationFromViaRouteScreen];
        }
    }
}

- (IBAction)shareOnFbButtonTouched:(HTButton *)sender
{
    if (_locationAddressTF.text.length > 0 && ![_locationAddressTF.text isEqualToString:kSearchingAddressString])
    {
        if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook]) {
            SLComposeViewController *composeController = [SLComposeViewController
                                                          composeViewControllerForServiceType:SLServiceTypeFacebook];
            [composeController setInitialText:[NSString stringWithFormat:@"I am going to\n%@\nusing Hubble Go services.",[self completeAddressString]]];
            [composeController addImage:[UIImage imageNamed:@"Icon.png"]];
            [composeController setCompletionHandler:^(SLComposeViewControllerResult result)
             {
                 if (result ==  SLComposeViewControllerResultDone) {
                     _userJourney.journeySharedOnFB = YES;
                 }
             }];
            [self presentViewController:composeController
                               animated:YES completion:nil];
            
        }else{
            [HTUtility showInfo:kNoFacebookAcountConfiguredString];
        }
    }else{
        [HTUtility showInfo:kWaitWhileGettingLocationInfoString];
    }
}

#pragma mark- Custom methods

- (void)configureMapView
{
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:0 longitude:0 zoom:kMapZoomValue];
    self.mapView = [GMSMapView mapWithFrame:_viewToShowMap.bounds camera:camera];
    [self.viewToShowMap addSubview:_mapView];
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onMapTappedWithGesture:)];
    [_mapView addGestureRecognizer:tapGesture];
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(onMapPannedWithGesture:)];
    [_mapView addGestureRecognizer:panGesture];
    _mapView.settings.consumesGesturesInView = NO;
    
    _mapView.myLocationEnabled = YES;
    _mapView.settings.compassButton = YES;
    //_mapView.settings.myLocationButton = YES;
    _mapView.delegate = self;
    
    for (int i=0; i < kMaximumViaPointsInAJourney; i++) {
        GMSMarker *marker = [GMSMarker markerWithPosition:_userJourney.pickupLocation.coordinates];
        marker.icon = [HTUtility halfSizedImageWithName:[NSString stringWithFormat:@"location_v%d_red.png",i+1]];
        marker.map = nil;
        [self.viaMarkerArray addObject:marker];
    }
    
    [self populateCommonPlaces];
}

- (void)populateCommonPlaces
{
    __block HTSessionRenew *sessionRenew = [[HTSessionRenew alloc] init];
    [self.renewSessionObjectsArray addObject:sessionRenew];
    [sessionRenew renewSessionWithCallbackBlock:^(bool succeeded, bool isLogout) {
        [self.renewSessionObjectsArray removeObject:sessionRenew];
        sessionRenew  = nil;
        if (isLogout) {
            [self forceLogoutCurrentUser];
        }else
        {
            if (succeeded)
            {
                [HTUtility addNotificationObserver:self selector:@selector(onCommonPlacesRestultNotification:) forNotificationWithName:kCommonPlacesRestultNotificationName];
                id networkRequstObj = [[HTUserLocationManager sharedManager] getCommonPlacesWithCompletionNotificationName:kCommonPlacesRestultNotificationName];
                [self performingNetworkCallWithObject:networkRequstObj forNotificationName:kServiceAreaFieldsFetchRestultNotificationName];
            }else
            {
                //Handled in renewSession class
            }
        }
    }];
}


- (void)moveMapToLocation:(CLLocationCoordinate2D)location
{
    [_mapView animateToLocation:location];
}

- (void)updateJourneyPriceValue
{
    [_directionsOfJourneyRequestObject cancelAllOperations];
    [_priceLabel setText:@"Calculating price..."];
    [HTUtility addNotificationObserver:self selector:@selector(onDirectionsOfJourneyReceivedRestultNotification:) forNotificationWithName:kDirectionsOfJourneyReceivedRestultNotificationName];
    NSString *viaRouteString = nil;
    if ([self existingViaRoutesCount] > 0) {
        for (HTLocation *location in _userJourney.viaRoutesArray) {
            if (location.address.length > 0) {
                NSString *oneViaPointString = [NSString stringWithFormat:@"via:%f,%f",location.coordinates.latitude,location.coordinates.longitude];
                if (viaRouteString) {
                    viaRouteString = [viaRouteString stringByAppendingString:[NSString stringWithFormat:@"|%@",oneViaPointString]];
                }else
                {
                    viaRouteString = oneViaPointString;
                }
                
            }
        }
    }
    
    self.directionsOfJourneyRequestObject = [[HTUserLocationManager sharedManager] directionsOfJourneyWithStartingLocation:[NSString stringWithFormat:@"%f,%f",_userJourney.pickupLocation.coordinates.latitude,_userJourney.pickupLocation.coordinates.longitude] endingLocation:[NSString stringWithFormat:@"%f,%f",_userJourney.destinationLocation.coordinates.latitude,_userJourney.destinationLocation.coordinates.longitude] viaRouteLocaton:viaRouteString completionNotificationName:kDirectionsOfJourneyReceivedRestultNotificationName];
}

- (void)mapLocationChangedToAddress:(GMSAddress*)address
{
    if (!_isFindingNearbyServiceArea) {
        self.currentSelectedGMAddress = address;
    }
    if ([self isOnPickupLocationScreen])
    {
        if (address.postalCode.length<1) {
            self.isFetchingServiceAreaFields = NO;
            self.serviceAreaDictionaryForSelectedPostCode = nil;
            [self resetVehicleSelectionButton];
            [self findServiceAreaNearby];
        }
        else
        {
            //On pickup location screen
            [self resetVehicleSelectionButton];
            id networkRequstObj = [self.objectsPerformingNetworkRequest objectForKey:kServiceAreaFieldsFetchRestultNotificationName];
            [networkRequstObj cancel];
            [self networkCallFinishedForNotificationName:kServiceAreaFieldsFetchRestultNotificationName];
            
            __block HTSessionRenew *sessionRenew = [[HTSessionRenew alloc] init];
            [self.renewSessionObjectsArray addObject:sessionRenew];
            [sessionRenew renewSessionWithCallbackBlock:^(bool succeeded, bool isLogout) {
                [self.renewSessionObjectsArray removeObject:sessionRenew];
                sessionRenew  = nil;
                if (isLogout) {
                    [self forceLogoutCurrentUser];
                }else
                {
                    if (succeeded)
                    {
                        [HTUtility addNotificationObserver:self selector:@selector(onServiceAreaFieldsFetchRestultNotification:) forNotificationWithName:kServiceAreaFieldsFetchRestultNotificationName];
                        NSString *firstPartOfPostalCode = [[address.postalCode componentsSeparatedByString:@" "] firstObject];
                        id networkRequstObj = [[HTUserLocationManager sharedManager] serviceAreaFieldsWithPostalCode:firstPartOfPostalCode completionNotificationName:kServiceAreaFieldsFetchRestultNotificationName];
                        [self performingNetworkCallWithObject:networkRequstObj forNotificationName:kServiceAreaFieldsFetchRestultNotificationName];
                        
                    }else
                    {
                        //Handled in renewSession class
                    }
                }
            }];
        }
        
    }else
    {
        
        NSString *countryName = [_serviceAreaDictionaryForSelectedPostCode objectForKey:kServiceAreaCountryKey];
        self.isSelectedAddressInServicesArea = [countryName isEqualToString:_currentSelectedGMAddress.country];
        if (_isSelectedAddressInServicesArea)
        {
            if ([self isOnDestinationLocationScreen])
            {//On destination location screen
                _userJourney.destinationLocation.gmsAddress = _currentSelectedGMAddress;
                _userJourney.destinationLocation.coordinates = _latestIdleCameraPosition;
                _userJourney.destinationLocation.address = [self completeAddressString];
                _userJourney.destinationLocation.postalCode = _currentSelectedGMAddress.postalCode;
            }else
            {//On via route screen
                
                HTLocation *viaRouteLocation = [_userJourney.viaRoutesArray objectAtIndex:_currentViaRouteNumber-1];
                viaRouteLocation.gmsAddress = _currentSelectedGMAddress;
                viaRouteLocation.coordinates = _latestIdleCameraPosition;
                viaRouteLocation.address = [self completeAddressString];
                viaRouteLocation.postalCode = _currentSelectedGMAddress.postalCode;
            }
            [self updateJourneyPriceValue];
        }else
        {
            [self showNoServicesPopup];
            self.isUpdatingJourneyPrice = NO;
            [_priceLabel setText:kPriceNoService];
        }
    }
}

- (void)changeViewToPickupLocationScreen
{
    self.topBarIV.image = [UIImage imageNamed:@"topbar_pickuplocation.png"];
    _screenDescriptionLabel.text = kPickupLocationTitleString;
    _viaRouteButton.hidden = YES;
    self.serviceAreaDictionaryForSelectedPostCode = nil;
    
    if (_userJourney.pickupLocation.address.length>0) {
        NSString *houseNumber = [self houseNumberStringFromAddress:_userJourney.pickupLocation.address];
        if (houseNumber.length>0) {
            _locationNumberTF.text = houseNumber;
            self.shouldNumberAddressRemainAsSearched = YES;
        }
    }
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:_userJourney.pickupLocation.coordinates.latitude longitude:_userJourney.pickupLocation.coordinates.longitude zoom:kMapZoomValue];
    [self mapView:_mapView idleAtCameraPosition:camera];
    [_mapView animateToCameraPosition:camera];
    
    [UIView animateWithDuration:kDefaultViewMovingAnimtionTime animations:^{
        [self moveView:_destinationLocationView toScreenPositon:screenPositionOutsideRightX];
        [self moveView:_viaRouteContainerView toScreenPositon:screenPositionOutsideRightX];
        [self moveView:_pickupLocationView toScreenPositon:screenPositionCenterX];
    } completion:nil];
    [self updateLocationMarkers];
}

- (void)changeViewToDestinationLocationFromPickupLocationScreen
{
    self.topBarIV.image = [UIImage imageNamed:@"topbar_destination.png"];
    _screenDescriptionLabel.text = kDestinationLocationTitleString;
    _viaRouteButton.hidden = NO;
    
    _userJourney.pickupLocation.gmsAddress = _currentSelectedGMAddress;
    _userJourney.pickupLocation.coordinates = _latestIdleCameraPosition;
    _userJourney.pickupLocation.address = [self completeAddressString];
    _userJourney.pickupLocation.postalCode = _currentSelectedGMAddress.postalCode;
    [UIView animateWithDuration:kDefaultViewMovingAnimtionTime animations:^{
        CGRect frame = _pickupLocationView.frame;
        frame.origin.x = -self.view.frame.size.width;
        _pickupLocationView.frame = frame;
        _destinationLocationView.center = CGPointMake(self.view.center.x, _destinationLocationView.center.y);
    } completion:nil];
    if (!_userJourney.destinationLocation.address) {
        _userJourney.destinationLocation.gmsAddress = _currentSelectedGMAddress;
        _userJourney.destinationLocation.coordinates = _latestIdleCameraPosition;
        _userJourney.destinationLocation.address = [self completeAddressString];
        _userJourney.destinationLocation.postalCode = _currentSelectedGMAddress.postalCode;
    }
    
    if (_userJourney.destinationLocation.address.length>0) {
        NSString *houseNumber = [self houseNumberStringFromAddress:_userJourney.destinationLocation.address];
        if (houseNumber.length>0) {
            _locationNumberTF.text = houseNumber;
            self.shouldNumberAddressRemainAsSearched = YES;
        }
    }
    
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:_userJourney.destinationLocation.coordinates.latitude longitude:_userJourney.destinationLocation.coordinates.longitude zoom:kMapZoomValue];
    [self mapView:_mapView idleAtCameraPosition:camera];
    [_mapView animateToCameraPosition:camera];
    [self updateLocationMarkers];
}

- (void)changeViewToDestinationLocationFromViaRouteScreen
{
    self.topBarIV.image = [UIImage imageNamed:@"topbar_destination.png"];
    _screenDescriptionLabel.text = kDestinationLocationTitleString;
    _viaRouteButton.hidden = NO;
    [UIView animateWithDuration:kDefaultViewMovingAnimtionTime animations:^{
        [self moveView:_viaRouteContainerView toScreenPositon:screenPositionOutsideLeftX];
        [self moveView:_destinationLocationView toScreenPositon:screenPositionCenterX];
    } completion:nil];
    
    if (_userJourney.destinationLocation.address.length>0) {
        NSString *houseNumber = [self houseNumberStringFromAddress:_userJourney.destinationLocation.address];
        if (houseNumber.length>0) {
            _locationNumberTF.text = houseNumber;
            self.shouldNumberAddressRemainAsSearched = YES;
        }
    }
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:_userJourney.destinationLocation.coordinates.latitude longitude:_userJourney.destinationLocation.coordinates.longitude zoom:kMapZoomValue];
    [self mapView:_mapView idleAtCameraPosition:camera];
    [_mapView animateToCameraPosition:camera];
    [self updateLocationMarkers];
}

- (void)changeViewToViaRouteNumber:(int)viaRouteNumber
{
    self.topBarIV.image = [UIImage imageNamed:@"topbar_viaroute.png"];
    
    if (viaRouteNumber <= _userJourney.viaRoutesArray.count)
    {
        _viaRouteButton.hidden = YES;
        _viaRouteContainerView.hidden = NO;
        if ([self isOnPickupLocationScreen])
        {
            [self moveView:_viaRouteContainerView toScreenPositon:screenPositionOutsideRightX];
            [UIView animateWithDuration:kDefaultViewMovingAnimtionTime animations:^{
                [self moveView:_pickupLocationView toScreenPositon:screenPositionOutsideLeftX];
                [self moveView:_viaRouteContainerView toScreenPositon:screenPositionCenterX];
            } completion:nil];
        }else if ([self isOnDestinationLocationScreen])
        {
            [self moveView:_viaRouteContainerView toScreenPositon:screenPositionOutsideLeftX];
            [UIView animateWithDuration:kDefaultViewMovingAnimtionTime animations:^{
                [self moveView:_destinationLocationView toScreenPositon:screenPositionOutsideRightX];
                [self moveView:_viaRouteContainerView toScreenPositon:screenPositionCenterX];
            } completion:nil];
        }
        else
        {
            BOOL isMovingLeft = viaRouteNumber > _currentViaRouteNumber;
            [self moveView:_viaScreenOfScreenContainerView toScreenPositon:isMovingLeft? screenPositionOutsideRightX:screenPositionOutsideLeftX];
            [UIView animateWithDuration:kDefaultViewMovingAnimtionTime animations:^{
                [self moveView:_viaRouteContainerView toScreenPositon:isMovingLeft? screenPositionOutsideLeftX:screenPositionOutsideRightX];
                [self moveView:_viaScreenOfScreenContainerView toScreenPositon:screenPositionCenterX];
            } completion:^(BOOL finished) {
                [self moveView:_viaRouteContainerView toScreenPositon:screenPositionCenterX];
                [self moveView:_viaScreenOfScreenContainerView toScreenPositon:screenPositionOutsideRightX];
            }];
        }
        
        self.currentViaRouteNumber = viaRouteNumber;
        _screenDescriptionLabel.text  = [NSString stringWithFormat:@"Via Route (%d)",_currentViaRouteNumber];
        
        HTLocation *viaRouteLocation = [_userJourney.viaRoutesArray objectAtIndex:viaRouteNumber-1];
        if (viaRouteLocation.address.length>0) {
            if (viaRouteLocation.address.length>0) {
                NSString *houseNumber = [self houseNumberStringFromAddress:viaRouteLocation.address];
                if (houseNumber.length>0) {
                    _locationNumberTF.text = houseNumber;
                    self.shouldNumberAddressRemainAsSearched = YES;
                }
            }
            GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:viaRouteLocation.coordinates.latitude longitude:viaRouteLocation.coordinates.longitude zoom:kMapZoomValue];
            [_mapView animateToCameraPosition:camera];
            [self mapView:_mapView idleAtCameraPosition:camera];
        }else{
            HTLocation *lastRouteLocation = [_userJourney.viaRoutesArray objectAtIndex:viaRouteNumber-1];
            lastRouteLocation.gmsAddress = _currentSelectedGMAddress;
            lastRouteLocation.coordinates = _latestIdleCameraPosition;
            lastRouteLocation.address = [self completeAddressString];
            lastRouteLocation.postalCode = _currentSelectedGMAddress.postalCode;
        }
    }
    [self updateLocationMarkers];
}

- (BOOL)isOnPickupLocationScreen
{
    return [_screenDescriptionLabel.text isEqualToString:kPickupLocationTitleString];
}

- (BOOL)isOnDestinationLocationScreen
{
    return [_screenDescriptionLabel.text isEqualToString:kDestinationLocationTitleString];
}

- (void)resetVehicleSelectionButton
{
    _vehicleSelectionButton.selected = NO;
    [_vehicleSelectionButton setTitle:@"Select Vehicle" forState:UIControlStateNormal];
    //Reset pickup time too, as it is directly related to vehicle availability
    [_estPickupTimeLabel setText:@"-"];
}

- (void)changeVehicleTypeTo:(NSString*)vehichleType
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [_vehicleSelectionButton setTitle:vehichleType forState:UIControlStateNormal];
        [_vehicleSelectionButton setTitle:vehichleType forState:UIControlStateSelected];
        _vehicleSelectionButton.selected = YES;
        [self updateLocationIcon:YES];
    });
}

- (BOOL)isPickupTimeInRushHours:(NSArray *)rushHours
{
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"HHmm"];
    NSString *timeString = [dateFormat stringFromDate:_pickupTime];
    
    BOOL isTimeInRushHours = NO;
    
    float timeValue = timeString.floatValue;
    float rushHourStartValue = 0;
    float rushHourEndValue = 0;
    for (NSString *rushHourString in rushHours)
    {
        if (rushHourString.length==9)
        {
            rushHourStartValue = [[rushHourString substringToIndex:4] floatValue];
            rushHourEndValue = [[rushHourString substringFromIndex:5] floatValue];
            isTimeInRushHours = timeValue>rushHourStartValue && timeValue<rushHourEndValue;
            if (isTimeInRushHours) {
                break;
            }
        }
    }
    return isTimeInRushHours;
}

- (void)showNoServicesPopup
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.view makeToast:@"We currently do not provide services in your selected place"  duration:3.0 position:[NSValue valueWithCGPoint:CGPointMake(130, 80)]];
    });
}

- (void)selectTodaysDate
{
    NSDateComponents *dateComponents = [[NSCalendar currentCalendar] components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:[NSDate date]];
    [_selectedDatesArray addObject:dateComponents];
}
- (void)findServiceAreaNearby
{
    self.nearbyServiceAreaFindingTryNumber++;
    CLLocationDegrees nearbyLat = 0.0, nearbyLng = 0.0;
    if (_nearbyServiceAreaFindingTryNumber== 1 || _nearbyServiceAreaFindingTryNumber == 2)
    {
        nearbyLat = _latestIdleCameraPosition.latitude;
        nearbyLng = _latestIdleCameraPosition.longitude +(_nearbyServiceAreaFindingTryNumber==1?1:-1) * kNearbyServiceAreaDistanceInMeters/(1000*111.320*cos(nearbyLat));
    }
    else if (_nearbyServiceAreaFindingTryNumber== 3 || _nearbyServiceAreaFindingTryNumber == 4)
    {
        nearbyLat = _latestIdleCameraPosition.latitude +(_nearbyServiceAreaFindingTryNumber==3?1:-1) * kNearbyServiceAreaDistanceInMeters/(110.54*1000);
        nearbyLng = _latestIdleCameraPosition.longitude;
    }else
    {
        self.nearbyServiceAreaFindingTryNumber = 0;
        self.isFindingNearbyServiceArea = NO;
        [self showNoServicesPopup];
    }
    if (_nearbyServiceAreaFindingTryNumber) {
        if (CLLocationCoordinate2DIsValid(CLLocationCoordinate2DMake(nearbyLat, nearbyLng)))
        {
            self.isFindingNearbyServiceArea = YES;
            GMSCameraPosition *cameraPosition = [GMSCameraPosition cameraWithLatitude:nearbyLat longitude:nearbyLng zoom:_mapView.camera.zoom];
            [self mapView:_mapView idleAtCameraPosition:cameraPosition];
        }else
        {
            self.nearbyServiceAreaFindingTryNumber = 0;
            self.isFindingNearbyServiceArea = NO;
            [self showNoServicesPopup];
        }
    }
}

- (int)existingViaRoutesCount
{
    int existingViaPointsCount = 0;
    for (HTLocation *location in _userJourney.viaRoutesArray) {
        existingViaPointsCount = location.address.length>0?++existingViaPointsCount:existingViaPointsCount;
    }
    return existingViaPointsCount;
}


- (NSString*)houseNumberStringFromAddress:(NSString*)completeAddress
{
    NSInteger houseNumber = 0;
    NSString *houseNumberString = @"0";
    BOOL success = [[NSScanner scannerWithString:completeAddress] scanInteger:&houseNumber];
    if (success && houseNumber)
    {
        houseNumberString = [NSString stringWithFormat:@"%ld",(long)houseNumber];
        NSRange range = [completeAddress rangeOfString:houseNumberString];
        if (range.location != NSNotFound)
        {
            NSRange rangeOfSpace = [completeAddress rangeOfString:@" "];
            if (rangeOfSpace.location != NSNotFound) {
                NSRange houseNumberStringRange = NSMakeRange(0, rangeOfSpace.location);
                houseNumberString = [completeAddress substringWithRange:houseNumberStringRange];
            }
        }
    }
    return houseNumberString;
}

- (NSString*)completeAddressString
{
    NSString *completeAddress = _locationAddressTF.text;
    if (_locationNumberTF.text.integerValue > 0) {
        completeAddress = [NSString stringWithFormat:@"%@ %@",_locationNumberTF.text,_locationAddressTF.text];
    }
    return completeAddress;
}

- (void)updateMinimumDateValue
{
    NSDateComponents *todayDateComponents = [[NSCalendar currentCalendar] components:NSCalendarUnitDay fromDate:[NSDate date]];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"day==%ld",todayDateComponents.day];
    NSArray *filteredArray = [_selectedDatesArray filteredArrayUsingPredicate:predicate];
    if (filteredArray.count>0) {
        _timePickerView.minimumDate = [NSDate date];
    }else
    {
        _timePickerView.minimumDate = nil;
    }
}

- (void)updateLocationIcon:(BOOL)isSearchComplete
{
    if (isSearchComplete) {
        if ([self isOnPickupLocationScreen]) {
            [_locationArrow setImage:[UIImage imageNamed:@"location_a_green.png"]];
            [_pickupLocationNextButton setBackgroundImage:[UIImage imageNamed:@"btn_pickup_next_orange.png"] forState:UIControlStateNormal];
        }else if ([self isOnDestinationLocationScreen])
        {
            [_locationArrow setImage:[UIImage imageNamed:@"location_b_red.png"]];
            [_destinationNextButton setBackgroundImage:[UIImage imageNamed:@"btn_dest_next_orange.png"] forState:UIControlStateNormal];
        }else
        {
            [_locationArrow setImage:[UIImage imageNamed:[NSString stringWithFormat:@"location_v%d_red.png",_currentViaRouteNumber]]];
            [_viaRouteNextButton setBackgroundImage:[UIImage imageNamed:@"btn_dest_next_orange.png"] forState:UIControlStateNormal];
        }
    }else
    {
        if ([self isOnPickupLocationScreen]) {
            [_locationArrow setImage:[UIImage imageNamed:@"location_a_gray.png"]];
            [_pickupLocationNextButton setBackgroundImage:[UIImage imageNamed:@"btn_pickup_next_gray.png"] forState:UIControlStateNormal];
        }else if ([self isOnDestinationLocationScreen])
        {
            [_locationArrow setImage:[UIImage imageNamed:@"location_b_gray.png"]];
            [_destinationNextButton setBackgroundImage:[UIImage imageNamed:@"btn_dest_next_gray.png"] forState:UIControlStateNormal];
        }else
        {
            [_locationArrow setImage:[UIImage imageNamed:[NSString stringWithFormat:@"location_v%d_gray.png",_currentViaRouteNumber]]];
            [_viaRouteNextButton setBackgroundImage:[UIImage imageNamed:@"btn_dest_next_gray.png"] forState:UIControlStateNormal];
        }
    }
}

- (void)updatePickupTime
{
    id networkRequstObj = [self.objectsPerformingNetworkRequest objectForKey:kGetDriverNearbyNotificationName];
    [networkRequstObj cancel];
    [self networkCallFinishedForNotificationName:kGetDriverNearbyNotificationName];
    
    __block HTSessionRenew *sessionRenew = [[HTSessionRenew alloc] init];
    [self.renewSessionObjectsArray addObject:sessionRenew];
    [sessionRenew renewSessionWithCallbackBlock:^(bool succeeded, bool isLogout) {
        [self.renewSessionObjectsArray removeObject:sessionRenew];
        sessionRenew  = nil;
        if (isLogout) {
            [self forceLogoutCurrentUser];
        }else
        {
            if (succeeded)
            {
                [HTUtility addNotificationObserver:self selector:@selector(onGetDriverNearbyRestultNotification:) forNotificationWithName:kGetDriverNearbyNotificationName];
                NSString *locationString = [NSString stringWithFormat:@"%f,%f;%d",_latestIdleCameraPosition.longitude,_latestIdleCameraPosition.latitude,25000];
                id networkRequstObj = [[HTUserProfileManager sharedManager] getDriverAvailableNearToLocation:locationString completionNotificationName:kGetDriverNearbyNotificationName];
                [self performingNetworkCallWithObject:networkRequstObj forNotificationName:kGetDriverNearbyNotificationName];
            }else
            {
                //Handled in renewSession class
            }
        }
    }];
}

- (void)updateLocationMarkers
{
    if ([self isOnPickupLocationScreen]) {
        self.pickupLocationMarker.map = nil;
        self.destinationLocationMarker.map = nil;
        [self updateViaMarkersWithUserOnViaNumber:0];
    }else if ([self isOnDestinationLocationScreen])
    {
        self.destinationLocationMarker.map = nil;
        [self updateViaMarkersWithUserOnViaNumber:kMaximumViaPointsInAJourney+1];
        if (!_pickupLocationMarker) {
            self.pickupLocationMarker = [GMSMarker markerWithPosition:_userJourney.pickupLocation.coordinates];
            self.pickupLocationMarker.icon = [HTUtility halfSizedImageWithName:@"location_a_green.png"];
        }
        self.pickupLocationMarker.map = _mapView;
    }else
    {
        if (!_pickupLocationMarker) {
            self.pickupLocationMarker = [GMSMarker markerWithPosition:_userJourney.pickupLocation.coordinates];
            self.pickupLocationMarker.icon = [HTUtility halfSizedImageWithName:@"location_a_green.png"];
        }
        if (!_destinationLocationMarker) {
            self.destinationLocationMarker = [GMSMarker markerWithPosition:_userJourney.destinationLocation.coordinates];
            self.destinationLocationMarker.icon = [HTUtility halfSizedImageWithName:@"location_b_red.png"];
        }
        self.pickupLocationMarker.map = _mapView;
        self.destinationLocationMarker.map = _mapView;
        [self updateViaMarkersWithUserOnViaNumber:_currentViaRouteNumber];
    }
    self.pickupLocationMarker.position = _userJourney.pickupLocation.coordinates;
    self.destinationLocationMarker.position = _userJourney.destinationLocation.coordinates;
}

- (void)updateViaMarkersWithUserOnViaNumber:(int)viaNumber
{
    if (viaNumber == 0) {
        for (int index = 0; index<kMaximumViaPointsInAJourney; index++) {
            GMSMarker *marker = [self.viaMarkerArray objectAtIndex:index];
            marker.map = nil;
        }
    }else
    {
        for (int index = 0; index<kMaximumViaPointsInAJourney; index++) {
            GMSMarker *marker = [self.viaMarkerArray objectAtIndex:index];
            marker.map = index+1!=viaNumber?_mapView:nil;
            marker.position = ((HTLocation*)_userJourney.viaRoutesArray[index]).coordinates;
        }
    }
    
}

#pragma mark - KVO updates
- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    NSString *contextString = (__bridge NSString *)(context);
    if ([contextString isEqualToString:_updateLocationKVContext])
    {
        if (!_isLocationUpdated)
        {
            CLLocation *location = [change objectForKey:NSKeyValueChangeNewKey];
            [self moveMapToLocation:location.coordinate];
            self.isLocationUpdated = YES;
        }
    }
}

#pragma mark - Text Field methods

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if ([textField isEqual:_locationAddressTF] || [textField isEqual:_locationNumberTF]) {
        if ([string isEqualToString:@"\n"])
        {
            [textField resignFirstResponder];
            return NO;
        }
    }
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if (textField.text.length > 0)
    {
        if ([_addressToLocationRequestObject respondsToSelector:@selector(cancelAllOperations)]) {
            [HTUtility removeNotificationObserver:self withNotificationName:kAddressToLocationResultNotificationName];
            [_addressToLocationRequestObject cancelAllOperations];
            self.addressToLocationRequestObject = nil;
        }
        [HTUtility addNotificationObserver:self selector:@selector(onAddressToLocationResultNotification:) forNotificationWithName:kAddressToLocationResultNotificationName];
        NSString *searchAddress = [self completeAddressString];
        self.addressToLocationRequestObject = [[HTUserLocationManager sharedManager] locationAgainstAddress:searchAddress inLocality:textField==_locationNumberTF?_currentSelectedGMAddress.locality?_currentSelectedGMAddress.locality:_currentSelectedGMAddress.subLocality:nil completionNotificationName:kAddressToLocationResultNotificationName];
        self.isLocationUpdated = YES;
        self.shouldNumberAddressRemainAsSearched = (textField == _locationNumberTF);
        if ([self isOnPickupLocationScreen]) {
            _userJourney.pickupLocation.isCommonPlace = NO;
        }else if ([self isOnDestinationLocationScreen])
        {
            _userJourney.pickupLocation.isCommonPlace = NO;
            self.isUpdatingJourneyPrice = YES;
        }else
        {
            HTLocation *lastRouteLocation = [_userJourney.viaRoutesArray objectAtIndex:_currentViaRouteNumber-1];
            lastRouteLocation.isCommonPlace = NO;
        }
    }
}

#pragma mark- Map methods

- (void)onMapTappedWithGesture:(UITapGestureRecognizer*)gesture
{
    [self endEditing:YES];
}

- (void)onMapPannedWithGesture:(UIPanGestureRecognizer*)gesture
{
    [self endEditing:YES];
    [self endEditing:YES];
    self.isLocationUpdated = YES;
    self.shouldNumberAddressRemainAsSearched = NO;
    if ([self isOnPickupLocationScreen]) {
        _userJourney.pickupLocation.isCommonPlace = NO;
    }else if ([self isOnDestinationLocationScreen])
    {
        _userJourney.pickupLocation.isCommonPlace = NO;
    }else
    {
        HTLocation *lastRouteLocation = [_userJourney.viaRoutesArray objectAtIndex:_currentViaRouteNumber-1];
        lastRouteLocation.isCommonPlace = NO;
    }
    
}

-(void)updateMarkersVisibility
{
    GMSVisibleRegion visibleRegion = [_mapView.projection visibleRegion];
    GMSCoordinateBounds *bounds = [[GMSCoordinateBounds alloc]initWithRegion:visibleRegion];
    GMSMarker *resultMarker = nil;
    int markerShownCount = 0;
    for (int index=0; index<_markersArray.count; index++)
    {
        resultMarker = _markersArray[index];
        resultMarker.opacity = 0.0;
        if ([bounds containsCoordinate:resultMarker.position])
        {
            if (markerShownCount == 3) { //Maximum number of marker to be shown is 3 for now
                continue;
            }
            resultMarker.opacity = 1;
            markerShownCount++;
        }
    }
}

- (void)mapView:(GMSMapView *)mapView didChangeCameraPosition:(GMSCameraPosition *)position
{
    [self updateMarkersVisibility];
    [self endEditing:YES];
    self.isFindingNearbyServiceArea = NO;
    self.nearbyServiceAreaFindingTryNumber = 0;
    [_locationAddressTF setText:kSearchingAddressString];
    [self updateLocationIcon:NO];
    if(!_shouldNumberAddressRemainAsSearched)
    {
        [_locationNumberTF setText:[NSString stringWithFormat:@"0"]];
    }
}

- (void)mapView:(GMSMapView *)mapView idleAtCameraPosition:(GMSCameraPosition *)position
{
    self.lastSearchedLocationOnMap = position.target;
    if (!_isFindingNearbyServiceArea) {
        self.latestIdleCameraPosition = position.target;
        [self updateLocationIcon:NO];
    }
    if([self isOnPickupLocationScreen])
    {
        [self resetVehicleSelectionButton];
    }
    self.isFetchingServiceAreaFields = YES;
    self.isUpdatingJourneyPrice = YES;
    [[GMSGeocoder geocoder] reverseGeocodeCoordinate:position.target completionHandler:^(GMSReverseGeocodeResponse *response, NSError *error)
     {
         if (!error && response.results.count > 0)
         {
             GMSAddress *address = response.firstResult;
             if (address.coordinate.latitude == _lastSearchedLocationOnMap.latitude && address.coordinate.longitude == _lastSearchedLocationOnMap.longitude) {
                 //update only if this is the latest position selected by user [this is due to async call response]
                 NSString *completeAddress = address.lines.count>0?[address.lines firstObject]:@"";
                 NSString *addressSuffix = [NSString stringWithFormat:@", %@",address.postalCode.length>0?address.postalCode:address.locality.length>0?address.locality:@""];
                 completeAddress = [completeAddress stringByAppendingString:addressSuffix.length>2?addressSuffix:@""];
                 
                 NSString *houseNumberString = [self houseNumberStringFromAddress:completeAddress];
                 NSRange range = [completeAddress rangeOfString:houseNumberString];
                 NSString *addressTextPart = completeAddress;
                 if (range.location != NSNotFound && range.length < completeAddress.length)
                 {
                     addressTextPart = [completeAddress substringFromIndex:range.length];
                 }
                 if (!_isFindingNearbyServiceArea) {
                     [_locationAddressTF setText:addressTextPart];
                     
                     if (!_shouldNumberAddressRemainAsSearched) {
                         [_locationNumberTF setText:houseNumberString];
                     }
                 }
                 [self mapLocationChangedToAddress:address];
             }else{
                 self.isFindingNearbyServiceArea = NO;
                 self.nearbyServiceAreaFindingTryNumber = 0;
             }
         }
         {
             if([self isOnPickupLocationScreen])
             {
                 [self resetVehicleSelectionButton];
             }
         }
     }];
}

- (BOOL)mapView:(GMSMapView *)mapView didTapMarker:(GMSMarker *)marker
{
    if ([self isOnPickupLocationScreen]) {
        _userJourney.pickupLocation.isCommonPlace = YES;
    }else if ([self isOnDestinationLocationScreen])
    {
        _userJourney.pickupLocation.isCommonPlace = YES;
    }else
    {
        HTLocation *lastRouteLocation = [_userJourney.viaRoutesArray objectAtIndex:_currentViaRouteNumber-1];
        lastRouteLocation.isCommonPlace = YES;
    }
    return NO;
}

#pragma mark- Notification methods
- (void)onAddressToLocationResultNotification:(NSNotification*)notification
{
    [HTUtility removeNotificationObserver:self withNotificationName:notification.name];
    NSDictionary *notifyDictionary = [notification userInfo];
    BOOL success = [[notifyDictionary objectForKey:kResponseSuccessKey] boolValue];
    if (success)
    {
        float lat = [[notifyDictionary objectForKey:kLatitudeKey] floatValue];
        float lng = [[notifyDictionary objectForKey:kLongitudeKey] floatValue];
        if(lat > 180)
        {
            [HTUtility showInfo:kNoAddressMatchFoundString];
        }else{
            dispatch_async(dispatch_get_main_queue(), ^
                           {
                               [self moveMapToLocation:CLLocationCoordinate2DMake(lat, lng)];
                               GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:lat longitude:lng zoom:_mapView.camera.zoom];
                               [self mapView:_mapView idleAtCameraPosition:camera];
                           });
        }
    }else
    {
        if (_addressToLocationRequestObject) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:kAppName message:kNetworkErrorString delegate:self cancelButtonTitle:kCancelString otherButtonTitles:kTryAgainString, nil];
            alertView.tag = kNetworkErrorStringViewTag;
            [alertView show];
        }
    }
    self.addressToLocationRequestObject = nil;
}

- (void)onSearchedPlaceSelectedNotification:(NSNotification*)notification
{
    [HTUtility removeNotificationObserver:self withNotificationName:notification.name];
    NSDictionary *notifyDictionary = [notification userInfo];
    [self dismissViewControllerAnimated:YES completion:nil];
    float lat = [[notifyDictionary objectForKey:kLatitudeKey] floatValue];
    float lng = [[notifyDictionary objectForKey:kLongitudeKey] floatValue];
    NSString *address = [notifyDictionary objectForKey:kSelectedPlaceKey];
    if (lat) {
        //Move map to lat,lng
        [self moveMapToLocation:CLLocationCoordinate2DMake(lat,lng)];
    }else if(address)
    {
        //Move map to address
        [_locationAddressTF setText:address];
        [self textFieldDidEndEditing:_locationAddressTF];
    }
    NSString *homeNumberString = [self houseNumberStringFromAddress:address];
    if (homeNumberString.length > 0) {
        [_locationNumberTF setText:homeNumberString];
        self.shouldNumberAddressRemainAsSearched = YES;
    }
    
    self.isLocationUpdated = YES;
    if ([self isOnPickupLocationScreen]) {
        _userJourney.pickupLocation.isCommonPlace = NO;
    }else if ([self isOnDestinationLocationScreen])
    {
        _userJourney.pickupLocation.isCommonPlace = NO;
    }else
    {
        HTLocation *lastRouteLocation = [_userJourney.viaRoutesArray objectAtIndex:_currentViaRouteNumber-1];
        lastRouteLocation.isCommonPlace = NO;
    }
}

- (void)onServiceAreaFieldsFetchRestultNotification:(NSNotification*)notification
{
    [HTUtility removeNotificationObserver:self withNotificationName:notification.name];
    [self networkCallFinishedForNotificationName:notification.name];
    self.isFetchingServiceAreaFields = NO;
    
    NSDictionary *notifyDictionary = [notification userInfo];
    BOOL success = [[notifyDictionary objectForKey:kResponseSuccessKey] boolValue];
    if (success) {
        NSDictionary *ServiceAreaObjectDictionary = [notifyDictionary objectForKey:kServiceAreaObjectsKey];
        self.isSelectedAddressInServicesArea = NO;
        if ([self isOnPickupLocationScreen])
        {
            //On pickup location screen
            self.serviceAreaDictionaryForSelectedPostCode = nil;
            NSArray *vehicleTypes = [ServiceAreaObjectDictionary objectForKey:kServiceAreaVehicleTypesKey];
            if ([vehicleTypes isKindOfClass:[NSArray class]] && vehicleTypes.count>0) {
                self.serviceAreaDictionaryForSelectedPostCode = ServiceAreaObjectDictionary;
                self.isSelectedAddressInServicesArea = YES;
                NSString *userOldVehicleType = [[HTUserLocationManager sharedManager] userSelectedVehicleType];
                if ([vehicleTypes containsObject:userOldVehicleType]) {
                    [self changeVehicleTypeTo:userOldVehicleType];
                }else{
                    [self changeVehicleTypeTo:[vehicleTypes firstObject]];
                }
                self.isFindingNearbyServiceArea = NO;
                self.nearbyServiceAreaFindingTryNumber = 0;
                [self updatePickupTime];
            }
            if (!_isSelectedAddressInServicesArea) {
                [self findServiceAreaNearby];
            }
        }else
        {
            //On destination location screen
        }
    }
}

- (void)onDirectionsOfJourneyReceivedRestultNotification:(NSNotification*)notification
{
    _directionsOfJourneyRequestObject = nil;
    self.isUpdatingJourneyPrice = NO;
    NSDictionary *notifyDictionary = [notification userInfo];
    BOOL success = [[notifyDictionary objectForKeyedSubscript:kResponseSuccessKey] boolValue];
    if (success) {
        [HTUtility removeNotificationObserver:self withNotificationName:notification.name];
        NSArray *directionsArray = [notifyDictionary objectForKey:kMapDirectionsKey];
        if (directionsArray.count < 1) {
            [_priceLabel setText:kPriceNoService];
        }else
        {
            NSDictionary *directionDictionary = directionsArray.count>0?[directionsArray firstObject]:nil;
            NSArray *directionLegs = [directionDictionary objectForKey:@"legs"];
            NSDictionary *distanceDictionary = directionLegs.count>0?[[directionLegs firstObject] objectForKey:@"distance"]:nil;
            NSNumber *distance = [distanceDictionary objectForKey:@"value"];
            
            NSArray *rushHours = [_serviceAreaDictionaryForSelectedPostCode objectForKey:kServiceAreaRushHoursKey];
            NSArray *minimalFares = [_serviceAreaDictionaryForSelectedPostCode objectForKey:kServiceAreaMinimalFaresKey];
            NSArray *startingFares = [_serviceAreaDictionaryForSelectedPostCode objectForKey:kServiceAreaStartingFaresKey];
            NSArray *withoutRushRates = [_serviceAreaDictionaryForSelectedPostCode objectForKey:kServiceAreaWithoutRushRatesKey];
            NSArray *rushRates = [_serviceAreaDictionaryForSelectedPostCode objectForKey:kServiceAreaRushRatesKey];
            float longDistanceStartKmValue = [[_serviceAreaDictionaryForSelectedPostCode objectForKey:kServiceAreaLongDistanceStartsFromKmValueKey] floatValue];
            NSArray *longDistanceRates = [_serviceAreaDictionaryForSelectedPostCode objectForKey:kServiceAreaLongDistanceRatesKey];
            
            NSUInteger indexForCurrentCalculations = [[_serviceAreaDictionaryForSelectedPostCode objectForKey:kServiceAreaVehicleTypesKey] indexOfObject:_vehicleSelectionButton.currentTitle];
            float minimalFareValue = indexForCurrentCalculations<minimalFares.count?[[minimalFares objectAtIndex:indexForCurrentCalculations] floatValue]:0;
            float startingFareValue = indexForCurrentCalculations<startingFares.count?[[startingFares objectAtIndex:indexForCurrentCalculations] floatValue]:0;
            float withoutRushRateValue = indexForCurrentCalculations<withoutRushRates.count?[[withoutRushRates objectAtIndex:indexForCurrentCalculations] floatValue]:0;
            float rushRateValue = indexForCurrentCalculations<rushRates.count?[[rushRates objectAtIndex:indexForCurrentCalculations] floatValue]:0;
            float longDistanceRateValue = indexForCurrentCalculations<longDistanceRates.count?[[longDistanceRates objectAtIndex:indexForCurrentCalculations] floatValue]:0;
            
            
            float priceValue = startingFareValue;
            float priceMultiplier = [self isPickupTimeInRushHours:rushHours]?rushRateValue:withoutRushRateValue;
            float distanceInKm = distance.floatValue/1000;
            _userJourney.distanceTravelled = distanceInKm;
            
            priceValue += distanceInKm>longDistanceStartKmValue?longDistanceStartKmValue*priceMultiplier:distanceInKm*priceMultiplier;
            priceValue += distanceInKm-longDistanceStartKmValue>0?(distanceInKm-longDistanceStartKmValue)*longDistanceRateValue:0;
            priceValue = priceValue>minimalFareValue?priceValue:minimalFareValue;
            dispatch_async(dispatch_get_main_queue(), ^{
                [_priceLabel setText:[NSString stringWithFormat:@"£%0.01f0",priceValue]];
                [self updateLocationIcon:YES];
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

- (void)onCommonPlacesRestultNotification:(NSNotification*)notification
{
    [HTUtility removeNotificationObserver:self withNotificationName:notification.name];
    [self networkCallFinishedForNotificationName:notification.name];
    NSDictionary *notifyDictionary = [notification userInfo];
    BOOL success = [[notifyDictionary objectForKey:kResponseSuccessKey] boolValue];
    if (success)
    {
        NSArray *addressObjects = notifyDictionary[kCommonPlacesObjectsKey];
        if ([addressObjects isKindOfClass:[NSArray class]])
        {
            for (NSDictionary *dictioary in addressObjects)
            {
                NSString *address = dictioary[@"Address"];
                NSArray *addressComponents = [address componentsSeparatedByString:@">>"];
                if (addressComponents.count >=3) {
                    CLLocationDegrees lat = [addressComponents[0] doubleValue];
                    CLLocationDegrees lng = [addressComponents[1] doubleValue];
                    NSString *title = addressComponents[2];
                    GMSMarker *marker = [GMSMarker markerWithPosition:CLLocationCoordinate2DMake(lat, lng)];
                    marker.title = title;
                    marker.icon = [GMSMarker markerImageWithColor:[UIColor yellowColor]];
                    marker.map = _mapView;
                    [self.markersArray addObject:marker];
                }
            }
        }
    }else
    {
        UIAlertView *addNewHobbyView = [[UIAlertView alloc] initWithTitle:kAppName message:@"We are unable to load common places from server. Please check your internet connection and try again." delegate:self cancelButtonTitle:kCancelString otherButtonTitles:kTryAgainString, nil];
        addNewHobbyView.tag = kCommonPlacesFailedTryAgainStringViewTag;
        [addNewHobbyView show];
    }
}

- (void)onGetDriverNearbyRestultNotification:(NSNotification*)notification
{
    [HTUtility removeNotificationObserver:self withNotificationName:notification.name];
    [self networkCallFinishedForNotificationName:notification.name];
    NSDictionary *notifyDictionary = [notification userInfo];
    BOOL success = [[notifyDictionary objectForKey:kResponseSuccessKey] boolValue];
    if (success)
    {
        NSDictionary *driverFields = notifyDictionary[kDriverObjectFieldsKey];
        NSArray *locationCoordinates = driverFields[@"location_coordinates"];
        float time = 50;
        if ([locationCoordinates isKindOfClass:[NSArray class]] && locationCoordinates.count > 1) {
            CLLocationCoordinate2D from = CLLocationCoordinate2DMake([locationCoordinates[1] doubleValue], [locationCoordinates[0] doubleValue]);
            CLLocationCoordinate2D to = _latestIdleCameraPosition;
            double distance = GMSGeometryDistance(from, to)/1000;
            time = distance * 2+2; //(distance/25.0)*50.0;
            time = MIN(time, 50);
        }
        _estPickupTimeLabel.text = [NSString stringWithFormat:@"%1.0f Min%@",ceil(time),ceil(time)>1?@"s":@""];
        //[HTUtility showInfo:[NSString stringWithFormat:@"Driver exits with name %@ and will reach in %1.0f minutes",driverFields[@"first_name"],ceil( time)]];
    }else
    {
        //Set default pickup time, already set
    }
}


#pragma mark- Alert view delegate methods
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    self.noServiceAreaInfoView = nil;
    if (alertView.tag == kCommonPlacesFailedTryAgainStringViewTag) {
        if (buttonIndex == 1) {
            [self populateCommonPlaces];
        }
    }else if (alertView.tag == kNetworkErrorStringViewTag)
    {
        if (buttonIndex ==1) {
            [self textFieldDidEndEditing:_locationAddressTF];
        }
    }
}

#pragma mark- Picker methods
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return [[_serviceAreaDictionaryForSelectedPostCode objectForKey:kServiceAreaVehicleTypesKey] count];
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    HTLabel *carNameLabel = [[HTLabel alloc] initWithFrame:CGRectMake(0, 0, [pickerView rowSizeForComponent:component].width, [pickerView rowSizeForComponent:component].height)];
    carNameLabel.text = [[_serviceAreaDictionaryForSelectedPostCode objectForKey:kServiceAreaVehicleTypesKey] objectAtIndex:row];
    carNameLabel.textAlignment = NSTextAlignmentCenter;
    carNameLabel.textColor = [UIColor blackColor];
    carNameLabel.font = [UIFont boldSystemFontOfSize:16];
    return carNameLabel;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    [_vehicleSelectionVehicleNameLabel setText:[[_serviceAreaDictionaryForSelectedPostCode objectForKey:kServiceAreaVehicleTypesKey] objectAtIndex:row]];
    NSString *vehicleDescription = [[_serviceAreaDictionaryForSelectedPostCode objectForKey:kServiceAreaVehicleDescriptionsKey] objectAtIndex:row];
    [_vehicleSelectionVehicleDescriptionLabel setText:[vehicleDescription stringByReplacingOccurrencesOfString:kCommaAlternateString withString:@","]];
}

#pragma mark- Calendar methods

- (void)calendar:(CKCalendarView *)calendar configureDateItem:(CKDateItem *)dateItem forDate:(NSDate *)date {
    NSDateComponents *dateComponents = [[NSCalendar currentCalendar] components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:date];
    
    dateItem.backgroundColor = [UIColor whiteColor];
    dateItem.textColor = [UIColor blackColor];
    dateItem.selectedBackgroundColor = [UIColor colorWithRed:140/255.0 green:144/255.0 blue:145/255.0 alpha:1];
    dateItem.selectedTextColor = [UIColor whiteColor];
    
    if ([self.selectedDatesArray containsObject:dateComponents]) {
        dateItem.backgroundColor = [UIColor colorWithRed:140/255.0 green:144/255.0 blue:145/255.0 alpha:1];
        dateItem.textColor = [UIColor whiteColor];
    }
    
    dateComponents = [[NSCalendar currentCalendar] components:NSCalendarUnitMonth|NSCalendarUnitDay fromDate:date];
    NSDateComponents *todayDateComponents = [[NSCalendar currentCalendar] components:NSCalendarUnitMonth|NSCalendarUnitDay fromDate:[NSDate date]];
    if (dateComponents.month == todayDateComponents.month && dateComponents.day < todayDateComponents.day)
    {
        dateItem.textColor = [UIColor lightGrayColor];
    }
}

- (BOOL)calendar:(CKCalendarView *)calendar willSelectDate:(NSDate *)date {
    NSDateComponents *dateComponents = [[NSCalendar currentCalendar] components:NSCalendarUnitMonth|NSCalendarUnitDay fromDate:date];
    NSDateComponents *todayDateComponents = [[NSCalendar currentCalendar] components:NSCalendarUnitMonth|NSCalendarUnitDay fromDate:[NSDate date]];
    
    if(dateComponents.month == todayDateComponents.month
       && dateComponents.day < todayDateComponents.day)
    {
        return NO;
    }
    return YES;
}

- (void)calendar:(CKCalendarView *)calendar didSelectDate:(NSDate *)date
{
    
    if(date)
    {
        NSDateComponents *dateComponents = [[NSCalendar currentCalendar] components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:date];
        
        if ([self.selectedDatesArray containsObject:dateComponents]) {
            [self.selectedDatesArray removeObject:dateComponents];
            [calendar selectDate:nil makeVisible:YES];
        }else
        {
            [self.selectedDatesArray addObject:dateComponents];
        }
    }
    if (_selectedDatesArray.count > 1) {
        [_calendarDescriptionLabel setText:@"You have selected multiple dates"];
    }else if(_selectedDatesArray.count == 1)
    {
        [_calendarDescriptionLabel setText:@"You have selected one date"];
    }else{
        [_calendarDescriptionLabel setText:@"Select your pickup date"];
    }
    [self updateMinimumDateValue];
}

- (BOOL)calendar:(CKCalendarView *)calendar willChangeToMonth:(NSDate *)date {
    NSInteger todaysMonthValue = [[[NSCalendar currentCalendar] components:NSCalendarUnitMonth fromDate:[NSDate date]] month];
    NSInteger selectedMonthValue = [[[NSCalendar currentCalendar] components:NSCalendarUnitMonth fromDate:date] month];
    
    if (selectedMonthValue == todaysMonthValue || selectedMonthValue%12 == (todaysMonthValue+1)%12) {
        self.calendarView.backgroundColor = [UIColor colorWithRed:140/255.0 green:144/255.0 blue:145/255.0 alpha:1];
        return YES;
    } else {
        self.calendarView.backgroundColor = [UIColor redColor];
        return NO;
    }
}

- (void)calendar:(CKCalendarView *)calendar didLayoutInRect:(CGRect)frame {
    //Layout
}

#pragma mark- Location manager methods
// Location Manager Delegate Methods
- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status{
    if (status != kCLAuthorizationStatusAuthorizedAlways) {
        [HTUtility showInfo:kEnableLocationServices];
    }
}

#pragma mark - Swipe gesture methods

- (IBAction)pickupLocationLeftSwipeRecognized:(UISwipeGestureRecognizer *)sender
{
    [self pickupLocationNextButtonTouched:nil];
}

- (IBAction)destinationLocationRightSwipeRecognized:(UISwipeGestureRecognizer *)sender
{
    [self destinationBackButtonTouched:nil];
}

- (IBAction)destinationLocationLeftSwipeRecognized:(UISwipeGestureRecognizer *)sender
{
    [self destinationNextButtonTouched:nil];
}

- (IBAction)viaLocationRightSwipeRecognized:(UISwipeGestureRecognizer *)sender
{
    [self viaRouteBackButtonTouched:nil];
}

- (IBAction)viaLocationLeftSwipeRecognized:(UISwipeGestureRecognizer *)sender
{
    [self viaRouteNextButtonTouched:nil];
}

@end
