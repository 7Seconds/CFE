//
//  HistoricalPaymentViewController.m
//  CFE Móvil
//
//  Created by Vladimir Rojas on 08/10/14.
//  Copyright (c) 2014 7Seconds Technologies. All rights reserved.
//

#import "HistoricalPaymentViewController.h"
#import "MenuViewController.h"

@interface HistoricalPaymentViewController ()

@end

@implementation HistoricalPaymentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UILabel *label = [[MenuViewController menuController] labelWithTitle:@"histórico"];
    self.navigationItem.titleView = label;
    [self setTitle:@" "];
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
