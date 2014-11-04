//
//  MenuViewController.m
//  7sEvents
//
//  Created by Vladimir Rojas on 16/06/14.
//  Copyright (c) 2014 7Seconds Technologies. All rights reserved.
//

#import "MenuViewController.h"
#import "SettingsViewController.h"
#import "LocationViewController.h"
#import "ErrorReportViewController.h"
#import "OnlinePaymentViewController.h"
#import "MyReportsViewController.h"
#import "RegistrationViewController.h"
#import "StreamingViewController.h"
#import "SponsorsViewController.h"
#import "WeatherViewController.h"
#import "TYDotIndicatorView.h"
#import "ComplaintsReportViewController.h"
#import "ViewController.h"

@interface MenuViewController ()
{
    IBOutlet UIView *backgroundView;
    IBOutlet UILabel *countLabel;
    IBOutlet UIImageView *badgeImage;
    IBOutlet UIScrollView *scrollView;
    IBOutletCollection(UILabel) NSArray *menuLabels;
    
    TYDotIndicatorView *darkCircleDot;
}

@end

@implementation MenuViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

+ (MenuViewController *)menuController
{
    static  MenuViewController *singleton = nil;
    @synchronized(self) {
        if (!singleton) {
            singleton = [self new];
        }
    }
    return singleton;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self performSelector:@selector(setScrollView) withObject:nil afterDelay:0.5f];
    UIFont *customFont = [UIFont fontWithName:@"BaronNeue" size:12.f];
    for (UILabel *label in menuLabels) {
        label.textColor = [UIColor colorWithRed:234.f/255.f green:227.f/255.f blue:183.f/255.f alpha:1.f];
        [label setFont:customFont];
    }
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if (![defaults objectForKey:@"fallasCount"]) {
        [defaults setObject:[NSNumber numberWithInteger:0] forKey:@"fallasCount"];
    } else if (![defaults objectForKey:@"quejasCount"]){
        [defaults setObject:[NSNumber numberWithInteger:0] forKey:@"quejasCount"];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reloadReports:)
                                                 name:@"reloadReports"
                                               object:nil];
    
    NSInteger count = [[defaults objectForKey:@"fallasCount"] integerValue] + [[defaults objectForKey:@"quejasCount"] integerValue];
    if (count) {
        [countLabel setText:[NSString stringWithFormat:@"%@", @(count)]];
    } else {
        [countLabel setHidden:YES];
        [badgeImage setHidden:YES];
    }
}

- (void)reloadReports:(NSNotification *)notification
{
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray *fallas = [[NSMutableArray alloc] initWithArray:[defaults objectForKey:[[notification valueForKey:@"object"] valueForKey:@"tipo"]]];
    NSMutableDictionary *report = [[NSMutableDictionary alloc] initWithDictionary:[fallas objectAtIndex:[[[notification valueForKey:@"object"] valueForKey:@"ID"] integerValue] - 1]];
    [report setValue:@"Atendido" forKey:@"estatus"];
    [fallas setObject:report atIndexedSubscript:[[[notification valueForKey:@"object"] valueForKey:@"ID"] integerValue] - 1];
    [defaults setObject:fallas forKey:[[notification valueForKey:@"object"] valueForKey:@"tipo"]];
    
    NSInteger count;
    NSString *message;
    
    if ([[[notification valueForKey:@"object"] valueForKey:@"tipo"] isEqualToString:@"fallas"]) {
        count = [[defaults objectForKey:@"fallasCount"] integerValue] + 1;
        [defaults setObject:[NSNumber numberWithInteger:count] forKey:@"fallasCount"];
        message = [[NSString alloc] initWithFormat:@"Se atendió tu reporte de falla, puedes seguirla en la sección Mis Reportes"];
    } else if ([[[notification valueForKey:@"object"] valueForKey:@"tipo"] isEqualToString:@"quejas"]) {
        count = [[defaults objectForKey:@"quejasCount"] integerValue] + 1;
        [defaults setObject:[NSNumber numberWithInteger:count] forKey:@"quejasCount"];
        message = [[NSString alloc] initWithFormat:@"Se atendió tu queja, puedes seguirla en la sección Mis Reportes"];
    }
    count = [[defaults objectForKey:@"fallasCount"] integerValue] + [[defaults objectForKey:@"quejasCount"] integerValue];
    
    if (count) {
        [countLabel setHidden:NO];
        [badgeImage setHidden:NO];
        [countLabel setText:[NSString stringWithFormat:@"%@", @(count)]];
    } else {
        [countLabel setHidden:YES];
        [badgeImage setHidden:YES];
    }
    
    [defaults synchronize];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"CFE Móvil te informa"
                                                    message:message
                                                   delegate:self cancelButtonTitle:@"Aceptar"
                                          otherButtonTitles:nil];
    [alert show];
    //NSLog(@"notification:%@ \nfallas: %@\nquejas: %@", [notification valueForKey:@"object"], [defaults objectForKey:@"fallas"], [defaults objectForKey:@"quejas"]);
}

