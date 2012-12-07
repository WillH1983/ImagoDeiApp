//
//  MainPageViewController.m
//  ImagoDei
//
//  Created by Will Hindenburg on 4/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MainPageViewController.h"
#import "RSSTableView.h"
#import "ImagoDeiMediaController.h"
#import "WebViewController.h"

@interface MainPageViewController ()

@end

@implementation MainPageViewController

- (void)awakeFromNib
{
    //This function is called when an xib is loaded from a storyboard
    
    [super awakeFromNib];
    
    //Setup the tabbar with the background image, selected image
    self.tabBarController.tabBar.backgroundImage = [UIImage imageNamed:@"tabbar-bg"];
    self.tabBarController.tabBar.selectionIndicatorImage = [UIImage imageNamed:@"tabbar-active-bg"];
    
    //Setup the "home" tabbar item with the correct image and name
    [self.tabBarItem setFinishedSelectedImage:[UIImage imageNamed:@"home-active.png"] withFinishedUnselectedImage:[UIImage imageNamed:@"home-inactive"]];
    self.tabBarItem.title = @"Home";

}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self setFinishblock:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            
        });
    }];
    
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //Set the Imago Dei logo to the title view of the navigation controler
    //With the content mode set to AspectFit
    UIImage *logoImage = [UIImage imageNamed:@"imago-logo.png"];
    UIImageView *logoImageView = [[UIImageView alloc] initWithImage:logoImage];
    logoImageView.contentMode = UIViewContentModeScaleAspectFit;
    self.navigationItem.titleView = logoImageView;
    
    //Create a UIImageView and set the content mode to be placed in the background
    UIImageView *backgroundImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"background.png"]];
    backgroundImageView.contentMode = UIViewContentModeScaleToFill;
    
    //Set the background of the ImagoDei app to the background image
    self.tableView.backgroundView = backgroundImageView;
    
    //Set the navigation bar color to the standard color
    UIColor *standardColor = [UIColor colorWithRed:0.8509 green:0.8352 blue:0.7725 alpha:1.0];
    [[[self navigationController] navigationBar] setTintColor:standardColor];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *primaryTextLabel = [[NSString alloc] init];
    
    //Get the title for the Cell to be displayed
    
    primaryTextLabel = cell.textLabel.text;
    
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //Pull the URL from the selected tablecell, which is from the parsed RSS file with the key "link"
    NSURL *url = [[NSURL alloc] initWithString:[[self.RSSDataArray objectAtIndex:indexPath.row] valueForKeyPath:@"link.text"]];
    
    //Get the title for the next view from the selected tablecell, which is composed from the RSS file
    NSString *title = [[self.RSSDataArray objectAtIndex:indexPath.row] valueForKeyPath:@"title.text"];
    //Only perform actions on url if it is a valid URL
    if (url)
    {
        //If the URL is for an RSS file, initialize a mainpageviewcontroller with the URL
        //and set the title
        if ([[url pathExtension] isEqualToString:@"rss"] || [[url lastPathComponent] isEqualToString:@"feed"] || [[url lastPathComponent] isEqualToString:@"rss"])
        {
            ImagoDeiStandardTableViewController *idstvc = [[ImagoDeiStandardTableViewController alloc] initWithModel:url];
            idstvc.title = title;
            [self.navigationController pushViewController:idstvc animated:YES];
        }
        //If the URL is for an mp3 file, initialize a mediacontroller with the URL
        //and set the title
        else if ([[url pathExtension] isEqualToString:@"mp3"])
        {
            ImagoDeiMediaController *controller = [[ImagoDeiMediaController alloc] initImageoDeiMediaControllerWithURL:url];
            controller.title = title;
            [self.navigationController pushViewController:controller animated:YES];
        }
        //Catch all is to load a webview with the contents of the URL
        else 
        {
            WebViewController *wvc = [[WebViewController alloc] init];
            [wvc setUrlToLoad:url];
            [[self navigationController] pushViewController:wvc animated:YES];
        }
    }
}

@end
