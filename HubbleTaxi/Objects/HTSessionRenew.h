//
//  HTSessionRenew.h
//  HubbleTaxi
//
//  Created by Aamir Javed on 21/05/2014.
//  Copyright (c) 2014 Apponative. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HTSessionRenew : NSObject
@property (copy) void (^sessionRenewCallBackBlock)(bool succeeded, bool isLogout);
- (void)renewSessionWithCallbackBlock:(void (^)(bool succeeded, bool isLogout))callbackBlock;
@end
