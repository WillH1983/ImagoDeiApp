//
//  WebViewController.m
//  ImagoDei
//
//  Created by Will Hindenburg on 4/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "WebViewController.h"

@interface WebViewController () <UIWebViewDelegate>
@property (nonatomic, strong) UIWebView *webView;
@property (nonatomic, strong) UINavigationItem *navItem;
@property (nonatomic, strong) UIBarButtonItem *oldBarButtonItem;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;

@end

@implementation WebViewController
@synthesize urlToLoad = _urlToLoad;
@synthesize webView = _webView;
@synthesize titleForWebView = _titleForWebView;
@synthesize navItem = _navItem;
@synthesize oldBarButtonItem = _oldBarButtonItem;
@synthesize activityIndicator = _activityIndicator;


- (id)initWithToolbar:(BOOL)toolbar
{
    self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    if (toolbar)
    {
        UINavigationBar *navigationBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
        UIColor *standardColor = [UIColor colorWithRed:.7529 green:0.7372 blue:0.7019 alpha:1.0];
        [navigationBar setTintColor:standardColor];
        UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(donePressed:)];
        self.navItem = [[UINavigationItem alloc] init];
        self.navItem.leftBarButtonItem = barButtonItem;
        navigationBar.items = [[NSArray alloc] initWithObjects:self.navItem, nil];
        [self.view addSubview:navigationBar];
        CGRect tmpRect = CGRectMake(0, 44, 320, 416);
        self.webView = [[UIWebView alloc] initWithFrame:tmpRect];
    }
    else 
    {
        self.webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
    }
    
    [self.view addSubview:self.webView];
    self.webView.delegate = self; 
    
    self = [self init];
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationItem.title = self.titleForWebView;
    NSLog(@"%@", self.urlToLoad);
    NSURLRequest *urlRequest = [[NSURLRequest alloc] initWithURL:self.urlToLoad];
    [self.webView loadRequest:urlRequest];
    
    
}

- (void)viewDidUnload
{
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
    self.navItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.activityIndicator];
    
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    self.navigationItem.rightBarButtonItem = nil;
    self.navItem.rightBarButtonItem = nil;
}

- (void)donePressed:(id)sender
{
    [[self presentingViewController] dismissViewControllerAnimated:YES completion:nil];
}

@end
