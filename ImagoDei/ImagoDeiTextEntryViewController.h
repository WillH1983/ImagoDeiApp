//
//  ImagoDeiTextEntryViewController.h
//  ImagoDei
//
//  Created by Will Hindenburg on 6/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ImagoDeiTextEntryDelegate <NSObject>
- (void)textView:(UITextView *)sender didFinishWithString:(NSString *)string withDictionaryForComment:(NSDictionary *)dictionary;
@end

@interface ImagoDeiTextEntryViewController : UIViewController
@property (nonatomic, weak) id <ImagoDeiTextEntryDelegate> textEntryDelegate;
@property (nonatomic, strong) NSDictionary *dictionaryForComment;
@end
