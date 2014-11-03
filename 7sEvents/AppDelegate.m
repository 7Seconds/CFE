//
//  AppDelegate.m
//  7sEvents
//
//  Created by Vladimir Rojas on 16/06/14.
//  Copyright (c) 2014 7Seconds Technologies. All rights reserved.
//

#import "AppDelegate.h"
#import "PayPalMobile.h"
#import "MenuViewController.h"
#import "ViewController.h"

@implementation AppDelegate

@synthesize lugaresList;
@synthesize distances;
@synthesize estado, mpo, lugar;
@synthesize hasCamera, headingAvailable;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    /*UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"CFE Móvil" message:[launchOptions description] delegate:nil cancelButtonTitle:@"Aceptar" otherButtonTitles:nil];
    [alertView show];*/
    
    [NSThread sleepForTimeInterval:2.0];
    
    if ([UIApplication instancesRespondToSelector:@selector(registerUserNotificationSettings:)]){
        [application registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert|UIUserNotificationTypeBadge|UIUserNotificationTypeSound categories:nil]];
    }
    
    UILocalNotification *locationNotification = [launchOptions objectForKey:UIApplicationLaunchOptionsLocalNotificationKey];
    if (locationNotification) {
        NSLog(@"notification to zero...");
        application.applicationIconBadgeNumber = 0;
    }
    
    [PayPalMobile initializeWithClientIdsForEnvironments:@{PayPalEnvironmentProduction : @"YOUR_CLIENT_ID_FOR_PRODUCTION",
                                                           PayPalEnvironmentSandbox : @"AdmFchBa37xOnCyRiM2iUOEG3wK1iMNOpNBRoCDEerZbaTZiRl7e4Dhs-2An"}];
    [self initializeStoryBoardBasedOnScreenSizeWithOptions:launchOptions];
    return YES;
}

- (void)initializeStoryBoardBasedOnScreenSizeWithOptions:(NSDictionary *)launchOptions {
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

    UIViewController *initialViewController = [storyboard instantiateInitialViewController];
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.rootViewController = initialViewController;
    [self.window makeKeyAndVisible];
    
    NSNotification *notification = [launchOptions objectForKey:@"UIApplicationLaunchOptionsLocalNotificationKey"];
    if (launchOptions) {
        [[MenuViewController menuController] reloadReportsWithNotification:notification];
    }
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    NSLog(@"didReceiveLocalNotification: %@", [[notification userInfo] objectForKey:@"ID"]);
    //UIApplicationState state = [application applicationState];
    /*UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Se atendió el reporte"
                                                    message:notification.alertBody
                                                   delegate:self cancelButtonTitle:@"Aceptar"
                                          otherButtonTitles:nil];
    [alert show];*/
    
    // Request to reload table view data
    [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadReports" object:[notification userInfo]];
    
    // Set icon badge number to zero
    application.applicationIconBadgeNumber = 0;
}

- (CMMotionManager *)motionManager
{
    if (!motionManager) motionManager = [[CMMotionManager alloc] init];
    return motionManager;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
