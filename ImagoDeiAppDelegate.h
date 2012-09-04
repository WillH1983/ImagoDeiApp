//
//  ImagoDeiAppDelegate.h
//  ImagoDei
//
//  Created by Will Hindenburg on 4/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <FacebookSDK/FacebookSDK.h>
#import "NSMutableDictionary+appConfiguration.h"

#define FACEBOOK_APP_ID @"207547516014316"

@interface ImagoDeiAppDelegate : UIResponder <UIApplicationDelegate>
{
    FBSession *facebookSession;
    AVAudioSession *audioSession;
}

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, retain) FBSession *facebookSession;
@property (nonatomic, retain) AVAudioSession *audioSession;
@property (nonatomic, strong) UITabBarController *tabBarController;
@property (strong, nonatomic) NSMutableDictionary *appConfiguration;

- (BOOL)openURL:(NSURL *)url;


@end
