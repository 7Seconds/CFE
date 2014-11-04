//
//  ARViewController.m
//  CFE Móvil
//
//  Created by Vladimir Rojas on 27/10/14.
//  Copyright (c) 2014 7Seconds Technologies. All rights reserved.
//

#import "ARViewController.h"
#import "UIDeviceHardware.h"
#import "Lugar.h"
#import "AccelerometerFilter.h"
#import "MenuViewController.h"

#define MAX_RADIUS			3000.0
#define TAM_Y				76.0
#define TAM_X				60.0
#define kUpdateFrequency	60.0
#define FRAME_TIME			0.45

@interface ARViewController ()
{
    IBOutlet UIView *dialogueBackgrond;
}

- (void)startCameraCapture;
- (void)stopCameraCapture;

@end

@implementation ARViewController

@synthesize CLController;
@synthesize cameraView;
@synthesize compassView;
@synthesize angleView;
@synthesize currentLocation;
@synthesize dialogueView;
@synthesize dialogueText;
@synthesize titleLabel;
@synthesize distanceLabel;
@synthesize closeButton;
@synthesize loadingView;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //[[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"nav_bg@2x.png"] forBarMetrics:UIBarMetricsDefault];
    
    UILabel *label = [[MenuViewController menuController] labelWithTitle:@"sucursales"];
    self.navigationItem.titleView = label;
    dialogueView.layer.cornerRadius = 7.5;
    dialogueView.layer.masksToBounds = YES;
    
    [loadingView startAnimating];
    
    delegate = [[UIApplication sharedApplication] delegate];
    CLController = [[CoreLocationController alloc] init];
    CLController.delegate = self;
    
    self.currentLocation = [[CLLocation alloc] init];
    places = (MKMapPoint *) malloc(sizeof(MKMapPoint)*[delegate.lugaresList count]);
    distances = (CLLocationDirection *) malloc(sizeof(CLLocationDirection)*[delegate.lugaresList count]);
    angles = (double *) malloc(sizeof(double)*[delegate.lugaresList count]);
    oldAngles = (double *) malloc(sizeof(double)*[delegate.lugaresList count]);
    [CLController.locMgr startUpdatingLocation];
    [CLController.locMgr startUpdatingHeading];
    [self performSelector:@selector(clearArrays)];
    
    filter = [[LowpassFilter alloc] initWithSampleRate:kUpdateFrequency cutoffFrequency:5.];
    
    [self startAccelerometer];
    [self performSelector:@selector(translucentViews)];
    [self performSelector:@selector(loadPlaces)];
    
    [timer invalidate];
    timer = nil;
    timer = [NSTimer scheduledTimerWithTimeInterval:FRAME_TIME target:self selector:@selector(updateFrames) userInfo:nil repeats:YES];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self startCameraCapture];
    [[[self navigationController] navigationBar] setBackgroundImage:[UIImage imageNamed:@"nav_bg"] forBarMetrics:UIBarMetricsDefault];
    [[[self navigationController] navigationBar] setAlpha:1.f];
}

- (void)viewWillDisappear:(BOOL)animated
{
    for (UIButton *image in imagesViews) {
        [image removeFromSuperview];
    }
    for (UIImageView *image in dialoguesViews) {
        [image removeFromSuperview];
    }
    for (UILabel *label in namesViews) {
        [label removeFromSuperview];
    }
}

- (void)clearArrays{
    //NSLog(@"clearArrays");
    indexes = [[NSMutableArray alloc] init];
    [indexes removeAllObjects];
    imagesViews = [[NSMutableArray alloc] init];
    [imagesViews removeAllObjects];
    anglesViews = [[NSMutableArray alloc] initWithCapacity:[delegate.lugaresList count]];
    for (NSUInteger i = 0; i < [delegate.lugaresList count]; i++) {
        [anglesViews addObject:[NSNumber numberWithInt:0]];
    }
    namesViews = [[NSMutableArray alloc] init];
    [namesViews removeAllObjects];
    dialoguesViews = [[NSMutableArray alloc] init];
    [dialoguesViews removeAllObjects];
}


