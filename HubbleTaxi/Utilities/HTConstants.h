//
//  HTConstants.h
//  HubbleTaxi
//
//  Created by Aamir Javed on 30/01/2014.
//  Copyright (c) 2014 Apponative. All rights reserved.
//

#import <Foundation/Foundation.h>

//Generic Constants
extern NSString* const kAppName;
extern NSString* const kOKString;
extern NSString* const kAddString;
extern NSString* const kTryAgainString;
extern NSString* const kSendAnotherCodeString;
extern NSString* const kCancelString;
extern int const kQBAppID;
extern NSString* const kGMAPIKey;
NSString* const kGMServerAPIKey;
extern NSString* const kQBAuthorizationKeyString;
extern NSString* const kQBAuthorizationSecretString;
extern NSString* const kQBDefaultPassword;
extern NSString* const kQBDefaultPassword;
extern NSString* const kMrTitleString;
extern NSString* const kMsTitleString;
extern NSString* const kSearchingAddressString;
extern int const kMapZoomValue;
extern int const kMapNearbySearchRadiusValue;
extern NSString* const kPickupLocationTitleString;
extern NSString* const kDestinationLocationTitleString;
extern NSString* const kCommaAlternateString;
extern NSString* const kFacebookAPIKey;
extern int const kNearbyServiceAreaDistanceInMeters;
extern int const kMaximumViaPointsInAJourney;
extern NSString* const kPriceNoService;
extern NSString* const kStripePublishableKey;
extern NSString* const kPaymentMethodPayByCashString;
extern NSString* const kPaymentMethodNoDestinationSelectedString;
extern NSString* const kPaymentMethodPayUsingNewCardString;
extern NSString* const kPaymentMethodBusinessString;
extern NSString* const kPaymentMethodDecideLaterString;
extern NSString* const kParseAppID;
extern NSString* const kParseClientKey;
extern int const kOffsetRowsForCardNumbersInTableView;
extern NSString* const kUserTypeCustomerString;
extern NSString* const kReferenceDateString;
extern NSString* const kEnableLocationServices;

//Info View Constants
extern NSString* const kPhoneNumberMissingString;
extern NSString* const kPhotosNotAvailableString;
extern NSString* const kCameraNotAvailableString;
extern NSString* const kCTSecrectCodeIsSentToYouPhoneString;
extern NSString* const kUnableToCreateSessionTryAgainString;
extern NSString* const kCTUnableToSendSMSTryAgainString;
extern NSString* const kCTSecretCodeDoesNotMatchToUserEnteredString;
extern NSString* const kGetStartedRequestUnSuccessfulString;
extern NSString* const kLoginRequestFailedAfterGetStartedString;
extern NSString* const kLogoutRequestUnSuccessfulString;
extern NSString* const kDPUploadingFailedTryAgainString;
extern NSString* const kProfileUploadingFailedTryAgainString;
extern NSString* const kProfilePersonalInfoDownloadingFailedTryAgainString;
extern NSString* const kProfileUploadingSuccessfulString;
extern NSString* const kDPUploadingSuccessfulString;
extern NSString* const kDPDownloadingFailedTryAgainString;
extern NSString* const kAddHobbyString;
extern NSString* const kNetworkErrorString;
extern NSString* const kNameTitleMissingString;
extern NSString* const kFirstNameMissingString;
extern NSString* const kLastNameMissingString;
extern NSString* const kAccountInfoEmailMissingString;
extern NSString* const kAccountInfoEmailNotValidString;
extern NSString* const kNoAddressMatchFoundString;
extern NSString* const kUpdateProfileInfoBeforeProceedingString;
extern NSString* const kUnableToAccessContactsString;
extern NSString* const kWaitWhileGettingLocationInfoString;
extern NSString* const kNoFacebookAcountConfiguredString;

