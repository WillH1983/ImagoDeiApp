//
//  ImageViewController.m
//  ImagoDei
//
//  Created by Will Hindenburg on 4/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ImageViewController.h"

@interface ImageViewController ()

@end

@implementation ImageViewController
@synthesize scrollView;
@synthesize navigationBar = _navigationBar;
@synthesize imageView;
@synthesize imageForImageView = _imageForImageView;
@synthesize facebookPhotoObjectID = _facebookPhotoObjectID;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.scrollView.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated
{
    
    NSString *urlStringForProfile = [[NSString alloc] initWithFormat:@"https://graph.facebook.com/%@/picture", self.facebookPhotoObjectID];
    
    NSURL *urlForProfile = [NSURL URLWithString:urlStringForProfile];
    UIBarButtonItem *oldBarButtonItem = self.navigationBar.topItem.leftBarButtonItem;
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [spinner startAnimating];
    UIBarButtonItem *spinnerButton = [[UIBarButtonItem alloc] initWithCustomView:spinner];
    self.navigationBar.topItem.leftBarButtonItem = spinnerButton;

    
    dispatch_queue_t downloadQueue2 = dispatch_queue_create("downloader", NULL);
    dispatch_async(downloadQueue2, ^{
        UIImage *tmpImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:urlForProfile]];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.imageForImageView = tmpImage;
            self.scrollView.zoomScale = 1;
            self.imageView.image = self.imageForImageView;
            [self.imageView sizeToFit];
            self.scrollView.contentSize = self.imageView.bounds.size;
            CGRect tmpRect = CGRectMake(0, 0, self.imageForImageView.size.width, self.imageForImageView.size.height);
            [self.scrollView zoomToRect:tmpRect animated:NO];
            self.navigationBar.topItem.leftBarButtonItem = oldBarButtonItem;
        });
    });
    dispatch_release(downloadQueue2);
}

- (void)viewDidUnload
{
    [self setImageView:nil];
    [self setScrollView:nil];
    [self setScrollView:nil];
    [self setNavigationBar:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView //1 line
{
    return self.imageView;
}
- (IBAction)doneButtonPressed:(id)sender 
{
    [[self presentingViewController] dismissViewControllerAnimated:YES completion:nil];
}

@end
