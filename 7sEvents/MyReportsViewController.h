//
//  PresentationsViewController.h
//  7sEvents
//
//  Created by Vladimir Rojas on 16/06/14.
//  Copyright (c) 2014 7Seconds Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyReportsViewController : UIViewController
{
    NSMutableArray *objArray;
    NSMutableArray *childArray;
    NSArray *filteredChildArray;
    NSInteger indentationlevel;
    CGFloat indendationWidth;
}

@end
