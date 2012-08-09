//
//  NSMutableDictionary+appConfiguration.h
//  TPM
//
//  Created by Will Hindenburg on 7/29/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableDictionary (appConfiguration)
@property (nonatomic, strong) NSURL *RSSlink;
@property (nonatomic, strong) NSString *defaultLocalPathImageForTableViewCell;
@property (nonatomic, strong) NSString *appName;
@end