- (void)translucentViews{
    //NSLog(@"translucentViews");
    [closeButton setAlpha:0.];
    [dialogueView setAlpha:0.];
    [dialogueBackgrond setAlpha:0.];
    [dialogueText setAlpha:0.];
    [titleLabel setAlpha:0.];
    [distanceLabel setAlpha:0.];
}


- (void)solidViews{
    //NSLog(@"solidViews");
    [closeButton setAlpha:.85];
    [dialogueView setAlpha:.85];
    [dialogueBackgrond setAlpha:0.5f];
    [dialogueText setAlpha:1.];
    [titleLabel setAlpha:1.];
    [distanceLabel setAlpha:1.];
}


- (void)loadPlaces{
    //NSLog(@"loadPlaces");
    Lugar *place = [[Lugar alloc] init];
    
    for (NSInteger i = 0; i < [delegate.lugaresList count]; i++) {
        place = [delegate.lugaresList objectAtIndex:i];
        NSNumber *index = [NSNumber numberWithInteger:i];
        
        [self performSelector:@selector(loadButtonWithIndex:) withObject:index];
        [self performSelector:@selector(loadLabelWithPlace:) withObject:place];
        
        if ([[delegate.distances objectAtIndex:i] doubleValue] < MAX_RADIUS) {
            [self.view addSubview:[imagesViews lastObject]];
            [self.view addSubview:[dialoguesViews lastObject]];
            [self.view addSubview:[namesViews lastObject]];
            [indexes addObject:[NSNumber numberWithInteger:i]];
        }
    }
    /*for (NSUInteger i = 0; i < [indexes count]; i++) {
     NSLog(@"-------->indexes: %d", [[indexes objectAtIndex:i] intValue]);
     }*/
}


- (void)loadButtonWithIndex:(NSNumber *)index{
    //NSLog(@"loadButtonWithIndex");
    UIImage *imagePlace = [UIImage imageNamed:@"puntero.png"];
    UIImage *imageDialogue = [UIImage imageNamed:@"globo2.png"];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button addTarget:self action:@selector(showDetails:)
     forControlEvents:UIControlEventTouchDown];
    [button setImage:imagePlace forState:UIControlStateNormal];
    [button setTag:[index intValue]];
    [button setAlpha:0.92];
    [imagesViews addObject:button];
    [[imagesViews lastObject] setFrame:CGRectMake(0., 0. , 53., 76.)];
    namePlaceView = [[UIImageView alloc] initWithImage:imageDialogue];
    [namePlaceView setFrame:CGRectMake(0., 0., 0., 0.)];
    [namePlaceView setAlpha:0.92];
    [dialoguesViews addObject:namePlaceView];
}


- (void)loadLabelWithPlace:(Lugar *)place{
    //NSLog(@"loadLabelWithPlace");
    UILabel *namePlace = [[UILabel alloc] initWithFrame:CGRectMake(0., 0., 0., 0.)];
    namePlace.text = place.title;
    namePlace.textAlignment = NSTextAlignmentCenter;
    NSString *deviceType = [UIDevice currentDevice].model;
    if([deviceType isEqualToString:@"iPad"])
        namePlace.font = [UIFont fontWithName:@"Helvetica" size: 12.];
    else
        namePlace.font = [UIFont fontWithName:@"Helvetica" size: 10.];
    namePlace.backgroundColor = [UIColor clearColor];
    namePlace.textColor = [UIColor whiteColor];
    [namesViews addObject:namePlace];
}


