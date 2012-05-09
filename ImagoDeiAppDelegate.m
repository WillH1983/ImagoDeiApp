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
@synthesize audioSession = audioSession;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.

    facebook = [[Facebook alloc] initWithAppId:@"207547516014316" andDelegate:nil];
    
    NSMutableArray *listOfNavigationControllers = [[NSMutableArray alloc] init];
    
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"MainTabiPhone" ofType:@"rss"];
    NSURL *urlFilePath = [[NSURL alloc] initFileURLWithPath:filePath];
    NSLog(@"%@", filePath);
    
    MainPageViewController *mpvc = [[MainPageViewController alloc] initWithModel:urlFilePath];
    UINavigationController *mainPageNavController = [[UINavigationController alloc] initWithRootViewController:mpvc];
    [listOfNavigationControllers addObject:mainPageNavController];
    
    FacebookSocialMediaViewController *fbsmvc = [[FacebookSocialMediaViewController alloc] init];
    UINavigationController *facebookNavController = [[UINavigationController alloc] initWithRootViewController:fbsmvc];
    [listOfNavigationControllers addObject:facebookNavController];
    
    MainPageViewController *pco = [[MainPageViewController alloc] init];
    UINavigationController *pcoNavController = [[UINavigationController alloc] initWithRootViewController:pco];
    [listOfNavigationControllers addObject:pcoNavController];
    
    UITabBarController *tabBarController = [[UITabBarController alloc] init];
    [tabBarController setViewControllers:listOfNavigationControllers];
    self.tabBarController = tabBarController;
    
    UITabBarItem *homeTabBarItem = [[[self.tabBarController viewControllers] objectAtIndex:0] tabBarItem];
    [homeTabBarItem setFinishedSelectedImage:[UIImage imageNamed:@"home-active.png"] withFinishedUnselectedImage:[UIImage imageNamed:@"home-inactive.png"]];
    homeTabBarItem.title = @"Home";
    
    UITabBarItem *facebookTabBarItem = [[[self.tabBarController viewControllers] objectAtIndex:1] tabBarItem];
    [facebookTabBarItem setFinishedSelectedImage:[UIImage imageNamed:@"fb-logo-active.png"] withFinishedUnselectedImage:[UIImage imageNamed:@"fb-logo-inactive.png"]];
    facebookTabBarItem.title = @"Facebook";
    
    UITabBarItem *pcoTabBarItem = [[[self.tabBarController viewControllers] objectAtIndex:2] tabBarItem];
    [pcoTabBarItem setFinishedSelectedImage:[UIImage imageNamed:@"pco-logo-active.png"] withFinishedUnselectedImage:[UIImage imageNamed:@"pco-logo-inactive.png"]];
    pcoTabBarItem.title = @"Planning Center";
    
    UITabBar *tabBar = [tabBarController tabBar];
    tabBar.backgroundImage = [UIImage imageNamed:@"tabbar-bg.png"];
    tabBar.selectionIndicatorImage = [UIImage imageNamed:@"tabbar-active-bg.png"];
    
    [[self window] setRootViewController:tabBarController];
    
    audioSession = [AVAudioSession sharedInstance];
    [audioSession setCategory:AVAudioSessionCategoryPlayback error:nil];
    
    self.window.backgroundColor = [UIColor whiteColor];
    application.statusBarStyle = UIStatusBarStyleBlackOpaque;
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
