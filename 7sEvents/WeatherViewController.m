//
//  WeatherViewController.m
//  7sEvents
//
//  Created by Vladimir Rojas on 16/06/14.
//  Copyright (c) 2014 7Seconds Technologies. All rights reserved.
//

#import "WeatherViewController.h"
#import "MenuViewController.h"
#import "TYDotIndicatorView.h"

@interface WeatherViewController ()
{
    NSDictionary *weatherToday;
    NSDictionary *weatherForecast;
    TYDotIndicatorView *darkCircleDot;
    
    IBOutlet UILabel *location;
    IBOutlet UILabel *day;
    IBOutlet UILabel *date;
    IBOutlet UILabel *celsius;
    IBOutlet UILabel *temperatureC;
    IBOutlet UILabel *temperatureF;
    IBOutlet UIImageView *figureToday;
    IBOutlet UIImageView *locationImage;
    IBOutletCollection(UILabel) NSArray *temperatures;
    IBOutletCollection(UILabel) NSArray *dates;
    IBOutletCollection(UIImageView) NSArray *figure;
}

@end

@implementation WeatherViewController

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
    UILabel *label = [[MenuViewController menuController] labelWithTitle:@"Clima"];
    self.navigationItem.titleView = label;
    UIImage *rightImage = [UIImage imageNamed:@"logoRight.png"];
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithImage:rightImage style:UIBarButtonItemStylePlain target:nil action:nil];
    [[self navigationItem] setRightBarButtonItem:rightButton];
    
    [self setLocationImage];
    // Set Font
    [location setFont:[UIFont fontWithName:@"NexaLight" size:22.f]];
    [day setFont:[UIFont fontWithName:@"NexaLight" size:18.f]];
    [date setFont:[UIFont fontWithName:@"NexaLight" size:18.f]];
    [celsius setFont:[UIFont fontWithName:@"NexaLight" size:24.f]];
    [temperatureC setFont:[UIFont fontWithName:@"NexaLight" size:42.f]];
    [temperatureF setFont:[UIFont fontWithName:@"NexaLight" size:20.f]];
    
    CGRect bounds = [[self view] bounds];
    darkCircleDot = [[TYDotIndicatorView alloc] initWithFrame:CGRectMake(100, (bounds.size.height / 2.) - 25., 120, 50) dotStyle:TYDotIndicatorViewStyleCircle dotColor:[UIColor colorWithWhite:0.8 alpha:0.9] dotSize:CGSizeMake(15, 15)];
    darkCircleDot.backgroundColor = [UIColor colorWithRed:0.22 green:0.22 blue:0.22 alpha:0.9];
    [darkCircleDot startAnimating];
    darkCircleDot.layer.cornerRadius = 5.0f;
    [self.view addSubview:darkCircleDot];
    
    for (UILabel *label in dates) {
        [label setFont:[UIFont fontWithName:@"NexaLight" size:14.f]];
    }
    
    for (UILabel *label in temperatures) {
        [label setFont:[UIFont fontWithName:@"NexaLight" size:14.f]];
    }
    
    [self performSelectorInBackground:@selector(updateWeather) withObject:nil];
    //[NSTimer scheduledTimerWithTimeInterval:60 target:self selector:@selector(updateWeather) userInfo:nil repeats:YES];
}



- (void)updateWeather
{
    [self setWeatherToday];
    [self setWeatherForecast];
    [self setLocationImage];
    [self performSelectorOnMainThread:@selector(dismissActivityIndicator) withObject:nil waitUntilDone:NO];
}

- (void)dismissActivityIndicator
{
    [UIView animateWithDuration:0.75f animations:^{
        [darkCircleDot setAlpha:0.f];
    }];
}

- (void)setLocationImage
{
    NSCalendar *gregorianCal = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *dateComps = [gregorianCal components: (NSHourCalendarUnit | NSMinuteCalendarUnit)
                                                  fromDate:[NSDate date]];
    // Then use it
    if ([dateComps hour] < 18) {
        [locationImage setImage:[UIImage imageNamed:@"locationDay"]];
    } else {
        //[location setTextColor:[UIColor whiteColor]];
        [locationImage setImage:[UIImage imageNamed:@"locationNight.jpg"]];
    }
}

