//
//  LocationViewController.m
//  7sEvents
//
//  Created by Vladimir Rojas on 16/06/14.
//  Copyright (c) 2014 7Seconds Technologies. All rights reserved.
//

#import "LocationViewController.h"
#import "MenuViewController.h"
#import "LocationDetailViewController.h"
#import "AppDelegate.h"

#import "ARViewController.h"

#import <MapKit/MapKit.h>

#define ZOOM_LEVEL 0.07

#pragma mark - AddressAnnotation Class

@implementation AddressAnnotation

@synthesize coordinate;

- (NSString *)subtitle{
    return mSubTitle;
}
- (NSString *)title{
    return mTitle;
}

- (NSNumber *)tag{
    return tag;
}

- (id)initWithCoordinate:(CLLocationCoordinate2D)coord
                   title:(NSString *)title
                subtitle:(NSString *)subtitle
                     tag:(NSNumber *)_tag {
    coordinate = coord;
    mTitle = title;
    mSubTitle = subtitle;
    tag = _tag;
    return self;
}

@end

@interface LocationViewController ()
{
    IBOutlet MKMapView *mapView;
    
    BOOL userLocation;
    NSArray *contentArray;
    NSMutableArray *addresses;
    NSMutableArray *distances;
    UIImageView *blurImageView;
    CLLocationManager *locationManager;
}

@end

@implementation LocationViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    userLocation = NO;
    [self setTitle:@" "];
    UILabel *label = [[MenuViewController menuController] labelWithTitle:@"sucursales"];
    self.navigationItem.titleView = label;
    
    [self performSelector:@selector(setUserLocation) withObject:nil afterDelay:1.f];
}

- (void)viewWillAppear:(BOOL)animated
{
    [[[self navigationController] navigationBar] setBackgroundImage:[UIImage imageNamed:@"nav_bg2"] forBarMetrics:UIBarMetricsDefault];
}

- (void)loadDistancesFromCurrentLocation
{
    
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    delegate.distances = [[NSMutableArray alloc] initWithCapacity:[delegate.lugaresList count]];
    [delegate.distances removeAllObjects];
    
    NSString* plistPath = [[NSBundle mainBundle] pathForResource:@"CAC_CFE" ofType:@"plist"];
    contentArray = [NSArray arrayWithContentsOfFile:plistPath];
    distances = [[NSMutableArray alloc] init];
    addresses = [[NSMutableArray alloc] init];
    
    for (NSInteger i = 0; i < [contentArray count]; i++) {
        CLLocation *myLocation = [locationManager location];
        //NSLog(@"myLocation: %@ %@", @(myLocation.coordinate.latitude), @(myLocation.coordinate.longitude));
        if ([[[contentArray objectAtIndex:i] objectForKey:@"latitud"] doubleValue] != 0 &&
            [[[contentArray objectAtIndex:i] objectForKey:@"longitud"] doubleValue] != 0) {
            CLLocation *locationAddress = [[CLLocation alloc] initWithLatitude:[[[contentArray objectAtIndex:i] objectForKey:@"latitud"] doubleValue]
                                                                     longitude:
                [[[contentArray objectAtIndex:i] objectForKey:@"longitud"] doubleValue]];
            CLLocationDistance distance = [myLocation distanceFromLocation:locationAddress];
            //NSLog(@"distance: %@", @(distance));
            
            [distances addObject:[NSNumber numberWithDouble:distance]];
            [delegate.distances addObject:[NSNumber numberWithDouble:distance]];
            
            [addresses addObject:[contentArray objectAtIndex:i]];
            
            NSString *sSubtitle;
            AddressAnnotation *addAnnotation;
            CLLocationCoordinate2D locationCoordinateAddress = CLLocationCoordinate2DMake([[[contentArray objectAtIndex:i] objectForKey:@"latitud"] doubleValue], [[[contentArray objectAtIndex:i] objectForKey:@"longitud"] doubleValue]);
            
            //CLLocationCoordinate2D locationCoordinateAddress = CLLocationCoordinate2DMake(19.2666828,-99.1229282);
            
            if (distance == 0)
                sSubtitle = @"";
            else if(distance >= 1000)
                sSubtitle = [[NSString alloc] initWithFormat:@"Está a: %.2lf kilómetros", distance/1000.];
            else
                sSubtitle = [[NSString alloc] initWithFormat:@"Está a: %.0lf metros", distance];
            
            //NSLog(@"%@, %@: %@", @(locationCoordinateAddress.latitude), @(locationCoordinateAddress.longitude), @(distance));
            if (distance < 3000.){
                //NSLog(@"addPin!");
                addAnnotation = [[AddressAnnotation alloc] initWithCoordinate:locationCoordinateAddress title:[[contentArray objectAtIndex:i] objectForKey:@"colonia"] subtitle:sSubtitle tag:[NSNumber numberWithInteger:i]];
                [mapView addAnnotation:addAnnotation];
            }
        }
    }
    //NSLog(@"count: %@", @([distances count]));
}

