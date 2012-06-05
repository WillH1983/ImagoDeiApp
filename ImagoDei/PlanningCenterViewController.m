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
#import <QuartzCore/QuartzCore.h>
#import "WebViewController.h"

static NSString *const kPCOKeychainItemName = @"Imago Dei: Planning Center";
static NSString *const kPCOServiceName = @"Planning Center";
static NSString *const CONSUMER_KEY = @"VmHJumSJqVS80j5TejhH";
static NSString *const CONSUMER_SECRECT = @"NkutqYLfideVKX2nqHRV9UIIGYe8rA4qVtu29hu1";
static NSString *const PCOServiceIDsPath = @"id";
static NSString *const PCOServiceTypes = @"organization.service-types.service-type";
static NSString *const DanaPeopleID = @"1240047";

#define DEGREES_TO_RADIANS(angle) (angle / 180.0 * M_PI)

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
    /*NSString *filePath = [[NSBundle mainBundle] pathForResource:@"future_plans" ofType:@"xml"];
    NSData *xmlData = [[NSData alloc] initWithContentsOfFile:filePath];
    NSDictionary *dictionary = [XMLReader dictionaryForXMLData:xmlData error:nil];*/
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
            
            NSMutableArray *mutableArray = [tmpArray mutableCopy];
            for (int x = 0; x < [mutableArray count]; x++)
            {
                id items = [mutableArray objectAtIndex:x];
                id planPerson = [items valueForKeyPath:@"my-plan-people.my-plan-person"];
                if ([planPerson isKindOfClass:[NSArray class]])
                {
                    if ([items isKindOfClass:[NSMutableDictionary class]])
                    {
                        [mutableArray removeObjectAtIndex:x];
                        NSMutableDictionary *myPlanPerson = nil;
                        for (int i = 0; i < [planPerson count]; i++)
                        {
                            myPlanPerson = [[NSMutableDictionary alloc] initWithObjectsAndKeys:[planPerson objectAtIndex:i], @"my-plan-person", nil];
                            NSMutableDictionary *tmpItems = [items mutableCopy];
                            [tmpItems setObject:myPlanPerson forKey:@"my-plan-people"];
                            [mutableArray insertObject:tmpItems atIndex:(x + i)];
                        }
                    }
                }
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                self.arrayOfTableData = mutableArray;
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

- (void)cellButtonPushed:(id)sender
{
    UIView *cellView = [sender superview];
    UITableViewCell *cell = (UITableViewCell *)[cellView superview];
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    id object = [self.arrayOfTableData objectAtIndex:indexPath.row];
    if ([object isKindOfClass:[NSMutableDictionary class]])
    {
        NSMutableDictionary *dictionary = object;
        NSString *isEditing = [dictionary valueForKeyPath:@"isEditing"];
        if ((isEditing == nil) || ([isEditing isEqualToString:@"NO"]))
        {
            [dictionary setObject:@"YES" forKey:@"isEditing"];
            [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        }
        else if ([isEditing isEqualToString:@"YES"])
        {
            [dictionary setObject:@"NO" forKey:@"isEditing"];
            [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        }
        
    }
}

- (void)acceptButtonPressed:(id)sender
{
    UIView *cellView = [sender superview];
    UITableViewCell *cell = (UITableViewCell *)[cellView superview];
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    id object = [self.arrayOfTableData objectAtIndex:indexPath.row];
    if ([object isKindOfClass:[NSDictionary class]])
    {
        NSDictionary *tmpDictionary = object;
        NSString *acceptURL = [NSString stringWithFormat:@"https://www.planningcenteronline.com/planning_center/accept/%@", [tmpDictionary valueForKeyPath:@"my-plan-people.my-plan-person.access-code.text"]];
        [self performSegueWithIdentifier:@"AcceptDecline" sender:acceptURL];
    }
}

- (void)declineButtonPressed:(id)sender
{
    UIView *cellView = [sender superview];
    UITableViewCell *cell = (UITableViewCell *)[cellView superview];
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    id object = [self.arrayOfTableData objectAtIndex:indexPath.row];
    if ([object isKindOfClass:[NSDictionary class]])
    {
        NSDictionary *tmpDictionary = object;
        NSString *declineURL = [NSString stringWithFormat:@"https://www.planningcenteronline.com/planning_center/decline/%@", [tmpDictionary valueForKeyPath:@"my-plan-people.my-plan-person.access-code.text"]];
        [self performSegueWithIdentifier:@"AcceptDecline" sender:declineURL];
    }
        
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"AcceptDecline"])
    {
        [segue.destinationViewController setUrlToLoad:[NSURL URLWithString:sender]];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //Set the cell identifier to the same as the prototype cell in the story board
    static NSString *CellIdentifier = @"Planning Center Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    UIButton *button = nil;
    UIButton *acceptButton = nil;
    UIButton *declineButton = nil;
    UILabel *cellText = nil;
    UILabel *cellSubtitle = nil;
    UIImageView *arrow = nil;
    
    //If there is no reusable cell of this type, create a new one
    if (!cell)
    {
        //Set the atributes of the main page cell
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        
        button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(cell.contentView.bounds.size.width - 70, 2, 65, 40);
        [button addTarget:self action:@selector(cellButtonPushed:) forControlEvents:UIControlEventTouchUpInside];
        button.tag = 1;
        
        [cell.contentView addSubview:button];
        
        acceptButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [acceptButton addTarget:self action:@selector(acceptButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        acceptButton.tag = 2;
        [cell.contentView addSubview:acceptButton];
        
        declineButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [declineButton addTarget:self action:@selector(declineButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        declineButton.tag = 3;
        [cell.contentView addSubview:declineButton];
        
        cellText = [[UILabel alloc] init];
        cellText.frame = CGRectMake(10, 0, 225, 21);
        cellText.backgroundColor = [UIColor clearColor];
        cellText.font = [UIFont boldSystemFontOfSize:18.0];
        cellText.textColor = [UIColor colorWithRed:0.29803 green:0.1529 blue:0.0039 alpha:1];
        cellText.tag = 4;
        [cell.contentView addSubview:cellText];
        
        cellSubtitle = [[UILabel alloc] init];
        cellSubtitle.frame = CGRectMake(10, 20, 225, 21);
        cellSubtitle.backgroundColor = [UIColor clearColor];
        cellSubtitle.font = [UIFont systemFontOfSize:14.0];
        cellSubtitle.textColor = [UIColor colorWithRed:0.2666 green:0.2666 blue:0.2666 alpha:1];
        cellSubtitle.tag = 5;
        [cell.contentView addSubview:cellSubtitle];
        
        arrow = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"arrow-sideways.png"]];
        arrow.frame = CGRectMake(cell.contentView.bounds.size.width - 45, 12, 40, 20);
        arrow.tag = 6;
        [cell.contentView addSubview:arrow];
        
        cell.backgroundColor = [UIColor clearColor];
    }
    else 
    {
        button = (UIButton *)[cell.contentView viewWithTag:1];
        acceptButton = (UIButton *)[cell.contentView viewWithTag:2];
        declineButton = (UIButton *)[cell.contentView viewWithTag:3];
        cellText = (UILabel *)[cell.contentView viewWithTag:4];
        cellSubtitle = (UILabel *)[cell.contentView viewWithTag:5];
        arrow = (UIImageView *)[cell.contentView viewWithTag:6];
    }
    
    //Retrieve the corresponding dictionary to the index row requested
    NSDictionary *dictionaryForCell = [self.arrayOfTableData objectAtIndex:[indexPath row]];
    
    NSString *isEditing = [dictionaryForCell valueForKeyPath:@"isEditing"];
    
    if ([isEditing isEqualToString:@"YES"])
    {
        UIEdgeInsets AcceptDeclineEdge = UIEdgeInsetsMake(12, 12, 12, 12);
        
        acceptButton.frame = CGRectMake(5, 50, 99, 45);
        UIImage *greenAcceptButtonImage = [UIImage imageNamed:@"greenButton.png"];
        UIImage *stretchableGreenAcceptButton = [greenAcceptButtonImage resizableImageWithCapInsets:AcceptDeclineEdge];
        [acceptButton setBackgroundImage:stretchableGreenAcceptButton forState:UIControlStateNormal];
        
        UIImage *darkGreenAcceptButtonImage = [UIImage imageNamed:@"greenButtonActivated.png"];
        UIImage *stretchabledarkGreenAcceptButton = [darkGreenAcceptButtonImage resizableImageWithCapInsets:AcceptDeclineEdge];
        [acceptButton setBackgroundImage:stretchabledarkGreenAcceptButton forState:UIControlStateHighlighted];
        [acceptButton setTitle:@"Accept" forState:UIControlStateNormal];
        
        declineButton.frame = CGRectMake(110, 50, 99, 45);
        UIImage *redDeclineButtonImage = [UIImage imageNamed:@"redButton.png"];
        UIImage *stretchableRedDeclineButton = [redDeclineButtonImage resizableImageWithCapInsets:AcceptDeclineEdge];
        [declineButton setBackgroundImage:stretchableRedDeclineButton forState:UIControlStateNormal];
        
        UIImage *darkRedDeclineButtonImage = [UIImage imageNamed:@"redButtonActivated.png"];
        UIImage *stretchabledarkRedDeclineButton = [darkRedDeclineButtonImage resizableImageWithCapInsets:AcceptDeclineEdge];
        [declineButton setBackgroundImage:stretchabledarkRedDeclineButton forState:UIControlStateHighlighted];
        [declineButton setTitle:@"Decline" forState:UIControlStateNormal];
        
        // Setup the animation
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0];
        [UIView setAnimationCurve:UIViewAnimationCurveLinear];
        [UIView setAnimationBeginsFromCurrentState:YES];
        
        [arrow layer].transform = CATransform3DMakeRotation(M_PI/2, 0, 0, 1);
        // Commit the changes
        [UIView commitAnimations];
    }
    else 
    {
        acceptButton.frame = CGRectZero;
        declineButton.frame = CGRectZero;
        
        // Setup the animation
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0];
        [UIView setAnimationCurve:UIViewAnimationCurveLinear];
        [UIView setAnimationBeginsFromCurrentState:YES];
        
        [arrow layer].transform = CATransform3DMakeRotation(M_PI * 2, 0, 0, 1);
        // Commit the changes
        [UIView commitAnimations];
    }
    
    NSString *status = [dictionaryForCell valueForKeyPath:@"my-plan-people.my-plan-person.status.text"];
     UIEdgeInsets smallButtonEdge = UIEdgeInsetsMake(12, 12, 12, 12);
    if ([status isEqualToString:@"C"])
    {
        UIImage *greenButtonImage = [UIImage imageNamed:@"greenButton.png"];
        UIImage *stretchableGreenButton = [greenButtonImage resizableImageWithCapInsets:smallButtonEdge];
        [button setBackgroundImage:stretchableGreenButton forState:UIControlStateNormal];
        
        UIImage *darkGreenButtonImage = [UIImage imageNamed:@"greenButtonActivated.png"];
        UIImage *stretchabledarkGreenButton = [darkGreenButtonImage resizableImageWithCapInsets:smallButtonEdge];
        [button setBackgroundImage:stretchabledarkGreenButton forState:UIControlStateHighlighted];
        [button setTitle:@"A     " forState:UIControlStateNormal];
    }
    else if ([status isEqualToString:@"U"])
    {
        UIImage *yellowButtonImage = [UIImage imageNamed:@"yellowButton.png"];
        UIImage *stretchableYellowButton = [yellowButtonImage resizableImageWithCapInsets:smallButtonEdge];
        [button setBackgroundImage:stretchableYellowButton forState:UIControlStateNormal];
        
        UIImage *darkYellowButtonImage = [UIImage imageNamed:@"yellowButtonActivated.png"];
        UIImage *stretchabledarkYellowButton = [darkYellowButtonImage resizableImageWithCapInsets:smallButtonEdge];
        [button setBackgroundImage:stretchabledarkYellowButton forState:UIControlStateHighlighted];
        [button setTitle:@"U     " forState:UIControlStateNormal];
    }
    else {
        UIImage *redButtonImage = [UIImage imageNamed:@"redButton.png"];
        UIImage *stretchableRedButton = [redButtonImage resizableImageWithCapInsets:smallButtonEdge];
        [button setBackgroundImage:stretchableRedButton forState:UIControlStateNormal];
        
        UIImage *darkRedButtonImage = [UIImage imageNamed:@"redButtonActivated.png"];
        UIImage *stretchabledarkRedButton = [darkRedButtonImage resizableImageWithCapInsets:smallButtonEdge];
        [button setBackgroundImage:stretchabledarkRedButton forState:UIControlStateHighlighted];
        [button setTitle:@"D     " forState:UIControlStateNormal];
    }
    
    
    //Pull the main and detail text label out of the corresponding dictionary
    NSString *mainTextLabel = [self mainCellTextLabelForSelectedCellDictionary:dictionaryForCell];
    NSString *detailTextLabel = [self detailCellTextLabelForSelectedCellDictionary:dictionaryForCell];
    
    //Check if the main text label is equal to NSNULL, if it is replace the text
    if ([mainTextLabel isEqual:[NSNull null]]) mainTextLabel = @"Imago Dei Church";
    
    //Set the cell text label's based upon the table contents array location
    cellText.text = mainTextLabel;
    cellSubtitle.text = detailTextLabel;
    
    //Make sure that the imageview is set to nil when the cell is reused
    //this makes sure that the old image does not show up
    cell.imageView.image = nil;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    id object = [self.arrayOfTableData objectAtIndex:indexPath.row];
    if ([object isKindOfClass:[NSMutableDictionary class]]){
        NSMutableDictionary *dictionary = object;
        NSString * tmpString = [dictionary valueForKeyPath:@"isEditing"];
        if ([tmpString isEqualToString:@"YES"]) 
        {
            return 105;
        }
    }
    return 48;
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
