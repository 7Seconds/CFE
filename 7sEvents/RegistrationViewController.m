//
//  RegistrationViewController.m
//  7sEvents
//
//  Created by Vladimir Rojas on 16/06/14.
//  Copyright (c) 2014 7Seconds Technologies. All rights reserved.
//

#import "RegistrationViewController.h"
#import "MenuViewController.h"
#import "ActionSheetStringPicker.h"
#import <CoreImage/CoreImage.h>

@interface RegistrationViewController ()
{
    NSInteger rateIndex;
    UIImageView *blurImageView;
    NSArray *monthsArray, *rateArray;
    
    IBOutlet UILabel *basico;
    IBOutlet UILabel *intermedio;
    IBOutlet UILabel *excedente;
    IBOutlet UIButton *rateButton;
}

@end

@implementation RegistrationViewController

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
    
    rateIndex = 9;
    UILabel *label = [[MenuViewController menuController] labelWithTitle:@"tarifas 2014"];
    self.navigationItem.titleView = label;
    monthsArray = [[NSArray alloc] initWithObjects:
                   @"Enero 2014",
                   @"Febrero 2014",
                   @"Marzo 2014",
                   @"Abril 2014",
                   @"Mayo 2014",
                   @"Junio 2014",
                   @"Julio 2014",
                   @"Agosto 2014",
                   @"Septiembre 2014",
                   @"Octubre 2014",
                   @"Noviembre 2014",
                   @"Diciembre 2014", nil];
    
    rateArray = @[@[@"$ 0.792", @"$ 0.963", @"$ 2.817"],
                  @[@"$ 0.795", @"$ 0.966", @"$ 2.826"],
                  @[@"$ 0.798", @"$ 0.969", @"$ 2.835"],
                  @[@"$ 0.801", @"$ 0.972", @"$ 2.844"],
                  @[@"$ 0.804", @"$ 0.975", @"$ 2.853"],
                  @[@"$ 0.807", @"$ 0.978", @"$ 2.862"],
                  @[@"$ 0.810", @"$ 0.981", @"$ 2.871"],
                  @[@"$ 0.813", @"$ 0.984", @"$ 2.880"],
                  @[@"$ 0.816", @"$ 0.987", @"$ 2.889"],
                  @[@"$ 0.819", @"$ 0.990", @"$ 2.817"],
                  @[@"$ 0.822", @"$ 0.993", @"$ 2.907"],
                  @[@"$ 0.825", @"$ 0.996", @"$ 2.917"]];
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

- (IBAction)showPicker:(id)sender
{
    ActionStringDoneBlock done = ^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
        //NSLog(@"%@, %d, %@", picker, selectedIndex, selectedValue);
        rateIndex = selectedIndex;
        [rateButton setTitle:(NSString *)selectedValue forState:UIControlStateNormal];
        //NSLog(@"%@", [rateArray objectAtIndex:selectedIndex]);
        [basico setText:[[rateArray objectAtIndex:selectedIndex] objectAtIndex:0]];
        [intermedio setText:[[rateArray objectAtIndex:selectedIndex] objectAtIndex:1]];
        [excedente setText:[[rateArray objectAtIndex:selectedIndex] objectAtIndex:2]];
        [[picker actionSheet] dismissWithClickedButtonIndex:0 animated:YES];
    };
    [ActionSheetStringPicker showPickerWithTitle:@"" rows:monthsArray initialSelection:rateIndex doneBlock:done cancelBlock:nil origin:sender];
    //[ActionSheetStringPicker showPickerWithTitle:@"" rows:monthsArray initialSelection:9 doneBlock:done cancelBlock:nil origin:sender];
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
