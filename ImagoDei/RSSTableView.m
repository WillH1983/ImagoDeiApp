//
//  BaseRSSTableView.m
//  TPM
//
//  Created by Will Hindenburg on 7/29/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "RSSTableView.h"
#import "XMLReader.h"
#import "WebViewController.h"
#import "NSMutableDictionary+appConfiguration.h"
#import "NSString+HTML.h"
#import "ImagoDeiAppDelegate.h"

@interface RSSTableView ()
@property (strong, nonatomic) UIActivityIndicatorView *activityIndicator;
@property (nonatomic, strong) UIBarButtonItem *oldBarButtonItem;
@property (nonatomic, strong) NSMutableDictionary *appConfiguration;
@end

@implementation RSSTableView
@synthesize mainRSSLink = _mainRSSLink;
@synthesize tableView = _tableView;
@synthesize RSSDataArray = _RSSDataArray;
@synthesize activityIndicator = _activityIndicator;
@synthesize oldBarButtonItem = _oldBarButtonItem;
@synthesize appConfiguration = _appConfiguration;
@synthesize finishblock = _finishblock;

- (void)setRSSDataArray:(NSArray *)RSSDataArray
{
    _RSSDataArray = RSSDataArray;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    ImagoDeiAppDelegate *appDelegate = (ImagoDeiAppDelegate *)[[UIApplication sharedApplication] delegate];
    self.appConfiguration = appDelegate.appConfiguration;
    self.mainRSSLink = self.appConfiguration.RSSlink;
    
    //initialize the activity indicator, set it to the center top of the view, and
    //start it animating
    self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
	self.activityIndicator.hidesWhenStopped = YES;
    
    //Save the previous rightBarButtonItem so it can be put back on once the View is done loading
    self.oldBarButtonItem = self.navigationItem.rightBarButtonItem;
    
    //Set the right navigation bar button item to the activity indicator
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.activityIndicator];
    
    [self downloadData];
}

- (void)viewDidUnload
{
    [self setTableView:nil];
    [self setTableView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)downloadData
{
    [self.activityIndicator startAnimating];
    if (self.mainRSSLink)
    {
        dispatch_queue_t downloadQueue = dispatch_queue_create("downloader", NULL);
        dispatch_async(downloadQueue, ^{
            NSData *xmlData = nil;
            NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] initWithURL:self.mainRSSLink];
            NSError *error = [[NSError alloc] init];
            NSHTTPURLResponse *response;
            xmlData = [NSURLConnection sendSynchronousRequest:urlRequest returningResponse:&response error:&error];
            NSDictionary *xmlDictionary = nil;
            if (!xmlData)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    ImagoDeiAppDelegate *appDelegate = (ImagoDeiAppDelegate *)[[UIApplication sharedApplication] delegate];
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:appDelegate.appConfiguration.appName message:[error localizedDescription] delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles: nil];
                    [alertView show];
                });
            }
            else
            {
                xmlDictionary = [XMLReader dictionaryForXMLData:xmlData error:nil];

                if (!xmlDictionary)
                {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        ImagoDeiAppDelegate *appDelegate = (ImagoDeiAppDelegate *)[[UIApplication sharedApplication] delegate];
                        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:appDelegate.appConfiguration.appName message:[error localizedDescription] delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles: nil];
                        [alertView show];
                    });
                }
                else 
                {
                    id tmp = [xmlDictionary valueForKeyPath:@"rss.channel.item"];
                    self.RSSDataArray = tmp;
                    if ([tmp isKindOfClass:[NSArray class]])
                    {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self.activityIndicator stopAnimating];
                            self.navigationItem.rightBarButtonItem = self.oldBarButtonItem;
                            //[self performSelector:@selector(stopLoading) withObject:nil afterDelay:0];
                        });
                    }

                    if (self.finishblock) self.finishblock();
                }
            }
        });
        dispatch_release(downloadQueue);
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:animated];
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.RSSDataArray count];
}

- (NSString *)mainCellTextLabelForSelectedCellDictionary:(NSDictionary *)cellDictionary
{
    return [cellDictionary valueForKeyPath:@"title.text"];
}

