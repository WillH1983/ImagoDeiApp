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
static NSString *const DanaPeopleID = @"1240047";


@interface PlanningCenterViewController ()
@property (nonatomic, strong)GTMOAuthAuthentication *authentication;
@end

@implementation PlanningCenterViewController
@synthesize authentication = _authentication;

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

- (NSDictionary *)dictionaryForXMLURLString:(NSString *)urlString
{
    NSMutableURLRequest *xmlURLRequest = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:urlString]];
    [self.authentication authorizeRequest:xmlURLRequest];
    NSHTTPURLResponse *response;
    NSData *xmlData = [NSURLConnection sendSynchronousRequest:xmlURLRequest returningResponse:&response error:nil];
    NSDictionary *dictionary = [XMLReader dictionaryForXMLData:xmlData error:nil];
    return dictionary;
}

- (void)downloadPlanningCenterData
{
    if ([self.authentication canAuthorize]) 
    {
        self.navigationItem.leftBarButtonItem.title = @"Log Out";
        [self.activityIndicator startAnimating];
        __block NSArray *tmpArray = [[NSArray alloc] init];
        dispatch_queue_t downloadQueue = dispatch_queue_create("downloader", NULL);
        dispatch_async(downloadQueue, ^{
            NSString *futurePlansURL = [[NSString alloc] initWithString:@"https://www.planningcenteronline.com/me/future_plans.xml"];
            NSDictionary *futurePlansDictionary = [self dictionaryForXMLURLString:futurePlansURL];
            if (futurePlansDictionary)
            {
                id futurePlans = [futurePlansDictionary valueForKeyPath:@"plans.plan"];
                if ([futurePlans isKindOfClass:[NSDictionary class]])
                {
                    tmpArray = [tmpArray arrayByAddingObject:futurePlans];
                }
                else if ([futurePlans isKindOfClass:[NSArray class]]) 
                {
                    tmpArray = [tmpArray arrayByAddingObjectsFromArray:futurePlans];
                }
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                self.arrayOfTableData = tmpArray;
                [self.activityIndicator stopAnimating];
                [self performSelector:@selector(stopLoading) withObject:nil afterDelay:0.0];
            });
        });
        dispatch_release(downloadQueue);
    } 
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.activityIndicator stopAnimating];
    [self downloadPlanningCenterData];
    
}

- (NSString *)mainCellTextLabelForSelectedCellDictionary:(NSDictionary *)cellDictionary
{
    return [cellDictionary valueForKeyPath:@"dates.text"];
}

- (NSString *)detailCellTextLabelForSelectedCellDictionary:(NSDictionary *)cellDictionary
{
    NSString *category = [cellDictionary valueForKeyPath:@"my-plan-people.my-plan-person.category-name.text"];
    NSString *position = [cellDictionary valueForKeyPath:@"my-plan-people.my-plan-person.position.text"];
    
    return [[NSString alloc] initWithFormat:@"%@ - %@", category, position];
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
        [self downloadPlanningCenterData];
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
    [self downloadPlanningCenterData];
}

@end
