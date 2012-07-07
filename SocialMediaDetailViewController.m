//
//  SocialMediaDetailViewController.m
//  ImagoDei
//
//  Created by Will Hindenburg on 4/18/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SocialMediaDetailViewController.h"
#import "ImageViewController.h"
#import "WebViewController.h"

@interface SocialMediaDetailViewController ()
@property (nonatomic, strong) NSArray *commentsArray;
@property (nonatomic, strong) UIImage *postImage;
@property (nonatomic, strong) UIButton *buttonImage;
@property (nonatomic, strong) FBRequest *facebookRequest;
@end

@implementation SocialMediaDetailViewController
@synthesize profilePictureImageView;
@synthesize shortCommentsDictionaryModel = _shortCommentsDictionaryModel;
@synthesize commentsArray = _commentsArray;
@synthesize socialMediaDelegate = _socialMediaDelegate;
@synthesize textView = _textView;
@synthesize buttonImage = _buttonImage;
@synthesize fullCommentsDictionaryModel = _fullCommentsDictionaryModel;
@synthesize postImage = _postImage;
@synthesize facebookRequest = _facebookRequest;

#define FONT_SIZE 14.0f
#define CELL_CONTENT_WIDTH 200.0f
#define CELL_CONTENT_MARGIN 16.0f
#define FACEBOOK_DETAIL_FONT_SIZE 16.0f

- (void)setCommentsArray:(NSArray *)commentsArray
{
    _commentsArray = commentsArray;
    [self.tableView reloadData];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        //Set a notification up to call the function presentWebView when a URL is clicked
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(presentWebView:) 
                                                     name:@"urlSelected"
                                                   object:nil];

    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    if (self)
    {
        //Set a notification up to call the function presentWebView when a URL is clicked
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(presentWebView:) 
                                                     name:@"urlSelected"
                                                   object:nil];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //Do not allow the cells in the tableview to be selected
    [self.tableView setAllowsSelection:NO];
    
    //Pull the full comments dictionary from the delegate to use as our Model
    [self.socialMediaDelegate SocialMediaDetailViewController:self dictionaryForFacebookGraphAPIString:[self.shortCommentsDictionaryModel objectForKey:@"id"]];
    
}

