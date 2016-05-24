//
//  HTConstants.m
//  HubbleTaxi
//
//  Created by Aamir Javed on 30/01/2014.
//  Copyright (c) 2014 Apponative. All rights reserved.
//

#import "HTConstants.h"

//Generic Constants
NSString* const kAppName = @"HubbleGo";
NSString* const kOKString = @"OK";
NSString* const kAddString = @"Add";
NSString* const kTryAgainString = @"Try Again";
NSString* const kSendAnotherCodeString = @"Send New Code";
NSString* const kCancelString = @"Cancel";
int const kQBAppID = isPointingToLiveServer?6909:20919;
NSString* const kGMAPIKey = isPointingToLiveServer?@"AIzaSyB2dCEW23MIxSImZzjFnwpfCWSTIgnnLFs": @"AIzaSyAcvL_kDjoGv1Ge_RK0j28PIBen4QfBVTU";
NSString* const kGMServerAPIKey = isPointingToLiveServer?@"AIzaSyCzDpTj8BDMz3iO6c8dVmNGKSkJBbt5oH0": @"AIzaSyCyc4Ci9woiZBgfXp6sZ423YaxBS3BX_Y0";
NSString* const kQBAuthorizationKeyString = isPointingToLiveServer?@"Vd7QgZWFKS8XKVR":@"L72kwcq3FCX6jR7";
NSString* const kQBAuthorizationSecretString = isPointingToLiveServer?@"GtXObNehnC7G7wg":@"CnUnERgUax6TAUm";
NSString* const kQBDefaultPassword = @"QW1234er";
NSString* const kMrTitleString = @"Mr";
NSString* const kMsTitleString = @"Ms";
NSString* const kSearchingAddressString = @"Searching address...";
int const kMapZoomValue = 16.0;
int const kMapNearbySearchRadiusValue = 1000;
NSString* const kPickupLocationTitleString = @"Pickup Locaton";
NSString* const kDestinationLocationTitleString = @"Destination";
NSString* const kCommaAlternateString = @"&#161;";
NSString* const kFacebookAPIKey = isPointingToLiveServer?@"691813980876677":@"1412903509019363";
int const kNearbyServiceAreaDistanceInMeters = 200;
int const kMaximumViaPointsInAJourney = 5;
NSString* const kPriceNoService = @"No Service";
NSString* const kStripePublishableKey = isPointingToLiveServer?@"pk_live_RDIGBw4Qhc1iap20zRzSK9Nc": @"pk_test_iXIVR6C2yxymdtKuw7g9IGM0"; //Change to production key when app is on production
NSString* const kPaymentMethodPayByCashString = @"PAY VIA CASH";
NSString* const kPaymentMethodNoDestinationSelectedString = @"No destination selected";
NSString* const kPaymentMethodPayUsingNewCardString = @"ADD NEW CARD";
NSString* const kPaymentMethodBusinessString = @"Charge: Business ABC";
NSString* const kPaymentMethodDecideLaterString = @"Decide later";
NSString* const kParseAppID = isPointingToLiveServer?@"jFpg3Jm8oxPOog6k4jAoCpJzh9OirObULRMBG5Lb": @"U7tENibGSuOnDE2LWEkT4d31QojaXofKVfgymTAU";
NSString* const kParseClientKey = isPointingToLiveServer?@"ueTl82VBF4yQFxpoTHyjA3xmqzR45xoUOI96kJXf": @"PCv7fnExFe9LpqR4UNAdnzufQKG0uF7JgPsKW9Ow";
int const kOffsetRowsForCardNumbersInTableView = 1;
NSString* const kUserTypeCustomerString = @"customer";
NSString* const kReferenceDateString = @"01-12-2014 00:00";
NSString* const kEnableLocationServices = @"We are unable to detect your location, please ensure that your location services are enabled and try again";

