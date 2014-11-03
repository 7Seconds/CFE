//
//  DirectoryViewController.h
//  7sEvents
//
//  Created by Vladimir Rojas on 16/06/14.
//  Copyright (c) 2014 7Seconds Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PayPalViewController.h"

@interface OnlinePaymentViewController : UIViewController <PayPalDelegate>

- (void)hideMenuController;

@end