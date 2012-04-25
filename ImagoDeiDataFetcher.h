//
//  ImagoDeiDataFetcher.h
//  ImagoDei
//
//  Created by Will Hindenburg on 4/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ImagoDeiDataFetcher : NSObject

#define CONTENT_TITLE @"title"
#define CONTENT_DESCRIPTION @"description"
#define CONTENT_SMALL_PHOTO_URL @"smallphotourl"
#define CONTENT_UNIQUE_ID @"id"
#define CONTENT_URL_LINK @"link"

+ (NSArray *)tableOfContents;
+ (NSArray *)arrayForSelectedContent:(NSDictionary *)selection;
+ (NSDictionary *)DictionaryForImagoDeiLayout;

@end