- (MKAnnotationView *) mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>) annotation{
    if([annotation isKindOfClass:[MKUserLocation class]])
        return nil;
    if ([annotation isKindOfClass:[AddressAnnotation class]]) {
        
        AddressAnnotation *tmp = (AddressAnnotation *)annotation;
        
        MKPinAnnotationView *annView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:nil];
        annView.canShowCallout = YES;
        UIImage *flagImage;
        flagImage = [UIImage imageNamed:@"CFE-13"];
        
        CGSize newSize = CGSizeMake(31, 39);
        
        UIImageView *myImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logo_cfe"]];
        myImageView.frame = CGRectMake(0.f, 0.f, 40.f, 40.f);
        annView.leftCalloutAccessoryView = myImageView;
        
        UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        [rightButton addTarget:self action:@selector(loadDetail:) forControlEvents:UIControlEventTouchUpInside];
        rightButton.tag = [[tmp tag] integerValue];
        annView.rightCalloutAccessoryView = rightButton;
        
        if(UIGraphicsBeginImageContextWithOptions != NULL){
            UIGraphicsBeginImageContextWithOptions(newSize, NO, 2);
        } else
            UIGraphicsBeginImageContext(newSize);
        
        [flagImage drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
        UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        flagImage = newImage;
        annView.image = flagImage;
        annView.opaque = NO;
        return annView;
    }
    return nil;
}

- (void)loadDetail:(UIButton *)sender
{
    //NSLog(@"%@", [contentArray objectAtIndex:[sender tag]]);
    UIStoryboard *storyboard = nil;
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
    {
        CGSize iOSDeviceScreenSize = [[UIScreen mainScreen] bounds].size;
        if (iOSDeviceScreenSize.height == 480)
        {
            storyboard = [UIStoryboard storyboardWithName:@"Main_iPhone4" bundle:nil];
        }
        if (iOSDeviceScreenSize.height == 568)
        {
            storyboard = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:nil];
        }
        
    }
    else if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad)
    {
        storyboard = [UIStoryboard storyboardWithName:@"Main_iPad" bundle:nil];
    }
    LocationDetailViewController *locationDetailVC = [storyboard instantiateViewControllerWithIdentifier:@"LocationDetailViewController"];
    [locationDetailVC setData:[contentArray objectAtIndex:[sender tag]]];
    //locationDetailVC.latitude = [[locationManager location] coordinate].latitude;
    //locationDetailVC.longitude = [[locationManager location] coordinate].longitude;
    [[self navigationController] pushViewController:locationDetailVC animated:YES];
}

