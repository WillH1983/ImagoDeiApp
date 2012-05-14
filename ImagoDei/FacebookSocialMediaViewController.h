//
//  FacebookSocialMediaViewController.h
//  ImagoDei
//
//  Created by Will Hindenburg on 4/21/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Facebook.h"
#import "SocialMediaDetailViewController.h"
#import "PullRefreshTableViewController.h"

@interface FacebookSocialMediaViewController : PullRefreshTableViewController <FBSessionDelegate,FBRequestDelegate, FBDialogDelegate, SocialMediaDetailViewControllerDelegate>

@property (nonatomic, retain) Facebook *facebook;

@end
