//
//  HTDropDownView.m
//  HubbleTaxi
//
//  Created by Aamir Javed on 21/07/2014.
//  Copyright (c) 2014 Apponative. All rights reserved.
//

#import "HTDropDownView.h"
@interface HTDropDownView()<UITableViewDataSource,UITableViewDelegate>

- (void)tapGestureRecognized:(UITapGestureRecognizer*)gesture;

@end

@implementation HTDropDownView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.delegate = self;
        self.dataSource = self;
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
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
    return _dropDownTextsArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 32.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellID = @"DropDwonCellID";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    }
    cell.textLabel.text = _dropDownTextsArray[indexPath.row];
    cell.backgroundColor = [UIColor clearColor];
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.textLabel.textAlignment = NSTextAlignmentCenter;
    cell.separatorInset = UIEdgeInsetsZero;
    for (UIGestureRecognizer *recognizer in cell.gestureRecognizers) {
        [self removeGestureRecognizer:recognizer];
    }
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureRecognized:)];
    [cell addGestureRecognizer:tapGesture];
    cell.tag = indexPath.row;
    NSString *imageName = @"dropdown_middle";
    imageName = indexPath.row == 0? @"dropdown_upper":imageName;
    imageName = indexPath.row == _dropDownTextsArray.count-1?@"dropdown_lower":imageName;
    cell.backgroundView = [[HTImageView alloc] initWithImage:[UIImage imageNamed:imageName]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([_dropDownDelegate respondsToSelector:@selector(dropDownItemSelectedAtIndex:)]) {
        [_dropDownDelegate dropDownItemSelectedAtIndex:indexPath.row];
    }
}

- (void)tapGestureRecognized:(UITapGestureRecognizer*)gesture
{
    NSInteger index = gesture.view.tag;
    if ([_dropDownDelegate respondsToSelector:@selector(dropDownItemSelectedAtIndex:)]) {
        [_dropDownDelegate dropDownItemSelectedAtIndex:index];
    }
}

@end
