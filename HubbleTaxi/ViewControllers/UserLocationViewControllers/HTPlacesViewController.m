//
//  HTPlacesViewController.m
//  HubbleTaxi
//
//  Created by Aamir Javed on 18/03/2014.
//  Copyright (c) 2014 Apponative. All rights reserved.
//

@interface HTPlace:NSObject
{
    
}
@property (nonatomic, assign)CLLocationCoordinate2D placeLocation;
@property (nonatomic, retain)NSString *placeName;
@property (nonatomic, retain)NSString *placeVicinity;
@property (nonatomic, retain)UIImage *placeImage;
@end

@implementation HTPlace
@end

@interface HTFacebookUserData : NSObject
{
    
}
@property (nonatomic, retain)NSString *gender;
@property (nonatomic, retain)NSString *birthday;
@property (nonatomic, retain)NSArray *pageLikes;
@end

@implementation HTFacebookUserData
@end

#import "HTPlacesViewController.h"
#import "HTUserLocationManager.h"
#import "HTUserProfileManager.h"
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
#import <Social/Social.h>
#import <Accounts/Accounts.h>

@interface HTPlacesViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    
}
@property (weak, nonatomic) IBOutlet HTScrollView *placesSearchOptionsScrollView;
@property (weak, nonatomic) IBOutlet HTButton *nearbyButton;
@property (weak, nonatomic) IBOutlet HTButton *recentButton;
@property (weak, nonatomic) IBOutlet HTButton *favouritiesButton;
@property (weak, nonatomic) IBOutlet HTButton *contactsButton;
@property (weak, nonatomic) IBOutlet HTButton *facebookButton;
@property (weak, nonatomic) IBOutlet HTButton *trainStationButton;
@property (weak, nonatomic) IBOutlet HTButton *airportsButton;
@property (weak, nonatomic) IBOutlet HTButton *restaurantsButton;
@property (weak, nonatomic) IBOutlet HTTextField *placesSearchTF;
@property (weak, nonatomic) IBOutlet HTTableView *searchPlacesTableView;
@property (nonatomic, retain) NSMutableArray *searchedPlacesArray;//array of HTPlace objects
@property (nonatomic, retain) IBOutletCollection(UIButton) NSArray *searchOptionsButtonArray;
@property (nonatomic,retain) id searchNearbyLocationsRequestObject;
@property (nonatomic,retain) id liveSearchLocationsRequestObject;
@property (nonatomic, assign)CLLocationCoordinate2D userLocation;
@property (weak, nonatomic) IBOutlet HTLabel *searchingPlaceLabel;
@property (weak, nonatomic) IBOutlet HTLabel *dataNotFoundLabel;
@property (nonatomic,retain) HTFacebookUserData *facebookUserData;
@property (nonatomic, retain) NSString *suffixForLiveLocalSearchNotificationName;
@property (weak, nonatomic) IBOutlet HTImageView *poweredByGoogleIV;


- (IBAction)nearbyButtonTouched:(HTButton *)sender;
- (IBAction)recentButtonTouched:(HTButton *)sender;
- (IBAction)favouritiesButtonTouched:(HTButton *)sender;
- (IBAction)contactsButtonTouched:(HTButton *)sender;
- (IBAction)facebookButtonTouched:(HTButton *)sender;
- (IBAction)trainStationButtonTouched:(HTButton *)sender;
- (IBAction)airportsButtonTouched:(HTButton *)sender;
- (IBAction)restaurantsButtonTouched:(HTButton *)sender;
- (IBAction)crossButtonTouched:(HTButton *)sender;

- (void)showSearchingView;
- (void)showNoDataView;
- (void)saveFacebookDataWithAccount:(ACAccount*)facebookAccount;
- (void)searchLocationWithActionOnButton:(HTButton*)button searchType:(NSString*)searchType;
- (void)deselectAllSearchButtonsExceptButton:(HTButton*)selectedButton;
- (NSString*)notificationNameForLiveLocalSearch:(NSString*)liveSearchNotificationName;

- (void)onSearchedLocationsResultNotification:(NSNotification*)notification;
- (void)onPersonalInformationDownloadResultNotification:(NSNotification*)notification;
- (void)onPersonalInformationUpdateResultNotification:(NSNotification*)notification;

