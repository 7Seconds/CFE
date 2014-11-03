//
//  PresentationsViewController.m
//  7sEvents
//
//  Created by Vladimir Rojas on 16/06/14.
//  Copyright (c) 2014 7Seconds Technologies. All rights reserved.
//

#import "MyReportsViewController.h"
#import "MenuViewController.h"
#import "AMPObjects.h"
#import "DateTableViewCell.h"
#import "DetailDateTableViewCell.h"
#import "DetailPresentationViewController.h"
#import "TYDotIndicatorView.h"

@interface MyReportsViewController ()
{
    IBOutlet UITableView *_tableView;
    
    UIImageView *blurImageView;
    TYDotIndicatorView *darkCircleDot;
    NSMutableArray *presAux, *presOrdered, *titles;
}

@end

@implementation MyReportsViewController

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
    UILabel *label = [[MenuViewController menuController] labelWithTitle:@"mis reportes"];
    self.navigationItem.titleView = label;
    [self setTitle:@" "];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    /*if (![defaults arrayForKey:@"calendar"]) {
        CGRect bounds = [[self view] bounds];
        darkCircleDot = [[TYDotIndicatorView alloc] initWithFrame:CGRectMake(100, (bounds.size.height / 2.) - 25., 120, 50) dotStyle:TYDotIndicatorViewStyleCircle dotColor:[UIColor colorWithWhite:0.8 alpha:0.9] dotSize:CGSizeMake(15, 15)];
        darkCircleDot.backgroundColor = [UIColor colorWithRed:0.22 green:0.22 blue:0.22 alpha:0.9];
        [darkCircleDot startAnimating];
        darkCircleDot.layer.cornerRadius = 5.0f;
        [self.view addSubview:darkCircleDot];
    }*/
    
    //[self getCachePresentations];
    [self getDates];
    
    objArray = [[NSMutableArray alloc] init];
    //childArray = [[NSMutableArray alloc] init];
    //filteredChildArray = [[NSArray alloc] init];
    indentationlevel = 0;
    indendationWidth = 20;
    // Create a sample array of parent objects

    for (NSInteger i = 0; i < [titles count]; i++) {
        AMPObjects *obj = [[AMPObjects alloc] init];
        obj.name = [titles objectAtIndex:i];
        obj.parent = @"";
        obj.isExpanded = NO;
        obj.level = 0;
        obj.isChildren = NO;
        if ([defaults arrayForKey:[titles objectAtIndex:i]]) {
            obj.canBeExpanded = YES;
        } else {
            obj.canBeExpanded = NO;
        }
        obj.indexRow = i;
        [objArray addObject:obj];
    }
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

