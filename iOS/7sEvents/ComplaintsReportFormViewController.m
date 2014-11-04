//
//  Complaints2ViewController.m
//  CFE Móvil
//
//  Created by Vladimir Rojas on 08/10/14.
//  Copyright (c) 2014 7Seconds Technologies. All rights reserved.
//

#import "ComplaintsReportFormViewController.h"
#import "PreviewComplaintsReportViewController.h"
#import "MenuViewController.h"

@interface ComplaintsReportFormViewController ()
{
    IBOutlet UIImageView *header;
    IBOutlet UITextView *observations;
}

@end

@implementation ComplaintsReportFormViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UILabel *label = [[MenuViewController menuController] labelWithTitle:@"reportar quejas"];
    self.navigationItem.titleView = label;
    [self setTitle:@" "];
    
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

-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString*)string
{
    if([string isEqualToString:@"\n"]){
        [textView resignFirstResponder];
    }
    
    return YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    PreviewComplaintsReportViewController *report2VC = [segue destinationViewController];
    [report2VC setReportID:[self reportID]];
    [report2VC setRootController:[self rootController]];
    [report2VC setObservations:[observations text]];
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
