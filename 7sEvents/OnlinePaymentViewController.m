//
//  DirectoryViewController.m
//  7sEvents
//
//  Created by Vladimir Rojas on 16/06/14.
//  Copyright (c) 2014 7Seconds Technologies. All rights reserved.
//

#import "OnlinePaymentViewController.h"
#import "MenuViewController.h"
#import "ViewController.h"

@interface OnlinePaymentViewController()
{
    IBOutlet UIImageView *paymentStatus;
    IBOutlet UIButton *historicalButton;
    IBOutlet UILabel *payLabel;
    
    UIImageView *blurImageView;
}

@end

@implementation OnlinePaymentViewController

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
    UILabel *label = [[MenuViewController menuController] labelWithTitle:@"pago en línea"];
    self.navigationItem.titleView = label;
    [self setTitle:@" "];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if (![defaults boolForKey:@"settings:paid"]) {
        [historicalButton setHidden:YES];
    } else {
        [paymentStatus setImage:[UIImage imageNamed:@"CFE-08"]];
    }
    
    [payLabel setText:[NSString stringWithFormat:@"$ %@.00", @([defaults integerForKey:@"settings:total"])]];
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

- (void)paymentSuccess
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:YES forKey:@"settings:paid"];
    [defaults synchronize];
    [paymentStatus setImage:[UIImage imageNamed:@"CFE-08"]];
    [historicalButton setHidden:NO];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"PayPalViewController"]) {
        PayPalViewController *payPalVC = [segue destinationViewController];
        [payPalVC setDelegate:self];
    }
}

@end