- (void)showDetails:(id)sender{
    //NSLog(@"showDetails");
    UIImage *imagePlace = [UIImage imageNamed:@"puntero.png"];;
    /*for (NSInteger i = 0; i < [imagesViews count]; i++) {
     if ([[imagesViews objectAtIndex:i] tag] == tag)
     [[imagesViews objectAtIndex:i] setImage:imagePlace forState:UIControlStateNormal];
     }*/
    for (NSUInteger j = 0; j < [indexes count]; j++) {
        NSUInteger i = [[indexes objectAtIndex:j] intValue];
        if ([[imagesViews objectAtIndex:i] tag] == tag)
            [[imagesViews objectAtIndex:i] setImage:imagePlace forState:UIControlStateNormal];
    }
    [self performSelector:@selector(translucentViews)];
    [UIView beginAnimations:@"frame" context:nil];
    [UIView setAnimationDuration:.5];
    tag = [sender tag];
    UIImage *imageNegative = [UIImage imageNamed:@"puntero2.png"];
    [sender setImage:imageNegative forState:UIControlStateNormal];
    [self performSelector:@selector(solidViews)];
    Lugar *place = [[Lugar alloc] init];
    /*for (NSInteger i = 0; i < [delegate.lugaresList count]; i++) {
     if (i == [sender tag]) {
     place = [delegate.lugaresList objectAtIndex:i];
     [titleLabel setText:place.title];
     NSString *dialogueString = [NSString stringWithFormat:@"%@\n%@", place.calle, place.horario];
     [dialogueText setText:dialogueString];
     if (distances[i] > 1000.)
     [distanceLabel setText:[NSString stringWithFormat:@"Está a %.2f kilómetros", distances[i]/1000.]];
     else
     [distanceLabel setText:[NSString stringWithFormat:@"Está a %.2f metros", distances[i]]];
     }
     }*/
    for (NSUInteger j = 0; j < [indexes count]; j++){
        NSInteger i = [[indexes objectAtIndex:j] intValue];
        if (i == [sender tag]){
            place = [delegate.lugaresList objectAtIndex:i];
            [titleLabel setText:place.title];
            NSString *dialogueString = [NSString stringWithFormat:@"%@\n\n%@\n%@", place.calle, place.referencias, place.horario];
            [dialogueText setText:dialogueString];
            if (distances[i] > 1000.)
                [distanceLabel setText:[NSString stringWithFormat:@"Está a %.2f kilómetros", distances[i]/1000.]];
            else
                [distanceLabel setText:[NSString stringWithFormat:@"Está a %.2f metros", distances[i]]];
        }
    }
    [UIView commitAnimations];
}


- (IBAction)hiddenDialogue:(id)sender{
    //NSLog(@"hiddenDialogue");
    [UIView beginAnimations:@"frame" context:nil];
    [UIView setAnimationDuration:.5];
    UIImage *imagePlace = [UIImage imageNamed:@"puntero.png"];
    /*for (NSInteger i = 0; i < [imagesViews count]; i++) {
     if ([[imagesViews objectAtIndex:i] tag] == tag)
     [[imagesViews objectAtIndex:i] setImage:imagePlace forState:UIControlStateNormal];
     }*/
    for (NSUInteger j = 0; j < [indexes count]; j++) {
        NSUInteger i = [[indexes objectAtIndex:j] intValue];
        if ([[imagesViews objectAtIndex:i] tag] == tag)
            [[imagesViews objectAtIndex:i] setImage:imagePlace forState:UIControlStateNormal];
    }
    [self performSelector:@selector(translucentViews)];
    [UIView commitAnimations];
}

#pragma mark -
#pragma mark CoreLocationControllerDelegate

- (void)locationUpdate:(CLLocation *)location {
    //NSLog(@"---------------------->locationUpdate");
    self.currentLocation = location;
    //NSLog(@"RA----> locationUpdate: %f, %f", location.coordinate.latitude, location.coordinate.longitude);
    [loadingView stopAnimating];
    [self drawRadar];
    //[self performSelector:@selector(loadPlaces)];
    //NSLog(@"@selector(updateFrames)");
    //[self performSelector:@selector(updateFrames)];
    //[timer invalidate];
    //timer = nil;
    //timer = [NSTimer scheduledTimerWithTimeInterval:FRAME_TIME target:self selector:@selector(updateFrames) userInfo:nil repeats:YES];
}


