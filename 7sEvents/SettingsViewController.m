//
//  InfoViewController.m
//  7sEvents
//
//  Created by Vladimir Rojas on 16/06/14.
//  Copyright (c) 2014 7Seconds Technologies. All rights reserved.
//

#import "SettingsViewController.h"
#import "MenuViewController.h"

@interface SettingsViewController ()
{
    UIImageView *blurImageView;
    CGRect contentFrame, warningFrame;
    
    IBOutlet UIView *contentView;
    IBOutlet UILabel *warning;
    IBOutlet UIButton *emailButton;
    IBOutlet UIButton *twitterButton;
    IBOutletCollection(UITextField) NSArray *textFieldArray;
}

@end

@implementation SettingsViewController

#pragma mark - InfoViewController

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
    UILabel *label = [[MenuViewController menuController] labelWithTitle:@"Configuración"];
    self.navigationItem.titleView = label;
    contentFrame = contentView.frame;
    warningFrame = warning.frame;
    UIFont *customFont = [UIFont fontWithName:@"BaronNeue" size:13.f];
    for (UITextField *textField in textFieldArray) {
        [textField setFont:customFont];
    }
    
    [self updateSettingsFields];
    [self updateSettingsButtons];
    [self registerForKeyboardNotifications];
}

- (UIImageView *)loadBlurView
{
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

- (void)updateSettingsButtons
{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    if ([prefs objectForKey:@"settings:mailReport"]) {
        if (![prefs boolForKey:@"settings:mailReport"]) {
            [emailButton setImage:[UIImage imageNamed:@"CFE-03"] forState:UIControlStateNormal];
        } else {
            [emailButton setImage:[UIImage imageNamed:@"CFE-59"] forState:UIControlStateNormal];
        }
    }
    
    if ([prefs objectForKey:@"settings:twitterReport"]) {
        if (![prefs boolForKey:@"settings:twitterReport"]) {
            [twitterButton setImage:[UIImage imageNamed:@"CFE-04"] forState:UIControlStateNormal];
        } else {
            [twitterButton setImage:[UIImage imageNamed:@"CFE-60"] forState:UIControlStateNormal];
        }
    }
}

- (void)updateSettingsFields
{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    if ([prefs objectForKey:@"settings:numberAccount"]) {
        [[textFieldArray objectAtIndex:0] setText:[prefs objectForKey:@"settings:numberAccount"]];
    }
    if ([prefs objectForKey:@"settings:twitterAccount"]) {
        [[textFieldArray objectAtIndex:1] setText:[prefs objectForKey:@"settings:twitterAccount"]];
    }
    if ([prefs objectForKey:@"settings:mailAccount"]) {
        [[textFieldArray objectAtIndex:2] setText:[prefs objectForKey:@"settings:mailAccount"]];
    }
}

#pragma mark - Keyboard Notifications

- (void)registerForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
}

- (void)keyboardWasShown:(NSNotification*)aNotification
{
    NSDictionary *info = [aNotification userInfo];
    NSNumber *number = [info objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    double duration = [number doubleValue];
    [UIView animateWithDuration:duration animations:^{
        [warning setFrame:CGRectMake(0.f, -20.f, warningFrame.size.width, warningFrame.size.height)];
        [warning setAlpha:0.f];
        [contentView setFrame:CGRectMake(0.f, 64.f, contentFrame.size.width, contentFrame.size.height)];
    }];
}

- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    NSDictionary *info = [aNotification userInfo];
    NSNumber *number = [info objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    double duration = [number doubleValue];
    [UIView animateWithDuration:duration animations:^{
        [warning setFrame:warningFrame];
        [warning setAlpha:1.f];
        [contentView setFrame:contentFrame];
    }];
}

#pragma mark - TextField Delegate

- (BOOL)textFieldShouldReturn:(UITextField*)textField;
{
    NSInteger nextTag = textField.tag + 1;
    UIResponder *nextResponder = [textField.superview viewWithTag:nextTag];
    if (nextResponder) {
        [nextResponder becomeFirstResponder];
    } else {
        [textField resignFirstResponder];
    }
    return NO;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [textField setTextColor:[UIColor darkGrayColor]];
}

#pragma mark - Validate Methods

- (BOOL)isAllDigits:(NSString *)string
{
    NSCharacterSet* nonNumbers = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];
    NSRange r = [string rangeOfCharacterFromSet: nonNumbers];
    return r.location == NSNotFound;
}

