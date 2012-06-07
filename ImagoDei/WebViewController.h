//
//  WebViewController.h
//  ImagoDei
//
//  Created by Will Hindenburg on 4/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WebViewController : UIViewController
@property (nonatomic, strong) NSURL *urlToLoad;
@property (nonatomic, strong) NSString *titleForWebView;
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (strong, nonatomic) UINavigationBar *navigationBar;

@end
