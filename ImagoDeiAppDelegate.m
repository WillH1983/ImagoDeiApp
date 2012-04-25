//
//  ImagoDeiAppDelegate.m
//  ImagoDei
//
//  Created by Will Hindenburg on 4/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ImagoDeiAppDelegate.h"
#import "ImagoDeiDataFetcher.h"
#import "MainPageViewController.h"
#import "WebViewController.h"
#import "FacebookSocialMediaViewController.h"

@implementation ImagoDeiAppDelegate

@synthesize window = _window;
@synthesize facebook;
@synthesize tabBarController = _tabBarController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.

    facebook = [[Facebook alloc] initWithAppId:@"207547516014316" andDelegate:nil];
    
    NSDictionary *imagoDeiData = [ImagoDeiDataFetcher DictionaryForImagoDeiLayout];
    NSArray *tabBarContents = [imagoDeiData valueForKeyPath:@"imagodeitabbar"];

    
    NSMutableArray *listOfNavigationControllers = [[NSMutableArray alloc] init];
    
    for (id items in tabBarContents)
    {
        if ([[items valueForKey:CONTENT_TITLE] isEqualToString:@"Facebook"])
        {
            FacebookSocialMediaViewController *fbsmvc = [[FacebookSocialMediaViewController alloc] init];
            fbsmvc.title = @"Facebook";
            UINavigationController *mainPageNavController = [[UINavigationController alloc] initWithRootViewController:fbsmvc];
            [listOfNavigationControllers addObject:mainPageNavController];
        }
        else 
        {
            NSString *referenceData = [items valueForKey:@"referencedata"];
            NSArray *dataArray = [imagoDeiData valueForKey:referenceData];
            if ([dataArray isKindOfClass:[NSArray class]] || dataArray == nil)
            {
                MainPageViewController *mpvc = [[MainPageViewController alloc] initWithModel:[imagoDeiData valueForKeyPath:referenceData]];
                mpvc.title = [items valueForKeyPath:@"title"];
                UINavigationController *mainPageNavController = [[UINavigationController alloc] initWithRootViewController:mpvc];
                [listOfNavigationControllers addObject:mainPageNavController];
            }
        }
    }
    
    //UINavigationController *mainPageController = [listOfNavigationControllers objectAtIndex:0];
    //[[[mainPageController viewControllers] lastObject] setImageName:@"who-we-are.jpg"];
    
    UITabBarController *tabBarController = [[UITabBarController alloc] init];
    [tabBarController setViewControllers:listOfNavigationControllers];
    self.tabBarController = tabBarController;
    [[self window] setRootViewController:tabBarController];
    
    self.window.backgroundColor = [UIColor whiteColor];
    application.statusBarStyle = UIStatusBarStyleBlackTranslucent;
    [self.window makeKeyAndVisible];
    return YES;
}

// Pre iOS 4.2 support
- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    return [facebook handleOpenURL:url]; 
}

// For iOS 4.2+ support
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    return [facebook handleOpenURL:url]; 
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
}

-(BOOL)openURL:(NSURL *)url
{
    [[NSNotificationCenter defaultCenter] 
     postNotificationName:@"urlSelected"
     object:url];

    return YES;
}

@end