@end

@implementation HTPlacesViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.searchedPlacesArray = [[NSMutableArray alloc] init];
        self.suffixForLiveLocalSearchNotificationName = @"Local";
    }
    return self;
}

- (id)initWithUserLocation:(CLLocationCoordinate2D)userLocation
{
    self = [super init];
    if (self) {
        // Custom initialization
        self.searchedPlacesArray = [[NSMutableArray alloc] init];
        self.suffixForLiveLocalSearchNotificationName = @"Local";
        self.userLocation = userLocation;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    _placesSearchOptionsScrollView.contentSize = CGSizeMake(_restaurantsButton.frame.origin.x+_restaurantsButton.frame.size.width,_placesSearchOptionsScrollView.frame.size.height);
    [self nearbyButtonTouched:nil];
    self.view.backgroundColor = [UIColor colorWithRed:207/255.0 green:211/255.0 blue:203/255.0 alpha:1];
    self.searchPlacesTableView.tableFooterView = [[UIView alloc] init];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)deselectAllSearchButtonsExceptButton:(HTButton*)selectedButton
{
    for (HTButton *button in _searchOptionsButtonArray) {
        button.selected = YES;
        if (button != selectedButton) {
            button.selected = NO;
        }
    }
}

- (NSString*)notificationNameForLiveLocalSearch:(NSString*)liveSearchNotificationName
{
    return [liveSearchNotificationName stringByAppendingString:_suffixForLiveLocalSearchNotificationName];
}

- (void)populatePersonAdresses
{
    [self deselectAllSearchButtonsExceptButton:_contactsButton];
    [_searchingPlaceLabel setHidden:NO];
    [_searchedPlacesArray removeAllObjects];
    [_searchPlacesTableView reloadData];
    [HTUtility removeNotificationObserver:self withNotificationName:kSearchedLocationsResultNotificationName];
    [HTUtility removeNotificationObserver:self withNotificationName:[self notificationNameForLiveLocalSearch:kSearchedLocationsResultNotificationName]];
    [_liveSearchLocationsRequestObject cancelAllOperations];
    [_searchNearbyLocationsRequestObject cancelAllOperations];
    CFErrorRef *error = nil;
    
    
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, error);
    
    __block BOOL accessGranted = NO;
    if (ABAddressBookRequestAccessWithCompletion != NULL) { // we're on iOS 6
        dispatch_semaphore_t sema = dispatch_semaphore_create(0);
        ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
            accessGranted = granted;
            dispatch_semaphore_signal(sema);
        });
        dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
        
    }
    else { // we're on iOS 5 or older
        accessGranted = YES;
    }
    
    if (addressBook != nil) {
        NSArray *allContacts = (__bridge_transfer NSArray *)ABAddressBookCopyArrayOfAllPeople(addressBook);
        HTPlace *contactPlace = nil;
        NSUInteger i = 0; for (i = 0; i < [allContacts count]; i++)
        {
            ABRecordRef contactPerson = (__bridge ABRecordRef)allContacts[i];
            NSString *firstName = (__bridge_transfer NSString *)ABRecordCopyValue(contactPerson, kABPersonFirstNameProperty);
            NSString *lastName = (__bridge_transfer NSString *)ABRecordCopyValue(contactPerson, kABPersonLastNameProperty);
            NSString *fullName = [NSString stringWithFormat:@"%@ %@", firstName.length>0?firstName:@"", lastName.length>0?lastName:@""];
            fullName = fullName.length>1?fullName:@"No Name";
            
            ABMultiValueRef addressRef = ABRecordCopyValue(contactPerson, kABPersonAddressProperty);
            if (ABMultiValueGetCount(addressRef) > 0) {
                NSDictionary *addressDict = (__bridge NSDictionary *)ABMultiValueCopyValueAtIndex(addressRef, 0);
                NSString *street = [addressDict objectForKey:(NSString *)kABPersonAddressStreetKey];
                NSString *city = [addressDict objectForKey:(NSString *)kABPersonAddressCityKey];
                NSString *state = [addressDict objectForKey:(NSString *)kABPersonAddressStateKey];
                NSString *zipCode = [addressDict objectForKey:(NSString *)kABPersonAddressZIPKey];
                NSString *country = [addressDict objectForKey:(NSString *)kABPersonAddressCountryKey];
                NSString *countryCode = [addressDict objectForKey:(NSString *)kABPersonAddressCountryCodeKey];
                
                NSString *addressString = [NSString stringWithFormat:@"%@ %@ %@ %@ %@ %@",
                                           street?street:@"",
                                           city?city:@"",
                                           state?state:@"",
                                           zipCode?zipCode:@"",
                                           country?country:@"",
                                           countryCode?countryCode:@""];
                
                contactPlace = [[HTPlace alloc] init];
                contactPlace.placeName = fullName;
                contactPlace.placeVicinity = addressString;
                contactPlace.placeImage = [UIImage imageNamed:@"icon_contact.png"];
                [_searchedPlacesArray addObject:contactPlace];
            }
            CFRelease(addressRef);
        }
        CFRelease(addressBook);
        [_searchingPlaceLabel setHidden:YES];
        _dataNotFoundLabel.hidden = _searchedPlacesArray.count>0;
        [_searchPlacesTableView reloadData];
    } else {
        [HTUtility showInfo:kUnableToAccessContactsString];
    }
}


