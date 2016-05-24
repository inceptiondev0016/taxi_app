//
//  HTDropDownView.h
//  HubbleTaxi
//
//  Created by Aamir Javed on 21/07/2014.
//  Copyright (c) 2014 Apponative. All rights reserved.
//

#import "HTView.h"

@protocol HTDropDownViewDelegate <NSObject>

@optional
- (void)dropDownItemSelectedAtIndex:(NSInteger)index;

@end

@interface HTDropDownView : HTTableView
@property (nonatomic,assign)id<HTDropDownViewDelegate>dropDownDelegate;
@property (nonatomic,retain)NSArray *dropDownTextsArray;//Array of NSString objects

@end
