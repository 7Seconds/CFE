//
//  Report2ViewController.h
//  CFE Móvil
//
//  Created by Vladimir Rojas on 08/10/14.
//  Copyright (c) 2014 7Seconds Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ErrorReportViewController.h"

@interface PreviewErrorReportViewController : UIViewController <UIAlertViewDelegate>

@property NSInteger reportID;
@property NSString *observations;
@property (strong, nonatomic) ErrorReportViewController *rootController;

@end