- (IBAction)nearbyButtonTouched:(HTButton *)sender
{
    _poweredByGoogleIV.hidden = NO;
    [self searchLocationWithActionOnButton:_nearbyButton searchType:nil];
}

- (IBAction)recentButtonTouched:(HTButton *)sender {
    //Implement later
}

- (IBAction)favouritiesButtonTouched:(HTButton *)sender {
    //Implement later
}

- (IBAction)contactsButtonTouched:(HTButton *)sender
{
    _poweredByGoogleIV.hidden = YES;
    [self populatePersonAdresses];
}

- (IBAction)facebookButtonTouched:(HTButton *)sender
{
    _poweredByGoogleIV.hidden = YES;

    [self deselectAllSearchButtonsExceptButton:_facebookButton];
    [self showSearchingView];
    [_searchedPlacesArray removeAllObjects];
    [_searchPlacesTableView reloadData];
    [HTUtility removeNotificationObserver:self withNotificationName:kSearchedLocationsResultNotificationName];
    [HTUtility removeNotificationObserver:self withNotificationName:[self notificationNameForLiveLocalSearch:kSearchedLocationsResultNotificationName]];
    [_liveSearchLocationsRequestObject cancelAllOperations];
    [_searchNearbyLocationsRequestObject cancelAllOperations];
    
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook]) {
        ACAccountStore *accountStore = [[ACAccountStore alloc] init];
        ACAccountType *accountTypeFacebook = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierFacebook];
        NSDictionary *options = @{ACFacebookAppIdKey: kFacebookAPIKey, ACFacebookPermissionsKey:@[@"email",@"user_about_me",@"user_likes",@"user_events"],
                                  ACFacebookAudienceKey: ACFacebookAudienceEveryone };
        [accountStore requestAccessToAccountsWithType:accountTypeFacebook options:options completion:^(BOOL granted, NSError *error) {
            if(granted)
            {
                NSArray *accounts = [accountStore accountsWithAccountType:accountTypeFacebook];
                if (accounts.count>0) {
                    ACAccount *facebookAccount = [accounts lastObject];
                    [self saveFacebookDataWithAccount:facebookAccount];
                    
                    NSString *acessToken = [NSString stringWithFormat:@"%@",facebookAccount.credential.oauthToken];
                    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:@"name,location",@"fields",acessToken,@"access_token", nil];
                    NSURL *feedURL = [NSURL URLWithString:@"https://graph.facebook.com/me/events"];
                    SLRequest *feedRequest = [SLRequest requestForServiceType:SLServiceTypeFacebook requestMethod:SLRequestMethodGET URL:feedURL parameters:params];
                    feedRequest.account = facebookAccount;
                    [feedRequest performRequestWithHandler:^(NSData *responseData,
                                                             NSHTTPURLResponse *urlResponse, NSError *error)
                     {
                         if(!error)
                         {
                             NSDictionary *json =[NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:&error];
                             
                             if([json objectForKey:@"error"]!=nil)
                             {
                                 [self showNoDataView];
                             }else{
                                 NSArray *events = [json objectForKey:@"data"];
                                 if (events.count>0 && _facebookButton.selected)
                                 {
                                     HTPlace *place= nil;
                                     for (NSDictionary *event in events) {
                                         place = [[HTPlace alloc] init];
                                         place.placeName = [event objectForKey:@"name"];
                                         place.placeVicinity = [event objectForKey:@"location"];
                                         [_searchedPlacesArray addObject:place];
                                     }
                                     dispatch_async(dispatch_get_main_queue(), ^{
                                         if (_facebookButton.selected) {
                                             [_searchingPlaceLabel setHidden:YES];
                                             [_searchPlacesTableView reloadData];
                                         }
                                     });
                                 }else{
                                     [self showNoDataView];
                                 }
                             }
                         }else
                         {
                             [self showNoDataView];
                         }
                     }];
                }else{
                    [self showNoDataView];
                }
            }else
            {
                [self showNoDataView];
            }
        }];
        }else{
            [self showNoDataView];
            [HTUtility showInfo:kNoFacebookAcountConfiguredString];
        }
}