//Notification Constants
extern NSString* const kGetStartedResultNotificationName;
extern NSString* const kLogoutResultNotificationName;
extern NSString* const kLoginResultNotificationName;
extern NSString* const kdpCroppedNotificationName;
extern NSString* const kApplicationSessionResultNotificationName;
extern NSString* const kUserSessionResultNotificationName;
extern NSString* const kCTSecretCodeSendingResultNotificationName;
extern NSString* const kProfileUploadDPResultNotificationName;
extern NSString* const kProfileDownloadDPResultNotificationName;
extern NSString* const kAccountInfoUpdateResultNotificationName;
extern NSString* const kUserAlreadyExistsResultNotificationName;
extern NSString* const kProfilePersonalInformationUpdateResultNotificationName;
extern NSString* const kProfilePersonalInfoDownloadNotificationName;
extern NSString* const kAccountInfoChangedNotificationName;
extern NSString* const kDPChangedNotificationName;
extern NSString* const kAddressToLocationResultNotificationName;
extern NSString* const kSearchedLocationsResultNotificationName;
extern NSString* const kSearchedPlaceSelectedNotificationName;
extern NSString* const kServiceAreaFieldsFetchRestultNotificationName;
extern NSString* const kDirectionsOfJourneyReceivedRestultNotificationName;
extern NSString* const kCommonPlacesRestultNotificationName;
extern NSString* const kBookingOrderRestultNotificationName;
extern NSString* const kCurrentDriverProfileDownloadRestultNotificationName;
extern NSString* const kSendCustomerInstructionsToDriverRestultNotificationName;
extern NSString* const kJobRatingUpdateRestultNotificationName;
extern NSString* const kBookingJobCreationNotificationName;
extern NSString* const kIncrementJobNumberNotificationName;
extern NSString* const kGetDriverNearbyNotificationName;
extern NSString* const kFutureBookingDownloadResultNotificationName;
extern NSString* const kFutureBookingCancelResultNotificationName;
extern NSString* const kSecretCodeEnteredNotificationName;
extern NSString* const kGetAlreadyBookedCurrentJobsNotificationName;

//Dictionary Keys Constants
extern NSString* const kResponseSuccessKey;
extern NSString* const kResponseErrorKey;
extern NSString* const kResponseStatusKey;
extern NSString* const kLoginResultUserKey;
extern NSString* const kLoggedInUserKey;
extern NSString* const kLoggedInUserIDKey;
extern NSString* const kLoggedInUserFullNameKey;
extern NSString* const kLoggedInUserPhoneNumberKey;
extern NSString* const kLoggedInUserTitleKey;
extern NSString* const kLoggedInUserFirstNameKey;
extern NSString* const kLoggedInUserLastNameKey;
extern NSString* const kLoggedInUserEmailKey;
extern NSString* const kLoggedInUserDeviceKey;
extern NSString* const kLoggedInUserAddressCountryKey;
extern NSString* const kLoggedInUserAddressPostCodeKey;
extern NSString* const kLoggedInUserAddressLine1Key;
extern NSString* const kLoggedInUserAddressLine2Key;
extern NSString* const kLoggedInUserAddressLine3Key;
extern NSString* const kLoggedInUserAddressCityKey;
extern NSString* const kLoggedInUserAddressStateKey;
extern NSString* const kLoggedInUserHobbiesKey;
extern NSString* const kLoggedInUserCardsKey;
extern NSString* const kLoggedInUserCardNumberKey;
extern NSString* const kLoggedInUserCardCVCKey;
extern NSString* const kLoggedInUserCardExpiryKey;
extern NSString* const kLoggedInUserGenderKey;
extern NSString* const kLoggedInUserBirthdayKey;
extern NSString* const kLoggedInUserFacebookPageLikesKey;
extern NSString* const kLoggedInUserDPBlobIDKey;
extern NSString* const kLoggedInUserDPImageIDKey;
extern NSString* const kLoggedInUserSelectedVehicleTypeKey;
extern NSString* const kDPCroppedImageKey;
extern NSString* const kDPImageDataKey;
extern NSString* const kCTSecretCodeSendingResultKey;
extern NSString* const kHobbiesArrayKey;
extern NSString* const kLoggedInUserPersonInfoObjectIDKey;
extern NSString* const kProfilePersonalInformationKey;
extern NSString* const kProfilePersonalInfoTableTitleKey;
extern NSString* const kProfilePersonalInfoTableFirstNameKey;
extern NSString* const kProfilePersonalInfoTableLastNameKey;
extern NSString* const kProfilePersonalInfoTableAddressCountryKey;
extern NSString* const kProfilePersonalInfoTableAddressPostCodeKey;
extern NSString* const kProfilePersonalInfoTableAddressLine1Key;
extern NSString* const kProfilePersonalInfoTableAddressLine2Key;
extern NSString* const kProfilePersonalInfoTableAddressLine3Key;
extern NSString* const kProfilePersonalInfoTableAddressCityKey;
extern NSString* const kProfilePersonalInfoTableAddressStateKey;
extern NSString* const kProfilePersonalInfoTableHobbiesKey;
extern NSString* const kLongitudeKey;
extern NSString* const kLatitudeKey;
extern NSString* const kSearchedPlacesKey;
extern NSString* const kSelectedPlaceKey;
extern NSString* const kServiceAreaCitiesKey;
extern NSString* const kServiceAreaCountryKey;
extern NSString* const kServiceAreaPostalCodeKey;
extern NSString* const kServiceAreaAllocatedToFirmsKey;
extern NSString* const kServiceAreaRushHoursKey;
extern NSString* const kServiceAreaVehicleTypesKey;
extern NSString* const kServiceAreaVehicleDescriptionsKey;
extern NSString* const kServiceAreaMinimalFaresKey;
extern NSString* const kServiceAreaStartingFaresKey;
extern NSString* const kServiceAreaWithoutRushRatesKey;
extern NSString* const kServiceAreaRushRatesKey;
extern NSString* const kServiceAreaLongDistanceStartsFromKmValueKey;
extern NSString* const kServiceAreaLongDistanceRatesKey;
extern NSString* const kServiceAreaObjectsKey;
extern NSString* const kJobObjectFieldsKey;
extern NSString* const kDriverObjectFieldsKey;
extern NSString* const kCommonPlacesObjectsKey;
extern NSString* const kMapDirectionsKey;
extern NSString* const kDriverIDKey;
extern NSString* const kJobNumberObjectKey;

