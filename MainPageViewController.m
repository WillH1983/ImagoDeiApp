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
#import "ImagoDeiMediaController.h"

@interface MainPageViewController ()

@property (nonatomic, strong) NSArray *tableContents;

@end

@implementation MainPageViewController
@synthesize model = _model;
@synthesize tableContents = _tableContents;
@synthesize imageName = _imageName;
@synthesize activityIndicator = _activityIndicator;

- (void)setTableContents:(NSArray *)tableContents
{
    _tableContents = tableContents;
    
    //Ensure that reloading of the tableview always happens on main thread
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}

- (void)standardInitWithURL:(NSURL *)url
{
    //This class is a common function to initialize the class
    //from both a xib and non xib
    
    //Set the model equal to the URL based to the function
    self.model = url;
    
    //initialize RSSParser class, send the RSS URL to the class,
    //and set the parser delegate to self
    RSSParser *parser = [[RSSParser alloc] init];
    [parser XMLFileToParseAtURL:self.model withDelegate:self];
    
    //Set the Imago Dei logo to the title view of the navigation controler
    //With the content mode set to AspectFit
    UIImage *logoImage = [UIImage imageNamed:@"imago-logo.png"];
    UIImageView *logoImageView = [[UIImageView alloc] initWithImage:logoImage];
    logoImageView.contentMode = UIViewContentModeScaleAspectFit;
    self.navigationItem.titleView = logoImageView;
    
    //Set the background of the ImagoDei app to the background image
    self.tableView.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"background.png"]];
    
    //initialize the activity indicator, set it to the center top of the view, and
    //start it animating
    self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
	self.activityIndicator.hidesWhenStopped = YES;
    [self.activityIndicator startAnimating];
}

- (void)awakeFromNib
{
    //This function is called when an xib is loaded from a storyboard
    
    //Set the tableview delegate to this class
    self.tableView.delegate = self;
    
    //Setup the tabbar with the background image, selected image
    self.tabBarController.tabBar.backgroundImage = [UIImage imageNamed:@"tabbar-bg.png"];
    self.tabBarController.tabBar.selectionIndicatorImage = [UIImage imageNamed:@"tabbar-active-bg.png"];
    
    //Setup the "home" tabbar item with the correct image and name
    [self.tabBarItem setFinishedSelectedImage:[UIImage imageNamed:@"home-active.png"] withFinishedUnselectedImage:[UIImage imageNamed:@"home-inactive.png"]];
    self.tabBarItem.title = @"Home";
    
    //For now create a filepath string with the MainTabiPhone file that is bundled
    //with the application
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"MainTabiPhone" ofType:@"rss"];
    
    //initialize the class with the URL file path
    NSURL *urlFilePath = [[NSURL alloc] initFileURLWithPath:filePath];
    [self standardInitWithURL:urlFilePath];
}

- (id)initWithModel:(NSURL *)model
{
    //Call the super classes initialization
    self = [super init];
    
    //Call the standard initialization
    [self standardInitWithURL:model];
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    //Call the super classes view will appear method
    [super viewWillAppear:animated];
    
    //Set the navigation bar color to the standard color
    UIColor *standardColor = [UIColor colorWithRed:.7529 green:0.7372 blue:0.7019 alpha:1.0];
    [[[self navigationController] navigationBar] setTintColor:standardColor];
    
    //Create a small footerview so the UITableView lines do not show up
    //in blank cells
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, 1)];
    self.tableView.tableFooterView = view;
    
    //Set the right navigation bar button item to the activity indicator
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.activityIndicator];
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
    //Do not allow rotation
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)RSSParser:(RSSParser *)sender RSSParsingCompleteWithArray:(NSArray *)RSSArray
{
    //This method is called when the RSSParsing class has downloaded, and completed
    //parsing of the provided RSS URL
    self.tableContents = RSSArray;
    
    //Since the RSS file has been loaded, stop animating the activity indicator
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
    //Set the cell identifier to the same as the prototype cell in the story board
    static NSString *CellIdentifier = @"Main Page Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

    
    //If there is no reusable cell of this type, create a new one
    if (!cell)
    {
        //Set the atributes of the main page cell
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.backgroundColor = [UIColor clearColor];
        cell.textLabel.textColor = [UIColor colorWithRed:0.29803 green:0.1529 blue:0.0039 alpha:1];
        cell.detailTextLabel.textColor = [UIColor colorWithRed:0.2666 green:0.2666 blue:0.2666 alpha:1];
    }
    
    //Set the cell text label's based upon the table contents array location
    cell.textLabel.text = [[self.tableContents objectAtIndex:[indexPath row]] valueForKey:CONTENT_TITLE];
    cell.detailTextLabel.text = [[self.tableContents objectAtIndex:[indexPath row]] valueForKey:CONTENT_DESCRIPTION];
    
    //Make sure that the imageview is set to nil when the cell is reused
    //this makes sure that the old image does not show up
    cell.imageView.image = nil;
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //Pull the URL from the selected tablecell, which is from the parsed RSS file with the key "link"
    NSURL *url = [[NSURL alloc] initWithString:[[self.tableContents objectAtIndex:indexPath.row] valueForKey:@"link"]];
    
    //Get the title for the next view from the selected tablecell, which is composed from the RSS file
    NSString *title = [[self.tableContents objectAtIndex:indexPath.row] valueForKey:@"title"];
    
    //Only perform actions on url if it is a valid URL
    if (url)
    {
        //If the URL is for an RSS file, initialize a mainpageviewcontroller with the URL
        //and set the title
        if ([[url pathExtension] isEqualToString:@"rss"])
        {
            MainPageViewController *mpvc = [[MainPageViewController alloc] initWithModel:url];
            mpvc.title = title;
            [self.navigationController pushViewController:mpvc animated:YES];
        }
        //If the URL is for an mp3 file, initialize a mediacontroller with the URL
        //and set the title
        else if ([[url pathExtension] isEqualToString:@"mp3"])
        {
            ImagoDeiMediaController *controller = [[ImagoDeiMediaController alloc] initImageoDeiMediaControllerWithURL:url];
            controller.title = title;
            [self.navigationController pushViewController:controller animated:YES];
        }
        //Catch all is to load a webview with the contents of the URL
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
    
    //Get the title for the Cell to be displayed
    primaryTextLabel = [[self.tableContents objectAtIndex:[indexPath row]] valueForKey:CONTENT_TITLE];
    
    //Determine if an image should be displayed, and display it based upon the name
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