- (IBAction)trainStationButtonTouched:(HTButton *)sender
{
    _poweredByGoogleIV.hidden = NO;

    [self searchLocationWithActionOnButton:_trainStationButton searchType:@"train_station"];
}

- (IBAction)airportsButtonTouched:(HTButton *)sender
{
    _poweredByGoogleIV.hidden = NO;

    [self searchLocationWithActionOnButton:_airportsButton searchType:@"airport"];
}

- (IBAction)restaurantsButtonTouched:(HTButton *)sender
{
    _poweredByGoogleIV.hidden = NO;

    [self searchLocationWithActionOnButton:_restaurantsButton searchType:@"restaurant"];
}

- (IBAction)crossButtonTouched:(HTButton *)sender {
    [HTUtility postNotificationWithName:kSearchedPlaceSelectedNotificationName userInfo:nil];
}

- (void)showSearchingView
{
    dispatch_async(dispatch_get_main_queue(), ^{
        _searchingPlaceLabel.hidden = NO;
        _dataNotFoundLabel.hidden = YES;
    });
}

- (void)showNoDataView
{
    dispatch_async(dispatch_get_main_queue(), ^{
        _searchingPlaceLabel.hidden = YES;
        _dataNotFoundLabel.hidden = NO;
    });
}

- (void)saveFacebookDataWithAccount:(ACAccount*)facebookAccount
{
    NSString *acessToken = [NSString stringWithFormat:@"%@",facebookAccount.credential.oauthToken];
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:@"birthday,gender,likes",@"fields",acessToken,@"access_token", nil];
    NSURL *feedURL = [NSURL URLWithString:@"https://graph.facebook.com/me"];
    SLRequest *feedRequest = [SLRequest requestForServiceType:SLServiceTypeFacebook requestMethod:SLRequestMethodGET URL:feedURL parameters:params];
    feedRequest.account = facebookAccount;
    [feedRequest performRequestWithHandler:^(NSData *responseData,
                                             NSHTTPURLResponse *urlResponse, NSError *error)
     {
         if(!error)
         {
             NSDictionary *json =[NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:&error];
             NSString *gender  = [json objectForKey:@"gender"];
             NSString *birthday = [json objectForKey:@"birthday"];
             NSArray *likes = [[json objectForKey:@"likes"] objectForKey:@"data"];
             NSMutableArray *pageLikes = [[NSMutableArray alloc] init];
             for (NSDictionary *like in likes) {
                 NSString *pageName = [like objectForKey:@"name"];
                 [pageLikes addObject:pageName!=nil?pageName:@""];
             }
             if (gender || birthday || pageLikes.count>0)
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
                             self.facebookUserData = [[HTFacebookUserData alloc] init];
                             _facebookUserData.gender = gender;
                             _facebookUserData.birthday = birthday;
                             _facebookUserData.pageLikes = pageLikes;
                             
                             [self showFullScreenAcitvityIndicatorView];
                             [HTUtility addNotificationObserver:self selector:@selector(onPersonalInformationDownloadResultNotification:) forNotificationWithName:kProfilePersonalInfoDownloadNotificationName];
                             id networkOjbect = [[HTUserProfileManager sharedManager] downloadPersonalInformationWithCompletionNotificationName:kProfilePersonalInfoDownloadNotificationName];
                             [self performingNetworkCallWithObject:networkOjbect forNotificationName:kProfilePersonalInfoDownloadNotificationName];
                         }else
                         {
                             //Handled in renewSession class
                         }
                     }
                 }];
             }
         }
     }];
}