//tags
extern int const kCTSecretCodeIsSentToYourPhoneStringInfoViewTag;
extern int const kCTSecretCodeDoesNotMatchToUserEnteredStringInfoViewTag;
extern int const kUnableToCreateApplicationSessionStringInfoViewTag;
extern int const kUnableToCreateUserSessionStringInfoViewTag;
extern int const kLoginRequestFailedAfterGetStartedStringViewTag;
extern int const kDPUploadingFailedTryAgainStringViewTag;
extern int const kPersonalInfoUploadingFailedTryAgainStringViewTag;
extern int const kDPDownloadingFailedTryAgainStringViewTag;
extern int const kAddHobbyStringViewTag;
extern int const kNetworkErrorStringViewTag;
extern int const kProfilePersonalInfoDownloadingFailedTryAgainStringViewTag;
extern int const kAccountInfoUploadingFailedTryAgainStringViewTag;
extern int const kPaymentConfirmationEmailInputViewTag;
extern int const kDeviceInfoUploadingFailedTryAgainStringViewTag;
extern int const kCommonPlacesFailedTryAgainStringViewTag;
extern int const kBookingOrderFailedTryAgainViewTag;
extern int const kCurrentDriverProfileDownladFailedTryAgainViewTag;
extern int const kJobRatingUpdateFailedTryAgainViewTag;
extern int const kJobBookingFailedTryAgainViewTag;
extern int const kFutureBookingDownloadFailedTryAgainViewTag;
extern int const kJobCancelConfirmationViewTag;
extern int const kJourneyDirectionsDownloadFailedViewTag;
extern int const kFutureBookingCancelFailedViewTag;
extern int const kGetStartedRequestUnSuccessfulViewTag;
extern int const kSendCustomerInstructionsToDriverFailedViewTag;
extern int const kChargeUserCardFailedViewTag;
extern int const kGetAlreadyBookedCurrentJobsFailedViewTag;
extern int const kGetAlreadyBookedCurrentJobsExistsViewTag;

//Durations
extern NSTimeInterval const kDefaultViewMovingAnimtionTime;
extern NSTimeInterval const kDriverRefreshTime;

#define isSMSOnTest 1 //Set this to 0 with actual UK phone numbers, 1 for testing
#define isPointingToLiveServer 0 //Set this to 1 when live, 0 for test server
#define TestingPhoneNumber @"112233"
