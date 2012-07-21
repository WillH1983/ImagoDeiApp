//
//  ImagoDeiTextEntryViewController.m
//  ImagoDei
//
//  Created by Will Hindenburg on 6/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ImagoDeiTextEntryViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface ImagoDeiTextEntryViewController ()
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *postButton;
@end

@implementation ImagoDeiTextEntryViewController
@synthesize textView;
@synthesize postButton;
@synthesize textEntryDelegate = _textEntryDelegate;
@synthesize dictionaryForComment = _dictionaryForComment;

- (void)textChanged:(NSNotification *) notification
{
    id object = [notification object];
    if ([object isKindOfClass:[UITextView class]])
    {
        UITextView *notificationTextView = object;
        if ([notificationTextView hasText]) self.postButton.enabled = YES;
        else self.postButton.enabled = NO;
    }
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(textChanged:) 
                                                 name:UITextViewTextDidChangeNotification 
                                               object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UITextViewTextDidChangeNotification
                                                  object:nil];
}

- (void)viewDidUnload
{
    [self setTextView:nil];
    [self setPostButton:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.postButton.enabled = NO;
    [self.textView becomeFirstResponder];
    
    self.textView.layer.cornerRadius = 10;   
    self.textView.clipsToBounds = YES;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)cancelButtonPressed:(id)sender 
{
    [[self presentingViewController] dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)postButtonPushed:(id)sender 
{
    if ([self.textEntryDelegate respondsToSelector:@selector(textView:didFinishWithString:withDictionaryForComment:)])
    {
        [self.textEntryDelegate textView:self.textView didFinishWithString:self.textView.text withDictionaryForComment:self.dictionaryForComment];
    }
    [[self presentingViewController] dismissViewControllerAnimated:YES completion:nil];
}

@end
