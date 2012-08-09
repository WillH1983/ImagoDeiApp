//
//  NSMutableDictionary+appConfiguration.m
//  TPM
//
//  Created by Will Hindenburg on 7/29/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NSMutableDictionary+appConfiguration.h"

@implementation NSMutableDictionary (appConfiguration)

- (void)setRSSlink:(NSURL *)RSSlink
{
    [self setObject:RSSlink forKey:@"RSSLink"];
}

- (NSURL *)RSSlink
{
    return [self objectForKey:@"RSSLink"];
}

- (void)setDefaultLocalPathImageForTableViewCell:(NSString *)defaultLocalPathImageForTableViewCell
{
    [self setObject:defaultLocalPathImageForTableViewCell forKey:@"defaultLocalPathImageForTableViewCell"];
}

- (NSString *)defaultLocalPathImageForTableViewCell
{
    return [self objectForKey:@"defaultLocalPathImageForTableViewCell"];
}

- (void)setAppName:(NSString *)appName
{
    [self setObject:appName forKey:@"appName"];
}

- (NSString *)appName
{
    return [self objectForKey:@"appName"];
}

@end
