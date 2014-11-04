//
//  AppDelegate.h
//  7sEvents
//
//  Created by Vladimir Rojas on 16/06/14.
//  Copyright (c) 2014 7Seconds Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreMotion/CoreMotion.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>
{
    CMMotionManager *motionManager;
}

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, retain) NSMutableArray *lugaresList;
@property (nonatomic, retain) NSMutableArray *distances;
@property (nonatomic, retain) NSString *estado;
@property (nonatomic, retain) NSString *mpo;
@property (nonatomic, retain) NSString *lugar;
@property (nonatomic) BOOL hasCamera;
@property (nonatomic) BOOL headingAvailable;
@property (readonly) CMMotionManager *motionManager;

@end
