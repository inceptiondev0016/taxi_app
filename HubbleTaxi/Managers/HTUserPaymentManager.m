//
//  HTUserPriceAndPaymentManager.m
//  HubbleTaxi
//
//  Created by Aamir Javed on 30/01/2014.
//  Copyright (c) 2014 Apponative. All rights reserved.
//

#import "HTUserPaymentManager.h"
#import "HTDMManager.h"

static HTUserPaymentManager *_sharedManager;

@implementation HTUserPaymentManager

+ (HTUserPaymentManager*)sharedManager
{
    if (!_sharedManager) {
        _sharedManager = [[HTUserPaymentManager alloc] init];
    }
    return _sharedManager;
}

- (void)saveCardWithNumberString:(NSString *)cardNumberString CVCString:(NSString *)cvcString expiryString:(NSString*)expiryString
{
    [[HTDMManager sharedManager] saveCardWithNumberString:cardNumberString CVCString:cvcString expiryString:expiryString];
}

- (void)deleteCardWithCardIndex:(NSUInteger)cardIndex
{
    [[HTDMManager sharedManager] deleteCardWithCardIndex:cardIndex];
}
@end
