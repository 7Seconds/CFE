//
//  Complaints3ViewController.h
//  CFE Móvil
//
//  Created by Vladimir Rojas on 08/10/14.
//  Copyright (c) 2014 7Seconds Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ComplaintsReportViewController.h"

@interface PreviewComplaintsReportViewController : UIViewController

@property NSInteger reportID;
@property NSString *observations;
@property (strong, nonatomic) ComplaintsReportViewController *rootController;

@end