//Info view constants
NSString* const kPhoneNumberMissingString = @"Please enter your mobile number";
NSString* const kPhotosNotAvailableString = @"Oops - we can’t access your photos!";
NSString* const kCameraNotAvailableString = @"Oops - we can't access your camera!";
NSString* const kCTSecrectCodeIsSentToYouPhoneString = @"We just texted you a code to \n%@\n Pop it in below to get started.";
NSString* const kUnableToCreateSessionTryAgainString = @"Seems like there may be a network problem. Check your settings and try again.";
NSString* const kCTUnableToSendSMSTryAgainString = @"We don’t recognise your mobile number. Please re-enter it correctly.";
;
NSString* const kCTSecretCodeDoesNotMatchToUserEnteredString = @"The code you entered doesn't match the one we sent you.";
NSString* const kGetStartedRequestUnSuccessfulString = @"Seems like there may be a network problem. Check your settings and try again.";
NSString* const kLoginRequestFailedAfterGetStartedString = @"Seems like there may be a network problem. Check your settings and try again.";
NSString* const kLogoutRequestUnSuccessfulString = @"Your log out request was unsuccessful, please try again";
NSString* const kDPUploadingFailedTryAgainString = @"Your image didn’t save because of a network problem. Check your settings and try again.";
NSString* const kDPDownloadingFailedTryAgainString = @"Seems like there may be a network problem. Check your settings and try again.";
NSString* const kProfileUploadingFailedTryAgainString = @"Seems like there may be a network problem. Check your settings and try again.";
NSString* const kProfilePersonalInfoDownloadingFailedTryAgainString = @"Seems like there may be a network problem. Check your settings and try again.";
NSString* const kProfileUploadingSuccessfulString = @"Your profile has updated successfully";
NSString* const kDPUploadingSuccessfulString = @"Your display picture has updated successfully";
NSString* const kAddHobbyString = @"Please enter your hobby here.";
NSString* const kNetworkErrorString = @"Seems like there may be a network problem. Check your settings and try again.";
NSString* const kNameTitleMissingString = @"Please select your Title.";
NSString* const kFirstNameMissingString = @"Please enter your first name";
NSString* const kLastNameMissingString = @"Please enter your last name";
NSString* const kAccountInfoEmailMissingString = @"Please enter a valid email address";
NSString* const kAccountInfoEmailNotValidString = @"Your email doesn’t look right. Try re-entering again.";
NSString* const kNoAddressMatchFoundString = @"No address match found. Please try again with alternat keywords.";
NSString* const kUpdateProfileInfoBeforeProceedingString = @"Please update your profile before proceeding to other screens";
NSString* const kUnableToAccessContactsString = @"We are unable to fetch your contacts. Please make sure you have granted permissions to access contacts in privacy settings.";
NSString* const kWaitWhileGettingLocationInfoString = @"Please wait while we are getting your selected location address";
NSString* const kNoFacebookAcountConfiguredString = @"There is no Facebook acounts configured. You can add or create a Facebook account in your device Settings";

//Notification Constants
NSString* const kGetStartedResultNotificationName = @"GetStartedResultNotificationName";
NSString* const kLogoutResultNotificationName = @"LogoutResultNotificationName";
NSString* const kLoginResultNotificationName = @"LoginResultNotificationName";
NSString* const kdpCroppedNotificationName = @"DPCroppedNotification";
NSString* const kApplicationSessionResultNotificationName = @"ApplicationSessionResultNotificationName";
NSString* const kUserSessionResultNotificationName = @"UserSessionResultNotificationName";
NSString* const kCTSecretCodeSendingResultNotificationName = @"CTSecretCodeSendingResultNotificationName";
NSString* const kProfileUploadDPResultNotificationName = @"ProfileUploadDPResultNotificationName";
NSString* const kProfileDownloadDPResultNotificationName = @"ProfileDownloadDPResultNotificationName";
NSString* const kAccountInfoUpdateResultNotificationName = @"AccountInfoUpdateResultNotificationName";
NSString* const kUserAlreadyExistsResultNotificationName = @"UserAlreadyExistsResultNotificationName";
NSString* const kProfilePersonalInformationUpdateResultNotificationName = @"ProfilePersonalInformationUpdateResultNotificationName";
NSString* const kProfilePersonalInfoDownloadNotificationName = @"ProfilePersonalInfoDownloadNotificationName";
NSString* const kAccountInfoChangedNotificationName = @"AccountInfoChangedNotificationName";
NSString* const kDPChangedNotificationName = @"DPChangedNotificationName";
NSString* const kAddressToLocationResultNotificationName = @"AddressToLocationResultNotificationName";
NSString* const kSearchedLocationsResultNotificationName = @"SearchedLocationsResultNotificationName";
NSString* const kSearchedPlaceSelectedNotificationName = @"SearchedPlaceSelectedNotificationName";
NSString* const kServiceAreaFieldsFetchRestultNotificationName = @"ServiceAreaFieldsFetchRestultNotificationName";
NSString* const kDirectionsOfJourneyReceivedRestultNotificationName = @"DirectionsOfJourneyReceivedRestultNotificationName";
NSString* const kCommonPlacesRestultNotificationName = @"CommonPlacesRestultNotificationName";
NSString* const kBookingOrderRestultNotificationName = @"BookingOrderRestultNotificationName";
NSString* const kCurrentDriverProfileDownloadRestultNotificationName = @"CurrentDriverProfileDownloadRestultNotificationName";
NSString* const kSendCustomerInstructionsToDriverRestultNotificationName = @"SendCustomerInstructionsToDriverRestultNotificationName";
NSString* const kJobRatingUpdateRestultNotificationName = @"JobRatingUpdateRestultNotificationName";
NSString* const kBookingJobCreationNotificationName = @"BookingJobCreationNotificationName";
NSString* const kIncrementJobNumberNotificationName = @"IncrementJobNumberNotificationName";
NSString* const kGetDriverNearbyNotificationName = @"GetDriverNearbyNotificationName";
NSString* const kFutureBookingDownloadResultNotificationName = @"FutureBookingDownloadResultNotificationName";
NSString* const kFutureBookingCancelResultNotificationName = @"FutureBookingCancelResultNotificationName";
NSString* const kSecretCodeEnteredNotificationName = @"SecretCodeEnteredNotificationName";
NSString* const kGetAlreadyBookedCurrentJobsNotificationName = @"GetAlreadyBookedCurrentJobsNotificationName";

