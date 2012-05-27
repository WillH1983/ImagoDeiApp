//
//  PlanningCenterViewController.m
//  ImagoDei
//
//  Created by Will Hindenburg on 5/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PlanningCenterViewController.h"
#import "GTMOAuthAuthentication.h"
#import "GTMOAuthViewControllerTouch.h"

static NSString *const kPCOKeychainItemName = @"Imago Dei: Planning Center";
static NSString *const kPCOServiceName = @"Planning Center";
static NSString *const CONSUMER_KEY = @"VmHJumSJqVS80j5TejhH";
static NSString *const CONSUMER_SECRECT = @"NkutqYLfideVKX2nqHRV9UIIGYe8rA4qVtu29hu1";
static NSString *const PCOServiceIDsPath = @"id";
static NSString *const PCOServiceTypes = @"organization.service-types.service-type";


@interface PlanningCenterViewController ()
@property (nonatomic, strong)GTMOAuthAuthentication *authentication;
@property (nonatomic, strong)NSArray *serviceTypes;

@end

@implementation PlanningCenterViewController
@synthesize authentication = _authentication;
@synthesize serviceTypes = _serviceTypes;

- (void)signOut {
    
    // remove the stored Twitter authentication from the keychain, if any
    [GTMOAuthViewControllerTouch removeParamsFromKeychainForName:kPCOKeychainItemName];
    
    // Discard our retained authentication object.
    [self setAuthentication:nil];
}

- (void)signInToPCO {
    
    [self signOut];
    
    NSURL *requestURL = [NSURL URLWithString:@"https://www.planningcenteronline.com/oauth/request_token"];
    NSURL *accessURL = [NSURL URLWithString:@"https://www.planningcenteronline.com/oauth/access_token"];
    NSURL *authorizeURL = [NSURL URLWithString:@"https://www.planningcenteronline.com/oauth/authorize"];
    NSString *scope = @"https://www.planningcenteronline.com/oauth/";
    
    GTMOAuthAuthentication *auth = [self authForPCO];
    
    // set the callback URL to which the site should redirect, and for which
    // the OAuth controller should look to determine when sign-in has
    // finished or been canceled
    //
    // This URL does not need to be for an actual web page; it will not be
    // loaded
    [auth setCallback:@"http://www.example.com/OAuthCallback"];
    
    
    // Display the autentication view.
    GTMOAuthViewControllerTouch *viewController;
    viewController = [[GTMOAuthViewControllerTouch alloc] initWithScope:scope
                                                                language:nil
                                                         requestTokenURL:requestURL
                                                       authorizeTokenURL:authorizeURL
                                                          accessTokenURL:accessURL
                                                          authentication:auth
                                                          appServiceName:kPCOKeychainItemName
                                                                delegate:self
                                                        finishedSelector:@selector(viewController:finishedWithAuth:error:)];
    
    // We can set a URL for deleting the cookies after sign-in so the next time
    // the user signs in, the browser does not assume the user is already signed
    // in
    [viewController setBrowserCookiesURL:[NSURL URLWithString:@"https://www.planningcenteronline.com/oauth"]];
    
    // You can set the title of the navigationItem of the controller here, if you want.
    
    [[self navigationController] pushViewController:viewController animated:YES];
}

