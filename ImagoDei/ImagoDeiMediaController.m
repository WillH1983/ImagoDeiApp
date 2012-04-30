//
//  ImagoDeiMediaController.m
//  ImagoDei
//
//  Created by Will Hindenburg on 4/29/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ImagoDeiMediaController.h"

@interface ImagoDeiMediaController ()
@property (nonatomic, strong) NSURL *modelURL;
@property (nonatomic, strong) MPMoviePlayerController *moviePlayer;
@end

@implementation ImagoDeiMediaController
@synthesize modelURL;
@synthesize moviePlayer = _moviePlayer;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(playMovie:) 
                                                     name:MPMediaPlaybackIsPreparedToPlayDidChangeNotification
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(didFinishMovie:) 
                                                     name:MPMoviePlayerPlaybackDidFinishNotification
                                                   object:nil];

    }
    return self;
    //MPMoviePlayerPlaybackDidFinishNotification
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.view addSubview:self.moviePlayer.view];
    self.moviePlayer.contentURL = self.modelURL;
    [self.moviePlayer prepareToPlay];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSLog(@"%@", self.modelURL);
    self.moviePlayer = [[MPMoviePlayerController alloc] init];
    self.moviePlayer.movieSourceType = MPMovieSourceTypeStreaming;
    self.moviePlayer.view.frame = self.view.bounds;  // player's frame must match parent's
    self.moviePlayer.controlStyle = MPMovieControlStyleEmbedded;
}

- (id)initImageoDeiMediaControllerWithURL:(NSURL *)url
{
    self = [self init];
    self.modelURL = url;
    return self;
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

- (void)playMovie:(NSNotification *) notification
{
    if ([[notification object] isKindOfClass:[MPMoviePlayerController class]])
    {
        [[notification object] play];
    }
}

- (void)didFinishMovie:(NSNotification *) notification
{
    NSLog(@"Test2");
}

@end