- (void)searchLocationWithActionOnButton:(HTButton*)button searchType:(NSString*)searchType
{
    [_searchedPlacesArray removeAllObjects];
    [_searchPlacesTableView reloadData];
    _searchingPlaceLabel.hidden = NO;
    _dataNotFoundLabel.hidden = YES;
    [self deselectAllSearchButtonsExceptButton:button];
    [HTUtility removeNotificationObserver:self withNotificationName:kSearchedLocationsResultNotificationName];
    [HTUtility removeNotificationObserver:self withNotificationName:[self notificationNameForLiveLocalSearch:kSearchedLocationsResultNotificationName]];
    [_liveSearchLocationsRequestObject cancelAllOperations];
    [_searchNearbyLocationsRequestObject cancelAllOperations];
    [HTUtility addNotificationObserver:self selector:@selector(onSearchedLocationsResultNotification:) forNotificationWithName:kSearchedLocationsResultNotificationName];
    
    NSInteger radius = button==_nearbyButton?kMapNearbySearchRadiusValue:0;
    self.searchNearbyLocationsRequestObject = [[HTUserLocationManager sharedManager] searchNearbyPlacesFromLatitude:_userLocation.latitude longitude:_userLocation.longitude nearbyRadius:radius searchType:searchType completionNotificationName:kSearchedLocationsResultNotificationName];
}

#pragma mark- Text field
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString *queryString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    if (queryString.length>0) {
        [_searchedPlacesArray removeAllObjects];
        [_searchPlacesTableView reloadData];
        _searchingPlaceLabel.hidden = NO;
        [self deselectAllSearchButtonsExceptButton:nil];
        [HTUtility removeNotificationObserver:self withNotificationName:kSearchedLocationsResultNotificationName];
        [HTUtility removeNotificationObserver:self withNotificationName:[self notificationNameForLiveLocalSearch:kSearchedLocationsResultNotificationName]];
        [_searchNearbyLocationsRequestObject cancelAllOperations];
        [_liveSearchLocationsRequestObject cancelAllOperations];
        
        //For live local search
        [HTUtility addNotificationObserver:self selector:@selector(onSearchedLocationsResultNotification:) forNotificationWithName:[self notificationNameForLiveLocalSearch:kSearchedLocationsResultNotificationName]];
        self.liveSearchLocationsRequestObject = [[HTUserLocationManager sharedManager] livePlaceSearchWithQueryText:queryString fromLatitude:_userLocation.latitude longitude:_userLocation.longitude nearbyRadius:kMapNearbySearchRadiusValue completionNotificationName:[self notificationNameForLiveLocalSearch:kSearchedLocationsResultNotificationName]];
    }
    return YES;
}

#pragma mark- Table view methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_searchedPlacesArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString* cellIdentifier = @"CELL_ID";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell =     [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
        cell.backgroundColor = [UIColor clearColor];
    }
    HTPlace *place = [_searchedPlacesArray objectAtIndex:indexPath.row];
    cell.textLabel.text = place.placeName;
    cell.detailTextLabel.text = place.placeVicinity;
    cell.imageView.image = place.placeImage;
    [tableView setSeparatorInset:UIEdgeInsetsZero];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    HTPlace *selectedPlace = [_searchedPlacesArray objectAtIndex:indexPath.row];
    NSDictionary *notifyDictionary = nil;
    if (selectedPlace.placeLocation.latitude) {
        notifyDictionary = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithFloat:selectedPlace.placeLocation.latitude],kLatitudeKey,[NSNumber numberWithFloat:selectedPlace.placeLocation.longitude],kLongitudeKey,selectedPlace.placeVicinity,kSelectedPlaceKey, nil];

    }else
    {
        notifyDictionary = [NSDictionary dictionaryWithObjectsAndKeys:selectedPlace.placeVicinity,kSelectedPlaceKey, nil];

    }
    [HTUtility postNotificationWithName:kSearchedPlaceSelectedNotificationName userInfo:notifyDictionary];
}