- (GTMOAuthAuthentication *)authForPCO {
    
    GTMOAuthAuthentication *auth;
    auth = [[GTMOAuthAuthentication alloc] initWithSignatureMethod:kGTMOAuthSignatureMethodHMAC_SHA1
                                                        consumerKey:CONSUMER_KEY
                                                         privateKey:CONSUMER_SECRECT];
    
    // setting the service name lets us inspect the auth object later to know
    // what service it is for
    [auth setServiceProvider:kPCOServiceName];
    
    return auth;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    [self.tabBarItem setFinishedSelectedImage:[UIImage imageNamed:@"pco-logo-active.png"] withFinishedUnselectedImage:[UIImage imageNamed:@"pco-logo-inactive.png"]];
    self.tabBarItem.title = @"Planning Center";
    
    /*NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(incrementNetworkActivity:) name:kGTMOAuthFetchStarted object:nil];
    [nc addObserver:self selector:@selector(decrementNetworkActivity:) name:kGTMOAuthFetchStopped object:nil];
    [nc addObserver:self selector:@selector(signInNetworkLostOrFound:) name:kGTMOAuthNetworkLost  object:nil];
    [nc addObserver:self selector:@selector(signInNetworkLostOrFound:) name:kGTMOAuthNetworkFound object:nil];*/
    
    GTMOAuthAuthentication *auth;
    auth = [self authForPCO];
    if (auth) {
        BOOL didAuth = [GTMOAuthViewControllerTouch authorizeFromKeychainForName:kPCOKeychainItemName
                                                                  authentication:auth];
        if (didAuth) {
            // Select the Twitter index
            //[mServiceSegments setSelectedSegmentIndex:1];
        }
    }
    
    // save the authentication object, which holds the auth tokens
    [self setAuthentication:auth];
    
    self.tableView.allowsSelection = NO;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.activityIndicator stopAnimating];
    
    if ([self.authentication canAuthorize]) 
    {
        self.navigationItem.leftBarButtonItem.title = @"Log Out";
        [self.activityIndicator startAnimating];
        NSMutableURLRequest *xmlURLRequest = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString: @"https://www.planningcenteronline.com/organization.xml"]];
        [self.authentication authorizeRequest:xmlURLRequest];
        
        dispatch_queue_t downloadQueue2 = dispatch_queue_create("downloader", NULL);
        dispatch_async(downloadQueue2, ^{
            NSHTTPURLResponse *response;
            NSData *xmlData = [NSURLConnection sendSynchronousRequest:xmlURLRequest returningResponse:&response error:nil];
            
            if (xmlData)
            {
                id tmpServiceTypes = [[XMLReader dictionaryForXMLData:xmlData error:nil] valueForKeyPath:PCOServiceTypes];
                if ([tmpServiceTypes isKindOfClass:[NSArray class]])
                {
                    self.serviceTypes = tmpServiceTypes;
                }
                NSArray *serviceTypeIDs = [self.serviceTypes valueForKeyPath:PCOServiceIDsPath];
                NSDictionary *dictionaryForServiceTypeIDs = nil;
                NSData *planningData = nil;
                NSDictionary *planningDictionary = nil;
                NSString *planDate = nil;
                NSMutableArray *tmpUpcomingVolunteerDates = [[NSMutableArray alloc] init];
                
                for (int i = 0; i < [serviceTypeIDs count]; i++)
                {
                    dictionaryForServiceTypeIDs = [serviceTypeIDs objectAtIndex:i];
                    NSString *urlString = [NSString stringWithFormat:@"https://www.planningcenteronline.com/service_types/%@/plans.xml", [dictionaryForServiceTypeIDs valueForKeyPath:@"text"]];
                    NSLog(@"%@", serviceTypeIDs);
                    [xmlURLRequest setURL:[NSURL URLWithString:urlString]];
                    [self.authentication authorizeRequest:xmlURLRequest];
                    NSHTTPURLResponse *response;
                    planningData = [NSURLConnection sendSynchronousRequest:xmlURLRequest returningResponse:&response error:nil];
                    planningDictionary = [XMLReader dictionaryForXMLData:planningData error:nil];
                    planDate = [planningDictionary valueForKeyPath:@"plans.plan.dates.text"];
                    if (planDate) 
                    {
                        id planData = [planningDictionary valueForKeyPath:@"plans.plan"];
                        if ([planData isKindOfClass:[NSDictionary class]])
                        {
                            [tmpUpcomingVolunteerDates addObject:planData];
                        }
                        else if ([planData isKindOfClass:[NSArray class]])
                        {
                            [tmpUpcomingVolunteerDates addObjectsFromArray:planData];
                        }
                    }
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.arrayOfTableData = tmpUpcomingVolunteerDates;
                    [self.activityIndicator stopAnimating];
                });
            }
        });
    }
}

- (NSString *)keyForMainCellLabelText
{
    return @"name.text";
}

- (NSString *)keyForDetailCellLabelText
{
    return @"dates.text";
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
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.backgroundColor = [UIColor clearColor];
        cell.textLabel.textColor = [UIColor colorWithRed:0.29803 green:0.1529 blue:0.0039 alpha:1];
        cell.detailTextLabel.textColor = [UIColor colorWithRed:0.2666 green:0.2666 blue:0.2666 alpha:1];
    }
    
    //Retrieve the corresponding dictionary to the index row requested
    NSDictionary *dictionaryForCell = [self.arrayOfTableData objectAtIndex:[indexPath row]];
    
    //Pull the main and detail text label out of the corresponding dictionary
    NSString *mainTextLabel = nil;
    NSString *mainTextLabelPlanID = [dictionaryForCell valueForKeyPath:@"service-type-id.text"];
    
    NSString *planID = nil;
    for (id items in self.serviceTypes)
    {
        if ([items isKindOfClass:[NSDictionary class]])
        {
            planID = [items valueForKeyPath:@"id.text"];
            if ([mainTextLabelPlanID isEqualToString:planID])
            {
                mainTextLabel = [items valueForKeyPath:@"name.text"];
            }
        }
    }
    
    NSString *detailTextLabel = [dictionaryForCell valueForKeyPath:[self keyForDetailCellLabelText]];
    
    //Check if the main text label is equal to NSNULL, if it is replace the text
    if ([mainTextLabel isEqual:[NSNull null]]) mainTextLabel = @"Imago Dei Church";
    
    //Set the cell text label's based upon the table contents array location
    cell.textLabel.text = mainTextLabel;
    cell.detailTextLabel.text = detailTextLabel;
    
    //Make sure that the imageview is set to nil when the cell is reused
    //this makes sure that the old image does not show up
    cell.imageView.image = nil;
    
    return cell;
}

- (void)viewController:(GTMOAuthViewControllerTouch *)viewController
      finishedWithAuth:(GTMOAuthAuthentication *)auth
                 error:(NSError *)error 
{
    if (error != nil) {
        NSLog(@"Error Signing In");
    } else {
        self.navigationItem.leftBarButtonItem.title = @"Log Out";
        self.authentication = auth;
        [self.activityIndicator stopAnimating];
    }
}
- (IBAction)logInOutButtonPressed:(id)sender 
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
        [self signOut];
        barButton.title = @"Log In";
    }
    //If the barbutton says Log In, check if the facebook session is still valid
    else if ([barButton.title isEqualToString: @"Log In"])
    {
        //If it is not valid, reauthorize the app for single sign on
        if (![self.authentication canAuthorize]) 
        {
            [self.activityIndicator startAnimating];
            [self signInToPCO];
        }
    }
    
}

- (void)refresh {
    // This is just a demo. Override this method with your custom reload action.
    // Don't forget to call stopLoading at the end.
    [self performSelector:@selector(stopLoading) withObject:nil afterDelay:2.0];
}

@end
