//
//  Report2ViewController.m
//  CFE Móvil
//
//  Created by Vladimir Rojas on 08/10/14.
//  Copyright (c) 2014 7Seconds Technologies. All rights reserved.
//

#import "PreviewErrorReportViewController.h"
#import "MenuViewController.h"

@interface PreviewErrorReportViewController ()
{
    IBOutlet UIImageView *header;
    IBOutlet UILabel *serviceNumber;
    IBOutlet UITextView *observationsTextView;
}

@end

@implementation PreviewErrorReportViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    UILabel *label = [[MenuViewController menuController] labelWithTitle:@"avisar fallas de luz"];
    self.navigationItem.titleView = label;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [serviceNumber setText:[defaults objectForKey:@"settings:numberAccount"]];
    
    [observationsTextView setText:[self observations]];
    [observationsTextView setTextColor:[UIColor darkGrayColor]];
    
    switch ([self reportID]) {
        case 0:
            [header setImage:[UIImage imageNamed:@"CFE-15"]];
            break;
        case 1:
            [header setImage:[UIImage imageNamed:@"CFE-16"]];
            break;
        case 2:
            [header setImage:[UIImage imageNamed:@"CFE-17"]];
            break;
        case 3:
            [header setImage:[UIImage imageNamed:@"CFE-18"]];
            break;
        case 4:
            [header setImage:[UIImage imageNamed:@"CFE-19"]];
            break;
        default:
            break;
    }
}

- (IBAction)sendReport:(id)sender
{
    NSArray *fallas = @[@"No hay luz en la cuadra", @"Variación del voltaje en la cuadra", @"No hay luz en la casa", @"Variación del voltaje en la casa", @"El CFEmático no funciona"];
    NSString *tipo = [[NSString alloc] initWithFormat:@"%@", @([self reportID])];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    //[defaults removeObjectForKey:@"fallas"];
    
    NSString *numeroServicio = [defaults objectForKey:@"settings:numberAccount"];
    NSDictionary *dictionary = [[NSDictionary alloc] initWithObjects:
                                [NSArray arrayWithObjects:
                                 tipo,
                                 [self observations],
                                 numeroServicio,
                                 [NSDate date],
                                 [fallas objectAtIndex:[self reportID]],
                                 @"Por atender", nil]
                                                             forKeys:
                                [NSArray arrayWithObjects:
                                 @"idReporte",
                                 @"observaciones",
                                 @"numeroServicio",
                                 @"fecha",
                                 @"tipo",
                                 @"estatus", nil]];
    
    NSMutableArray *array;
    if (![defaults arrayForKey:@"fallas"]) {
        array = [[NSMutableArray alloc] initWithObjects:dictionary, nil];
    } else {
        array = [[NSMutableArray alloc] initWithArray:[defaults arrayForKey:@"fallas"]];
        [array addObject:dictionary];
    }
    [defaults setObject:array forKey:@"fallas"];
    [defaults synchronize];
    
    UILocalNotification* localNotification = [[UILocalNotification alloc] init];
    localNotification.fireDate = [NSDate dateWithTimeIntervalSinceNow:60*60];
    localNotification.alertBody = @"Se atendió la falla";
    localNotification.alertAction = @"mostrar el elemento";
    localNotification.timeZone = [NSTimeZone defaultTimeZone];
    localNotification.soundName = UILocalNotificationDefaultSoundName;
    localNotification.applicationIconBadgeNumber = [[UIApplication sharedApplication] applicationIconBadgeNumber] + 1;
    
    NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] initWithDictionary:[localNotification userInfo]];
    [userInfo setValue:[NSNumber numberWithInteger:[array count]] forKey:@"ID"];
    [userInfo setValue:@"fallas" forKey:@"tipo"];
    [localNotification setUserInfo:userInfo];
    
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Se envió exitosamente"
                                                        message:@"Recibirás una copia del reporte en tu correo eletrónico.\nAdemás podrás seguirlo en la sección de Mis Reportes"
                                                       delegate:self
                                              cancelButtonTitle:@"Aceptar"
                                              otherButtonTitles:nil];
    [alertView show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [[self navigationController] popToViewController:[self rootController] animated:YES];
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
