//
//  HTDriverRatingViewController.h
//  HubbleTaxi
//
//  Created by Aamir Javed on 02/07/2014.
//  Copyright (c) 2014 Apponative. All rights reserved.
//

#import "HTViewController.h"

@interface HTDriverRating : NSObject
@property(nonatomic,assign)float price;
@property(nonatomic,retain)NSString *tokenID;
@property(nonatomic,assign)float tipValue;
@property(nonatomic,retain)NSString *jobID;
@property(nonatomic,retain)NSString *jobRideNumber;
@property(nonatomic,assign)BOOL isPaymentOK;

@end

@interface HTDriverRatingViewController : HTViewController

- (id)initWithRatingObject:(HTDriverRating*)driverRating;

@end
