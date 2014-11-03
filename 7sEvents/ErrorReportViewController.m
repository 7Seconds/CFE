//
//  PlaneViewController.m
//  7sEvents
//
//  Created by Vladimir Rojas on 16/06/14.
//  Copyright (c) 2014 7Seconds Technologies. All rights reserved.
//

#import "ErrorReportViewController.h"
#import "ErrorReportFormViewController.h"
#import "MenuViewController.h"

@interface ErrorReportViewController ()
{
    UIImageView *blurImageView;
}

@property (strong, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation ErrorReportViewController

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
    UILabel *label = [[MenuViewController menuController] labelWithTitle:@"avisar fallas de luz"];
    self.navigationItem.titleView = label;
    [self setTitle:@" "];
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

- (void)hideMenuController
{
    [blurImageView setAlpha:1.0f];
    [UIView animateWithDuration:0.6f animations:^{
        [blurImageView setAlpha:0.0f];
    } completion:^(BOOL finished){
        [blurImageView removeFromSuperview];
    }];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Prototype"];
    UIImageView *image = (UIImageView *)[cell.contentView viewWithTag:1];
    switch ([indexPath row]) {
        case 0:
            [image setImage:[UIImage imageNamed:@"CFE-15"]];
            break;
        case 1:
            [image setImage:[UIImage imageNamed:@"CFE-16"]];
            break;
        case 2:
            [image setImage:[UIImage imageNamed:@"CFE-17"]];
            break;
        case 3:
            [image setImage:[UIImage imageNamed:@"CFE-18"]];
            break;
        case 4:
            [image setImage:[UIImage imageNamed:@"CFE-19"]];
            break;
        default:
            break;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
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
    ErrorReportFormViewController *viewController = (ErrorReportFormViewController *)[storyboard instantiateViewControllerWithIdentifier:@"ReportViewController"];
    [viewController setReportID:[indexPath row]];
    [viewController setRootController:self];
    [[self navigationController] pushViewController:viewController animated:YES];
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