- (void)setWeatherToday
{
    [self weatherToday];
    [location setText:[weatherToday objectForKey:@"name"]];
    NSInteger _tempC = [[[weatherToday objectForKey:@"main"] objectForKey:@"temp"] integerValue];
    [temperatureC setText:[NSString stringWithFormat:@"%@", @(_tempC)]];
    NSInteger tempC = [[[weatherToday objectForKey:@"main"] objectForKey:@"temp"] integerValue];
    float tempF = (tempC*9.f/5.f) + 32;
    [temperatureF setText:[NSString stringWithFormat:@"%@ ºF", [[NSNumber numberWithFloat:tempF] stringValue]]];
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *comps = [gregorian components:NSWeekdayCalendarUnit fromDate:[NSDate date]];
    NSInteger weekday = [comps weekday];
    NSDate *_date = [NSDate date];
    NSCalendar *_gregorian = [NSCalendar currentCalendar];
    NSDateComponents *dateComponents = [_gregorian components:(NSDayCalendarUnit|NSMonthCalendarUnit|NSYearCalendarUnit) fromDate:_date];
    NSInteger month = [dateComponents month];
    NSInteger dayInt = [dateComponents day];
    
    NSString *dateString = [[NSString alloc] initWithFormat:@"%@ %@", @(dayInt), [self monthFromInt:month]];
    [date setText: dateString];
    [day setText:[self weekDayFromInt:weekday]];
    
    NSString *main = [[[weatherToday objectForKey:@"weather"] objectAtIndex:0] objectForKey:@"main"];
    if (![main isEqualToString:@"Clear"]) {
        [figureToday setImage:[UIImage imageNamed:@"weatherCloud"]];
    }
    else {
        [figureToday setImage:[UIImage imageNamed:@"weatherSun"]];
    }
}

- (void)setWeatherForecast
{
    [self weatherForecast];
    NSArray *weekForecast = [weatherForecast objectForKey:@"list"];
    NSInteger index = 0;
    for (NSDictionary *weather in weekForecast) {
        NSInteger _celsius = [[[weather objectForKey:@"temp"] objectForKey:@"day"] integerValue];
        NSString *temp = [[NSString alloc] initWithFormat:@"%@ ºC", @(_celsius)];
        [[temperatures objectAtIndex:index] setText:temp];
        
        NSString *main = [[[weather objectForKey:@"weather"] objectAtIndex:0] objectForKey:@"main"];
        if (![main isEqualToString:@"Clear"]) {
            [[figure objectAtIndex:index] setImage:[UIImage imageNamed:@"weatherCloud"]];
        }
        else {
            [[figure objectAtIndex:index] setImage:[UIImage imageNamed:@"weatherSun"]];
        }
        index++;
    }
    
    for (NSUInteger i = 1; i < 5; i++) {
        NSDate *now = [NSDate date];
        NSInteger daysToAdd = i;
        NSDate *newDate = [now dateByAddingTimeInterval:60*60*24*daysToAdd];
        
        NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
        NSDateComponents *comps = [gregorian components:NSWeekdayCalendarUnit fromDate:newDate];
        NSInteger weekday = [comps weekday];
        NSDate *_date = newDate;
        NSCalendar *_gregorian = [NSCalendar currentCalendar];
        NSDateComponents *dateComponents = [_gregorian components:(NSDayCalendarUnit|NSMonthCalendarUnit|NSYearCalendarUnit) fromDate:_date];
        NSInteger month = [dateComponents month];
        NSInteger dayInt = [dateComponents day];
        NSString *dateFormatter = [[NSString alloc] initWithFormat:@"%@ %@ %@", [self weekDayFromInt:weekday], @(dayInt), [self monthFromInt:month]];
        [[dates objectAtIndex:i-1] setText:dateFormatter];
    }
}

- (void)weatherForecast
{
    NSURL *url = [NSURL URLWithString:@"http://api.openweathermap.org/data/2.5/forecast/daily?q=Mexico%20City&mode=json&units=metric&cnt=4"];
    NSString *jsonString = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:nil];
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    if (jsonData != nil) {
        weatherForecast = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:nil];
    }
}

- (NSString *)weekDayFromInt:(NSInteger)weekdayInt
{
    NSString *weekdayString;
    switch (weekdayInt) {
        case 1:
            weekdayString = @"Domingo";
            break;
        case 2:
            weekdayString = @"Lunes";
            break;
        case 3:
            weekdayString = @"Martes";
            break;
        case 4:
            weekdayString = @"Miércoles";
            break;
        case 5:
            weekdayString = @"Jueves";
            break;
        case 6:
            weekdayString = @"Viernes";
            break;
        case 7:
            weekdayString = @"Sábado";
            break;
        default:
            weekdayString = @"";
            break;
    }
    return weekdayString;
}

- (NSString *)monthFromInt:(NSInteger)monthInt
{
    NSString *monthString;
    switch (monthInt) {
        case 1:
            monthString = @"Enero";
            break;
        case 2:
            monthString = @"Febrero";
            break;
        case 3:
            monthString = @"Marzo";
            break;
        case 4:
            monthString = @"Abril";
            break;
        case 5:
            monthString = @"Mayo";
            break;
        case 6:
            monthString = @"Junio";
            break;
        case 7:
            monthString = @"Julio";
            break;
        case 8:
            monthString = @"Agosto";
            break;
        case 9:
            monthString = @"Septiembre";
            break;
        case 10:
            monthString = @"Octubre";
            break;
        case 11:
            monthString = @"Noviembre";
            break;
        case 12:
            monthString = @"Diciembre";
            break;
        default:
            monthString = @"";
            break;
    }
    return monthString;
}

- (void)weatherToday
{
    NSURL *url = [NSURL URLWithString:@"http://api.openweathermap.org/data/2.5/weather?q=Mexico%20City&units=metric"];
    NSString *jsonString = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:nil];
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    if (jsonData != nil) {
        weatherToday = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:nil];
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
