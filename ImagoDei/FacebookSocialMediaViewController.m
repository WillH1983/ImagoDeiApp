//
//  FacebookSocialMediaViewController.m
//  ImagoDei
//
//  Created by Will Hindenburg on 4/21/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "FacebookSocialMediaViewController.h"
#import "ImagoDeiAppDelegate.h"
#import "Facebook.h"

@interface FacebookSocialMediaViewController ()
@property (nonatomic, strong) UIActivityIndicatorView *facebookActivityIndicator;
@property (nonatomic, strong) NSArray *imagoDeiFacebookPostsArray;
@property (nonatomic, strong) FBRequest *facebookRequest;
@property (nonatomic, strong) UIBarButtonItem *oldBarButtonItem;

- (void)facebookInit;
@end

@implementation FacebookSocialMediaViewController
@synthesize facebook = _facebook;
@synthesize tableView = _tableView;
@synthesize facebookActivityIndicator = _facebookActivityIndicator;
@synthesize imagoDeiFacebookPostsArray = _imagoDeiFacebookPostsArray;
@synthesize facebookRequest = _facebookRequest;
@synthesize oldBarButtonItem = _oldBarButtonItem;

- (void)setImagoDeiFacebookPostsArray:(NSArray *)imagoDeiFacebookPostsArray
{
    //Set the incoming variable equal to the variable
    _imagoDeiFacebookPostsArray = imagoDeiFacebookPostsArray;
    
    //Reload the table view on the main thread when the data changes
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}

- (void)donePressed:(id)sender
{
    //dismiss the popover when the done button is pressed
    [[self presentingViewController] dismissViewControllerAnimated:YES completion:nil];
}