- (void)locationError:(NSError *)error {
    NSLog(@"locationError: %@", [error description]);
}


- (void)headingUpdate:(CLHeading *)heading {
    //NSLog(@"headingUpdate: %f", heading.trueHeading);
    oldHeading = currentHeading;
    currentHeading = heading.trueHeading;
    CGAffineTransform compassTransform = compassView.transform;
    oldRotation = currentRotation;
    currentRotation = 360. - (heading.trueHeading + 16);
    double rotation = (currentRotation - oldRotation) * (M_PI / 180.);
    compassView.transform = CGAffineTransformRotate(compassTransform, rotation);
    [self performSelector:@selector(updateAngles)];
}

- (BOOL)displayCalibration:(CLLocationManager *)manager{
    return YES;
}

#pragma mark -
#pragma mark Camera Capture Control

- (void)startCameraCapture {
    //NSLog(@"startCameraCapture");
    sessionCamera = [[AVCaptureSession alloc] init];
    AVCaptureVideoPreviewLayer *cameraLayer = [AVCaptureVideoPreviewLayer layerWithSession:sessionCamera];
    
    UIDeviceHardware *deviceHardware = [[UIDeviceHardware alloc] init];
    NSString *versionDevice = [deviceHardware platformString];
    
    if ([versionDevice isEqual:@"iPhone 3GS"]){
        cameraLayer.frame = CGRectMake(0., -10., 345., 480.);
    }
    else if ([versionDevice isEqual:@"iPad 2"]){
        cameraLayer.frame = CGRectMake(0., -37., 768., 1365.);
    }
    else{
        cameraLayer.frame = CGRectMake(0., -37., 320., 570.);
    }
    
    [cameraView.layer addSublayer:cameraLayer];
    AVCaptureDevice* camera = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    AVCaptureInput* cameraInput = [[AVCaptureDeviceInput alloc] initWithDevice:camera error:nil];
    [sessionCamera addInput:cameraInput];
    [sessionCamera startRunning];
}


- (void)stopCameraCapture {
    //NSLog(@"stopCameraCapture");
    [sessionCamera stopRunning];
    sessionCamera=nil;
}

#pragma mark -

- (void)drawRadar {
    //NSLog(@"drawRadar");
    Lugar *place = [[Lugar alloc] init];
    /*for (NSInteger i = 0; i < [delegate.lugaresList count]; i++) {
     place = [delegate.lugaresList objectAtIndex:i];
     CLLocation *placeLocation = [[[CLLocation alloc] initWithLatitude:[place.latitud doubleValue]
     longitude:[place.longitud doubleValue]] autorelease];
     places[i] = [self pointUpdate:currentLocation placeLocation:placeLocation];
     distances [i] = [currentLocation distanceFromLocation:placeLocation];
     }*/
    for (NSUInteger j = 0; j < [indexes count]; j++) {
        NSUInteger i = [[indexes objectAtIndex:j] intValue];
        place = [delegate.lugaresList objectAtIndex:i];
        CLLocation *placeLocation = [[CLLocation alloc] initWithLatitude:[place.latitud doubleValue]
                                                                longitude:[place.longitud doubleValue]];
        places[i] = [self pointUpdate:currentLocation placeLocation:placeLocation];
        distances [i] = [currentLocation distanceFromLocation:placeLocation];
    }
    [compassView setImage:[UIImage imageNamed:@"radar.png"]];
    [self performSelector:@selector(updateRadar)];
}


