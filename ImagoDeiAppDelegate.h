//
//  ImagoDeiAppDelegate.h
//  ImagoDei
//
//  Created by Will Hindenburg on 4/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreLocation/CoreLocation.h>
#import "FBConnect.h"

#define FACEBOOK_APP_ID @"207547516014316"

@interface ImagoDeiAppDelegate : UIResponder <UIApplicationDelegate, CLLocationManagerDelegate>
{
    Facebook *facebook;
    AVAudioSession *audioSession;
    CLLocationManager *locationManager;
}

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, retain) Facebook *facebook;
@property (nonatomic, retain) AVAudioSession *audioSession;
@property (nonatomic, strong) UITabBarController *tabBarController;
@property (nonatomic, retain) CLLocationManager *locationManager;

- (BOOL)openURL:(NSURL *)url;


@end
