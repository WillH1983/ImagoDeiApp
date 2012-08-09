//
//  NSString+HTML.h
//  TPM
//
//  Created by Will Hindenburg on 7/29/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (HTML)
@property (nonatomic, readonly) NSURL *imageFromHTMLString;
- (NSString *)stringByDecodingXMLEntities;
@end