- (void)getDates
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray *fallas = (NSMutableArray *)[defaults arrayForKey:@"fallas"];
    NSMutableArray *quejas = (NSMutableArray *)[defaults arrayForKey:@"quejas"];
    
    if (fallas && quejas) {
        NSDictionary *dicFallas = [[NSDictionary alloc] initWithObjects:@[fallas] forKeys:@[@"fallas"]];
        NSDictionary *dicQuejas = [[NSDictionary alloc] initWithObjects:@[quejas] forKeys:@[@"quejas"]];
        NSMutableArray *presTemp = [[NSMutableArray alloc] initWithObjects:dicFallas, dicQuejas, nil];
        //NSLog(@"%@", presTemp);
        presOrdered = presTemp;
        //NSLog(@"%@", presOrdered);
    } if (fallas && !quejas) {
        NSDictionary *dicFallas = [[NSDictionary alloc] initWithObjects:@[fallas] forKeys:@[@"fallas"]];
        NSMutableArray *presTemp = [[NSMutableArray alloc] initWithObjects:dicFallas, nil];
        //NSLog(@"%@", presTemp);
        presOrdered = presTemp;
        //NSLog(@"%@", presOrdered);
    } if (!fallas && quejas) {
        NSDictionary *dicQuejas = [[NSDictionary alloc] initWithObjects:@[quejas] forKeys:@[@"quejas"]];
        NSMutableArray *presTemp = [[NSMutableArray alloc] initWithObjects:dicQuejas, nil];
        //NSLog(@"%@", presTemp);
        presOrdered = presTemp;
        //NSLog(@"%@", presOrdered);
    }
    titles = [[NSMutableArray alloc] initWithObjects:@"fallas", @"quejas", nil];
    
    /*
     NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSArray *presentations = [defaults objectForKey:@"calendar"];
    presAux = [[NSMutableArray alloc] init];
    
    for (NSDictionary *_presentation in presentations) {
        NSMutableDictionary *presentation = [[NSMutableDictionary alloc] initWithDictionary:_presentation];
        NSString *myDateString = [presentation objectForKey:@"date"];
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
            //NSLog(@"... %@", dateString);
        }
        [presentation setValue:date forKey:@"date"];
        [presAux addObject:presentation];
    }
    NSLog(@"presentations: %@", presentations);
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"date" ascending:true];
    [presAux sortUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    
    titles = [[NSMutableArray alloc] init];
    for (NSInteger index = 0; index < [presAux count]; index++) {
       
        NSDictionary *dictionary = [presAux objectAtIndex:index];
        NSDate *date = [dictionary objectForKey:@"date"];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"MMMM dd"];
        [dateFormatter setLocale:[NSLocale currentLocale]];
        NSString *dateString = [dateFormatter stringFromDate:date];
        
        if (![dateString isEqualToString:[titles lastObject]]) {
            [titles addObject:dateString];
        }
    }
    
    presOrdered = [[NSMutableArray alloc] init];
    NSMutableArray *aux = [[NSMutableArray alloc] init];
    for (NSString *title in titles) {
        for (NSDictionary *dictionary in presAux) {
            NSDate *date = [dictionary objectForKey:@"date"];
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"MMMM dd"];
            [dateFormatter setLocale:[NSLocale currentLocale]];
            NSString *dateString = [dateFormatter stringFromDate:date];
            if ([title isEqualToString:dateString]) {
                [aux addObject:dictionary];
            }
        }
        [presOrdered addObject:aux];
        aux = [[NSMutableArray alloc] init];
    }
    //NSLog(@"ordered: %@", presOrdered);
     */
}

/*
 - (void)getCachePresentations
{
    dispatch_queue_t queue = dispatch_queue_create("calendar", NULL);
    dispatch_async(queue, ^{
        NSURL *url = [NSURL URLWithString:@"http://www.7seconds.mx/7sEvents/ws/views/calendar"];
        NSString *jsonString = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:nil];
        NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
        if (jsonData != nil) {
            NSArray *parsedData = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:nil];
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            [defaults setObject:parsedData forKey:@"calendar"];
            [defaults synchronize];
            NSLog(@"%@", parsedData);
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self getDates];
                objArray = [[NSMutableArray alloc] init];
                //childArray = [[NSMutableArray alloc] init];
                //filteredChildArray = [[NSArray alloc] init];
                indentationlevel = 0;
                indendationWidth = 20;
                // Create a sample array of parent objects
                for (NSInteger i = 0; i < [titles count]; i++) {
                    AMPObjects *obj = [[AMPObjects alloc] init];
                    obj.name = [titles objectAtIndex:i];
                    obj.parent = @"";
                    obj.isExpanded = NO;
                    obj.level = 0;
                    obj.isChildren = NO;
                    obj.canBeExpanded = YES;
                    obj.indexRow = i;
                    [objArray addObject:obj];
                }
                
                [self dismissActivityIndicator];
                [_tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
            });
        }
    });
} 
 */

