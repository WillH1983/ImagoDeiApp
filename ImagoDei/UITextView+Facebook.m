//
//  UITextView+Facebook.m
//  TPM
//
//  Created by Will Hindenburg on 8/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "UITextView+Facebook.h"

@implementation UITextView (Facebook)

- (void)resizeTextViewForWidth:(CGFloat)width
{
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, width, self.frame.size.height);
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, self.contentSize.height);
}

@end
