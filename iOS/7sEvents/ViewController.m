//
//  ViewController.m
//  7sEvents
//
//  Created by Vladimir Rojas on 16/06/14.
//  Copyright (c) 2014 7Seconds Technologies. All rights reserved.
//

#import "ViewController.h"
#import "MenuViewController.h"
#import "SettingsViewController.h"
#import "OnlinePaymentViewController.h"
#import "AppDelegate.h"

#import <CoreLocation/CoreLocation.h>

@interface ViewController ()
{
    UIViewController *rootController;
}

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[[self navigationController] navigationBar] setBackgroundImage:[UIImage imageNamed:@"navigationBar"] forBarMetrics:UIBarMetricsDefault];
    [[[self navigationController] navigationBar] setShadowImage:[UIImage new]];
    [[[self navigationController] navigationBar] setTintColor:[UIColor colorWithRed:234.f/255.f green:227.f/255.f blue:183.f/255.f alpha:1.f]];
    
    [[[self navigationController] view] addSubview:[[MenuViewController menuController] view]];
    [[MenuViewController menuController] setDelegate:self];
    [[MenuViewController menuController] hideMenu];
    
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
    
    delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    //Detecta si el dispositivo tiene camara
    delegate.hasCamera = [UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera];
    delegate.headingAvailable = NO;
    if( [CLLocationManager locationServicesEnabled] && [CLLocationManager headingAvailable]){
        delegate.headingAvailable = YES;
    }
    
    [self performSelector:@selector(loadData)];
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    if ([prefs boolForKey:@"settings"]) {
        OnlinePaymentViewController *infoVC = (OnlinePaymentViewController *)[storyboard instantiateViewControllerWithIdentifier:@"OnlinePaymentViewController"];
        [[self navigationController] pushViewController:infoVC animated:NO];
        rootController = infoVC;
    } else {
        NSInteger total = [self getRandomNumberBetween:120 to:450];
        [prefs setInteger:total forKey:@"settings:total"];
        
        SettingsViewController *infoVC = (SettingsViewController *)[storyboard instantiateViewControllerWithIdentifier:@"InfoViewController"];
        [[self navigationController] pushViewController:infoVC animated:NO];
        rootController = infoVC;
    }
}

- (void)loadData
{
    NSString* plistPath = [[NSBundle mainBundle] pathForResource:@"CAC_CFE" ofType:@"plist"];
    NSArray *lugares = [NSArray arrayWithContentsOfFile:plistPath];
    delegate.lugaresList = [[NSMutableArray alloc] initWithCapacity:[lugares count]];
    //NSLog(@"lugaresCount = %d", [lugares count]);
    NSDictionary *lugar;
    NSInteger i = 0;
    for (lugar in lugares){
        if([lugar isKindOfClass:[NSDictionary class]]){
            
            if ([[[lugares objectAtIndex:i] objectForKey:@"latitud"] doubleValue] != 0 &&
                [[[lugares objectAtIndex:i] objectForKey:@"longitud"] doubleValue] != 0){
                Lugar *nuevoLugar = [[Lugar alloc] init];
                nuevoLugar.atm = [lugar objectForKey:@"val5"];
                nuevoLugar.calle = [lugar objectForKey:@"direccion"];
                nuevoLugar.cp = @(1234);
                nuevoLugar.colonia = @"colonia";
                nuevoLugar.estado = @"estado";
                nuevoLugar.horario = [lugar objectForKey:@"horario"];
                nuevoLugar.kiosco = @(1234);
                nuevoLugar.latitud = [lugar objectForKey:@"latitud"];
                nuevoLugar.longitud = [lugar objectForKey:@"longitud"];
                nuevoLugar.municipio = @"municipio";
                nuevoLugar.numero = @(1234);
                nuevoLugar.referencias = [lugar objectForKey:@"dias"];
                nuevoLugar.title = [lugar objectForKey:@"colonia"];
                [delegate.lugaresList  addObject:nuevoLugar];
                i++;
            }
        }
    }
}

- (NSInteger)getRandomNumberBetween:(NSInteger)from to:(NSInteger)to
{
    return (NSInteger)from + arc4random() % (to-from+1);
}

- (void)selectedViewController:(id)viewController
{
    rootController = viewController;
    [[MenuViewController menuController] hideMenu];
    [[self navigationController] popToRootViewControllerAnimated:NO];
    [[self navigationController] pushViewController:viewController animated:NO];
}

- (void)hideMenuController
{
    if ([rootController respondsToSelector:@selector(hideMenuController)]) {
        [rootController performSelector:@selector(hideMenuController) withObject:nil];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
