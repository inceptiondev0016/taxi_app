//
//  HTMenuView.h
//  HubbleTaxi
//
//  Created by Aamir Javed on 22/07/2014.
//  Copyright (c) 2014 Apponative. All rights reserved.
//

#import "HTTableView.h"

@protocol HTMenuViewDelegate <NSObject>

@optional
- (void)menuItemSelectedAtIndex:(NSInteger)index;

@end
@interface HTMenuView : HTTableView
@property (nonatomic,assign)id<HTMenuViewDelegate>menuDelegate;
@property (nonatomic,retain)NSArray *menuButtonsTextsArray;//Array of NSString objects
- (void)animateWithHiden:(BOOL)hidden;
@end
