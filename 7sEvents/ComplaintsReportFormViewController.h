//
//  Complaints2ViewController.h
//  CFE Móvil
//
//  Created by Vladimir Rojas on 08/10/14.
//  Copyright (c) 2014 7Seconds Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ComplaintsReportViewController.h"

@interface ComplaintsReportFormViewController : UIViewController

@property NSInteger reportID;
@property (strong, nonatomic) ComplaintsReportViewController *rootController;

@end
