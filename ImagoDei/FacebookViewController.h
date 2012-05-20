//
//  FacebookViewController.h
//  ImagoDei
//
//  Created by Will Hindenburg on 5/19/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Three20/Three20.h"
#import "Facebook.h"

@interface FacebookViewController : TTTableViewController <FBSessionDelegate,FBRequestDelegate, FBDialogDelegate, TTNavigatorDelegate>

@property (nonatomic, retain) Facebook *facebook;

@end