- (void)LogOutInButtonClicked:(id)sender 
{
    UIBarButtonItem *barButton = nil;
    
    //Verify that object that was clicked was a UIBarButtonItem
    if ([sender isKindOfClass:[UIBarButtonItem class]])
    {
        //If it was, then assign barButton to sender
        barButton = sender;
    }
    //If not return without any action
    else return;

    //If the barbutton says Log Out, tell the facebook app to logout
    //and set the title of the button to Log In
    if ([barButton.title isEqualToString: @"Log Out"])
    {
        [self.facebook logout];
        barButton.title = @"Log In";
    }
    //If the barbutton says Log In, check if the facebook session is still valid
    else if ([barButton.title isEqualToString: @"Log In"])
    {
        //If it is not valid, reauthorize the app for single sign on
        if (![self.facebook isSessionValid]) 
        {
            [self.facebook authorize:nil];
        }
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    //return (interfaceOrientation == UIInterfaceOrientationPortrait);
    return YES;
}

#pragma mark - View Lifecycle

- (void)viewWillDisappear:(BOOL)animated
{
    //When the view disappears the code in this fucnction removes all delegation to this class
    
    //This is required incase a connection request is in progress when the view disappears
    [self.facebookRequest setDelegate:nil];
    
    //This is required incase a facebook method completes after the view has disappered
    ImagoDeiAppDelegate *appDelegate = (ImagoDeiAppDelegate *)[[UIApplication sharedApplication] delegate];
    appDelegate.facebook.sessionDelegate = nil;
    
    //Super method
    [super viewWillDisappear:animated];
}

- (void)viewWillAppear:(BOOL)animated
{
    if ([self.imagoDeiFacebookPostsArray count] > 0) return;
    
    [super viewWillAppear:animated];
    
    //Set the footer to a blank view so table rows will not show up if no content
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, 1)];
    self.tableView.tableFooterView = view;
    
    //Init the facebook session
    [self facebookInit];
    
    //Set the Main Navigation Bar to the application standard color
    UIColor *standardColor = [UIColor colorWithRed:0.7529 green:0.7372 blue:0.7019 alpha:1.0];
    
    //Set the toolbar at the bottom of the screen to the application standard color
    self.navigationController.navigationBar.tintColor = standardColor;
    
    //Make ImagoDei Logo graphic the title for the navigation controller
    UIImage *logoImage = [UIImage imageNamed:@"imago-logo.png"];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:logoImage];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    self.navigationItem.titleView = imageView;
    
    
    //By default the "Log In/Out" button will say "Log In"
    UIBarButtonItem *barButtonItem = barButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Log In" 
                                                                                      style:UIBarButtonItemStyleBordered target:self
                                                                                     action:@selector(LogOutInButtonClicked:)];
    
    //If the facebook session is already valid, the barButtonItem will be change to say "Log Out"
    if ([self.facebook isSessionValid]) 
    {
        barButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Log Out"
                                                         style:UIBarButtonItemStyleBordered
                                                        target:self
                                                        action:@selector(LogOutInButtonClicked:)];
    }
    
    //Assign the LogOutIn button to the left bar button item
    self.navigationItem.leftBarButtonItem = barButtonItem;

    //Assign the post button to the right barbutton item
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Post"
                                                                              style:UIBarButtonItemStyleBordered
                                                                             target:self
                                                                             action:@selector(postToWall:)];
    
    
    //Save the previous rightBarButtonItem so it can be put back on once the View is done loading
    self.oldBarButtonItem = self.navigationItem.rightBarButtonItem;
    
    //Create an IndicatorView, start it animating, and place it in the rightBarButtonItem spot
    self.facebookActivityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [self.facebookActivityIndicator startAnimating];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.facebookActivityIndicator];
    
    //Help to verify small data requirement
    NSLog(@"Loading Web Data - Social Media View Controller");
    
    //Begin the facebook request, the data that comes back form this method will be used
    //to populate the UITableView
    [self.facebook requestWithGraphPath:@"ImagoDeiChurch/posts" andDelegate:self];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    NSIndexPath *selection = [self.tableView indexPathForSelectedRow];
	if (selection) [self.tableView deselectRowAtIndexPath:selection animated:YES];
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
    return [self.imagoDeiFacebookPostsArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    //Dequeue a cell if one is avaliable
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    
    //If there is no reusable cell of this type, create a new one
    if (!cell)
    {
        //Create standard cells
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    //Create cells with the standard app text
    cell.textLabel.textColor = [UIColor colorWithRed:0.29803 green:0.1529 blue:0.0039 alpha:1];
    cell.detailTextLabel.textColor = [UIColor colorWithRed:0.2666 green:0.2666 blue:0.2666 alpha:1];
    
    //Retrieve the corresponding dictionary to the index row requested
    NSDictionary *dictionaryForCell = [self.imagoDeiFacebookPostsArray objectAtIndex:[indexPath row]];
    
    //Pull the main and detail text label out of the corresponding dictionary
    NSString *mainTextLabel = [dictionaryForCell objectForKey:@"message"];
    NSString *detailTextLabel = [dictionaryForCell objectForKey:@"postedBy"];
    
    //Set the imageview on the left side of the see to the facebook logo
    cell.imageView.image = [UIImage imageNamed:@"f_logo.png"];
    
    //Check if the main text label is equal to NSNULL, if it is replace the text
    if ([mainTextLabel isEqual:[NSNull null]]) mainTextLabel = @"Error";
    
    //Set the cell properties to the corresponding text strings
    cell.textLabel.text = mainTextLabel;
    cell.detailTextLabel.text = detailTextLabel;
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //Retrieve the corresponding dictionary to the index row selected
    NSDictionary *tmpDictionary = [[NSDictionary alloc] initWithDictionary:[self.imagoDeiFacebookPostsArray objectAtIndex:[indexPath row]]];
    
    //Initiate the Social Detail controller
    SocialMediaDetailViewController *smdvc = [[SocialMediaDetailViewController alloc] init];
    
    //Set the model for the MVC we are about to push onto the stack
    [smdvc setShortCommentsDictionaryModel:tmpDictionary];
    
    //Set the delegate of the social media detail controller to this class
    [smdvc setSocialMediaDelegate:self];
    
    //Push the created view controller onto the stack
    [[self navigationController] pushViewController:smdvc animated:YES];
}

#pragma mark - SocialMediaDetailView datasource

- (void)SocialMediaDetailViewController:(SocialMediaDetailViewController *)sender dictionaryForFacebookGraphAPIString:(NSString *)facebookGraphAPIString
{
    NSLog(@"Loading Web Data - Social Media View Controller");
    
    //When the SocialMediaDetailViewController needs further information from
    //the facebook class, this method is called
    [self.facebook requestWithGraphPath:facebookGraphAPIString andDelegate:sender];
}

#pragma mark - Facebook Initialization Method

- (void)facebookInit
{
    //Retrieve a pointer to the appDelegate
    ImagoDeiAppDelegate *appDelegate = (ImagoDeiAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    //Set the local facebook property to point to the appDelegate facebook property
    self.facebook = appDelegate.facebook;
    
    //Set the facebook session delegate to this class
    self.facebook.sessionDelegate = self;
    
    //Retrieve the user defaults and store them in a variable
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    //If the User defaults contain the facebook access tokens, save them into the
    //facebook instance
    if ([defaults objectForKey:@"FBAccessTokenKey"] 
        && [defaults objectForKey:@"FBExpirationDateKey"]) 
    {
        self.facebook.accessToken = [defaults objectForKey:@"FBAccessTokenKey"];
        self.facebook.expirationDate = [defaults objectForKey:@"FBExpirationDateKey"];
    }
}

#pragma mark - Facebook Dialog Methods

- (void)postToWall:(id)sender
{
    NSMutableDictionary* params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   FACEBOOK_APP_ID, @"app_id",
                                   @"http://developers.facebook.com/docs/reference/dialogs/", @"link",
                                   @"http://fbrell.com/f8.jpg", @"picture",
                                   @"Facebook Dialogs", @"name",
                                   @"Reference Documentation", @"caption",
                                   @"Using Dialogs to interact with users.", @"description",
                                   nil];
    
    [self.facebook dialog:@"feed" andParams:params andDelegate:self];
}

#pragma mark - Facebook Request Delegate Methods

- (void)requestLoading:(FBRequest *)request
{
    //When a facebook request starts, save the request
    //so the delegate can be set to nill when the view disappears
    self.facebookRequest = request;
}

- (void)request:(FBRequest *)request didFailWithError:(NSError *)error
{
    NSLog(@"%@", error);
    //If the facebook request failed, stop the activityindicator
    [self.facebookActivityIndicator stopAnimating];
    
}

- (void)request:(FBRequest *)request didLoad:(id)result
{
    //Since the facebook request is complete, and setting the delegate to nil
    //will not be required if the view disappears, set the request to nil
    self.facebookRequest = nil;
    
    //Verify the result from the facebook class is actually a dictionary
    if ([result isKindOfClass:[NSDictionary class]])
    {
        //Retrieve an array of data IDs, messages, postedby, and comments
        //array from the dictionary
        NSMutableArray *idArray = [result mutableArrayValueForKeyPath:@"data.id"];
        NSMutableArray *messageArray = [result mutableArrayValueForKeyPath:@"data.message"];
        NSMutableArray *postedByArray = [result mutableArrayValueForKeyPath:@"data.from.name"];
        NSMutableArray *commentsArray = [result valueForKeyPath:@"data.comments"];
        
        //Setup a mutable dictionary with the help of the idArray count to help with performance
        NSMutableArray *arrayOfDictionaries = [[NSMutableArray alloc] initWithCapacity:[idArray count]];
        
        //Create an array of dictionaries, with each have an id, message, postedby, and comments key
        for (int i = 0; i < [idArray count]; i++) 
        {
            NSDictionary *tmpDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:[idArray objectAtIndex:i], @"id", [messageArray objectAtIndex:i], @"message", [postedByArray objectAtIndex:i], @"postedBy", [commentsArray objectAtIndex:i], @"comments", nil];
            [arrayOfDictionaries insertObject:tmpDictionary atIndex:i];
        }
        //Set the property equal to the new comments array, which will then trigger a table reload
        self.imagoDeiFacebookPostsArray = arrayOfDictionaries;
    }
    
    //Since the request has been recieved, and parsed, stop the Activity Indicator
    [self.facebookActivityIndicator stopAnimating];
    
    //If an oldbutton was removed from the right bar button spot, put it back
    self.navigationItem.rightBarButtonItem = self.oldBarButtonItem;
    
}


