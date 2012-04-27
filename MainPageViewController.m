//
//  MainPageViewController.m
//  ImagoDei
//
//  Created by Will Hindenburg on 4/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MainPageViewController.h"
#import "ImagoDeiDataFetcher.h"
#import "WebViewController.h"
#import "Facebook.h"
#import "FacebookSocialMediaViewController.h"
#import "TwitterSocialMediaViewController.h"

@interface MainPageViewController ()

@property (nonatomic, strong) NSArray *tableContents;

@end

@implementation MainPageViewController
@synthesize tableView = _tableView;
@synthesize model = _model;
@synthesize tableContents = _tableContents;
@synthesize imageName = _imageName;
@synthesize activityIndicator = _activityIndicator;

- (void)setTableContents:(NSArray *)tableContents
{
    _tableContents = tableContents;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}

- (id)init
{
    self = [super init];
    if (self) {
        self.tableView.delegate = self;
        UIImage *logoImage = [UIImage imageNamed:@"logo.png"];

        UIImageView *logoImageView = [[UIImageView alloc] initWithImage:logoImage];
        
        self.navigationItem.titleView = logoImageView;
        
        //Get the tab bar item
        UITabBarItem *tbi = [self tabBarItem];
        
        //Give it a label
        //[tbi setTitle:[self.model valueForKeyPath:CONTENT_TITLE]];
        
        //Create a UIImage from a file
        UIImage *i = [UIImage imageNamed:@"Hypno.png"];
        
        //Put the image on the tab bart item
        [tbi setImage:i];
    }
    return self;
}

- (void)facebookButtonPressed:(id)sender
{
    FacebookSocialMediaViewController *fbsmvc = [[FacebookSocialMediaViewController alloc]init];
    
    [fbsmvc setModalPresentationStyle:UIModalPresentationFormSheet];
    [fbsmvc setModalTransitionStyle:UIModalTransitionStyleCoverVertical];
    
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:fbsmvc];
    
    [self presentViewController:navController animated:YES completion:nil];
}

- (void)twitterButtonPressed:(id)sender
{
    TwitterSocialMediaViewController *tsmvc = [[TwitterSocialMediaViewController alloc] init];
    
    [tsmvc setModalPresentationStyle:UIModalPresentationFormSheet];
    [tsmvc setModalTransitionStyle:UIModalTransitionStyleCoverVertical];
    
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:tsmvc];
    
    [self presentViewController:navController animated:YES completion:nil];
}

- (id)initWithModel:(NSURL *)model
{
    self.model = model;
    RSSParser *parser = [[RSSParser alloc] init];
    [parser XMLFileToParseAtURL:self.model withDelegate:self];
    self = [self init];
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    UIColor *standardColor = [UIColor colorWithRed:.7529 green:0.7372 blue:0.7019 alpha:1.0];
    [[[self navigationController] navigationBar] setTintColor:standardColor];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.activityIndicator startAnimating];
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    NSIndexPath *selection = [self.tableView indexPathForSelectedRow];
	if (selection) [self.tableView deselectRowAtIndexPath:selection animated:YES];
}

- (void)viewDidUnload
{
    [self setTableView:nil];
    [self setActivityIndicator:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)RSSParser:(RSSParser *)sender RSSParsingCompleteWithArray:(NSArray *)RSSArray
{
    self.tableContents = RSSArray;
    [self.activityIndicator stopAnimating];
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
    return [self.tableContents count];
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

    
    //If there is no reusable cell of this type, create a new one
    if (!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }

    cell.textLabel.textColor = [UIColor colorWithRed:0.29803 green:0.1529 blue:0.0039 alpha:1];
    cell.detailTextLabel.textColor = [UIColor colorWithRed:0.2666 green:0.2666 blue:0.2666 alpha:1];
    cell.textLabel.text = [[self.tableContents objectAtIndex:[indexPath row]] valueForKey:CONTENT_TITLE];
    cell.detailTextLabel.text = [[self.tableContents objectAtIndex:[indexPath row]] valueForKey:CONTENT_DESCRIPTION];
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSURL *url = [[NSURL alloc] initWithString:[[self.tableContents objectAtIndex:indexPath.row] valueForKey:@"link"]];
    if (url != nil)
    {
        if ([[url pathExtension] isEqualToString:@"rss"])
        {
            MainPageViewController *mpvc = [[MainPageViewController alloc] initWithModel:url];
            mpvc.title = @"Planning Center";
            [self.navigationController pushViewController:mpvc animated:YES];
        }
        else 
        {
            WebViewController *wvc = [[WebViewController alloc] initWithToolbar:NO];
            [wvc setUrlToLoad:url];
            [wvc setTitleForWebView:[[self.tableContents objectAtIndex:[indexPath row]] valueForKeyPath:CONTENT_TITLE]];
            [[self navigationController] pushViewController:wvc animated:YES];
        }
    }
}


@end
