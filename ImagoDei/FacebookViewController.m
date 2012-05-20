//
//  FacebookViewController.m
//  ImagoDei
//
//  Created by Will Hindenburg on 5/19/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "FacebookViewController.h"
#import "ImagoDeiAppDelegate.h"
#import "WebViewController.h"

@interface FacebookViewController ()
@property (nonatomic, strong) FBRequest *facebookRequest;
@property (nonatomic, strong) TTListDataSource *facebookDataSource;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;
@property (nonatomic, strong) UIBarButtonItem *oldBarButtonItem;

- (void)facebookInit;
@end

@implementation FacebookViewController
@synthesize facebook = _facebook;
@synthesize facebookRequest = _facebookRequest;
@synthesize facebookDataSource = _facebookDataSource;
@synthesize activityIndicator = _activityIndicator;
@synthesize oldBarButtonItem = _oldBarButtonItem;

#define FACEBOOK_CONTENT_TITLE @"message"
#define FACEBOOK_CONTENT_DESCRIPTION @"postedBy"

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (IBAction)LogOutInButtonClicked:(id)sender 
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

#pragma mark - View Lifecycle

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self.tabBarItem setFinishedSelectedImage:[UIImage imageNamed:@"fb-logo-active.png"] withFinishedUnselectedImage:[UIImage imageNamed:@"fb-logo-inactive.png"]];
    self.tabBarItem.title = @"Facebook";
    self.facebookDataSource = [[TTListDataSource alloc] init];
    self.autoresizesForKeyboard = YES;
    self.variableHeightRows = YES;
    self.dataSource = self.facebookDataSource;
    [self emptyView];
    TTNavigator *navigator = [TTNavigator navigator];
    navigator.persistenceMode = TTNavigatorPersistenceModeNone;
    navigator.delegate = self;

}

- (void)viewDidDisappear:(BOOL)animated
{
    //When the view disappears the code in this fucnction removes all delegation to this class
    //and it stops the loading
    
    //This is required incase a connection request is in progress when the view disappears
    [self.facebookRequest setDelegate:nil];
    
    //This is required incase a facebook method completes after the view has disappered
    ImagoDeiAppDelegate *appDelegate = (ImagoDeiAppDelegate *)[[UIApplication sharedApplication] delegate];
    appDelegate.facebook.sessionDelegate = nil;
    
    //Super method
    [super viewDidDisappear:animated];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //initialize the activity indicator, set it to the center top of the view, and
    //start it animating
    self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
	self.activityIndicator.hidesWhenStopped = YES;
    [self.activityIndicator startAnimating];
    //Save the previous rightBarButtonItem so it can be put back on once the View is done loading
    self.oldBarButtonItem = self.navigationItem.rightBarButtonItem;
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.activityIndicator];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //if ([self.arrayOfTableData count] > 0) return;
    //Init the facebook session
    [self facebookInit];
    
    //If the facebook session is already valid, the barButtonItem will be change to say "Log Out"
    if ([self.facebook isSessionValid]) 
    {
        self.navigationItem.leftBarButtonItem.title = @"Log Out";
    }
    
    //Help to verify small data requirement
    NSLog(@"Loading Web Data - Social Media View Controller");
    
    //Set the Imago Dei logo to the title view of the navigation controler
    //With the content mode set to AspectFit
    UIImage *logoImage = [UIImage imageNamed:@"imago-logo.png"];
    UIImageView *logoImageView = [[UIImageView alloc] initWithImage:logoImage];
    logoImageView.contentMode = UIViewContentModeScaleAspectFit;
    self.navigationItem.titleView = logoImageView;
    
    //Create a UIImageView and set the content mode to be placed in the background
    UIImageView *backgroundImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"background.png"]];
    backgroundImageView.contentMode = UIViewContentModeScaleToFill;
    
    //Set the background of the ImagoDei app to the background image
    self.tableView.backgroundView = backgroundImageView;
    
    //Set the navigation bar color to the standard color
    UIColor *standardColor = [UIColor colorWithRed:.7529 green:0.7372 blue:0.7019 alpha:1.0];
    [[[self navigationController] navigationBar] setTintColor:standardColor];
    
    //Begin the facebook request, the data that comes back form this method will be used
    //to populate the UITableView
    [self.facebook requestWithGraphPath:@"ImagoDeiChurch/posts" andDelegate:self];
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

- (IBAction)postToWall:(id)sender 
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
    dispatch_async(dispatch_get_main_queue(), ^{
        //Since the request has been recieved, and parsed, stop the Activity Indicator
        [self.activityIndicator stopAnimating];

    });
    
}

- (BOOL)shouldReload
{
    return YES;
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
        
        TTStyledText *text = nil;
        
        //Create an array of dictionaries, with each have an id, message, postedby, and comments key
        for (int i = 0; i < [idArray count]; i++) 
        {
            //Check if the main text label is equal to NSNULL, if it is replace the text
            if ([[messageArray objectAtIndex:i] isEqual:[NSNull null]]) 
            {
                text = [TTStyledText textFromXHTML:@"Imago Dei Church"];
            }
            else 
            {
                text = [TTStyledText textFromXHTML:[messageArray objectAtIndex:i] lineBreaks:YES URLs:YES];
            }
            [self.facebookDataSource.items addObject:[TTTableStyledTextItem itemWithText:text URL:nil]];
        }
        //Set the property equal to the new comments array, which will then trigger a table reload
        //self.arrayOfTableData = arrayOfDictionaries;
        
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self updateView];
        
        //Since the request has been recieved, and parsed, stop the Activity Indicator
        [self.activityIndicator stopAnimating];
        
        //If an oldbutton was removed from the right bar button spot, put it back
        self.navigationItem.rightBarButtonItem = self.oldBarButtonItem;
        
        //[self performSelector:@selector(stopLoading) withObject:nil afterDelay:0];
    });
}


#pragma mark - Facebook Session Delegate Methods

- (void)fbDidLogin 
{
    //Since facebook had to log in, data will need to be requested, start the activity indicator
    [self.activityIndicator startAnimating];
    
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

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (BOOL) navigator:(TTBaseNavigator *)navigator shouldOpenURL:(NSURL *)URL
{
    WebViewController *wvc = [[WebViewController alloc] init];
    [wvc openURL:URL];
    [self.navigationController pushViewController:wvc animated:YES];
    return NO;
}

@end
