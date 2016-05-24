//
//  HTCallDriverViewController.h
//  HubbleTaxi
//
//  Created by Aamir Javed on 03/11/2014.
//  Copyright (c) 2014 Apponative. All rights reserved.
//

#import "HTViewController.h"
#import "HTDriverProfileViewController.h"

@interface HTDriverInfo : NSObject

@property(nonatomic,retain)NSString *driverName;
@property(nonatomic,retain)NSString *vehicleMakeNModel;
@property(nonatomic,retain)NSString *vehicleRegNo;
@property(nonatomic,retain)NSString *driverBio;
@property(nonatomic,retain)UIImage *driverDp;
@property(nonatomic,retain)NSString *driverPhoneNo;
@property(nonatomic,retain)NSString *timeToPickupString;
@property(nonatomic,assign)CLLocationCoordinate2D currentLocationCoordinates;
@property(nonatomic,retain)NSString *driverMessageString;
@property(nonatomic,retain)NSString *customerInstructionString;
@property(nonatomic,assign)BOOL isInstructionEnabled;
@end

@interface HTCallDriverViewController : HTViewController
@property (nonatomic,weak)HTDriverProfileViewController *driverProfileRef;
- (id)initWithDriverInfo:(HTDriverInfo*)driverInfo;
@end
