//
//  HTUserBookingsManager.m
//  HubbleTaxi
//
//  Created by Aamir Javed on 30/01/2014.
//  Copyright (c) 2014 Apponative. All rights reserved.
//

#import "HTUserBookingsManager.h"
#import "HTDMManager.h"
static HTUserBookingsManager *_sharedManager;

@implementation HTUserBookingsManager

+ (HTUserBookingsManager *)sharedManager
{
    if (!_sharedManager) {
        _sharedManager = [[HTUserBookingsManager alloc] init];
    }
    return _sharedManager;
}

- (id)currentbookingOrderWithCompletionNotificationName:(NSString*)completionNotificationName
{
    return [[HTDMManager sharedManager] currentbookingOrderWithcompletionNotificationName:completionNotificationName];
}

- (id)bookingOrderWithJobID:(NSString*)jobID completionNotificationName:(NSString*)completionNotificationName
{
    return [[HTDMManager sharedManager] bookingOrderWithJobID:jobID completionNotificationName:completionNotificationName];
}

- (id)updateJobRatingWithInfo:(NSDictionary*)jobRatingDictionary withJobID:(NSString*)jobID completionNotificationName:(NSString*)completionNotificationName
{
    return [[HTDMManager sharedManager] updateJobRatingWithInfo:jobRatingDictionary withJobID:jobID completionNotificationName:completionNotificationName];
}

-(id)createBookingJobs:(NSArray *)bookingJobs completionNotificationName:(NSString *)completionNotificationName
{
    return [[HTDMManager sharedManager] createBookingJobs:bookingJobs completionNotificationName:completionNotificationName];
}

- (id)futureBookingsWithCompletionNotificationName:(NSString*)completionNotificationName
{
    return [[HTDMManager sharedManager] futureBookingsWithCompletionNotificationName:completionNotificationName];
}

- (id)cancelFutureBookingWithJobID:(NSString*)jobID completionNotificationName:(NSString*)completionNotificationName
{
    return [[HTDMManager sharedManager] cancelFutureBookingWithJobID:jobID completionNotificationName:completionNotificationName];
}

- (id)incrementJobNumberBy:(NSInteger)incrementBy withCompletionNotificationName:(NSString*)completionNotificationName;
{
    return [[HTDMManager sharedManager] incrementJobNumberBy:incrementBy withCompletionNotificationName:completionNotificationName];
}

- (id)sendCustomerInstruction:(NSString*)instrcutionString toDriverWithJobID:(NSString*)jobID completionNotificationName:(NSString*)completionNotificationName
{
    return [[HTDMManager sharedManager] sendCustomerInstruction:instrcutionString toDriverWithJobID:jobID completionNotificationName:completionNotificationName];
}

- (id)logJobWithJobID:(NSString*)jobID rideNumber:(NSString*)rideNumber notes:(NSString*)notes type:(NSString*)type
{
    return [[HTDMManager sharedManager] logJobWithJobID:jobID rideNumber:rideNumber notes:notes type:type];
}

- (id)getAlreadyBookedJobsWithinBookingTime:(NSDate*)bookingTime completionNotificationName:(NSString*)completionNotificationName
{
    return [[HTDMManager sharedManager] getAlreadyBookedJobsWithinBookingTime:bookingTime completionNotificationName:completionNotificationName];
}

@end
