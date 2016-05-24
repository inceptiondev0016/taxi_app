//
//  HTPaymentMethodViewController.h
//  HubbleTaxi
//
//  Created by Aamir Javed on 22/04/2014.
//  Copyright (c) 2014 Apponative. All rights reserved.
//

#import "HTViewController.h"

@class GMSAddress;
@class PTKView;

@interface HTLocationInfo : NSObject
@property (nonatomic, retain) GMSAddress *gmsAddress;
@property (nonatomic, retain) NSString *addressString;
@property (nonatomic, assign) BOOL isCommonPlace;
@end

@interface HTPaymentInfo : NSObject
@property (nonatomic, retain)NSString *priceString;
@property (nonatomic, assign)BOOL noDestinationYet;
@property (nonatomic, retain)HTLocationInfo *pickupLocationInfo;
@property (nonatomic, retain)HTLocationInfo *destinationLocationInfo;
@property (nonatomic, retain)NSMutableArray *viaLocationInfoArray;
@property (nonatomic, retain)NSMutableArray *pickupDatesArray;
@property (nonatomic, retain)NSString *pickupFromAddress;
@property (nonatomic, retain)NSString *destinationAddress;
@property (nonatomic, retain)NSString *dateTimeString;
@property (nonatomic, retain)NSString *paymentMethod;
@property (nonatomic, retain)NSString *vehicleType;
@property (nonatomic, retain)PTKView *cardCharginView;
@property (nonatomic,retain)NSString *assignedToFirm;
@property (nonatomic,assign)BOOL journeySharedOnFB;
@property (nonatomic,assign)double distanceTravelled;

@end



@interface HTPaymentMethodViewController : HTViewController

- (id)initWithPaymentInfo:(HTPaymentInfo*)paymentInfo;
@end
