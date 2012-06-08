//
//  WebViewController.m
//  ImagoDei
//
//  Created by Will Hindenburg on 4/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "WebViewController.h"

@interface WebViewController () <UIWebViewDelegate>
@property (nonatomic, strong) UIBarButtonItem *oldBarButtonItem;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;
@property (nonatomic, strong) UIWebView *programmedWebView;
@end

@implementation WebViewController
@synthesize urlToLoad = _urlToLoad;
@synthesize webView = _webView;
@synthesize navigationBar = _navigationBar;
@synthesize titleForWebView = _titleForWebView;
@synthesize oldBarButtonItem = _oldBarButtonItem;
@synthesize activityIndicator = _activityIndicator;
@synthesize programmedWebView = _programmedWebView;


- (id)init
{
    return [self initWithToolbar:NO];
}

- (id)initWithToolbar:(BOOL)yesOrNo
{
    self = [super init];
    if (yesOrNo == YES)
    {
        UINavigationItem *navItem = [[UINavigationItem alloc] init];
        self.navigationBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 44)];
        self.navigationBar.items = [[NSArray alloc] initWithObjects:navItem, nil];
        UIColor *standardColor = [UIColor colorWithRed:.7529 green:0.7372 blue:0.7019 alpha:1.0];
        self.navigationBar.tintColor = standardColor;
        [self.view addSubview:self.navigationBar];
        self.programmedWebView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 44, self.view.bounds.size.width, self.view.bounds.size.height - 44)];
    }
    else
    {
        self.programmedWebView = [[UIWebView alloc] initWithFrame:self.view.bounds];
    }
    
    self.programmedWebView.delegate = self;
    self.programmedWebView.scalesPageToFit = YES;
    [self.view addSubview:self.programmedWebView];
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(donePressed:)];
    self.navigationBar.topItem.leftBarButtonItem = button;
    NSURLRequest *urlRequest = [[NSURLRequest alloc] initWithURL:self.urlToLoad];
    self.webView.scalesPageToFit = YES;
    [self.webView loadRequest:urlRequest];
    [self.programmedWebView loadRequest:urlRequest];
}

- (void)viewDidUnload
{
    [self setWebView:nil];
    [self setNavigationBar:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSURL *url = request.URL;
    NSString *tmpString = [url absoluteString];
    if ([tmpString isEqualToString:@"https://www.planningcenteronline.com/login"]) 
    {
        [[self presentingViewController] dismissViewControllerAnimated:YES completion:nil];
        return NO;
    }
    else return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    self.title = @"Loading...";
    self.navigationBar.topItem.title = @"Loading...";
    [self.activityIndicator startAnimating];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.activityIndicator];
    self.navigationBar.topItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.activityIndicator];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    self.navigationItem.rightBarButtonItem = nil;
    self.navigationBar.topItem.rightBarButtonItem = nil;
    NSString *title = [self.webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    self.navigationBar.topItem.title = title;
    self.title = title;
    if (!self.title)
    {
        self.title = [self.programmedWebView stringByEvaluatingJavaScriptFromString:@"document.title"];
        self.navigationBar.topItem.title = [self.programmedWebView stringByEvaluatingJavaScriptFromString:@"document.title"];
    }
}
- (IBAction)donePressed:(id)sender 
{
    [[self presentingViewController] dismissViewControllerAnimated:YES completion:nil];
}

@end