- (MKMapPoint)pointUpdate:(CLLocation *)currentLocation_ placeLocation:(CLLocation *)placeLocation {
    //NSLog(@"pointUpdate");
    CLLocationDistance distanceMeters = [currentLocation_ distanceFromLocation:placeLocation];
    MKMapPoint currentLocationPoint = MKMapPointForCoordinate(currentLocation_.coordinate);
    MKMapPoint placeLocationPoint = MKMapPointForCoordinate(placeLocation.coordinate);
    MKMapPoint point;
    
    point.x = placeLocationPoint.x - currentLocationPoint.x;
    point.y = currentLocationPoint.y - placeLocationPoint.y;
    
    double distanceMap = sqrt(pow(currentLocationPoint.x - placeLocationPoint.x, 2.)
                              + pow(currentLocationPoint.y - placeLocationPoint.y, 2.));
    double relation = distanceMeters / distanceMap;
    
    point.x *= relation;
    point.y *= relation;
    point.x /= MAX_RADIUS;
    point.y /= - MAX_RADIUS;
    
    return point;
}


- (double)angleUpdate:(CLLocation *)currentLocation_ placeLocation:(CLLocation *)placeLocation heading:(double)theHeading oldAngle:(double)oldAngle {
    //NSLog(@"angleUpdate");
    MKMapPoint currentLocationPoint = MKMapPointForCoordinate(currentLocation_.coordinate);
    MKMapPoint placeLocationPoint = MKMapPointForCoordinate(placeLocation.coordinate);
    
    double deltaX = (placeLocationPoint.x - currentLocationPoint.x);
    double deltaY = (placeLocationPoint.y - currentLocationPoint.y);
    
    double angle = atan(deltaY/deltaX);
    angle *= 180.0 / M_PI;
    
    if (deltaX < 0)
        angle = 270.0 + angle;
    else if (deltaX > 0)
        angle = 90.0 + angle;
    
    return angle - theHeading;
}


- (void) updateRadar {
    //NSLog(@"updateRadar");
    UIGraphicsBeginImageContext(compassView.frame.size);
    [compassView.image drawInRect:CGRectMake(0., 0., compassView.frame.size.width, compassView.frame.size.height)];
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(ctx, 2.);
    CGContextSetStrokeColorWithColor(ctx, [UIColor colorWithRed:28.f/255.f green:112.f/255.f blue:61/255.f alpha:1.f].CGColor);
    Lugar *place = [[Lugar alloc] init];
    /*for (NSInteger i = 0; i<[delegate.lugaresList count]; i++) {
     place = [delegate.lugaresList objectAtIndex:i];
     if (distances[i] < MAX_RADIUS){
     CGRect c_place = CGRectMake((compassView.frame.size.width/2)+(compassView.frame.size.width/2)*(places[i].x),
     (compassView.frame.size.height/2)+(compassView.frame.size.height/2)*(places[i].y), 2.5, 2.5);
     CGContextAddEllipseInRect(ctx, c_place);
     CGContextStrokePath(ctx);
     }
     }*/
    for (NSUInteger j = 0; j < [indexes count]; j++) {
        NSUInteger i = [[indexes objectAtIndex:j] intValue];
        place = [delegate.lugaresList objectAtIndex:i];
        if (distances[i] < MAX_RADIUS){
            CGRect c_place = CGRectMake((compassView.frame.size.width/2)+(compassView.frame.size.width/2)*(places[i].x),
                                        (compassView.frame.size.height/2)+(compassView.frame.size.height/2)*(places[i].y), 2.5, 2.5);
            CGContextAddEllipseInRect(ctx, c_place);
            CGContextStrokePath(ctx);
        }
    }
    CGContextSetStrokeColorWithColor(ctx, [UIColor whiteColor].CGColor);
    CGContextAddEllipseInRect(ctx, CGRectMake((compassView.frame.size.width/2), (compassView.frame.size.height/2), .75, .75));
    CGContextStrokePath(ctx);
    compassView.image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
}


