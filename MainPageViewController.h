//
//  MainPageViewController.h
//  ImagoDei
//
//  Created by Will Hindenburg on 4/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import "FBConnect.h"
#import "RSSParser.h"

@interface MainPageViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, RSSParserDelegate>
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSURL *model;
@property (strong, nonatomic) NSString *imageName;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

- (id)initWithModel:(NSURL *)model;

@end