- (BOOL)isValidTwitterUsername:(NSString *)username
{
    static NSRegularExpression* usernameRegularExpression;
    NSString* CLUTwitterUsernamePattern = @"^([0-9a-zA-Z_]{1,15})$";
    if (!usernameRegularExpression) {
        usernameRegularExpression = [NSRegularExpression regularExpressionWithPattern:CLUTwitterUsernamePattern options:NSRegularExpressionCaseInsensitive error:nil];
    }
    NSUInteger numberOfMatches = [usernameRegularExpression numberOfMatchesInString:username options:0 range:NSMakeRange(0, username.length)];
    return numberOfMatches == 1;
}

- (BOOL)isValidEmail: (NSString *)candidate
{
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:candidate];
}

- (BOOL)validateTextFields
{
    BOOL isCorrectForm = YES;
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    
    UITextField *numberAccount = [textFieldArray objectAtIndex:0];
    NSString *numberAccountString = [numberAccount text];
    numberAccountString = [numberAccountString stringByReplacingOccurrencesOfString:@" " withString:@""];
    if ([self isAllDigits:numberAccountString]) {
        [prefs setValue:numberAccountString forKey:@"settings:numberAccount"];
    } else {
        isCorrectForm = NO;
        [prefs removeObjectForKey:@"settings:numberAccount"];
        [numberAccount setTextColor:[UIColor redColor]];
    } if ([numberAccountString length] == 0) {
        [prefs removeObjectForKey:@"settings:numberAccount"];
    }
    
    UITextField *twitterAccount = [textFieldArray objectAtIndex:1];
    if ([[twitterAccount text] length] > 0) {
        if ([self isValidTwitterUsername:[twitterAccount text]]) {
            [prefs setValue:[twitterAccount text] forKey:@"settings:twitterAccount"];
        } else {
            isCorrectForm = NO;
            [prefs removeObjectForKey:@"settings:twitterAccount"];
            [twitterAccount setTextColor:[UIColor redColor]];
        }
    } if ([[twitterAccount text] length] == 0) {
        [prefs removeObjectForKey:@"settings:twitterAccount"];
    }
    
    UITextField *mailAccount = [textFieldArray objectAtIndex:2];
    if ([[mailAccount text] length] > 0) {
        if ([self isValidEmail:[mailAccount text]]) {
            [prefs setValue:[mailAccount text] forKey:@"settings:mailAccount"];
        } else {
            isCorrectForm = NO;
            [prefs removeObjectForKey:@"settings:mailAccount"];
            [mailAccount setTextColor:[UIColor redColor]];
        }
    } if ([[mailAccount text] length] == 0) {
        [prefs removeObjectForKey:@"settings:mailAccount"];
    }
    [prefs synchronize];
    
    if (!isCorrectForm) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"CFE Móvil"
                                                            message:@"Corrige los campos marcados con rojo"
                                                           delegate:nil
                                                  cancelButtonTitle:@"Aceptar"
                                                  otherButtonTitles:nil];
        [alertView show];
        return NO;
    } else {
        if ([[numberAccount text] length] == 0) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"CFE Móvil"
                                                                message:@"Ingresa el Número de Servicio que aparece en tu recibo"
                                                               delegate:nil
                                                      cancelButtonTitle:@"Aceptar"
                                                      otherButtonTitles:nil];
            [alertView show];
            return NO;
        } else if ([numberAccountString length] != 12) {
            [numberAccount setTextColor:[UIColor redColor]];
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"CFE Móvil"
                                                                message:@"El Número de Servicio está compuesto de 12 dígitos tal como aparece en tu recibo"
                                                               delegate:nil
                                                      cancelButtonTitle:@"Aceptar"
                                                      otherButtonTitles:nil];
            [alertView show];
            return NO;
        }
    }
    return YES;
}

