//
//  LocationDetailViewController.m
//  CFE Móvil
//
//  Created by Vladimir Rojas on 26/10/14.
//  Copyright (c) 2014 7Seconds Technologies. All rights reserved.
//

#import "LocationDetailViewController.h"
#import "MenuViewController.h"
#import <MapKit/MapKit.h>

#define ZOOM_LEVEL 0.001

@interface LocationDetailViewController ()
{
    IBOutlet MKMapView *mapView;
    IBOutlet UILabel *colony;
    IBOutlet UILabel *address;
    IBOutlet UILabel *attention;
    IBOutlet UILabel *horary;
    IBOutlet UILabel *cfematico;
    
    float latitude;
    float longitude;
}

@end

@implementation LocationDetailViewController

@synthesize data;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UILabel *label = [[MenuViewController menuController] labelWithTitle:@"sucursales"];
    self.navigationItem.titleView = label;
    
    [colony setText:[data objectForKey:@"colonia"]];
    [address setText:[data objectForKey:@"direccion"]];
    [attention setText:[data objectForKey:@"dias"]];
    [horary setText:[data objectForKey:@"horario"]];
    
    if (![[data objectForKey:@"val5"] integerValue]) {
        [cfematico removeFromSuperview];
    }
    
    latitude = [[data objectForKey:@"latitud"] doubleValue];
    longitude = [[data objectForKey:@"longitud"] doubleValue];
    
    MKCoordinateRegion region;
    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(latitude, longitude);
    region.center = coordinate;
    region.span = MKCoordinateSpanMake(ZOOM_LEVEL, ZOOM_LEVEL);
    region = [mapView regionThatFits:region];
    [mapView setRegion:region animated:YES];
    
    MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
    [annotation setCoordinate:coordinate];
    //[annotation setTitle:@"CFE"]; //You can set the subtitle too
    [mapView addAnnotation:annotation];
}

- (MKAnnotationView *) mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>) annotation{
    if([annotation isKindOfClass:[MKUserLocation class]])
        return nil;
    
    MKAnnotationView *annView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:nil];
    annView.canShowCallout = YES;
    UIImage *flagImage;
    flagImage = [UIImage imageNamed:@"CFE-13"];
    CGSize newSize = CGSizeMake(31, 39);
    
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

- (IBAction)drivingToLocation:(id)sender
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                  initWithTitle:nil
                                  delegate:self
                                  cancelButtonTitle:@"Cancelar"
                                  destructiveButtonTitle:nil
                                  otherButtonTitles:@"Mapas iOS", @"Google Maps", nil];
    [actionSheet showInView:[self view]];
}

#pragma mark - Action Sheet Delegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(latitude,longitude);
    
    //Create MKMapItem out of coordinates
    MKPlacemark* placeMark = [[MKPlacemark alloc] initWithCoordinate:coordinate addressDictionary:nil];
    MKMapItem* destination =  [[MKMapItem alloc] initWithPlacemark:placeMark];
    
    if (buttonIndex == 0) {
        if([destination respondsToSelector:@selector(openInMapsWithLaunchOptions:)])
        {
            //Using iOS native Maps app
            [destination openInMapsWithLaunchOptions:@{MKLaunchOptionsDirectionsModeKey:MKLaunchOptionsDirectionsModeDriving}];
        }
    }
    else if(buttonIndex == 1)
    {
        //Using iOS which has the Google Maps application
        NSString* url = [NSString stringWithFormat: @"http://maps.google.com/maps?saddr=%f,%f&daddr=%f,%f", [[[mapView userLocation] location] coordinate].latitude, [[[mapView userLocation] location] coordinate].longitude, latitude, longitude];
        [[UIApplication sharedApplication] openURL: [NSURL URLWithString: url]];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
