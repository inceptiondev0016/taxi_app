//
//  HTDriverProfileViewController.h
//  HubbleTaxi
//
//  Created by Aamir Javed on 25/06/2014.
//  Copyright (c) 2014 Apponative. All rights reserved.
//

#import "HTViewController.h"

@interface HTDriverProfileViewController : HTViewController<UITextFieldDelegate>
@property (nonatomic,retain)NSString *currentBookingJobID;
@property (nonatomic,retain)NSString *currentBookingRideNumber;
- (void)invalidateTimers;
@end