//Dictionary Keys Constants
NSString* const kResponseSuccessKey = @"ResponseSuccessKey";
NSString* const kResponseErrorKey = @"ResponseErrorKey";
NSString* const kResponseStatusKey = @"ResponseStatusKey";
NSString* const kLoginResultUserKey = @"LoginResultUserKey";
NSString* const kLoggedInUserKey = @"LogedInUserKey";
NSString* const kLoggedInUserIDKey = @"LogedInUserIDKey";
NSString* const kLoggedInUserFullNameKey = @"LogedInUserFullNameKey";
NSString* const kLoggedInUserPhoneNumberKey = @"LogedInUserPhoneNumberKey";
NSString* const kLoggedInUserTitleKey = @"LoggedInUserTitleKey";
NSString* const kLoggedInUserFirstNameKey = @"LoggedInUserFirstNameKey";
NSString* const kLoggedInUserLastNameKey = @"LoggedInUserLastNameKey";
NSString* const kLoggedInUserEmailKey = @"LogedInUserEmailKey";
NSString* const kLoggedInUserDeviceKey = @"LoggedInUserDeviceKey";
NSString* const kLoggedInUserAddressCountryKey = @"LoggedInUserAddressCountryKey";
NSString* const kLoggedInUserAddressPostCodeKey = @"LoggedInUserAddressPostCodeKey";
NSString* const kLoggedInUserAddressLine1Key = @"LoggedInUserAddressLine1Key";
NSString* const kLoggedInUserAddressLine2Key = @"LoggedInUserAddressLine2Key";
NSString* const kLoggedInUserAddressLine3Key = @"LoggedInUserAddressLine3Key";
NSString* const kLoggedInUserAddressCityKey = @"LoggedInUserAddressCityKey";
NSString* const kLoggedInUserAddressStateKey = @"LoggedInUserAddressStateKey";
NSString* const kLoggedInUserHobbiesKey = @"LogedInUserHobbiesKey";
NSString* const kLoggedInUserCardsKey = @"LoggedInUserCardKey";
NSString* const kLoggedInUserCardNumberKey = @"kLoggedInUserCardNumberKey";
NSString* const kLoggedInUserCardCVCKey = @"LoggedInUserCardCVCKey";
NSString* const kLoggedInUserCardExpiryKey = @"LoggedInUserCardExpiryKey";
NSString* const kLoggedInUserGenderKey = @"Gender";
NSString* const kLoggedInUserBirthdayKey = @"Birthday";
NSString* const kLoggedInUserFacebookPageLikesKey = @"FacebookPageLikes";
NSString* const kLoggedInUserDPBlobIDKey = @"LoggedInUserDPBlobIDKey";
NSString* const kLoggedInUserDPImageIDKey = @"LoggedInUserDPImageIDKey";
NSString* const kLoggedInUserSelectedVehicleTypeKey = @"LoggedInUserSelectedVehicleTypeKey";
NSString* const kDPCroppedImageKey = @"kKeyCroppedImage";
NSString* const kDPImageDataKey = @"DPImageDataKey";
NSString* const kCTSecretCodeSendingResultKey = @"CTSecretCodeSendingResultKey";
NSString* const kHobbiesArrayKey = @"HobbiesArrayKey";
NSString* const kLoggedInUserPersonInfoObjectIDKey = @"LoggedInUserPersonInfoObjectIDKey";
NSString* const kProfilePersonalInformationKey = @"ProfilePersonalInformationKey";
NSString* const kProfilePersonalInfoTableTitleKey = @"Title";
NSString* const kProfilePersonalInfoTableFirstNameKey = @"FirstName";
NSString* const kProfilePersonalInfoTableLastNameKey = @"LastName";
NSString* const kProfilePersonalInfoTableAddressCountryKey = @"AddressCountry";
NSString* const kProfilePersonalInfoTableAddressPostCodeKey = @"AddressPostCode";
NSString* const kProfilePersonalInfoTableAddressLine1Key = @"AddressLine1";
NSString* const kProfilePersonalInfoTableAddressLine2Key = @"AddressArea";
NSString* const kProfilePersonalInfoTableAddressLine3Key = @"AddressLine3";
NSString* const kProfilePersonalInfoTableAddressCityKey = @"AddressCity";
NSString* const kProfilePersonalInfoTableAddressStateKey = @"AddressState";
NSString* const kProfilePersonalInfoTableHobbiesKey = @"Hobbies";
NSString* const kLongitudeKey = @"LongitudeKey";
NSString* const kLatitudeKey = @"LatitudeKey";
NSString* const kSearchedPlacesKey = @"SearchedPlacesKey";
NSString* const kSelectedPlaceKey = @"SelectedPlaceKey";
NSString* const kServiceAreaCitiesKey = @"Cities";
NSString* const kServiceAreaCountryKey = @"Country";
NSString* const kServiceAreaPostalCodeKey = @"PostCode";
NSString* const kServiceAreaAllocatedToFirmsKey = @"AllocatedToFirms";
NSString* const kServiceAreaRushHoursKey = @"RushHours";
NSString* const kServiceAreaVehicleTypesKey = @"VehicleTypes";
NSString* const kServiceAreaVehicleDescriptionsKey = @"VehicleDescriptions";
NSString* const kServiceAreaMinimalFaresKey = @"MinimalFares";
NSString* const kServiceAreaStartingFaresKey = @"StartingFares";
NSString* const kServiceAreaWithoutRushRatesKey = @"WithoutRushRates";
NSString* const kServiceAreaRushRatesKey = @"RushRates";
NSString* const kServiceAreaLongDistanceStartsFromKmValueKey = @"LongDistanceStartsFromKmValue";
NSString* const kServiceAreaLongDistanceRatesKey = @"LongDistanceRates";
NSString* const kServiceAreaObjectsKey = @"ServiceAreaObjectsKey";
NSString* const kJobObjectFieldsKey = @"JobObjectFieldsKey";
NSString* const kDriverObjectFieldsKey = @"kDriverObjectFieldsKey";
NSString* const kCommonPlacesObjectsKey = @"CommonPlacesObjectsKey";
NSString* const kMapDirectionsKey = @"MapDirectionsKey";
NSString* const kDriverIDKey = @"driver_id";
NSString* const kJobNumberObjectKey = @"JobNumberObjectKey";

