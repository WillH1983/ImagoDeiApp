//
//  ImagoDeiStandardTableViewController.h
//  ImagoDei
//
//  Created by Will Hindenburg on 5/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PullRefreshTableViewController.h"

@interface ImagoDeiStandardTableViewController : PullRefreshTableViewController <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) NSURL *urlForTableData;
@property (strong, nonatomic) NSArray *arrayOfTableData;
@property (strong, nonatomic) UIActivityIndicatorView *activityIndicator;
@property (nonatomic, strong) UIBarButtonItem *oldBarButtonItem;

- (id)initWithModel:(NSURL *)model;

#define CONTENT_TITLE2 @"title.text"
#define CONTENT_DESCRIPTION2 @"pubDate.text"
#define CONTENT_SMALL_PHOTO_URL @"smallphotourl"
#define CONTENT_UNIQUE_ID @"id"
#define CONTENT_URL_LINK @"link"

@end