- (void)reloadBadge
{
    NSInteger count;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    count = [[defaults objectForKey:@"fallasCount"] integerValue] + [[defaults objectForKey:@"quejasCount"] integerValue];
    
    if (count) {
        [countLabel setHidden:NO];
        [badgeImage setHidden:NO];
        [countLabel setText:[NSString stringWithFormat:@"%@", @(count)]];
    } else {
        [countLabel setHidden:YES];
        [badgeImage setHidden:YES];
    }
}

- (void)reloadReportsWithNotification:(NSNotification *)notification
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray *fallas = [[NSMutableArray alloc] initWithArray:[defaults objectForKey:[[notification userInfo] objectForKey:@"tipo"]]];
    NSMutableDictionary *report = [[NSMutableDictionary alloc] initWithDictionary:[fallas objectAtIndex:[[[notification userInfo] valueForKey:@"ID"] integerValue] - 1]];
    [report setValue:@"Atendido" forKey:@"estatus"];
    [fallas setObject:report atIndexedSubscript:[[[notification userInfo] valueForKey:@"ID"] integerValue] - 1];
    [defaults setObject:fallas forKey:[[notification userInfo] valueForKey:@"tipo"]];
    
    NSInteger count;
    NSString *message;
    if ([[[notification userInfo] valueForKey:@"tipo"] isEqualToString:@"fallas"]) {
        count = [[defaults objectForKey:@"fallasCount"] integerValue] + 1;
        [defaults setObject:[NSNumber numberWithInteger:count] forKey:@"fallasCount"];
        message = [[NSString alloc] initWithFormat:@"Se ha atendido tu reporte de falla, puedes seguirla en la sección Mis Reportes"];
    } else if ([[[notification userInfo] valueForKey:@"tipo"] isEqualToString:@"quejas"]) {
        count = [[defaults objectForKey:@"quejasCount"] integerValue] + 1;
        [defaults setObject:[NSNumber numberWithInteger:count] forKey:@"quejasCount"];
        message = [[NSString alloc] initWithFormat:@"Se ha atendido tu queja, puedes seguirla en la sección Mis Reportes"];
    }
    count = [[defaults objectForKey:@"fallasCount"] integerValue] + [[defaults objectForKey:@"quejasCount"] integerValue];
    
    if (count) {
        [countLabel setHidden:NO];
        [badgeImage setHidden:NO];
        [countLabel setText:[NSString stringWithFormat:@"%@", @(count)]];
    } else {
        [countLabel setHidden:YES];
        [badgeImage setHidden:YES];
    }
    
    [defaults synchronize];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"CFE Móvil te informa"
                                                    message:message
                                                   delegate:self cancelButtonTitle:@"Aceptar"
                                          otherButtonTitles:nil];
    [alert show];
}

- (void)setScrollView
{
    [scrollView setShowsVerticalScrollIndicator:NO];
    [scrollView setContentSize:CGSizeMake([backgroundView frame].size.width, [backgroundView frame].size.height)];
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
    {
        CGSize iOSDeviceScreenSize = [[UIScreen mainScreen] bounds].size;
        if (iOSDeviceScreenSize.height == 480)
        {
            //[scrollView setContentSize:CGSizeMake([backgroundView frame].size.width, [backgroundView frame].size.height + 88.f)];
        }
    }
}

- (void)showMenu
{
    if ([[self view] frame].origin.x < 0) {
        [UIView animateWithDuration:0.6f animations:^{
            [[self view] setFrame:CGRectMake(
                                             [[self view] frame].origin.x + 320.f,
                                             [[self view] frame].origin.y,
                                             [[self view] frame].size.width,
                                             [[self view] frame].size.height)];
        }];
    }
}

- (void)hideMenu
{
    [UIView animateWithDuration:0.6f animations:^{
        [[self view] setFrame:CGRectMake(
                                         [[self view] frame].origin.x - 320.f,
                                         [[self view] frame].origin.y,
                                         [[self view] frame].size.width,
                                         [[self view] frame].size.height)];
    }];
}

