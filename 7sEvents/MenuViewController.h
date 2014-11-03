//
//  MenuViewController.h
//  7sEvents
//
//  Created by Vladimir Rojas on 16/06/14.
//  Copyright (c) 2014 7Seconds Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MenuViewControllerDelegate;

@interface MenuViewController : UIViewController
{
    NSMutableArray *_selections;
}

@property (nonatomic, strong) NSMutableArray *photos;
@property (nonatomic, strong) NSMutableArray *thumbs;
@property id<MenuViewControllerDelegate> delegate;

- (void)showMenu;
- (void)hideMenu;
- (void)setScrollView;

- (void)reloadBadge;
- (UILabel *)labelWithTitle:(NSString *)title;
- (void)reloadReportsWithNotification:(NSNotification *)notification;
+ (MenuViewController *)menuController;

@end

@protocol MenuViewControllerDelegate <NSObject>

@optional
- (void)selectedViewController:(id)viewController;
- (void)hideMenuController;

@end