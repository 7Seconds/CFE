//
//  DetailDateTableViewCell.m
//  7sEvents
//
//  Created by Vladimir Rojas on 21/07/14.
//  Copyright (c) 2014 7Seconds Technologies. All rights reserved.
//

#import "DetailDateTableViewCell.h"

@implementation DetailDateTableViewCell

@synthesize description;

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
