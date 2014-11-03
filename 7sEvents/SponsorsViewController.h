//
//  SponsorsViewController.h
//  7sEvents
//
//  Created by Vladimir Rojas on 16/06/14.
//  Copyright (c) 2014 7Seconds Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MFMailComposeViewController.h>

@interface SponsorsViewController : UIViewController<MFMailComposeViewControllerDelegate,  UICollectionViewDataSource, UICollectionViewDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *myCollectionView;
@property (nonatomic, retain) NSMutableArray *contentArray;

@end
