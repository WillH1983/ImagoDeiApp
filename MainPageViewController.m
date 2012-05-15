//
//  MainPageViewController.m
//  ImagoDei
//
//  Created by Will Hindenburg on 4/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MainPageViewController.h"
#import "ImagoDeiDataFetcher.h"
#import "WebViewController.h"
#import "Facebook.h"
#import "FacebookSocialMediaViewController.h"
#import "ImagoDeiMediaController.h"
#import "ImagoDeiStandardTableViewController.h"

@interface MainPageViewController ()

@end

@implementation MainPageViewController

- (void)awakeFromNib
{
    //This function is called when an xib is loaded from a storyboard
    
    //Set the tableview delegate to this class
    self.tableView.delegate = self;
    
    //Setup the tabbar with the background image, selected image
    self.tabBarController.tabBar.backgroundImage = [UIImage imageNamed:@"tabbar-bg.png"];
    self.tabBarController.tabBar.selectionIndicatorImage = [UIImage imageNamed:@"tabbar-active-bg.png"];
    
    //Setup the "home" tabbar item with the correct image and name
    [self.tabBarItem setFinishedSelectedImage:[UIImage imageNamed:@"home-active.png"] withFinishedUnselectedImage:[UIImage imageNamed:@"home-inactive.png"]];
    self.tabBarItem.title = @"Home";
    
    //For now create a filepath string with the MainTabiPhone file that is bundled
    //with the application
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"MainTabiPhone" ofType:@"rss"];
    
    //initialize the class with the URL file path
    NSURL *urlFilePath = [[NSURL alloc] initFileURLWithPath:filePath];
    [self standardInitWithURL:urlFilePath];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *primaryTextLabel = [[NSString alloc] init];
    
    //Get the title for the Cell to be displayed
    primaryTextLabel = [[self.arrayOfTableData objectAtIndex:[indexPath row]] valueForKey:CONTENT_TITLE];
    
    //Determine if an image should be displayed, and display it based upon the name
    if ([primaryTextLabel isEqualToString:@"NEWS"])
    {
        cell.imageView.image = [UIImage imageNamed:@"news-icon.png"];
    }
    else if ([primaryTextLabel isEqualToString:@"EVENTS"])
    {
        cell.imageView.image = [UIImage imageNamed:@"events-icon.png"];
    }
    else if ([primaryTextLabel isEqualToString:@"TEACHINGS"])
    {
        cell.imageView.image = [UIImage imageNamed:@"teachings-icon.png"];
    }
    else if ([primaryTextLabel isEqualToString:@"CONNECT"])
    {
        cell.imageView.image = [UIImage imageNamed:@"connect-icon.png"];
    }
    else if ([primaryTextLabel isEqualToString:@"WHO WE ARE"])
    {
        cell.imageView.image = [UIImage imageNamed:@"whoweare-icon.png"];
    }
}

@end
