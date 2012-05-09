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
#import "ImagoDeiMediaController.h"

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
        UIImage *logoImage = [UIImage imageNamed:@"imago-logo.png"];

        UIImageView *logoImageView = [[UIImageView alloc] initWithImage:logoImage];
        logoImageView.contentMode = UIViewContentModeScaleAspectFit;
        
        self.navigationItem.titleView = logoImageView;
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
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, 1)];
    self.tableView.tableFooterView = view;
    
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
    NSString *title = [[self.tableContents objectAtIndex:indexPath.row] valueForKey:@"title"];
    if (url != nil)
    {
        if ([[url pathExtension] isEqualToString:@"rss"])
        {
            MainPageViewController *mpvc = [[MainPageViewController alloc] initWithModel:url];
            mpvc.title = title;
            [self.navigationController pushViewController:mpvc animated:YES];
        }
        else if ([[url pathExtension] isEqualToString:@"mp3"])
        {
            //MPMoviePlayerViewController *controller = [[MPMoviePlayerViewController alloc] initWithContentURL:url];
            ImagoDeiMediaController *controller = [[ImagoDeiMediaController alloc] initImageoDeiMediaControllerWithURL:url];
            controller.title = title;
            [self.navigationController pushViewController:controller animated:YES];
        }
        else 
        {
            WebViewController *wvc = [[WebViewController alloc] initWithToolbar:NO];
            [wvc setUrlToLoad:url];
            [wvc setTitleForWebView:title];
            [[self navigationController] pushViewController:wvc animated:YES];
        }
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *primaryTextLabel = [[NSString alloc] init];
    primaryTextLabel = [[self.tableContents objectAtIndex:[indexPath row]] valueForKey:CONTENT_TITLE];
    
    if ([primaryTextLabel isEqualToString:@"NEWS"])
    {
        cell.imageView.image = [UIImage imageNamed:@"news-icon.png"];
    }
    else if ([primaryTextLabel isEqualToString:@"EVENTS"])
    {
        cell.imageView.image = [UIImage imageNamed:@"events-icon.png"];
    }
    else if ([primaryTextLabel isEqualToString:@"TEACHINGS"])
    {
        cell.imageView.image = [UIImage imageNamed:@"teachings-icon.png"];
    }
    else if ([primaryTextLabel isEqualToString:@"CONNECT"])
    {
        cell.imageView.image = [UIImage imageNamed:@"connect-icon.png"];
    }
    else if ([primaryTextLabel isEqualToString:@"WHO WE ARE"])
    {
        cell.imageView.image = [UIImage imageNamed:@"whoweare-icon.png"];
    }
}

@end
