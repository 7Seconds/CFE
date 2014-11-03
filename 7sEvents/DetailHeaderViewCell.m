//
//  DetailHeaderViewCell.m
//  7sEvents
//
//  Created by Vladimir Rojas on 23/07/14.
//  Copyright (c) 2014 7Seconds Technologies. All rights reserved.
//

#import "DetailHeaderViewCell.h"

@implementation DetailHeaderViewCell

@synthesize title, background;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
