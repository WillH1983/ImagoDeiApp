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
@synthesize commentsTableView;
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

- (void)setCommentsArray:(NSArray *)commentsArray
{
    _commentsArray = commentsArray;
    [self.commentsTableView reloadData];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(presentWebView:) 
                                                     name:@"urlSelected"
                                                   object:nil];

    }
    return self;
}

- (void)awakeFromNib
{
    if (self)
    {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(presentWebView:) 
                                                     name:@"urlSelected"
                                                   object:nil];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.commentsTableView setAllowsSelection:NO];
    self.navigationItem.title = @"Facebook Feed";
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    [spinner startAnimating];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:spinner];
    
    [self.socialMediaDelegate SocialMediaDetailViewController:self dictionaryForFacebookGraphAPIString:[self.shortCommentsDictionaryModel objectForKey:@"id"]];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [self setCommentsTableView:nil];
    [self setProfilePictureImageView:nil];
    [self setTextView:nil];
    [self setButtonImage:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, 1)];
    self.commentsTableView.tableFooterView = view;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    NSIndexPath *selection = [self.commentsTableView indexPathForSelectedRow];
	if (selection) [self.commentsTableView deselectRowAtIndexPath:selection animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
    //When the view disappears the code in this fucnction removes all delegation to this class
    //This is required incase a connection request is in progress when the view disappears
    [self.facebookRequest setDelegate:nil];
    
    [super viewWillDisappear:animated];
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
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell;
    
    
    //If there is no reusable cell of this type, create a new one
    if (!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        cell.textLabel.lineBreakMode = UILineBreakModeWordWrap;
        cell.textLabel.numberOfLines = 0;
        cell.textLabel.font = [UIFont fontWithName:@"Helvetica" size:17.0];
        cell.imageView.image = [UIImage imageNamed:@"f_logo.png"];
    }
    
    cell.textLabel.textColor = [UIColor colorWithRed:0.29803 green:0.1529 blue:0.0039 alpha:1];
    cell.detailTextLabel.textColor = [UIColor colorWithRed:0.2666 green:0.2666 blue:0.2666 alpha:1];
    

    NSDictionary *dictionaryForCell = [self.commentsArray objectAtIndex:[indexPath row]];
    NSString *mainTextLabel = [dictionaryForCell valueForKeyPath:@"message"];
    NSString *detailTextLabel = [dictionaryForCell valueForKeyPath:@"from.name"];
    //NSArray *test = [dictionaryForCell valueForKeyPath:@"comments.data"];
    
    cell.textLabel.text = mainTextLabel;
    cell.detailTextLabel.text = detailTextLabel;
    
    return cell;
    
}

- (void)tableView:(UITableView *)tableview willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    dispatch_queue_t downloadQueue = dispatch_queue_create("Profile Image Downloader", NULL);
    dispatch_async(downloadQueue, ^{
        NSDictionary *tmpDictionary = [self.commentsArray objectAtIndex:[indexPath row]];
        NSString *profileFromId = [tmpDictionary valueForKeyPath:@"from.id"];
        NSString *urlString = [[NSString alloc] initWithFormat:@"https://graph.facebook.com/%@/picture", profileFromId];
        NSURL *url = [[NSURL alloc] initWithString:urlString];
        UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:url]];
        NSLog(@"Loading Web Data");
        dispatch_async(dispatch_get_main_queue(), ^{
            NSArray *tmpArray = [self.commentsTableView indexPathsForVisibleRows];
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

- (void)loadSocialMediaView
{
    self.textView.text = [self.fullCommentsDictionaryModel objectForKey:@"message"];
    self.commentsArray = [self.fullCommentsDictionaryModel valueForKeyPath:@"comments.data"];
    
    NSString *urlStringForPostPicture = [self.fullCommentsDictionaryModel valueForKey:@"picture"];
    
    if (urlStringForPostPicture)
    {
        dispatch_queue_t downloadQueue = dispatch_queue_create("Post Imageview", NULL);
        dispatch_async(downloadQueue, ^{
            NSURL *url = [[NSURL alloc] initWithString:urlStringForPostPicture];
            self.postImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:url]];
            dispatch_async(dispatch_get_main_queue(), ^{
                self.buttonImage = [[UIButton alloc] initWithFrame:CGRectMake(83, 124, 94, 76)];
                [self.buttonImage addTarget:self action:@selector(postImageButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
                [self.buttonImage setImage:self.postImage forState:UIControlStateNormal];
                [self.view addSubview:self.buttonImage];
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
                self.navigationItem.rightBarButtonItem = nil;
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
    
    ImageViewController *imageViewController = [[ImageViewController alloc] init];
    
    [imageViewController setModalPresentationStyle:UIModalPresentationFormSheet];
    [imageViewController setModalTransitionStyle:UIModalTransitionStyleCoverVertical];
    [imageViewController setFacebookPhotoObjectID:[self.fullCommentsDictionaryModel valueForKeyPath:@"object_id"]];
    
    [self presentViewController:imageViewController animated:YES completion:nil];
}

- (void)request:(FBRequest *)request didLoad:(id)result
{
    if ([result isKindOfClass:[NSDictionary class]])
    {
        self.fullCommentsDictionaryModel = result;
        [self loadSocialMediaView];
    }
}

- (void)requestLoading:(FBRequest *)request
{
    //When a facebook request starts, save the request
    //so the delegate can be set to nill when the view disappears
    self.facebookRequest = request;
}

- (void) presentWebView:(NSNotification *) notification
{
    
    if ([[notification name] isEqualToString:@"urlSelected"])
    {
        WebViewController *wvc = [[WebViewController alloc] initWithToolbar:YES];
        [wvc setUrlToLoad:[notification object]];
        [wvc setModalPresentationStyle:UIModalPresentationFormSheet];
        [wvc setModalTransitionStyle:UIModalTransitionStyleCoverVertical];
        
        [self presentViewController:wvc animated:YES completion:nil];
    }
}


@end