//tags
int const kCTSecretCodeIsSentToYourPhoneStringInfoViewTag = 301;
int const kCTSecretCodeDoesNotMatchToUserEnteredStringInfoViewTag = 302;
int const kUnableToCreateApplicationSessionStringInfoViewTag = 304;
int const kUnableToCreateUserSessionStringInfoViewTag = 305;
int const kLoginRequestFailedAfterGetStartedStringViewTag = 306;
int const kDPUploadingFailedTryAgainStringViewTag = 307;
int const kPersonalInfoUploadingFailedTryAgainStringViewTag = 308;
int const kDPDownloadingFailedTryAgainStringViewTag = 309;
int const kAddHobbyStringViewTag = 310;
int const kNetworkErrorStringViewTag= 311;
int const kProfilePersonalInfoDownloadingFailedTryAgainStringViewTag = 312;
int const kAccountInfoUploadingFailedTryAgainStringViewTag = 313;
int const kPaymentConfirmationEmailInputViewTag = 314;
int const kDeviceInfoUploadingFailedTryAgainStringViewTag = 315;
int const kCommonPlacesFailedTryAgainStringViewTag = 316;
int const kBookingOrderFailedTryAgainViewTag = 317;
int const kCurrentDriverProfileDownladFailedTryAgainViewTag = 318;
int const kJobRatingUpdateFailedTryAgainViewTag = 319;
int const kJobBookingFailedTryAgainViewTag = 320;
int const kFutureBookingDownloadFailedTryAgainViewTag = 321;
int const kJobCancelConfirmationViewTag = 322;
int const kJourneyDirectionsDownloadFailedViewTag = 323;
int const kFutureBookingCancelFailedViewTag = 324;
int const kGetStartedRequestUnSuccessfulViewTag = 325;
int const kSendCustomerInstructionsToDriverFailedViewTag = 326;
int const kChargeUserCardFailedViewTag = 327;
int const kGetAlreadyBookedCurrentJobsFailedViewTag = 328;
int const kGetAlreadyBookedCurrentJobsExistsViewTag = 329;

//Durations
NSTimeInterval const kDefaultViewMovingAnimtionTime = 0.3;
NSTimeInterval const kDriverRefreshTime = 10.0;



