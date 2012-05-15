//
//  ImagoDeiStandardTableViewController.h
//  ImagoDei
//
//  Created by Will Hindenburg on 5/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PullRefreshTableViewController.h"
#import "RSSParser.h"

@interface ImagoDeiStandardTableViewController : PullRefreshTableViewController <UITableViewDataSource, UITableViewDelegate, RSSParserDelegate>

@property (strong, nonatomic) NSURL *urlForTableData;
@property (strong, nonatomic) NSArray *arrayOfTableData;

- (id)initWithModel:(NSURL *)model;
- (void)standardInitWithURL:(NSURL *)url;

@end