- (UILabel *)labelWithTitle:(NSString *)title
{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
    label.backgroundColor = [UIColor clearColor];
    UIFont *customFont = [UIFont fontWithName:@"BaronNeue" size:13.f];
    label.font = customFont;
    label.shadowColor = [UIColor colorWithWhite:0.0
                                          alpha:0.0];
    label.textColor = [UIColor colorWithRed:234.f/255.f
                                      green:227.f/255.f
                                       blue:183.f/255.f
                                      alpha:1.f];
    label.text = title;
    [label sizeToFit];
    CGRect frame = CGRectMake(label.frame.origin.x,
                              label.frame.origin.y,
                              label.frame.size.width,
                              label.frame.size.height + 10.f);
    [label setFrame:frame];
    return label;
}

- (IBAction)blankPressed:(id)sender
{
    [self hideMenu];
    if ([[self delegate] respondsToSelector:@selector(hideMenuController)]) {
        [[self delegate] hideMenuController];
    }
}

- (IBAction)selectedButtonAtIndex:(id)sender
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
    id viewController;
    
    /*UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"CFE Móvil"
                                                        message:@"Módulo en desarrollo"
                                                       delegate:nil
                                              cancelButtonTitle:@"Aceptar"
                                              otherButtonTitles:nil];*/
    
    switch ([sender tag]) {
        case 0:
            viewController = (OnlinePaymentViewController *)[storyboard instantiateViewControllerWithIdentifier:@"OnlinePaymentViewController"];
            break;
        case 1:
            viewController = (LocationViewController *)[storyboard instantiateViewControllerWithIdentifier:@"LocationViewController"];
            break;
        case 2:
            viewController = (ErrorReportViewController *)[storyboard instantiateViewControllerWithIdentifier:@"PlaneViewController"];
            break;
        case 3:
            viewController = (ComplaintsReportViewController *)[storyboard instantiateViewControllerWithIdentifier:@"ComplaintsViewController"];
            break;
        case 4:
            viewController = (MyReportsViewController *)[storyboard instantiateViewControllerWithIdentifier:@"PresentationsViewController"];
            break;
        case 5:
            viewController = (RegistrationViewController *)[storyboard instantiateViewControllerWithIdentifier:@"RegistrationViewController"];
            //[alertView show];
            //return;
            break;
        case 6:
            //viewController = (PreviousEventsViewController *)[storyboard instantiateViewControllerWithIdentifier:@"PreviousEventsViewController"];
            viewController = (SettingsViewController *)[storyboard instantiateViewControllerWithIdentifier:@"InfoViewController"];
            break;
        case 7:
            viewController = (StreamingViewController *)[storyboard instantiateViewControllerWithIdentifier:@"StreamingViewController"];
            break;
        case 8:
            //viewController = (TicketViewController *)[storyboard instantiateViewControllerWithIdentifier:@"TicketViewController"];
            break;
        case 9:
            viewController = (SponsorsViewController *)[storyboard instantiateViewControllerWithIdentifier:@"SponsorsViewController"];
            break;
        case 10:
            viewController = (WeatherViewController *)[storyboard instantiateViewControllerWithIdentifier:@"WeatherViewController"];
            break;
        default:
            break;
    }
    
    if ([[self delegate] respondsToSelector:@selector(selectedViewController:)]) {
        [[self delegate] selectedViewController:viewController];
    }
}

- (void)showActivityIndicator
{
    CGRect bounds = [[self view] bounds];
    darkCircleDot = [[TYDotIndicatorView alloc] initWithFrame:CGRectMake(100, (bounds.size.height / 2.) - 25., 120, 50)
                                                     dotStyle:TYDotIndicatorViewStyleCircle
                                                     dotColor:[UIColor colorWithWhite:0.8 alpha:0.9]
                                                      dotSize:CGSizeMake(15, 15)];
    darkCircleDot.backgroundColor = [UIColor colorWithRed:0.22 green:0.22 blue:0.22 alpha:0.9];
    [darkCircleDot startAnimating];
    darkCircleDot.layer.cornerRadius = 5.0f;
    [self.view addSubview:darkCircleDot];
}

- (void)dismissActivityIndicator
{
    [UIView animateWithDuration:0.f animations:^{
        [darkCircleDot setAlpha:0.f];
    }];
}

#pragma mark -

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