#pragma mark - Facebook Session Delegate Methods

- (void)fbDidLogin 
{
    //Since facebook had to log in, data will need to be requested, start the activity indicator
    [self.facebookActivityIndicator startAnimating];
    
    //Retireve the User Defaults
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    //Pull the accessToken, and expirationDate from the facebook instance, and
    //save them to the user defaults
    [defaults setObject:[self.facebook accessToken] forKey:@"FBAccessTokenKey"];
    [defaults setObject:[self.facebook expirationDate] forKey:@"FBExpirationDateKey"];
    [defaults synchronize];
    
    //Retrieve the left bar button item, and change the text to "Log Out"
    self.navigationItem.leftBarButtonItem.title = @"Log Out";
    
    //This method will request the full comments array from the delegate and
    //the facebook class will call request:request didLoad:result when complete
    [self.facebook requestWithGraphPath:@"ImagoDeiChurch/posts" andDelegate:self];
}

- (void)fbDidNotLogin:(BOOL)cancelled
{
    //Do nothing here for now, stubbed out to get rid of compiler warning
}

- (void) fbDidLogout 
{
    // Remove saved authorization information if it exists
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults objectForKey:@"FBAccessTokenKey"]) {
        [defaults removeObjectForKey:@"FBAccessTokenKey"];
        [defaults removeObjectForKey:@"FBExpirationDateKey"];
        [defaults synchronize];
    }
}

- (void)fbDidExtendToken:(NSString *)accessToken expiresAt:(NSDate *)expiresAt
{
    //Retrieve the user defaults, and save the new tokens
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[self.facebook accessToken] forKey:@"FBAccessTokenKey"];
    [defaults setObject:[self.facebook expirationDate] forKey:@"FBExpirationDateKey"];
    [defaults synchronize];
}

- (void)fbSessionInvalidated
{
    //Do nothing here for now, stubbed out to get rid of compiler warning
}

- (void)viewDidUnload {
    [self setTableView:nil];
    [super viewDidUnload];
}
@end