- (void)viewDidUnload
{
    [self setProfilePictureImageView:nil];
    [self setTextView:nil];
    [self setButtonImage:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (void)viewDidDisappear:(BOOL)animated
{
    //When the view disappears the code in this fucnction removes all delegation to this class
    //This is required incase a connection request is in progress when the view disappears
    [self.facebookRequest setDelegate:nil];
    
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.commentsArray count];
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //This function is used to configure a cell and display the proper information
    //for the table row.  The output of this function is a cell that displays one comment
    //from one facebook person, and the name of that person
    
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell;
    
    
    //If there is no reusable cell of this type, create a new one
    if (!cell)
    {
        //Initialize a UITableViewCell of type Subtitle
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        
        //Set the selection style of the cell to be gray
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        
        //Set the cell to be in word wrap mode to allow for long strings
        cell.textLabel.lineBreakMode = UILineBreakModeWordWrap;
        cell.textLabel.numberOfLines = 0;
        
        //Set the font of the label to be a known size and font type
        cell.textLabel.font = [UIFont fontWithName:@"Helvetica" size:17.0];
        
        //Set the default imageView to be the facebook logo
        cell.imageView.image = [UIImage imageNamed:@"f_logo.png"];
        
        //Set the cell background color to be clear so the background image
        //can be seen
        cell.backgroundColor = [UIColor clearColor];
    }
    
    //Set the cell main text label, and detail text label to be the standard color
    cell.textLabel.textColor = [UIColor colorWithRed:0.29803 green:0.1529 blue:0.0039 alpha:1];
    cell.detailTextLabel.textColor = [UIColor colorWithRed:0.2666 green:0.2666 blue:0.2666 alpha:1];
    
    //Retrieve the corresponding dictionary for the cell, retrieve the main and detail text
    //label, and set the cell labels
    NSDictionary *dictionaryForCell = [self.commentsArray objectAtIndex:[indexPath row]];
    NSString *mainTextLabel = [dictionaryForCell valueForKeyPath:@"message"];
    NSString *detailTextLabel = [dictionaryForCell valueForKeyPath:@"from.name"];
    cell.textLabel.text = mainTextLabel;
    cell.detailTextLabel.text = detailTextLabel;
    
    return cell;
    
}

- (void)tableView:(UITableView *)tableview willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    //This function is used to download the facebook person profile image and display
    //it in the table row cell
    
    //Create a download que to download the facebook profile image
    dispatch_queue_t downloadQueue = dispatch_queue_create("Profile Image Downloader", NULL);
    dispatch_async(downloadQueue, ^{
        //Retreive the NSDictionary corresponding to the table row
        NSDictionary *tmpDictionary = [self.commentsArray objectAtIndex:[indexPath row]];
        
        //Create a URL based upon the facebook graph API
        NSString *profileFromId = [tmpDictionary valueForKeyPath:@"from.id"];
        NSString *urlString = [[NSString alloc] initWithFormat:@"https://graph.facebook.com/%@/picture", profileFromId];
        NSURL *url = [[NSURL alloc] initWithString:urlString];
        
        //Create an image based upon the downloaded NSData from the Facebook graph URL
        //created above
        UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:url]];
        NSLog(@"Loading Web Data");
        dispatch_async(dispatch_get_main_queue(), ^{
            //Verify the index path the image was downloaded for is still visible
            //in the tableview.  If it is still visible set the cell imageView
            NSArray *tmpArray = [self.tableView indexPathsForVisibleRows];
            if ([tmpArray containsObject:indexPath]) [cell.imageView setImage:image];
        });
    });
    dispatch_release(downloadQueue);
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *tmpDictionary = [self.commentsArray objectAtIndex:[indexPath row]];
    NSString *text = [tmpDictionary valueForKeyPath:@"message"];
    
    // Get the text so we can measure it
    // Get a CGSize for the width and, effectively, unlimited height
    CGSize constraint = CGSizeMake(CELL_CONTENT_WIDTH - (CELL_CONTENT_MARGIN * 2), 20000.0f);
    // Get the size of the text given the CGSize we just made as a constraint
    CGSize size = [text sizeWithFont:[UIFont systemFontOfSize:FONT_SIZE] constrainedToSize:constraint lineBreakMode:UILineBreakModeWordWrap];
    // Get the height of our measurement, with a minimum of 44 (standard cell size)
    CGFloat height = MAX(size.height, 44.0f);
    // return the height, with a bit of extra padding in
    return height + (CELL_CONTENT_MARGIN * 2);

}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    //This function witll create a UITextView, put the UITextView inside a UITableViewCell and return
    //The cell as the header view
    
    //Pull the main and detail text label out of the corresponding dictionary
    NSString *mainTextLabel = [self.fullCommentsDictionaryModel valueForKeyPath:@"message"];
    
    //Determine the max height required for the UITextView with the comments string
    CGSize maxSize = CGSizeMake(320 - FACEBOOK_DETAIL_FONT_SIZE, CGFLOAT_MAX);
    CGSize size = [mainTextLabel sizeWithFont:[UIFont systemFontOfSize:FACEBOOK_DETAIL_FONT_SIZE]  constrainedToSize:maxSize lineBreakMode:UILineBreakModeWordWrap];
    size.height += FACEBOOK_DETAIL_FONT_SIZE; 
    
    //Setup the UITextView for the standard font, no scrolling, not editable,
    //detects URLs, clearcolor, and a frame height to match the size of the string
    UITextView *textView = [[UITextView alloc] initWithFrame:CGRectZero];
    textView.font = [UIFont systemFontOfSize:FACEBOOK_DETAIL_FONT_SIZE];
    textView.scrollEnabled = NO;
    textView.editable = NO;
    textView.tag = 1;
    textView.dataDetectorTypes = UIDataDetectorTypeLink;
    textView.backgroundColor = [UIColor clearColor];
    textView.frame = CGRectMake(0, 0, 320, size.height);
    
    //Create a UITableViewCell with the same height as the textview
    UITableViewCell *cell = [[UITableViewCell alloc] initWithFrame:CGRectMake(0, 0, 320, size.height)];
    [cell.contentView addSubview:textView];
    
    //Set the cell text label's based upon the table contents array location
    textView.text = mainTextLabel;
    cell.backgroundColor = [UIColor clearColor];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    //This function will determine the size required for the header based
    //upon the size of the text string
    
    //Pull the main and detail text label out of the corresponding dictionary
    NSString *mainTextLabel = [self.fullCommentsDictionaryModel valueForKeyPath:@"message"];
    
    CGSize maxSize = CGSizeMake(320 - FACEBOOK_DETAIL_FONT_SIZE, CGFLOAT_MAX);
    CGSize size = [mainTextLabel sizeWithFont:[UIFont systemFontOfSize:FACEBOOK_DETAIL_FONT_SIZE]  constrainedToSize:maxSize lineBreakMode:UILineBreakModeWordWrap];
    
    tableView.tableHeaderView.backgroundColor = [UIColor redColor];
    
    return size.height + FACEBOOK_DETAIL_FONT_SIZE;
}

