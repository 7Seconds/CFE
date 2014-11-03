//
//  ARViewController.h
//  CFE Móvil
//
//  Created by Vladimir Rojas on 27/10/14.
//  Copyright (c) 2014 7Seconds Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoreLocationController.h"
#import "AppDelegate.h"

#import <MapKit/MapKit.h>
#import <AVFoundation/AVFoundation.h>

@class AccelerometerFilter;

@interface ARViewController : UIViewController <CoreLocationControllerDelegate, UIAccelerometerDelegate>
{
    AppDelegate *delegate;
    
    CoreLocationController *CLController;
    AccelerometerFilter *filter;
    double x, y, z, part, angle_, currentRotation, oldRotation, currentHeading, oldHeading;
    double *angles, *oldAngles;
    AVCaptureSession *sessionCamera;
    UIView *cameraView;
    MKMapPoint *places;
    NSInteger tag;
    CLLocation *currentLocation;
    CLLocationDirection *distances;
    UIImageView *compassView, *dialogueView, *namePlaceView, *angleView;
    UITextView *dialogueText;
    UILabel *titleLabel, *distanceLabel;
    UIButton *closeButton;
    UIActivityIndicatorView *loadingView;
    NSMutableArray *imagesViews, *anglesViews, *namesViews, *dialoguesViews, *indexes;
    NSTimer *timer;
}

@property (nonatomic, retain) IBOutlet UIView *cameraView;
@property (nonatomic, retain) IBOutlet UIImageView *compassView;
@property (nonatomic, retain) IBOutlet UIImageView *dialogueView;
@property (nonatomic, retain) IBOutlet UIImageView *angleView;
@property (nonatomic, retain) IBOutlet UITextView *dialogueText;
@property (nonatomic, retain) IBOutlet UILabel *titleLabel;
@property (nonatomic, retain) IBOutlet UILabel *distanceLabel;
@property (nonatomic, retain) IBOutlet UIButton *closeButton;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *loadingView;
@property (nonatomic, retain) CoreLocationController *CLController;
@property (nonatomic, retain) CLLocation *currentLocation;

- (void)drawRadar;
- (void)stopAccelerometer;
- (void)startAccelerometer;
- (IBAction)goToMap;
- (IBAction)hiddenDialogue:(id)sender;
- (MKMapPoint)pointUpdate:(CLLocation *)currentLocation_ placeLocation:(CLLocation *)placeLocation;
- (double)angleUpdate:(CLLocation *)currentLocation_ placeLocation:(CLLocation *)placeLocation heading:(double)theHeading oldAngle:(double)oldAngle;

@end
