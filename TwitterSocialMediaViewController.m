//
//  TwitterSocialMediaViewController.m
//  ImagoDei
//
//  Created by Will Hindenburg on 4/21/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TwitterSocialMediaViewController.h"

@interface TwitterSocialMediaViewController ()
@property (nonatomic, strong) NSArray *imagoDeiTwitterTimelineArray;
@property (nonatomic, strong) UIActivityIndicatorView *twitterActivityIndicator;

- (void)imagoDeiTwitterTimeLineRequest;
@end

@implementation TwitterSocialMediaViewController
@synthesize imagoDeiTwitterTimelineArray = _imagoDeiTwitterTimelineArray;
@synthesize twitterActivityIndicator = _twitterActivityIndicator;


#define FONT_SIZE 14.0f
#define CELL_CONTENT_WIDTH 200.0f
#define CELL_CONTENT_MARGIN 13.0f

- (void)setImagoDeiTwitterTimelineArray:(NSArray *)imagoDeiTwitterTimelineArray
{
    _imagoDeiTwitterTimelineArray = imagoDeiTwitterTimelineArray;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}

- (void)logoPressed:(id)sender
{
    [[self presentingViewController] dismissViewControllerAnimated:YES completion:nil];
}

- (void)donePressed:(id)sender
{
    [[self presentingViewController] dismissViewControllerAnimated:YES completion:nil];
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    UIColor *standardColor = [UIColor colorWithRed:.7529 green:0.7372 blue:0.7019 alpha:1.0];
    [[[self navigationController] navigationBar] setTintColor:standardColor];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.tableView setAllowsSelection:NO];
    
    
    self.navigationController.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"body-bg.jpg"]]; 
    self.tableView.backgroundColor = [UIColor clearColor];
    
    UIImage *logoImage = [UIImage imageNamed:@"logo.png"];
    UIImageView *logoImageView = [[UIImageView alloc] initWithImage:logoImage];
    //UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(80, 130, 181, 102)];
    //[button addTarget:self action:@selector(logoPressed:) forControlEvents:UIControlEventTouchUpInside];
    //[button setBackgroundImage:image forState:UIControlStateNormal];
    self.navigationItem.titleView = logoImageView;

    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStylePlain target:self action:@selector(donePressed:)];
    
    self.twitterActivityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [self.twitterActivityIndicator startAnimating];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.twitterActivityIndicator];
    
    NSLog(@"Loading Web Data - Social Media View Controller");
    [self imagoDeiTwitterTimeLineRequest];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
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
    // Return the number of rows in the section.
    return [self.imagoDeiTwitterTimelineArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell;
    cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    
    //If there is no reusable cell of this type, create a new one
    if (!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        cell.textLabel.lineBreakMode = UILineBreakModeWordWrap;
        cell.textLabel.numberOfLines = 0;
    }
    
    cell.textLabel.textColor = [UIColor colorWithRed:0.29803 green:0.1529 blue:0.0039 alpha:1];
    cell.detailTextLabel.textColor = [UIColor colorWithRed:0.2666 green:0.2666 blue:0.2666 alpha:1];
    
    NSDictionary *dictionaryForCell = [self.imagoDeiTwitterTimelineArray objectAtIndex:[indexPath row]];
    cell.textLabel.text = [dictionaryForCell valueForKey:@"text"];
    cell.imageView.image = [UIImage imageNamed:@"twitter_newbird_blue small.png"];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *tmpDictionary = [self.imagoDeiTwitterTimelineArray objectAtIndex:[indexPath row]];
    NSString *text = [tmpDictionary valueForKeyPath:@"text"];
    
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

- (void)imagoDeiTwitterTimeLineRequest
{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:@"imagodeipeoria" forKey:@"screen_name"];
    [params setObject:@"25" forKey:@"count"];
    [params setObject:@"1" forKey:@"include_entities"];
    [params setObject:@"1" forKey:@"include_rts"];
    
    //  Next, we create an URL that points to the target endpoint
    NSURL *url = [NSURL URLWithString:@"http://api.twitter.com/1/statuses/user_timeline.json"];
    
    //  Now we can create our request.  Note that we are performing a GET request.
    TWRequest *request = [[TWRequest alloc] initWithURL:url parameters:params requestMethod:TWRequestMethodGET];
    [request performRequestWithHandler: ^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
        if (responseData) 
        { 
            //  Use the NSJSONSerialization class to parse the returned JSON
            NSError *jsonError;
            NSArray *timeline = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableLeaves error:&jsonError];
            if (timeline) 
            {
                // We have an object that we can parse
                if ([timeline isKindOfClass:[NSArray class]])
                {
                    self.imagoDeiTwitterTimelineArray = timeline;
                }
                else
                {
                    NSDictionary *tmpDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:@"Too Many Requests", @"text", nil];
                    self.imagoDeiTwitterTimelineArray = [[NSArray alloc] initWithObjects:tmpDictionary, nil];
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.twitterActivityIndicator stopAnimating];
                });
            } 
            
            else 
            { 
                // Inspect the contents of jsonError
                NSLog(@"%@", jsonError);
            }
        }
    }];
}

@end
