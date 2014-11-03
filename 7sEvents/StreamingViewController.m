//
//  StreamingViewController.m
//  7sEvents
//
//  Created by Vladimir Rojas on 16/06/14.
//  Copyright (c) 2014 7Seconds Technologies. All rights reserved.
//

#import "StreamingViewController.h"
#import "MenuViewController.h"
#import "StreamingViewCell.h"
#import "TYDotIndicatorView.h"

#import <Accounts/Accounts.h>
#import <Social/Social.h>

@interface StreamingViewController ()
{
    UIImage *profileImage;
    NSArray *timelineData;
    NSDictionary *profileData;
    TYDotIndicatorView *darkCircleDot;
    
    IBOutlet UIImageView *twitterLogo;
    IBOutlet UILabel *twitterNoAccess;
}

@property (nonatomic) ACAccountStore *accountStore;
@property (strong, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation StreamingViewController

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
    UILabel *label = [[MenuViewController menuController] labelWithTitle:@"Twitter"];
    self.navigationItem.titleView = label;
    UIImage *rightImage = [UIImage imageNamed:@"logoRight.png"];
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithImage:rightImage style:UIBarButtonItemStylePlain target:nil action:nil];
    [[self navigationItem] setRightBarButtonItem:rightButton];
    
    CGRect bounds = [[self view] bounds];
    darkCircleDot = [[TYDotIndicatorView alloc] initWithFrame:CGRectMake(100, (bounds.size.height / 2.) - 25., 120, 50) dotStyle:TYDotIndicatorViewStyleCircle dotColor:[UIColor colorWithWhite:0.8 alpha:0.9] dotSize:CGSizeMake(15, 15)];
    darkCircleDot.backgroundColor = [UIColor colorWithRed:0.22 green:0.22 blue:0.22 alpha:0.9];
    [darkCircleDot startAnimating];
    darkCircleDot.layer.cornerRadius = 5.0f;
    [self.view addSubview:darkCircleDot];
    
    _accountStore = [[ACAccountStore alloc] init];
    [self fetchTimelineForUser:@"Ticketmaster_Me"];
}

- (void)dismissActivityIndicator
{
    [UIView animateWithDuration:0.75f animations:^{
        [darkCircleDot setAlpha:0.f];
    }];
}

- (BOOL)userHasAccessToTwitter
{
    return [SLComposeViewController
            isAvailableForServiceType:SLServiceTypeTwitter];
}

