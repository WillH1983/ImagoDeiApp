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


- (id)initWithToolbar:(BOOL)toolbar
{
    self.programmedWebView = [[UIWebView alloc] initWithFrame:self.view.bounds];
    
    [self.view addSubview:self.programmedWebView];
    self.programmedWebView.delegate = self;
    
    self = [self init];
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    
    NSLog(@"%@", self.urlToLoad);
    NSURLRequest *urlRequest = [[NSURLRequest alloc] initWithURL:self.urlToLoad];
    [self.webView loadRequest:urlRequest];
    [self.programmedWebView loadRequest:urlRequest];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
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

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [self.activityIndicator startAnimating];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.activityIndicator];
    self.navigationBar.topItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.activityIndicator];
    
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    self.navigationItem.rightBarButtonItem = nil;
    self.navigationBar.topItem.rightBarButtonItem = nil;
}
- (IBAction)donePressed:(id)sender 
{
    [[self presentingViewController] dismissViewControllerAnimated:YES completion:nil];
}

@end
