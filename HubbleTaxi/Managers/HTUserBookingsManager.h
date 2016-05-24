//
//  HTUserBookingsManager.h
//  HubbleTaxi
//
//  Created by Aamir Javed on 30/01/2014.
//  Copyright (c) 2014 Apponative. All rights reserved.
//

#import "HTManager.h"

@interface HTUserBookingsManager : HTManager

+ (HTUserBookingsManager*)sharedManager;

- (id)currentbookingOrderWithCompletionNotificationName:(NSString*)completionNotificationName;
- (id)bookingOrderWithJobID:(NSString*)jobID completionNotificationName:(NSString*)completionNotificationName;
- (id)updateJobRatingWithInfo:(NSDictionary*)jobRatingDictionary withJobID:(NSString*)jobID completionNotificationName:(NSString*)completionNotificationName;
-(id)createBookingJobs:(NSArray *)bookingJobs completionNotificationName:(NSString *)completionNotificationName;
- (id)futureBookingsWithCompletionNotificationName:(NSString*)completionNotificationName;
- (id)cancelFutureBookingWithJobID:(NSString*)jobID completionNotificationName:(NSString*)completionNotificationName;
- (id)incrementJobNumberBy:(NSInteger)incrementBy withCompletionNotificationName:(NSString*)completionNotificationName;
- (id)sendCustomerInstruction:(NSString*)instrcutionString toDriverWithJobID:(NSString*)jobID completionNotificationName:(NSString*)completionNotificationName;
- (id)logJobWithJobID:(NSString*)jobID rideNumber:(NSString*)rideNumber notes:(NSString*)notes type:(NSString*)type;
- (id)getAlreadyBookedJobsWithinBookingTime:(NSDate*)bookingTime completionNotificationName:(NSString*)completionNotificationName;
@end