- (void)fetchTimelineForUser:(NSString *)username
{
    NSLog(@"User: %@", username);
    //  Step 0: Check that the user has local Twitter accounts
    if ([self userHasAccessToTwitter]) {
        
        NSLog(@"User has access to twitter");
        [twitterLogo setHidden:YES];
        [twitterNoAccess setHidden:YES];
        //  Step 1:  Obtain access to the user's Twitter accounts
        ACAccountType *twitterAccountType =
        [self.accountStore accountTypeWithAccountTypeIdentifier:
         ACAccountTypeIdentifierTwitter];
        
        [self.accountStore
         requestAccessToAccountsWithType:twitterAccountType
         options:NULL
         completion:^(BOOL granted, NSError *error) {
             if (granted) {
                 //  Step 2:  Create a request
                 NSArray *twitterAccounts =
                 [self.accountStore accountsWithAccountType:twitterAccountType];
                 NSURL *url = [NSURL URLWithString:@"https://api.twitter.com"
                               @"/1.1/statuses/user_timeline.json"];
                 NSDictionary *params = @{@"screen_name" : username,
                                          @"include_rts" : @"0",
                                          @"trim_user" : @"1",
                                          @"count" : @"10"};
                 SLRequest *request =
                 [SLRequest requestForServiceType:SLServiceTypeTwitter
                                    requestMethod:SLRequestMethodGET
                                              URL:url
                                       parameters:params];
                 
                 //  Attach an account to the request
                 [request setAccount:[twitterAccounts lastObject]];
                 
                 //  Step 3:  Execute the request
                 [request performRequestWithHandler:
                  ^(NSData *responseData,
                    NSHTTPURLResponse *urlResponse,
                    NSError *error) {
                      
                      if (responseData) {
                          if (urlResponse.statusCode >= 200 &&
                              urlResponse.statusCode < 300) {
                              
                              NSError *jsonError;
                              timelineData =
                              [NSJSONSerialization
                               JSONObjectWithData:responseData
                               options:NSJSONReadingAllowFragments error:&jsonError];
                              if (timelineData) {
                                  //NSLog(@"Timeline Response: %@\n", timelineData);
                                  //[[self tableView] reloadData];
                                  [self performSelectorOnMainThread:@selector(dismissActivityIndicator) withObject:nil waitUntilDone:NO];
                                  [[self tableView] performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
                              }
                              else {
                                  // Our JSON deserialization went awry
                                  NSLog(@"JSON Error: %@", [jsonError localizedDescription]);
                              }
                          }
                          else {
                              // The server did not respond ... were we rate-limited?
                              NSLog(@"The response status code is %@",
                                    @(urlResponse.statusCode));
                          }
                      }
                  }];
                 
                 
                 //  Step 2:  Create a request
                 NSLog(@"Download profile image");
                 twitterAccounts =
                 [self.accountStore accountsWithAccountType:twitterAccountType];
                 url = [NSURL URLWithString:@"https://api.twitter.com/1.1/users/show.json"];
                 params = @{@"screen_name" : username
                            };
                 request =
                 [SLRequest requestForServiceType:SLServiceTypeTwitter
                                    requestMethod:SLRequestMethodGET
                                              URL:url
                                       parameters:params];
                 
                 //  Attach an account to the request
                 [request setAccount:[twitterAccounts lastObject]];
                 
                 //  Step 3:  Execute the request
                 [request performRequestWithHandler:
                  ^(NSData *responseData,
                    NSHTTPURLResponse *urlResponse,
                    NSError *error) {
                      
                      if (responseData) {
                          if (urlResponse.statusCode >= 200 &&
                              urlResponse.statusCode < 300) {
                              
                              NSString *responseString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
                              NSLog(@"Response String: %@", responseString);
                              NSError *jsonError;
                              profileData =
                              [NSJSONSerialization
                               JSONObjectWithData:responseData
                               options:NSJSONReadingAllowFragments error:&jsonError];
                              if (profileData) {
                                  NSLog(@"Profile Response: %@\n", profileData);
                                  
                                  NSString *urlString = [profileData objectForKey:@"profile_image_url"];
                                  urlString = [urlString stringByReplacingOccurrencesOfString:@"_normal" withString:@""];
                                  NSURL *url = [NSURL URLWithString:urlString];
                                  NSData *data = [[NSData alloc] initWithContentsOfURL:url];
                                  profileImage = [[UIImage alloc] initWithData:data];
                                  //[[self tableView] reloadData];
                                  [[self tableView] performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
                              }
                              else {
                                  // Our JSON deserialization went awry
                                  NSLog(@"JSON Error: %@", [jsonError localizedDescription]);
                              }
                          }
                          else {
                              // The server did not respond ... were we rate-limited?
                              NSLog(@"The response status code is %@",
                                    @(urlResponse.statusCode) );
                          }
                          
                          
                          
                      }
                  }];
             }
             else {
                 // Access was not granted, or an error occurred
                 NSLog(@"%@", [error localizedDescription]);
             }
         }];
    } else {
        [darkCircleDot removeFromSuperview];
    }
}

- (IBAction)showMenu:(id)sender
{
    [[MenuViewController menuController] showMenu];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - TableView Data Source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [timelineData count];
}

#pragma mark - TableView Delegate

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"StreamingCell";
    StreamingViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    [[cell image] setAlpha:0.f];
    [[cell date] setAlpha:0.f];
    [[cell body] setAlpha:0.f];
    
    [[cell image] setImage:profileImage];
    [[cell date] setText:[self dateDiff:[[timelineData objectAtIndex:[indexPath row]] objectForKey:@"created_at"]]];
    [[cell body] setText:[[timelineData objectAtIndex:[indexPath row]] objectForKey:@"text"]];
    
    [UIView animateWithDuration:0.75f animations:^{
        [[cell image] setAlpha:1.f];
        [[cell date] setAlpha:1.f];
        [[cell body] setAlpha:1.f];
    }];
    return cell;
}

-(NSString *)dateDiff:(NSString *)origDate {
    // NSDateFormatter *df = [[NSDateFormatter alloc] init];
    // [df setFormatterBehavior:NSDateFormatterBehavior10_4];
    // Thu, 21 May 09 19:10:09 -0700
    // Wed Aug 06 17:18:39 +0000 2014
    
    NSString *myDateString = origDate;
    NSError *error = nil;
    NSDataDetector *detector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeDate error:&error];
    NSArray *matches = [detector matchesInString:myDateString options:0 range:NSMakeRange(0, [myDateString length])];
    NSDate *date;
    for (NSTextCheckingResult *match in matches) {
        date = [match date];
        //NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        //[dateFormatter setDateFormat:@"EEEE dd 'de' MMMM yyyy hh:mm a"];
        //[dateFormatter setLocale:[NSLocale currentLocale]];
        //NSString *dateString = [dateFormatter stringFromDate:date];
    }
    //[df setDateFormat:@"eee MMM dd HH:mm:ss ZZZZ yyyy"];
    NSDate *convertedDate = date;
    NSDate *todayDate = [NSDate date];
    double ti = [convertedDate timeIntervalSinceDate:todayDate];
    ti = ti * -1;
    if(ti < 1) {
    	return @"Ahora";
    } else 	if (ti < 60) {
    	return @"Ahora";
    } else if (ti < 3600) {
    	int diff = round(ti / 60);
    	if (diff == 1) {
            return [NSString stringWithFormat:@"Hace %d minuto", diff];
        } else {
            return [NSString stringWithFormat:@"Hace %d minutos", diff];
        }
    } else if (ti < 86400) {
    	int diff = round(ti / 60 / 60);
    	if (diff == 1) {
            return [NSString stringWithFormat:@"Hace %d hora", diff];
        } else {
            return [NSString stringWithFormat:@"Hace %d horas", diff];
        }
    } else if (ti < 2629743) {
    	int diff = round(ti / 60 / 60 / 24);
    	if (diff == 1) {
            return [NSString stringWithFormat:@"Hace %d día", diff];
        } else {
            return [NSString stringWithFormat:@"Hace %d días", diff];
        }
    } else {
    	return @"Ahora";
    }
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
