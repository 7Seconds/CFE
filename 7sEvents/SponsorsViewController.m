//
//  SponsorsViewController.m
//  7sEvents
//
//  Created by Vladimir Rojas on 16/06/14.
//  Copyright (c) 2014 7Seconds Technologies. All rights reserved.
//

#import "SponsorsViewController.h"
#import "MenuViewController.h"
#import "TYDotIndicatorView.h"

@interface SponsorsViewController ()
{
    NSMutableArray *urls;
    TYDotIndicatorView *darkCircleDot;
}

@end

@implementation SponsorsViewController

@synthesize myCollectionView;
@synthesize contentArray;

#pragma mark - ViewController's Life Cycle methods

- (void)viewDidLoad
{
    [super viewDidLoad];
    UILabel *label = [[MenuViewController menuController] labelWithTitle:@"Patrocinadores"];
    self.navigationItem.titleView = label;
    UIImage *rightImage = [UIImage imageNamed:@"logoRight.png"];
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithImage:rightImage style:UIBarButtonItemStylePlain target:nil action:nil];
    [[self navigationItem] setRightBarButtonItem:rightButton];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSArray *cacheInfo = [defaults valueForKey:@"sponsors"];
    if (!cacheInfo) {
        CGRect bounds = [[self view] bounds];
        darkCircleDot = [[TYDotIndicatorView alloc] initWithFrame:CGRectMake(100, (bounds.size.height / 2.) - 25., 120, 50) dotStyle:TYDotIndicatorViewStyleCircle dotColor:[UIColor colorWithWhite:0.8 alpha:0.9] dotSize:CGSizeMake(15, 15)];
        darkCircleDot.backgroundColor = [UIColor colorWithRed:0.22 green:0.22 blue:0.22 alpha:0.9];
        [darkCircleDot startAnimating];
        darkCircleDot.layer.cornerRadius = 5.0f;
        [self.view addSubview:darkCircleDot];
    }
    [self getCacheSponsors];
    [self loadInfoData];
}

- (void)dismissActivityIndicator
{
    [UIView animateWithDuration:0.75f animations:^{
        [darkCircleDot setAlpha:0.f];
    }];
}

- (void)loadInfoData
{
    //initialize array and put data on it
    contentArray = [[NSMutableArray alloc] init];
    urls = [[NSMutableArray alloc] init];
    
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSArray *cacheInfo = [defaults valueForKey:@"sponsors"];
    for (int i=0; i<[cacheInfo count]; i++) {
        [contentArray addObject:[[cacheInfo objectAtIndex:i] objectForKey:@"logo"]];
        [urls addObject:[[cacheInfo objectAtIndex:i] objectForKey:@"url"]];
    }
    
    //get the cell nib we have created
    UINib *cellNib = [UINib nibWithNibName:@"MyCell" bundle:nil];
    [myCollectionView registerNib:cellNib forCellWithReuseIdentifier:@"cvCell"];
    
    //create flow layout
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    [flowLayout setItemSize:CGSizeMake(145, 91)];
    //[flowLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
    
    //add flow layout to our collection view
    [myCollectionView setCollectionViewLayout:flowLayout];
    [myCollectionView setShowsHorizontalScrollIndicator:NO];
    [myCollectionView setShowsVerticalScrollIndicator:NO];
}

- (IBAction)showMenu:(id)sender
{
    [[MenuViewController menuController] showMenu];
}

- (void)getCacheSponsors
{
    dispatch_queue_t queue = dispatch_queue_create("sponsors", NULL);
    dispatch_async(queue, ^{
        NSURL *url = [NSURL URLWithString:@"http://7seconds.mx/7sEvents/ws/views/sponsors"];
        NSString *jsonString = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:nil];
        NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
        if (jsonData != nil) {
            NSArray *parsedData = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:nil];
            NSLog(@"%@", parsedData);
            [self saveSponsorImages:parsedData];
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            [defaults setObject:parsedData forKey:@"sponsors"];
            [defaults synchronize];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self loadInfoData];
                [self dismissActivityIndicator];
                [myCollectionView reloadData];
            });
        }
    });
}

- (void)saveSponsorImages:(NSArray *)data
{
    NSInteger index = 0;
    for (NSDictionary *info in data) {
        NSData *imageData = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:[info objectForKey:@"logo"]]];
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSString *key = [[NSString alloc] initWithFormat:@"sponsor%ld", (long)index];
        [defaults setObject:imageData forKey:key];
        [defaults synchronize];
        index++;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - UICollectionView DataSource methods

// DataSource - optional method
- (NSInteger)numberOfSectionsInCollectionView: (UICollectionView *)collectionView
{
    return 1;
}

// DataSource - mandatory methods
-(NSInteger) collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [contentArray count];
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    //NSString *cellData = [contentArray objectAtIndex:indexPath.row];
    static NSString *cellIdentifier = @"cvCell";
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    UIImageView *imageLabel = (UIImageView *)[cell viewWithTag:100];
    
    [imageLabel setAlpha:0.f];
    
    dispatch_queue_t queue = dispatch_queue_create("downloadLogo", NULL);
    dispatch_async(queue, ^{
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSString *key = [[NSString alloc] initWithFormat:@"sponsor%@", @(indexPath.row)];
        NSData *data = [defaults objectForKey:key];
        dispatch_async(dispatch_get_main_queue(), ^{
            [imageLabel setImage:[UIImage imageWithData:data]];
            [UIView animateWithDuration:0.5f animations:^{
                [imageLabel setAlpha:1.f];
            }];
        });
    });
    
    return cell;
}

#pragma mark - UICollectionView Delegate method

// Delegate - optional method
-(void) collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellData = [urls objectAtIndex:[indexPath row]];
    NSURL *url = [NSURL URLWithString:cellData];
    [[UIApplication sharedApplication] openURL:url];
}

@end
