//
//  SocialMediaDetailViewController.h
//  ImagoDei
//
//  Created by Will Hindenburg on 4/18/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FBRequest.h"
#import "ImagoDeiTextEntryViewController.h"

@class SocialMediaDetailViewController;

@protocol SocialMediaDetailViewControllerDelegate <NSObject>
- (void)SocialMediaDetailViewController:(SocialMediaDetailViewController *)sender dictionaryForFacebookGraphAPIString:(NSString *)facebookGraphAPIString;
- (void)SocialMediaDetailViewController:(SocialMediaDetailViewController *)sender postDataForFacebookGraphAPIString:(NSString *)facebookGraphAPIString withParameters:(NSMutableDictionary *)params;

@end

@interface SocialMediaDetailViewController : UITableViewController <FBRequestDelegate, ImagoDeiTextEntryDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *profilePictureImageView;
@property (nonatomic, strong) NSDictionary *shortCommentsDictionaryModel;
@property (nonatomic, strong) NSDictionary *fullCommentsDictionaryModel;
@property (nonatomic, weak) id <SocialMediaDetailViewControllerDelegate> socialMediaDelegate;
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;
@property (nonatomic, strong) UIBarButtonItem *oldBarButtonItem;

@end