- (CMMotionManager *)motionManager
{
    CMMotionManager *motionManager = nil;
    id appDelegate = [UIApplication sharedApplication].delegate;
    if ([appDelegate respondsToSelector:@selector(motionManager)]) {
        motionManager = [appDelegate motionManager];
    }
    return motionManager;
}

- (void)startMyMotionDetect
{
    [self.motionManager startAccelerometerUpdatesToQueue:[[NSOperationQueue alloc] init]
                                             withHandler:^(CMAccelerometerData *data, NSError *error) {
                                                 dispatch_async(dispatch_get_main_queue(), ^{
                                                     // Collecting data
                                                     [filter addAcceleration:data.acceleration];
                                                     x=filter.x;
                                                     y=filter.y;
                                                     z=filter.z;
                                                     angle_ = atan2(y, z);
                                                     angle_ *= 180.0 / M_PI;
                                                     angle_ = 180.0 - fabsf(angle_);
                                                     part = (((53.0 - 1.0) / (143.0 - 53.0))*(angle_ - 53.0)) + 1.0;
                                                 });
                                             }
     ];
}

/*
 - (void)accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration{
    //NSLog(@"accelerometer");
    [filter addAcceleration:acceleration];
    x=filter.x;
    y=filter.y;
    z=filter.z;
    angle_ = atan2(y, z);
    angle_ *= 180.0 / M_PI;
    angle_ = 180.0 - fabsf(angle_);
    part = (((53.0 - 1.0) / (143.0 - 53.0))*(angle_ - 53.0)) + 1.0;
}
 */


- (void)updateAngles{
    //NSLog(@"updateAngles");
    //[anglesViews removeAllObjects];
    /*for (NSInteger i = 0; i<[delegate.lugaresList count]; i++) {
     place = [delegate.lugaresList objectAtIndex:i];
     CLLocation *placeLocation = [[[CLLocation alloc] initWithLatitude:[place.latitud doubleValue]
     longitude:[place.longitud doubleValue]] autorelease];
     oldAngles[i] = angles[i];
     angles[i] = [self angleUpdate:currentLocation placeLocation:placeLocation heading:currentHeading oldAngle:oldAngles[i]];
     [anglesViews addObject:[[NSNumber alloc] initWithDouble:angles[i]]];
     }*/
    Lugar *place = [[Lugar alloc] init];
    for (NSUInteger j = 0; j < [indexes count]; j++) {
        NSUInteger i = [[indexes objectAtIndex:j] intValue];
        place = [delegate.lugaresList objectAtIndex:i];
        CLLocation *placeLocation = [[CLLocation alloc] initWithLatitude:[place.latitud doubleValue]
                                                                longitude:[place.longitud doubleValue]];
        oldAngles[i] = angles[i];
        angles[i] = [self angleUpdate:currentLocation placeLocation:placeLocation heading:currentHeading oldAngle:oldAngles[i]];
        //[anglesViews addObject:[[NSNumber alloc] initWithDouble:angles[i]]];
        [anglesViews replaceObjectAtIndex:i withObject:[[NSNumber alloc] initWithDouble:angles[i]]];
    }
}