- (BOOL)validateSettings
{
    BOOL isCorrectForm = YES;
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSInteger errorCode = 0;
    NSString *message = @"";
    
    if ([prefs boolForKey:@"settings:mailReport"]) {
        if (![prefs objectForKey:@"settings:mailAccount"]) {
            errorCode += 1;
            isCorrectForm = NO;
        }
    }
    if ([prefs boolForKey:@"settings:twitterReport"]) {
        if (![prefs objectForKey:@"settings:twitterAccount"]) {
            errorCode += 2;
            isCorrectForm = NO;
        }
    }
    
    switch (errorCode) {
        case 1:
            message = @"Para seguir tus reportes por email debes configurar una cuenta";
            break;
        case 2:
            message = @"Para seguir tus reportes por twitter debes configurar una cuenta";
            break;
        case 3:
            message = @"Para seguir tus reportes por email y twitter debes configurar ambas cuentas";
            break;
        default:
            break;
    }
    
    if (errorCode) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"CFE Móvil"
                                                            message:message
                                                           delegate:nil
                                                  cancelButtonTitle:@"Aceptar"
                                                  otherButtonTitles:nil];
        [alertView show];
    }
    return isCorrectForm;
}

- (BOOL)validateForm
{
    if ([self validateTextFields]) {
        if ([self validateSettings]) {
            return YES;
        }
    }
    return NO;
}

#pragma mark - IBActions

- (IBAction)showMenu:(id)sender
{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    if ([prefs boolForKey:@"settings"]) {
        blurImageView = [self loadBlurView];
        [blurImageView setAlpha:0.0f];
        [self.view addSubview:blurImageView];
        [UIView animateWithDuration:0.6f animations:^{
            [blurImageView setAlpha:1.0f];
        }];
        [[MenuViewController menuController] showMenu];
    } else {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"CFE Móvil"
                                                            message:@"Debes configurar tu cuenta antes de poder acceder a las opciones del menú"
                                                           delegate:nil
                                                  cancelButtonTitle:@"Aceptar"
                                                  otherButtonTitles:nil];
        [alertView show];
    }
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

- (IBAction)switchMailReport:(id)sender
{
    UIButton *dataAlarm = (UIButton *)sender;
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    if ([prefs objectForKey:@"settings:mailReport"]) {
        if ([prefs boolForKey:@"settings:mailReport"]) {
            [dataAlarm setImage:[UIImage imageNamed:@"CFE-03"] forState:UIControlStateNormal];
            [prefs setBool:NO forKey:@"settings:mailReport"];
        } else {
            [dataAlarm setImage:[UIImage imageNamed:@"CFE-59"] forState:UIControlStateNormal];
            [prefs setBool:YES forKey:@"settings:mailReport"];
        }
    } else {
        [dataAlarm setImage:[UIImage imageNamed:@"CFE-59"] forState:UIControlStateNormal];
        [prefs setBool:YES forKey:@"settings:mailReport"];
    }
    [prefs synchronize];
}

- (IBAction)switchTwitterReport:(id)sender
{
    UIButton *dataAlarm = (UIButton *)sender;
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    if ([prefs objectForKey:@"settings:twitterReport"]) {
        if ([prefs boolForKey:@"settings:twitterReport"]) {
            [dataAlarm setImage:[UIImage imageNamed:@"CFE-04"] forState:UIControlStateNormal];
            [prefs setBool:NO forKey:@"settings:twitterReport"];
        } else {
            [dataAlarm setImage:[UIImage imageNamed:@"CFE-60"] forState:UIControlStateNormal];
            [prefs setBool:YES forKey:@"settings:twitterReport"];
        }
    } else {
        [dataAlarm setImage:[UIImage imageNamed:@"CFE-60"] forState:UIControlStateNormal];
        [prefs setBool:YES forKey:@"settings:twitterReport"];
    }
    [prefs synchronize];
}

- (IBAction)saveSettings:(id)sender
{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    if ([self validateForm]) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"CFE Móvil"
                                                            message:@"Los datos de cuenta se almacenaron con éxito"
                                                           delegate:nil
                                                  cancelButtonTitle:@"Aceptar"
                                                  otherButtonTitles:nil];
        [alertView show];
        [prefs setBool:YES forKey:@"settings"];
    } else {
        [prefs setBool:NO forKey:@"settings"];
    }
    [prefs synchronize];
}

@end