- (void)dismissActivityIndicator
{
    [UIView animateWithDuration:0.75f animations:^{
        [darkCircleDot setAlpha:0.f];
    }];
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

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [objArray count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    AMPObjects *obj = [objArray objectAtIndex:indexPath.row];
    if (obj.isChildren) {
        return 40.f;
    }
    return 142.f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"cellForRowAtIndexPath: %@", indexPath);
    AMPObjects *obj = [objArray objectAtIndex:indexPath.row];
    if (obj.isChildren) {
        NSLog(@"LoadingDetailCell");
        static NSString *CellIdentifier = @"DetailDateCell";
        DetailDateTableViewCell *cell = (DetailDateTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        
        //NSString *description = [[[presOrdered objectAtIndex:obj.indexSection] objectAtIndex:obj.indexRow] objectForKey:@"name"];
        
        NSString *llave = @"fallas";
        if (obj.indexSection == 1) {
            llave = @"quejas";
        }
        
        NSLog(@"llave: %@", llave);
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSString *description;
        NSString *status;
        
        if ([defaults objectForKey:@"fallas"]) {
             description = [[[[presOrdered objectAtIndex:obj.indexSection] objectForKey:llave] objectAtIndex:obj.indexRow] objectForKey:@"tipo"];
             status = [[[[presOrdered objectAtIndex:obj.indexSection] objectForKey:llave] objectAtIndex:obj.indexRow] objectForKey:@"estatus"];
        } else {
            description = [[[[presOrdered objectAtIndex:obj.indexSection-1] objectForKey:llave] objectAtIndex:obj.indexRow] objectForKey:@"tipo"];
            status = [[[[presOrdered objectAtIndex:obj.indexSection-1] objectForKey:llave] objectAtIndex:obj.indexRow] objectForKey:@"estatus"];
        }
        
        if ([status isEqualToString:@"Atendido"]) {
            UIImageView *rightAccessory = (UIImageView *)[cell viewWithTag:10];
            [rightAccessory setImage:[UIImage imageNamed:@"CFE-67"]];
            //[cell setBackgroundColor:[UIColor colorWithWhite:0.15f alpha:0.1f]];
            //[cell setAlpha:0.f];
        }
        //NSLog(@"%@", [[presOrdered objectAtIndex:obj.indexSection] objectForKey:llave]);
        [[cell description] setText:description];
        
        //NSLog(@"presOrdered: %@", presOrdered);
        //NSLog(@"indexSection: %d", obj.indexSection);
        //NSLog(@"indexRow: %d", obj.indexRow);
        //NSLog(@"yosoy: %@", obj.name);
        //[[cell description] setText:@"hola! :D"];
        /*NSDate *date = [[[presOrdered objectAtIndex:obj.indexSection] objectAtIndex:obj.indexRow] objectForKey:@"date"];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"EEEE dd 'de' MMMM yyyy"];
        [dateFormatter setLocale:[NSLocale currentLocale]];
        NSString *dateString = [dateFormatter stringFromDate:date];
        
        NSString *description = [[[presOrdered objectAtIndex:obj.indexSection] objectAtIndex:obj.indexRow] objectForKey:@"name"];
        description = [description stringByAppendingString:[NSString stringWithFormat:@"\n%@", dateString]];
        
        [dateFormatter setDateFormat:@"HH:mm a"];
        [dateFormatter setLocale:[NSLocale currentLocale]];
        dateString = [dateFormatter stringFromDate:date];
        description = [description stringByAppendingString:[NSString stringWithFormat:@"\n%@", dateString]];
        
        [[cell description] setText:description];
        [[cell description] setFont:[UIFont fontWithName:@"NexaLight" size:12.f]];*/
        //cell.textLabel.text = obj.name;
        //cell.detailTextLabel.text = obj.parent;
        cell.indentationLevel = obj.level;
        cell.indentationWidth = indendationWidth;
        return cell;
    } else {
        static NSString *CellIdentifier = @"DateCell";
        DateTableViewCell *cell = (DateTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        //[[cell date] setText:[obj name]];
        UIImageView *imageView = (UIImageView *)[cell viewWithTag:10];
        if (!obj.canBeExpanded) {
            [imageView setHidden:YES];
        } else {
            [imageView setHidden:NO];
        }
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        
        NSLog(@"----------->%@<----------", obj.name);
        NSInteger count;
        if ([obj.name isEqualToString:@"fallas"]) {
            count = [[defaults objectForKey:@"fallasCount"] integerValue];
        } else if ([obj.name isEqualToString:@"quejas"]){
            count = [[defaults objectForKey:@"quejasCount"] integerValue];
        }
        
        if (count) {
            NSString *badge = [[NSString alloc] initWithFormat:@"%@", @(count)];
            [[cell badge] setHidden:NO];
            [[cell date] setHidden:NO];
            [[cell date] setText:badge];
        } else {
            [[cell date] setHidden:YES];
            [[cell badge] setHidden:YES];
        }
        
        NSString *imageName = [[NSString alloc] initWithFormat:@"CFE0%@", @(obj.indexRow + 1)];
        [[cell background] setImage:[UIImage imageNamed:imageName]];
        NSString *badgeName = [[NSString alloc] initWithFormat:@"CFE-Circle0%@", @(obj.indexRow + 1)];
        [[cell badge] setImage:[UIImage imageNamed:badgeName]];
        
        //[[cell date] setFont:[UIFont fontWithName:@"NexaLight" size:17.f]];
        //cell.textLabel.text = obj.name;
        //cell.detailTextLabel.text = obj.parent;
        cell.indentationLevel = obj.level;
        cell.indentationWidth = indendationWidth;
        return cell;
    }
    
    // Show disclosure only if the cell can expand
    if(obj.canBeExpanded) {
        //cell.accessoryView = [self viewForDisclosureForState:obj.isExpanded];
    } else {
        //cell.accessoryType = UITableViewCellAccessoryNone;
        //cell.accessoryView = nil;
    }
    // Configure the cell...
    //return cell;
}

// Show the arrow down if the row is expanded
- (UIView *)viewForDisclosureForState:(BOOL)isExpanded
{
    NSString *imageName;
    if(isExpanded) {
        imageName = @"ArrowD_blue.png";
    } else {
        imageName = @"ArrowR_blue.png";
    }
    UIView *myView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    UIImageView *imgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:imageName]];
    [imgView setFrame:CGRectMake(0, 6, 24, 24)];
    [myView addSubview:imgView];
    return myView;
}