- (void)updateFrames{
    //NSLog(@"updateFrames");
    [self performSelector:@selector(minimalDistance)];
    double coordX, coordY, tam_x, tam_y, highLabel;
    NSString *deviceType = [UIDevice currentDevice].model;
    if([deviceType isEqualToString:@"iPad"]){
        coordX = (768./2.) / (37.5/2.);
        coordY = (1004./53.) * part;
        tam_x = TAM_X*4/3;
        tam_y = TAM_Y*4/3;
        highLabel = 24.;
    } else {
        coordX = (320./2.) / (37.5/2.);
        coordY = (460./53.) * part;
        tam_x = TAM_X;
        tam_y = TAM_Y;
        highLabel = 20.;
    }
    double x_b, x_c;
    /*for (NSInteger i = 0; i < [imagesViews count]; i++) {
     if (i < [anglesViews count]) {
     x_b = [[dialoguesViews objectAtIndex:i] frame].origin.x;
     x_c = coordX * [[anglesViews objectAtIndex:i] doubleValue];
     [UIView beginAnimations:@"frame" context:nil];
     if (fabs(x_b - x_c) > 2000.)
     [UIView setAnimationDuration:1./60.];
     else
     [UIView setAnimationDuration:FRAME_TIME];
     NSString *deviceType = [UIDevice currentDevice].model;
     if([deviceType isEqualToString:@"iPad"]){
     [[dialoguesViews objectAtIndex:i] setFrame:CGRectMake(coordX * [[anglesViews objectAtIndex:i] doubleValue] + 13., coordY - tam_y/2.0 + tam_y, tam_x-26., highLabel)];
     [[namesViews objectAtIndex:i] setFrame:CGRectMake(coordX * [[anglesViews objectAtIndex:i] doubleValue] + 16., coordY - tam_y/2.0 + tam_y, tam_x-32., highLabel)];
     [[imagesViews objectAtIndex:i] setFrame:CGRectMake(coordX * [[anglesViews objectAtIndex:i] doubleValue], coordY - tam_y/2.0 , tam_x, tam_y)];
     } else {
     [[dialoguesViews objectAtIndex:i] setFrame:CGRectMake(coordX * [[anglesViews objectAtIndex:i] doubleValue], coordY - tam_y/2.0 + tam_y, tam_x, highLabel)];
     [[namesViews objectAtIndex:i] setFrame:CGRectMake(coordX * [[anglesViews objectAtIndex:i] doubleValue] + 5., coordY - tam_y/2.0 + tam_y, tam_x-10., highLabel)];
     [[imagesViews objectAtIndex:i] setFrame:CGRectMake(coordX * [[anglesViews objectAtIndex:i] doubleValue], coordY - tam_y/2.0 , tam_x, tam_y)];
     }
     }
     [UIView commitAnimations];
     }*/
    for (NSUInteger j = 0; j < [indexes count]; j++) {
        NSUInteger i = [[indexes objectAtIndex:j] intValue];
        if (i < [anglesViews count]) {
            x_b = [[dialoguesViews objectAtIndex:i] frame].origin.x;
            x_c = coordX * [[anglesViews objectAtIndex:i] doubleValue];
            [UIView beginAnimations:@"frame" context:nil];
            if (fabs(x_b - x_c) > 2000.)
                [UIView setAnimationDuration:1./60.];
            else
                [UIView setAnimationDuration:FRAME_TIME];
            NSString *deviceType = [UIDevice currentDevice].model;
            if([deviceType isEqualToString:@"iPad"]){
                [[dialoguesViews objectAtIndex:i] setFrame:CGRectMake(coordX * [[anglesViews objectAtIndex:i] doubleValue] + 13., coordY - tam_y/2.0 + tam_y, tam_x-26., highLabel)];
                [[namesViews objectAtIndex:i] setFrame:CGRectMake(coordX * [[anglesViews objectAtIndex:i] doubleValue] + 16., coordY - tam_y/2.0 + tam_y, tam_x-32., highLabel)];
                [[imagesViews objectAtIndex:i] setFrame:CGRectMake(coordX * [[anglesViews objectAtIndex:i] doubleValue], coordY - tam_y/2.0 , tam_x, tam_y)];
            } else {
                [[dialoguesViews objectAtIndex:i] setFrame:CGRectMake(coordX * [[anglesViews objectAtIndex:i] doubleValue], coordY - tam_y/2.0 + tam_y, tam_x, highLabel)];
                [[namesViews objectAtIndex:i] setFrame:CGRectMake(coordX * [[anglesViews objectAtIndex:i] doubleValue] + 5., coordY - tam_y/2.0 + tam_y, tam_x-10., highLabel)];
                [[imagesViews objectAtIndex:i] setFrame:CGRectMake(coordX * [[anglesViews objectAtIndex:i] doubleValue], coordY - tam_y/2.0 , tam_x, tam_y)];
            }
        }
        [UIView commitAnimations];
    }
}


