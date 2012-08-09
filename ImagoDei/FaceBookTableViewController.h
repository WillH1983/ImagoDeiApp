//
//  FaceBookTableViewController.h
//  TPM
//
//  Created by Will Hindenburg on 7/31/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Facebook.h"
#import "SocialMediaDetailViewController.h"
#import "ImagoDeiTextEntryViewController.h"

@interface FaceBookTableViewController : UITableViewController <FBSessionDelegate,FBRequestDelegate, FBDialogDelegate, SocialMediaDetailViewControllerDelegate, ImagoDeiTextEntryDelegate>

@property (nonatomic, strong) Facebook *facebook;
@property (nonatomic, strong) NSArray *facebookArrayTableData;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;
@property (nonatomic, strong) UIBarButtonItem *oldBarButtonItem;
@property (nonatomic, strong) NSString *userNameID;

#define FACEBOOK_CONTENT_TITLE @"message"
#define FACEBOOK_CONTENT_DESCRIPTION @"from.name"
#define FACEBOOK_FEED_TO_REQUEST @"imagodeichurch/feed"
#define FACEBOOK_FONT_SIZE 16.0
#define FACEBOOK_TEXTVIEW_TOP_MARGIN 12.0
#define FACEBOOK_COMMENTS_BUTTON_FONT_SIZE 14.0
#define FACEBOOK_MARGIN_BETWEEN_COMMENTS_BUTTONS 8.0
#define FACEBOOK_COMMENTS_BUTTON_WIDTH 300.0
#define FACEBOOK_COMMENTS_BUTTON_HEIGHT 20.0
#define FACEBOOK_PHOTO_WIDTH 130.0
#define FACEBOOK_PHOTO_HEIGHT 130.0
#define FACEBOOK_TEXTVIEW_POSITION_FROM_TOP 50

@end