// Utility class to create childrens for a selected parent class
- (void)fetchChildrenforParent:(AMPObjects*)parentobjects
{
    // If canBe Expanded then only we need to create child
    if(parentobjects.canBeExpanded)
    {
        NSLog(@"parentCanBeExpanded");
        // If Children are already added then no need to add again
        if([parentobjects.children count]>0) {
            //NSLog(@"parentobjectschildren > 0");
            return;
        }
        
        // The children property of the parent will be filled with this objects
        //NSLog(@"the parent will be filled with this objects %d", [[presOrdered objectAtIndex:parentobjects.indexRow] count]);
        
        NSLog(@"soy: %@", parentobjects.name);
        NSLog(@"presOrdered%@", presOrdered);
        //NSLog(@"indexRow: %d", parentobjects.indexRow);
        //[presOrdered objectAtIndex:1];
        NSLog(@"presorobjaIex %@", @([presOrdered count]));
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        
        NSInteger limit = 0;
        if ([parentobjects.name isEqualToString:@"quejas"]) {
            if ([defaults objectForKey:@"fallas"]) {
                limit = [[[presOrdered objectAtIndex:parentobjects.indexRow] objectForKey:@"quejas"] count];
            } else {
                limit = [[[presOrdered objectAtIndex:parentobjects.indexRow - 1] objectForKey:@"quejas"] count];
            }
        } else if ([parentobjects.name isEqualToString:@"fallas"]) {
            limit = [[[presOrdered objectAtIndex:parentobjects.indexRow] objectForKey:@"fallas"] count];
        }
        
        //NSLog(@"limit: %d", limit);
        for (NSInteger i = 0; i < limit; i++) {
            //NSLog(@"----> %@", [presOrdered objectAtIndex:parentobjects.indexRow]);
            AMPObjects *obj = [[AMPObjects alloc] init];
            obj.name = [NSString stringWithFormat:@"Child %@", @(i)];
            // This is used for setting the indentation level so that it look like an accordion view
            obj.level  = parentobjects.level+1;
            obj.parent = [NSString stringWithFormat:@"Child %@ of Level %@", @(i), @(obj.level)];
            obj.isExpanded = NO;
            obj.isChildren = YES;
            obj.indexSection = parentobjects.indexRow;
            obj.indexRow = i;
            obj.canBeExpanded = NO;
            [parentobjects.children addObject:obj];
        }
    }
}


