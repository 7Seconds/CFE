//
//  StreamingViewCell.h
//  7sEvents
//
//  Created by Vladimir Rojas on 09/07/14.
//  Copyright (c) 2014 7Seconds Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface StreamingViewCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel *date;
@property (strong, nonatomic) IBOutlet UITextView *body;
@property (strong, nonatomic) IBOutlet UIImageView *image;

@end