- (void)loadSocialMediaView
{
    id commentData = [self.fullCommentsDictionaryModel objectForKey:@"message"];
    if ([commentData isKindOfClass:[NSString class]]) self.textView.text = commentData;
    
    id commentsArray = [self.fullCommentsDictionaryModel valueForKeyPath:@"comments.data"];
    if ([commentsArray isKindOfClass:[NSArray class]]) self.commentsArray = commentsArray;
    
    NSString *urlStringForPostPicture = [self.fullCommentsDictionaryModel valueForKey:@"picture"];
    
    if ([urlStringForPostPicture isKindOfClass:[NSString class]])
    {
        dispatch_queue_t downloadQueue = dispatch_queue_create("Post Imageview", NULL);
        dispatch_async(downloadQueue, ^{
            NSURL *url = [[NSURL alloc] initWithString:urlStringForPostPicture];
            self.postImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:url]];
            dispatch_async(dispatch_get_main_queue(), ^{
                //self.buttonImage = [[UIButton alloc] initWithFrame:CGRectMake(83, 124, 94, 76)];
                //[self.buttonImage addTarget:self action:@selector(postImageButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
                //[self.buttonImage setImage:self.postImage forState:UIControlStateNormal];
                //[self.view addSubview:self.buttonImage];
            });
        });
        dispatch_release(downloadQueue);
    }
    else 
    {
        CGRect textViewCurrentFrame = self.textView.frame;
        
        if ([self.commentsArray count] == 0)
        {
            self.textView.frame = CGRectMake(textViewCurrentFrame.origin.x, textViewCurrentFrame.origin.y, textViewCurrentFrame.size.width, 350);
        }
        else 
        {
            self.textView.frame = CGRectMake(textViewCurrentFrame.origin.x, textViewCurrentFrame.origin.y, textViewCurrentFrame.size.width, 188);
        }
        
    }
    
    NSString *profileId = [self.fullCommentsDictionaryModel valueForKeyPath:@"from.id"];
    NSString *urlStringForProfile = [[NSString alloc] initWithFormat:@"https://graph.facebook.com/%@/picture", profileId];
    
    if (urlStringForProfile)
    {
        dispatch_queue_t downloadQueue2 = dispatch_queue_create("Post Imageview", NULL);
        dispatch_async(downloadQueue2, ^{
            NSURL *urlForProfilePicture = [[NSURL alloc] initWithString:urlStringForProfile];
            NSLog(@"Loading Web Data");
            UIImage *profileImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:urlForProfilePicture]];
            dispatch_async(dispatch_get_main_queue(), ^{
                self.navigationItem.rightBarButtonItem = self.oldBarButtonItem;
                self.profilePictureImageView.image = profileImage;
            });
        });
        dispatch_release(downloadQueue2);
    }
}
- (void)postImageButtonPressed:(id)sender 
{
    NSDictionary *imageViewModel = [self.fullCommentsDictionaryModel valueForKeyPath:@"object_id"];
    if (imageViewModel == nil) return;
    [self performSegueWithIdentifier:@"Photo" sender:self];
}

- (void)request:(FBRequest *)request didLoad:(id)result
{
    if ([request.httpMethod isEqualToString:@"GET"])
    {
        if ([result isKindOfClass:[NSDictionary class]])
        {
            self.fullCommentsDictionaryModel = result;
            [self loadSocialMediaView];
        }
        [self performSelector:@selector(stopLoading) withObject:nil afterDelay:0];
        //Since the RSS file has been loaded, stop animating the activity indicator
        [self.activityIndicator stopAnimating];
        
        //If there is a right bar button item, put it back
        self.navigationItem.rightBarButtonItem = self.oldBarButtonItem;
    }
    else {
        [self.socialMediaDelegate SocialMediaDetailViewController:self dictionaryForFacebookGraphAPIString:[self.shortCommentsDictionaryModel objectForKey:@"id"]];
    }
}

- (void)requestLoading:(FBRequest *)request
{
    //When a facebook request starts, save the request
    //so the delegate can be set to nill when the view disappears
    self.facebookRequest = request;
    
     [self.activityIndicator startAnimating];
    
    //Set the right navigation bar button item to the activity indicator
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.activityIndicator];
}

- (void) presentWebView:(NSNotification *) notification
{
    
    if ([[notification name] isEqualToString:@"urlSelected"])
    {
        [self performSegueWithIdentifier:@"Web" sender:[notification object]];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"Photo"])
    {
        [segue.destinationViewController setFacebookPhotoObjectID:[self.fullCommentsDictionaryModel valueForKeyPath:@"object_id"]];
    }
    else if ([segue.identifier isEqualToString:@"Web"] & [sender isKindOfClass:[NSURL class]])
    {
        [segue.destinationViewController setUrlToLoad:sender];
    }
    else if ([segue.identifier isEqualToString:@"comment"])
    {
        [segue.destinationViewController setTextEntryDelegate:self];
    }
}

- (void)refresh 
{
    //This method will request the full comments array from the delegate and
    //the facebook class will call request:request didLoad:result when complete
    [self.socialMediaDelegate SocialMediaDetailViewController:self dictionaryForFacebookGraphAPIString:[self.shortCommentsDictionaryModel objectForKey:@"id"]];
}

- (IBAction)commentButtonPressed:(id)sender 
{
    [self performSegueWithIdentifier:@"comment" sender:self];
}

- (void)textView:(UITextView *)sender didFinishWithString:(NSString *)string withDictionaryForComment:(NSDictionary *)dictionary
{
    NSString *graphAPIString = [NSString stringWithFormat:@"%@/comments", [self.fullCommentsDictionaryModel valueForKeyPath:@"id"]];
    [self.socialMediaDelegate SocialMediaDetailViewController:self postDataForFacebookGraphAPIString:graphAPIString withParameters:[[NSMutableDictionary alloc] initWithObjectsAndKeys:string, @"message", nil]];
}


@end
