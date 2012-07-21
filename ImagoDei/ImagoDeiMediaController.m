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

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.view addSubview:self.moviePlayer.view];
    self.moviePlayer.contentURL = self.modelURL;
    [self.moviePlayer prepareToPlay];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(playMovie:) 
                                                 name:MPMediaPlaybackIsPreparedToPlayDidChangeNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didFinishMovie:) 
                                                 name:MPMoviePlayerPlaybackDidFinishNotification
                                               object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:MPMediaPlaybackIsPreparedToPlayDidChangeNotification 
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:MPMoviePlayerPlaybackDidFinishNotification
                                                  object:nil];
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