- (NSString *)detailCellTextLabelForSelectedCellDictionary:(NSDictionary *)cellDictionary
{
    return [cellDictionary valueForKeyPath:@"description.text"];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //Set the cell identifier to the same as the prototype cell in the story board
    static NSString *CellIdentifier = @"BaseRSSTableCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    
    //If there is no reusable cell of this type, create a new one
    if (!cell)
    {
        //Set the atributes of the main page cell
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        
    }
    
    //Retrieve the corresponding dictionary to the index row requested
    id dictionaryForCell = [self.RSSDataArray objectAtIndex:[indexPath row]];
    NSString *mainTextLabel = nil;
    NSString *detailTextLabel = nil;
    
    if ([dictionaryForCell isKindOfClass:[NSDictionary class]])
    {
        //Pull the main and detail text label out of the corresponding dictionary
        mainTextLabel = [self mainCellTextLabelForSelectedCellDictionary:dictionaryForCell];
        mainTextLabel = [mainTextLabel stringByDecodingXMLEntities];
        
        detailTextLabel = [self detailCellTextLabelForSelectedCellDictionary:dictionaryForCell];
        detailTextLabel = [detailTextLabel stringByDecodingXMLEntities];
    }
    
    
    //Check if the main text label is equal to NSNULL, if it is replace the text
    if ([mainTextLabel isEqual:[NSNull null]]) mainTextLabel = self.appConfiguration.appName;
    
    //Set the cell text label's based upon the table contents array location
    cell.textLabel.text = mainTextLabel;
    cell.detailTextLabel.text = detailTextLabel;
    
    cell.imageView.image = [UIImage imageNamed:self.appConfiguration.defaultLocalPathImageForTableViewCell];
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //Pull the URL from the selected tablecell, which is from the parsed RSS file with the key "link"
    NSURL *url = [[NSURL alloc] initWithString:[[self.RSSDataArray objectAtIndex:indexPath.row] valueForKeyPath:@"link.text"]];
    
    //Only perform actions on url if it is a valid URL
    if (url)
    {
        //If the URL is for an RSS file, initialize a mainpageviewcontroller with the URL
        //and set the title
        if ([[url pathExtension] isEqualToString:@"rss"]|| [[url lastPathComponent] isEqualToString:@"feed"])
        {
            RSSTableView *brtv = [[RSSTableView alloc] init];
            [brtv setMainRSSLink:url];
            [self.navigationController pushViewController:brtv animated:YES];
        }
        //Catch all is to load a webview with the contents of the URL
        else 
        {
            WebViewController *wvc = [[WebViewController alloc] init];
            [wvc setUrlToLoad:url];
            [[self navigationController] pushViewController:wvc animated:YES];
        }
    }
}

- (UIImage*)imageWithImage:(UIImage*)image 
              scaledToSize:(CGSize)newSize;
{
    UIGraphicsBeginImageContext( newSize );
    [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

- (void)tableView:(UITableView *)tableview willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *url = nil;
    NSDictionary *RSSContentDictionary = [self.RSSDataArray objectAtIndex:indexPath.row];
    NSString *htmlString = [RSSContentDictionary valueForKeyPath:@"content:encoded.text"]; //fix me
    NSScanner *theScanner = [NSScanner scannerWithString:htmlString];
    // find start of IMG tag
    [theScanner scanUpToString:@"<img" intoString:nil];
    if (![theScanner isAtEnd]) {
        [theScanner scanUpToString:@"src" intoString:nil];
        NSCharacterSet *charset = [NSCharacterSet characterSetWithCharactersInString:@"\"'"];
        [theScanner scanUpToCharactersFromSet:charset intoString:nil];
        [theScanner scanCharactersFromSet:charset intoString:nil];
        [theScanner scanUpToCharactersFromSet:charset intoString:&url];
        // "url" now contains the URL of the img
    }
    
    dispatch_queue_t downloadQueue = dispatch_queue_create("Profile Image Downloader", NULL);
    dispatch_async(downloadQueue, ^{
        NSData *picture = nil;
        if (url)
        {
            NSURL *photoURL = [[NSURL alloc] initWithString:url];
            picture = [NSData dataWithContentsOfURL:photoURL];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                NSArray *tmpArray = [self.tableView indexPathsForVisibleRows];
                if ([tmpArray containsObject:indexPath])
                {
                    UIImage *image = [UIImage imageWithData:picture];
                    UIImage *imageResized = [self imageWithImage:image scaledToSize:CGSizeMake(50, 50)];
                    cell.imageView.image = imageResized;
                    
                }
            });
        }
        
    });
    dispatch_release(downloadQueue);

}

@end
