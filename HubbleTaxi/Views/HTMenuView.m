//
//  HTMenuView.m
//  HubbleTaxi
//
//  Created by Aamir Javed on 22/07/2014.
//  Copyright (c) 2014 Apponative. All rights reserved.
//

#import "HTMenuView.h"
@interface HTMenuView()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic,assign)CGRect shownFrame;
@property (nonatomic,assign)CGRect hiddenFrame;

@end

@implementation HTMenuView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.delegate = self;
        self.dataSource = self;
        self.separatorStyle = UITableViewCellSeparatorStyleNone;
        self.scrollEnabled = NO;
        self.shownFrame = self.frame;
        self.hiddenFrame = CGRectMake(-self.frame.size.width, self.frame.origin.y, self.frame.size.width, self.frame.size.height);
    }
    return self;
}

- (void)animateWithHiden:(BOOL)hidden
{
    if (!hidden) {
        self.hidden = hidden;
    }
    
    [UIView animateWithDuration:0.2 animations:^{
        self.frame = hidden?_hiddenFrame:_shownFrame;
    } completion:^(BOOL finished) {
        self.hidden = hidden;
    }];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

#pragma mark- Tableview mehtods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _menuButtonsTextsArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return self.frame.size.height/_menuButtonsTextsArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellID = @"MenuCellID";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    }
    cell.textLabel.text = _menuButtonsTextsArray[indexPath.row];
    cell.backgroundColor = [UIColor clearColor];
    cell.textLabel.textColor = [UIColor blackColor];
    if (cell.textLabel.text.length) {
        NSString *imageName = [NSString stringWithFormat:@"%@.png",[[(NSString*)_menuButtonsTextsArray[indexPath.row] stringByReplacingOccurrencesOfString:@" " withString:@""] lowercaseString]];
        UIImage *image = [UIImage imageNamed:imageName];
        CGSize size= CGSizeMake(image.size.width/2, image.size.height/2);//set the width and height
        UIGraphicsBeginImageContext(size);
        [image drawInRect:CGRectMake(0,0,size.width,size.height)];
        UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        cell.imageView.image = newImage?newImage:[UIImage imageNamed:@"buttonplane.png"];
    }
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    return indexPath.row != 4 && indexPath.row != 5;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([_menuDelegate respondsToSelector:@selector(menuItemSelectedAtIndex:)]) {
        [_menuDelegate menuItemSelectedAtIndex:indexPath.row];
    }
}
@end