- (UIImageView *)loadBlurView
{
    @autoreleasepool {
        UIGraphicsBeginImageContext(self.view.bounds.size);
        [self.view.layer renderInContext:UIGraphicsGetCurrentContext()];
        UIImage *viewImg = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        CIImage *blurImg = [CIImage imageWithCGImage:viewImg.CGImage];
        CGAffineTransform transform = CGAffineTransformIdentity;
        CIFilter *clampFilter = [CIFilter filterWithName:@"CIAffineClamp"];
        [clampFilter setValue:blurImg forKey:@"inputImage"];
        [clampFilter setValue:[NSValue valueWithBytes:&transform objCType:@encode(CGAffineTransform)] forKey:@"inputTransform"];
        
        CIFilter *gaussianBlurFilter = [CIFilter filterWithName: @"CIGaussianBlur"];
        [gaussianBlurFilter setValue:clampFilter.outputImage forKey: @"inputImage"];
        [gaussianBlurFilter setValue:[NSNumber numberWithFloat:7.0f] forKey:@"inputRadius"];
        
        CIContext *context = [CIContext contextWithOptions:nil];
        CGImageRef cgImg = [context createCGImage:gaussianBlurFilter.outputImage fromRect:[blurImg extent]];
        UIImage *outputImg = [UIImage imageWithCGImage:cgImg];
        cgImg = nil;
        CGImageRelease(cgImg);
        
        UIView *blurView = [[UIImageView alloc] initWithFrame:self.view.bounds];
        [blurView setBackgroundColor:[UIColor colorWithWhite:.15f alpha:0.5]];
        UIImageView *imgView = [[UIImageView alloc] initWithFrame:self.view.bounds];
        imgView.image = outputImg;
        [imgView addSubview:blurView];
        return imgView;
    }
}

- (void)setUserLocation
{
    locationManager = [[CLLocationManager alloc] init];
    [locationManager setDelegate:self];
#ifdef __IPHONE_8_0
    if (IS_OS_8_OR_LATER) {
        [locationManager requestWhenInUseAuthorization];
        [locationManager requestAlwaysAuthorization];
    }
#endif
    [locationManager setDesiredAccuracy:kCLLocationAccuracyBestForNavigation];
    [locationManager startUpdatingLocation];
}

// Delegate method from the CLLocationManagerDelegate protocol.
- (void)locationManager:(CLLocationManager *)manager
     didUpdateLocations:(NSArray *)locations {
    // If it's a relatively recent event, turn off updates to save power.
    if (!userLocation) {
        CLLocation* location = [locations lastObject];
        NSDate* eventDate = location.timestamp;
        NSTimeInterval howRecent = [eventDate timeIntervalSinceNow];
        if (abs(howRecent) < 15.0) {
            // If the event is recent, do something with it.
            
            MKCoordinateRegion region;
            CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude);
            region.center = coordinate;
            region.span = MKCoordinateSpanMake(ZOOM_LEVEL, ZOOM_LEVEL);
            region = [mapView regionThatFits:region];
            [mapView setRegion:region animated:YES];
            userLocation = YES;
            [self loadDistancesFromCurrentLocation];
            
            NSLog(@"latitude %+.6f, longitude %+.6f\n",
                  location.coordinate.latitude,
                  location.coordinate.longitude);
        }
    }
}

- (IBAction)showMenu:(id)sender
{
    blurImageView = [self loadBlurView];
    [blurImageView setAlpha:0.0f];
    [self.view addSubview:blurImageView];
    [UIView animateWithDuration:0.6f animations:^{
        [blurImageView setAlpha:1.0f];
    }];
    [[MenuViewController menuController] showMenu];
}

/*- (IBAction)loadARViewController:(id)sender
{
    UIStoryboard *storyboard = nil;
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
    {
        CGSize iOSDeviceScreenSize = [[UIScreen mainScreen] bounds].size;
        if (iOSDeviceScreenSize.height == 480)
        {
            storyboard = [UIStoryboard storyboardWithName:@"Main_iPhone4" bundle:nil];
        }
        if (iOSDeviceScreenSize.height == 568)
        {
            storyboard = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:nil];
        }
        
    }
    else if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad)
    {
        storyboard = [UIStoryboard storyboardWithName:@"Main_iPad" bundle:nil];
    }
    
    ARViewController *arVC = [storyboard instantiateViewControllerWithIdentifier:@"ARViewController"];
    [self presentViewController:arVC animated:YES completion:nil];
}*/

- (void)hideMenuController
{
    [blurImageView setAlpha:1.0f];
    [UIView animateWithDuration:0.6f animations:^{
        [blurImageView setAlpha:0.0f];
    } completion:^(BOOL finished){
        [blurImageView removeFromSuperview];
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
 {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
