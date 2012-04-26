//
//  RSSParser.h
//  ImagoDei
//
//  Created by Will Hindenburg on 4/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RSSParser;

@protocol RSSParserDelegate <NSObject>
- (void)RSSParser:(RSSParser *)sender RSSParsingCompleteWithArray:(NSArray *)RSSArray;
@end

@interface RSSParser : NSObject

- (void)XMLFileToParseAtURL:(NSURL *)URL withDelegate:(id<RSSParserDelegate>)delegate;

@end