#pragma mark - Table view delegate
// Method to collapse the cell if it is already expanded
- (void)collapseCellsFromIndexOf:(AMPObjects *)obj indexPath:(NSIndexPath *)indexPath tableView:(UITableView *)tableView
{
    // Find the number of childrens opened under the parent recursively as there can be expanded children also
    NSInteger collapseCol = [self numberOfCellsToBeCollapsed:obj];
    
    // Find the range from the parent index and the length to be removed.
    NSRange collapseRange = NSMakeRange(indexPath.row+1, collapseCol);
    // Remove all the objects in that range from the main array so that number of rows are maintained properly
    [objArray removeObjectsInRange:collapseRange];
    obj.isExpanded = NO;
    // Create index paths for the number of rows to be removed
    NSMutableArray *indexPaths = [[NSMutableArray alloc] init];
    for (int i = 0; i<collapseRange.length; i++) {
        [indexPaths addObject:[NSIndexPath indexPathForRow:collapseRange.location+i inSection:0]];
    }
    // Animate and delete
    // arrowView.transform = CGAffineTransformMakeRotation(M_PI_2);
    [tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationTop];
}

// Method to Expand the cell
- (void)expandCellsFromIndexOf:(AMPObjects *)obj tableView:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath
{ //j.antonio.canton@gmail.com
    NSLog(@"expandCells");
    // Create dummy children
    NSLog(@"fetchChildrenforParent");
    [self fetchChildrenforParent:obj];
    NSLog(@"fetchedChildrenforParent");
    // Expand only if children are available
    if([obj.children count]>0)
    {
        //NSLog(@"obj.children count: %d", [obj.children count]);
        obj.isExpanded = YES;
        int i =0;
        // Insert all the child to the main array just after the parent's index
        for (AMPObjects *obj1 in obj.children) {
            [objArray insertObject:obj1 atIndex:indexPath.row+i+1];
            i++;
        }
        
        NSLog(@"objArray: %@", objArray);
        // Find the range for insertion
        NSRange expandedRange = NSMakeRange(indexPath.row, i);
        NSMutableArray *indexPaths = [[NSMutableArray alloc] init];
        // Create index paths for the range
        for (int i = 0; i<expandedRange.length; i++) {
            [indexPaths addObject:[NSIndexPath indexPathForRow:expandedRange.location+i+1 inSection:0]];
        }
        NSLog(@"indexPaths: %@", indexPaths);
        // Insert the rows
        // arrowView.transform = CGAffineTransformMakeRotation(M_PI_2);
        [tableView insertRowsAtIndexPaths:indexPaths
                         withRowAnimation:UITableViewRowAnimationBottom];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    BOOL moveToBottom = NO;
    NSInteger rowsCount = [tableView numberOfRowsInSection:0];
    if ([indexPath row] == rowsCount - 1) {
        moveToBottom = YES;
    }
    
    AMPObjects *obj = [objArray objectAtIndex:indexPath.row];
    //UITableViewCell *selectedCell = [tableView cellForRowAtIndexPath:indexPath];
    
    UITableViewCell * cell = [tableView cellForRowAtIndexPath:indexPath];
    UIImageView *imageView = (UIImageView *)[cell viewWithTag:10];
    
    if(obj.canBeExpanded) {
        NSLog(@"canBeExpanded");
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        
        if ([[defaults objectForKey:@"fallasCount"] integerValue] > 0 ||
            [[defaults objectForKey:@"quejasCount"] integerValue] > 0) {
            [tableView reloadData];
        }
        
        if ([obj.name isEqualToString:@"fallas"]) {
            [defaults setObject:[NSNumber numberWithInteger:0] forKey:@"fallasCount"];
        } else if ([obj.name isEqualToString:@"quejas"]) {
            [defaults setObject:[NSNumber numberWithInteger:0] forKey:@"quejasCount"];
        }
        
        [[MenuViewController menuController] reloadBadge];
        
        if(obj.isExpanded) {
            NSLog(@"isExpanded");
            [self collapseCellsFromIndexOf:obj indexPath:indexPath tableView:tableView];
            [UIView animateWithDuration:.5f animations:^{
                CGAffineTransform rtransform = imageView.transform;
                imageView.transform= CGAffineTransformRotate(rtransform, M_PI);
            }];
            //selectedCell.accessoryView = [self viewForDisclosureForState:NO];
        } else {
            NSLog(@"isNotExpanded");
            [self expandCellsFromIndexOf:obj tableView:tableView indexPath:indexPath];
            [UIView animateWithDuration:.5f animations:^{
                CGAffineTransform rtransform = imageView.transform;
                imageView.transform= CGAffineTransformRotate(rtransform, M_PI);
            }];
            //selectedCell.accessoryView = [self viewForDisclosureForState:YES];
            if (moveToBottom) {
                NSIndexPath *_indexPath = [NSIndexPath indexPathForRow:[tableView numberOfRowsInSection:0]-1 inSection:0];
                [tableView scrollToRowAtIndexPath:_indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
            }
        }
    } else {
        NSLog(@"cantBeExpanded");
        //NSString *imageName = [[NSString alloc] initWithFormat:@"presBackground0%@", @(obj.indexSection + 1)];
        
        UIStoryboard *storyboard = nil;
        //UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:nil];
        if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
        {    // The iOS device = iPhone or iPod Touch
            CGSize iOSDeviceScreenSize = [[UIScreen mainScreen] bounds].size;
            if (iOSDeviceScreenSize.height == 480)
            {   // iPhone 3GS, 4, and 4S and iPod Touch 3rd and 4th generation: 3.5 inch screen (diagonally measured)
                NSLog(@"Loading iphone 4 storyboard");
                // Instantiate a new storyboard object using the storyboard file named MainStoryboard_iPhone
                storyboard = [UIStoryboard storyboardWithName:@"Main_iPhone4" bundle:nil];
            }
            if (iOSDeviceScreenSize.height == 568)
            {   // iPhone 5 and iPod Touch 5th generation: 4 inch screen (diagonally measured)
                NSLog(@"Loading iphone 5 storyboard");
                // Instantiate a new storyboard object using the storyboard file named Storyboard_iPhone4
                storyboard = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:nil];
            }
        }
        
        NSLog(@"DetailPresentationViewController");
        NSLog(@"obj.name: %@", obj.name);
        if (![obj.name isEqualToString:@"fallas"] && ![obj.name isEqualToString:@"quejas"]) {
            DetailPresentationViewController *viewController = (DetailPresentationViewController *)[storyboard instantiateViewControllerWithIdentifier:@"DetailPresentationViewController"];
            //NSLog(@"%d %d", obj.indexSection, obj.indexRow);
            
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            NSDictionary *data;
            if (!obj.indexSection) {
                data = [[defaults objectForKey:@"fallas"] objectAtIndex:obj.indexRow];
                viewController.type = @"fallas";
            } else {
                data = [[defaults objectForKey:@"quejas"] objectAtIndex:obj.indexRow];
                viewController.type = @"quejas";
            }
            
            viewController.data = data;
            //viewController.imageHeader = imageName;
            [[self navigationController] pushViewController:viewController animated:YES];
            /*UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"CFE Móvil"
                                                                message:@"Módulo en desarrollo"
                                                               delegate:nil
                                                      cancelButtonTitle:@"Aceptar"
                                                      otherButtonTitles:nil];
            [alertView show];*/
        }
    }
}

// Find the number of cells to be collapsed
- (NSInteger) numberOfCellsToBeCollapsed:(AMPObjects*) objects
{
    NSInteger total = 0;
    if(objects.isExpanded)
    {
        // Set the expanded status to no
        objects.isExpanded = NO;
        NSMutableArray *child = objects.children;
        total = child.count;
        // traverse through all the children of the parent and get the count.
        for(AMPObjects *obj in child) {
            total += [self numberOfCellsToBeCollapsed:obj];
        }
    }
    return total;
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