- (void)minimalDistance{
    //NSLog(@"minimalDistance");
    NSNumber *index = [NSNumber numberWithInt:0];
    NSString *deviceType = [UIDevice currentDevice].model;
    double center;
    if([deviceType isEqualToString:@"iPad"])
        center = 384.;
    else
        center = 160.;
    double minDistance = fabs([[imagesViews objectAtIndex:0] frame].origin.x - center);
    /*for (NSInteger i = 0; i < [imagesViews count]; i++) {
     double aux = fabs([[imagesViews objectAtIndex:i] frame].origin.x - center);
     if (aux < minDistance) {
     minDistance = aux;
     index = [NSNumber numberWithInt:i];
     }
     }*/
    
    for (NSUInteger j = 0; j < [indexes count]; j++) {
        NSUInteger indice = [[indexes objectAtIndex:j] intValue];
        double aux = fabs([[imagesViews objectAtIndex:indice] frame].origin.x - center);
        if (aux < minDistance) {
            minDistance = aux;
            index = [NSNumber numberWithInteger:indice];
        }
    }
    
    [self performSelector:@selector(bringSubviewsToFrontWithIndex:) withObject:index];
}


- (void)bringSubviewsToFrontWithIndex:(NSNumber *)index{
    //NSLog(@"bringSubviewsToFrontWithIndex");
    
    NSArray *arrayViews = [[NSArray alloc] initWithObjects:[dialoguesViews objectAtIndex:[index intValue]],
                           [imagesViews objectAtIndex:[index intValue]],
                           [namesViews objectAtIndex:[index intValue]],
                           compassView, angleView, dialogueView /*dialogueBackgrond*/,
                           titleLabel, distanceLabel, dialogueText,
                           closeButton, nil];
    
    for (NSUInteger i = 0; i < [arrayViews count]; i++) {
        [self.view bringSubviewToFront:[arrayViews objectAtIndex:i]];
    }
    
    /*[self.view bringSubviewToFront:[dialoguesViews objectAtIndex:[index intValue]]];
     [self.view bringSubviewToFront:[imagesViews objectAtIndex:[index intValue]]];
     [self.view bringSubviewToFront:[namesViews objectAtIndex:[index intValue]]];
     [self.view bringSubviewToFront:compassView];
     [self.view bringSubviewToFront:angleView];
     [self.view bringSubviewToFront:dialogueView];
     [self.view bringSubviewToFront:titleLabel];
     [self.view bringSubviewToFront:distanceLabel];
     [self.view bringSubviewToFront:dialogueText];
     [self.view bringSubviewToFront:closeButton];*/
}


- (void)startAccelerometer {
    //NSLog(@"startAccelerometer");
    /*UIAccelerometer *accelerometer = [UIAccelerometer sharedAccelerometer];
    accelerometer.delegate = self;
    accelerometer.updateInterval = .025;*/
    [self startMyMotionDetect];
}


- (void)stopAccelerometer {
    //NSLog(@"stopAccelerometer");
    /*UIAccelerometer *accelerometer = [UIAccelerometer sharedAccelerometer];
    accelerometer.delegate = nil;*/
    [self.motionManager stopAccelerometerUpdates];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)goToMap{
    //NSLog(@"goToMap");
    [CLController.locMgr stopUpdatingHeading];
    [CLController.locMgr stopUpdatingLocation];
    [self stopCameraCapture];
    [timer invalidate];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    [CLController.locMgr stopUpdatingHeading];
    [CLController.locMgr stopUpdatingLocation];
    [self stopCameraCapture];
    self.cameraView = nil;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