#pragma mark- Notification methods
- (void)onSearchedLocationsResultNotification:(NSNotification*)notification
{
    _liveSearchLocationsRequestObject = nil;
    _searchNearbyLocationsRequestObject = nil;
    NSDictionary *notifyDictionary = [notification userInfo];
    BOOL success = [[notifyDictionary objectForKey:kResponseSuccessKey] boolValue];
    if (success) {
        [HTUtility removeNotificationObserver:self withNotificationName:notification.name];
        NSArray *totalSearchedPlaces = [notifyDictionary objectForKey:kSearchedPlacesKey];
        if ([totalSearchedPlaces isKindOfClass:[NSArray class]] && totalSearchedPlaces.count>0) {
            
            if([notification.name hasSuffix:_suffixForLiveLocalSearchNotificationName])
            {
                totalSearchedPlaces = [totalSearchedPlaces subarrayWithRange:NSMakeRange(0, MIN(5, totalSearchedPlaces.count))];
            }
            HTPlace *searchedPlace = nil;
            CLLocationDegrees lat=0,lng= 0;
            NSArray *types = nil;
            for (NSDictionary *dictionary in totalSearchedPlaces) {
                searchedPlace = [[HTPlace alloc] init];
                searchedPlace.placeName = [dictionary objectForKey:@"name"];
                searchedPlace.placeVicinity = [dictionary objectForKey:@"vicinity"];
                if (searchedPlace.placeVicinity.length < 1) {
                    searchedPlace.placeVicinity = [dictionary objectForKey:@"formatted_address"];
                }
                lat = [[[[dictionary objectForKey:@"geometry"] objectForKey:@"location"] objectForKey:@"lat"] floatValue];
                lng = [[[[dictionary objectForKey:@"geometry"] objectForKey:@"location"] objectForKey:@"lng"] floatValue];
                searchedPlace.placeLocation = CLLocationCoordinate2DMake(lat, lng);
                types = [dictionary objectForKey:@"types"];
                if ([types containsObject:@"train_station"] || [types containsObject:@"bus_station"])
                {
                    searchedPlace.placeImage = [UIImage imageNamed:@"train.png"];
                }else if([types containsObject:@"restaurants"] || [types containsObject:@"food"] || [types containsObject:@"bakery"] || [types containsObject:@"cafe"] || [types containsObject:@"lodging"] || [types containsObject:@"meal_delivery"] || [types containsObject:@"meal_takeaway"])
                {
                    searchedPlace.placeImage = [UIImage imageNamed:@"restaurant.png"];
                }
                else if ([types containsObject:@"airport"])
                {
                    searchedPlace.placeImage = [UIImage imageNamed:@"airport.png"];
                }
                else if ([types containsObject:@"university"] || [types containsObject:@"school"] )
                {
                    searchedPlace.placeImage = [UIImage imageNamed:@"school.png"];
                }
                else if ([types containsObject:@"hospital"] || [types containsObject:@"pharmacy"] || [types containsObject:@"doctor"] || [types containsObject:@"dentist"] || [types containsObject:@"physiotherapist"])
                {
                    searchedPlace.placeImage = [UIImage imageNamed:@"hospital.png"];
                }else
                {
                    searchedPlace.placeImage = [UIImage imageNamed:@"common_place.png"];
                }
                
                NSPredicate *predicate = [NSPredicate predicateWithFormat:@"placeName=%@",searchedPlace.placeName];
                NSArray *filteredArray = [_searchedPlacesArray filteredArrayUsingPredicate:predicate];
                if (filteredArray.count == 0) {
                    [_searchedPlacesArray addObject:searchedPlace];
                }
            }
            if([notification.name hasSuffix:_suffixForLiveLocalSearchNotificationName])
            {
                [HTUtility addNotificationObserver:self selector:@selector(onSearchedLocationsResultNotification:) forNotificationWithName:kSearchedLocationsResultNotificationName];
                self.liveSearchLocationsRequestObject = [[HTUserLocationManager sharedManager] livePlaceSearchWithQueryText:_placesSearchTF.text fromLatitude:0 longitude:0 nearbyRadius:0 completionNotificationName:kSearchedLocationsResultNotificationName];
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            _searchingPlaceLabel.hidden = YES;
            _dataNotFoundLabel.hidden = _searchedPlacesArray.count>0;
            [_searchPlacesTableView reloadData];
        });
    }else
    {
        NSString *errorString = [notifyDictionary objectForKey:kResponseErrorKey];
        if (![errorString isEqualToString:kCancelString]) {
            [HTUtility removeNotificationObserver:self withNotificationName:notification.name];
        }
    }
}

