//
//  ViewController.h
//  7sEvents
//
//  Created by Vladimir Rojas on 16/06/14.
//  Copyright (c) 2014 7Seconds Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MenuViewController.h"
#import "Lugar.h"

@class AppDelegate;

@interface ViewController : UIViewController<MenuViewControllerDelegate>
{
    AppDelegate *delegate;
}

@end
