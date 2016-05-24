//
//  HTInfoView.h
//  HubbleTaxi
//
//  Created by Aamir Javed on 12/08/2014.
//  Copyright (c) 2014 Apponative. All rights reserved.
//

#import "HTView.h"

@interface HTInfoView : HTView

- (id)initWithMessage:(NSString*)message;
- (id)initWithSecretCode:(NSString*)secretCode toMobNumber:(NSString*)mobileNumber;
- (void)show;
@end
