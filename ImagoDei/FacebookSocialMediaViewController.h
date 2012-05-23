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
#import "ImagoDeiStandardTableViewController.h"

@interface FacebookSocialMediaViewController : ImagoDeiStandardTableViewController <FBSessionDelegate,FBRequestDelegate, FBDialogDelegate, SocialMediaDetailViewControllerDelegate>

@property (nonatomic, strong) Facebook *facebook;

@end
