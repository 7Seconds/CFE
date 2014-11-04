//
//  DetailPresentationViewController.m
//  7sEvents
//
//  Created by Vladimir Rojas on 23/07/14.
//  Copyright (c) 2014 7Seconds Technologies. All rights reserved.
//

#import "DetailPresentationViewController.h"
#import "DetailHeaderViewCell.h"
#import "DetailPresentationViewCell.h"
#import "MenuViewController.h"

@interface DetailPresentationViewController ()
{
    IBOutlet UITableView *tableView;
    IBOutlet UIImageView *imageHeader;
    IBOutlet UITextView *description;
}

@end

@implementation DetailPresentationViewController

@synthesize data, type;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UILabel *label = [[MenuViewController menuController] labelWithTitle:@"mis reportes"];
    self.navigationItem.titleView = label;
    NSLog(@"data %@", [self data]);
    
    if ([[self type] isEqualToString:@"fallas"]) {
        switch ([[[self data] objectForKey:@"idReporte"] integerValue]) {
            case 0:
                [imageHeader setImage:[UIImage imageNamed:@"CFE-15"]];
                break;
            case 1:
                [imageHeader setImage:[UIImage imageNamed:@"CFE-16"]];
                break;
            case 2:
                [imageHeader setImage:[UIImage imageNamed:@"CFE-17"]];
                break;
            case 3:
                [imageHeader setImage:[UIImage imageNamed:@"CFE-18"]];
                break;
            case 4:
                [imageHeader setImage:[UIImage imageNamed:@"CFE-19"]];
                break;
            default:
                break;
        }
    } else if ([[self type] isEqualToString:@"quejas"])
    {
        switch ([[[self data] objectForKey:@"idReporte"] integerValue]) {
            case 0:
                [imageHeader setImage:[UIImage imageNamed:@"CFE-24"]];
                break;
            case 1:
                [imageHeader setImage:[UIImage imageNamed:@"CFE-25"]];
                break;
            case 2:
                [imageHeader setImage:[UIImage imageNamed:@"CFE-26"]];
                break;
            default:
                break;
        }
    }
    
    if ([[[self data] objectForKey:@"estatus"] isEqualToString:@"Atendido"]) {
        [description setText:@"Se atendió de manera adecuada tu reporte.\n\nCFE agradece tu colaboración y te invita a seguir colaborando para continuar brindándote un excelente servicio."];
        [description setTextAlignment:NSTextAlignmentCenter];
        [description setTextColor:[UIColor darkGrayColor]];
    } else {
        [description setText:@"Tu reporte está siendo procesado.\n\nCFE agradece tu colaboración y te invita a seguir colaborando para continuar brindándote un excelente servicio."];
        [description setTextAlignment:NSTextAlignmentCenter];
        [description setTextColor:[UIColor darkGrayColor]];
    }
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
