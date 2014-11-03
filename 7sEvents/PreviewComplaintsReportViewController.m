//
//  Complaints3ViewController.m
//  CFE Móvil
//
//  Created by Vladimir Rojas on 08/10/14.
//  Copyright (c) 2014 7Seconds Technologies. All rights reserved.
//

#import "PreviewComplaintsReportViewController.h"
#import "MenuViewController.h"

@interface PreviewComplaintsReportViewController ()
{
    IBOutlet UIImageView *header;
    IBOutlet UILabel *serviceNumber;
    IBOutlet UITextView *observationsTextView;
}

@end

@implementation PreviewComplaintsReportViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    UILabel *label = [[MenuViewController menuController] labelWithTitle:@"reporte quejas"];
    self.navigationItem.titleView = label;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [serviceNumber setText:[defaults objectForKey:@"settings:numberAccount"]];
    [observationsTextView setText:[self observations]];
    [observationsTextView setTextColor:[UIColor darkGrayColor]];
    
    switch ([self reportID]) {
        case 0:
            [header setImage:[UIImage imageNamed:@"CFE-24"]];
            break;
        case 1:
            [header setImage:[UIImage imageNamed:@"CFE-25"]];
            break;
        case 2:
            [header setImage:[UIImage imageNamed:@"CFE-26"]];
            break;
        default:
            break;
    }
}

- (IBAction)sendReport:(id)sender
{
    NSArray *quejas = @[@"Alto consumo de recibo de luz", @"Extorsión o corrupción", @"Mala atención en el centro de Atención a clientes"];
    NSString *tipo = [[NSString alloc] initWithFormat:@"%@", @([self reportID])];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    //[defaults removeObjectForKey:@"quejas"];
    
    NSString *numeroServicio = [defaults objectForKey:@"settings:numberAccount"];
    NSDictionary *dictionary = [[NSDictionary alloc] initWithObjects:
                                [NSArray arrayWithObjects:
                                 tipo,
                                 [self observations],
                                 numeroServicio,
                                 [NSDate date],
                                 [quejas objectAtIndex:[self reportID]],
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
    if (![defaults arrayForKey:@"quejas"]) {
        array = [[NSMutableArray alloc] initWithObjects:dictionary, nil];
    } else {
        array = [[NSMutableArray alloc] initWithArray:[defaults arrayForKey:@"quejas"]];
        [array addObject:dictionary];
    }
    [defaults setObject:array forKey:@"quejas"];
    [defaults synchronize];
    
    UILocalNotification* localNotification = [[UILocalNotification alloc] init];
    localNotification.fireDate = [NSDate dateWithTimeIntervalSinceNow:60*30];
    localNotification.alertBody = @"Se atendió la queja";
    localNotification.alertAction = @"mostrar el elemento";
    localNotification.timeZone = [NSTimeZone defaultTimeZone];
    localNotification.soundName = UILocalNotificationDefaultSoundName;
    localNotification.applicationIconBadgeNumber = [[UIApplication sharedApplication] applicationIconBadgeNumber] + 1;
    
    NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] initWithDictionary:[localNotification userInfo]];
    [userInfo setValue:[NSNumber numberWithInteger:[array count]] forKey:@"ID"];
    [userInfo setValue:@"quejas" forKey:@"tipo"];
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