- (void)onPersonalInformationDownloadResultNotification:(NSNotification*)notification
{
    [self hideFullScreenAcitvityIndicatorView];
    [HTUtility removeNotificationObserver:self withNotificationName:notification.name];
    [self networkCallFinishedForNotificationName:notification.name];
    NSDictionary *personalInfoDonwloadResultDictionary = [notification userInfo];
    BOOL success = [[personalInfoDonwloadResultDictionary objectForKey:kResponseSuccessKey] boolValue];
    if (success)
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
                    NSDictionary *personalInfo = [personalInfoDonwloadResultDictionary objectForKey:kProfilePersonalInformationKey];
                    
                    [HTUtility addNotificationObserver:self selector:@selector(onPersonalInformationUpdateResultNotification:) forNotificationWithName:kProfilePersonalInformationUpdateResultNotificationName];
                    NSMutableDictionary *userProfileDictionary = [NSMutableDictionary dictionaryWithDictionary:personalInfo];
                    NSArray *hobbiesArray = [personalInfo objectForKey:kLoggedInUserHobbiesKey];
                    NSArray *hobbiesArrayToSave = [[hobbiesArray isKindOfClass:[NSArray class]]?hobbiesArray:[NSArray alloc] init];
                    [userProfileDictionary setObject:hobbiesArrayToSave forKey:kLoggedInUserHobbiesKey];
                    [userProfileDictionary setObject:_facebookUserData.gender?_facebookUserData.gender:@"" forKey:kLoggedInUserGenderKey];
                    [userProfileDictionary setObject:_facebookUserData.birthday?_facebookUserData.birthday:@"" forKey:kLoggedInUserBirthdayKey];
                    [userProfileDictionary setObject:_facebookUserData.pageLikes?_facebookUserData.pageLikes:[[NSArray alloc] init] forKey:kLoggedInUserFacebookPageLikesKey];
                    
                    NSString *personalInfoIDObject = [[[HTUserProfileManager sharedManager] currentUserProfile] objectForKey:kLoggedInUserPersonInfoObjectIDKey];
                    [userProfileDictionary setObject:personalInfoIDObject.length>0?personalInfoIDObject:@"" forKey:kLoggedInUserPersonInfoObjectIDKey];
                    id networkOjbect = [[HTUserProfileManager sharedManager] updatePersonInformationWithDictionary:userProfileDictionary completionNotificationName:kProfilePersonalInformationUpdateResultNotificationName];
                    [self performingNetworkCallWithObject:networkOjbect forNotificationName:kProfilePersonalInformationUpdateResultNotificationName];
                }else
                {
                    //Handled in renewSession class
                }
            }
        }];
    }else{
        //No other error handling for saving facebook data
    }
}

- (void)onPersonalInformationUpdateResultNotification:(NSNotification*)notification
{
    [self hideFullScreenAcitvityIndicatorView];
    [HTUtility removeNotificationObserver:self withNotificationName:notification.name];
    [self networkCallFinishedForNotificationName:notification.name];
    //No other error handling for saving facebook data
}
@end
