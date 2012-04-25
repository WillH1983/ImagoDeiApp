//
//  ImagoDeiDataFetcher.m
//  ImagoDei
//
//  Created by Will Hindenburg on 4/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ImagoDeiDataFetcher.h"

@implementation ImagoDeiDataFetcher

+ (NSArray *)tableOfContents
{
    /*NSDictionary *mainPage = [[NSDictionary alloc] initWithObjectsAndKeys:@"Home", CONTENT_TITLE, @"More about Imago Dei", CONTENT_DESCRIPTION, @"http://www.yahoo.com", CONTENT_SMALL_PHOTO_URL, @"1", CONTENT_UNIQUE_ID, nil];
    
    NSDictionary *whoWeAre = [[NSDictionary alloc] initWithObjectsAndKeys:@"Who We Are", CONTENT_TITLE, @"More about Imago Dei", CONTENT_DESCRIPTION, @"http://www.yahoo.com", CONTENT_SMALL_PHOTO_URL, @"2", CONTENT_UNIQUE_ID, nil];
    
    NSDictionary *connect = [[NSDictionary alloc] initWithObjectsAndKeys:@"Connect", CONTENT_TITLE, @"Connect with people at Imago Dei", CONTENT_DESCRIPTION, @"http://www.yahoo.com", CONTENT_SMALL_PHOTO_URL, @"3", CONTENT_UNIQUE_ID, nil];
    
    NSDictionary *news = [[NSDictionary alloc] initWithObjectsAndKeys:@"News", CONTENT_TITLE, @"News from Imago Dei", CONTENT_DESCRIPTION, @"http://www.yahoo.com", CONTENT_SMALL_PHOTO_URL, @"4", CONTENT_UNIQUE_ID, nil];
    
    NSDictionary *events = [[NSDictionary alloc] initWithObjectsAndKeys:@"Events", CONTENT_TITLE, @"Events at Imago Dei", CONTENT_DESCRIPTION, @"http://www.yahoo.com", CONTENT_SMALL_PHOTO_URL, @"5", CONTENT_UNIQUE_ID, nil];
    
    NSDictionary *teachings = [[NSDictionary alloc] initWithObjectsAndKeys:@"Teachings", CONTENT_TITLE, @"Teachings at Imago Dei", CONTENT_DESCRIPTION, @"http://www.yahoo.com", CONTENT_SMALL_PHOTO_URL, @"6", CONTENT_UNIQUE_ID, nil];
    
    NSArray *tmpArray = [[NSArray alloc] initWithObjects:mainPage, whoWeAre, events,teachings, nil];
    return tmpArray;*/
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"JSONFile" ofType:@"txt"];
    NSData *jsonData = [NSData dataWithContentsOfFile:filePath];
    NSError *error = nil;
    NSDictionary *results = jsonData ? [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&error] : nil;
    
    NSArray *tmpArray = [results valueForKeyPath:@"imagodei"];
    if ([tmpArray isKindOfClass:[NSArray class]]) return tmpArray;
    else return nil;
}

+ (NSArray *)arrayForSelectedContent:(NSDictionary *)selection
{
    NSString *uniqueID = [selection objectForKey:CONTENT_UNIQUE_ID];
    NSArray *tmpArray;
    
    if ([uniqueID isEqualToString:@"1"])
    {
        NSDictionary *kidsAtImago = [[NSDictionary alloc] initWithObjectsAndKeys:@"Kids at Imago Dei", CONTENT_TITLE, @"How Kids fit in at Imago Dei", CONTENT_DESCRIPTION, @"http://www.yahoo.com", CONTENT_SMALL_PHOTO_URL, @"10", CONTENT_UNIQUE_ID, @"http://www.imagodeichurch.org/connect/kids-at-imago/", CONTENT_URL_LINK, nil];
        
        NSDictionary *whatToExpect = [[NSDictionary alloc] initWithObjectsAndKeys:@"ImagoWeekly", CONTENT_TITLE, @"Articles from members of Imago Dei", CONTENT_DESCRIPTION, @"http://www.yahoo.com", CONTENT_SMALL_PHOTO_URL, @"8", CONTENT_UNIQUE_ID, @"http://www.imagodeichurch.org/imagoweekly/", CONTENT_URL_LINK, nil];
        
        NSDictionary *whatWeBelieve = [[NSDictionary alloc] initWithObjectsAndKeys:@"What We Believe", CONTENT_TITLE, @"The beliefs of Imago Dei", CONTENT_DESCRIPTION, @"http://www.yahoo.com", CONTENT_SMALL_PHOTO_URL, @"7", CONTENT_UNIQUE_ID, @"http://www.imagodeichurch.org/who-we-are/what-we-believe/", CONTENT_URL_LINK, nil];
        
        NSDictionary *leadership = [[NSDictionary alloc] initWithObjectsAndKeys:@"Leadership", CONTENT_TITLE, @"The leaders of Imago Dei", CONTENT_DESCRIPTION, @"http://www.yahoo.com", CONTENT_SMALL_PHOTO_URL, @"8", CONTENT_UNIQUE_ID, @"http://www.imagodeichurch.org/who-we-are/leadership/", CONTENT_URL_LINK, nil];
        
        NSDictionary *news = [[NSDictionary alloc] initWithObjectsAndKeys:@"News", CONTENT_TITLE, @"News from Imago Dei", CONTENT_DESCRIPTION, @"http://www.yahoo.com", CONTENT_SMALL_PHOTO_URL, @"8", CONTENT_UNIQUE_ID, @"http://www.imagodeichurch.org/news/", CONTENT_URL_LINK, nil];
        
        NSDictionary *teachings = [[NSDictionary alloc] initWithObjectsAndKeys:@"Teachings", CONTENT_TITLE, @"Teachings from Imago Dei", CONTENT_DESCRIPTION, @"http://www.yahoo.com", CONTENT_SMALL_PHOTO_URL, @"8", CONTENT_UNIQUE_ID, @"http://www.imagodeichurch.org/teachings/", CONTENT_URL_LINK, nil];
        
        tmpArray = [[NSArray alloc] initWithObjects: kidsAtImago, whatToExpect, whatWeBelieve, leadership, news, teachings, nil];
    }
    
    if ([uniqueID isEqualToString:@"2"])
    {
        NSDictionary *storyOfTheChurch = [[NSDictionary alloc] initWithObjectsAndKeys:@"Story of the Church", CONTENT_TITLE, @"The story of Imago Dei", CONTENT_DESCRIPTION, @"http://www.yahoo.com", CONTENT_SMALL_PHOTO_URL, @"6", CONTENT_UNIQUE_ID, @"http://www.imagodeichurch.org/who-we-are/story-of-church/", CONTENT_URL_LINK, nil];
        
        NSDictionary *whatWeBelieve = [[NSDictionary alloc] initWithObjectsAndKeys:@"What We Believe", CONTENT_TITLE, @"The beliefs of Imago Dei", CONTENT_DESCRIPTION, @"http://www.yahoo.com", CONTENT_SMALL_PHOTO_URL, @"7", CONTENT_UNIQUE_ID, @"http://www.imagodeichurch.org/who-we-are/what-we-believe/", CONTENT_URL_LINK, nil];
        
        NSDictionary *leadership = [[NSDictionary alloc] initWithObjectsAndKeys:@"Leadership", CONTENT_TITLE, @"The leaders of Imago Dei", CONTENT_DESCRIPTION, @"http://www.yahoo.com", CONTENT_SMALL_PHOTO_URL, @"8", CONTENT_UNIQUE_ID, @"http://http://www.imagodeichurch.org/who-we-are/leadership/", CONTENT_URL_LINK, nil];
        
        NSDictionary *staff = [[NSDictionary alloc] initWithObjectsAndKeys:@"Staff", CONTENT_TITLE, @"The staff of Imago Dei", CONTENT_DESCRIPTION, @"http://www.yahoo.com", CONTENT_SMALL_PHOTO_URL, @"8", CONTENT_UNIQUE_ID, @"http://www.imagodeichurch.org/who-we-are/staff/", CONTENT_URL_LINK, nil];
        
        NSDictionary *whatToExpect = [[NSDictionary alloc] initWithObjectsAndKeys:@"ImagoWeekly", CONTENT_TITLE, @"Articles from members of Imago Dei", CONTENT_DESCRIPTION, @"http://www.yahoo.com", CONTENT_SMALL_PHOTO_URL, @"8", CONTENT_UNIQUE_ID, @"http://www.imagodeichurch.org/imagoweekly/", CONTENT_URL_LINK, nil];
        
        tmpArray = [[NSArray alloc] initWithObjects: storyOfTheChurch, whatWeBelieve, leadership, staff,whatToExpect, nil];
    }
    
    if ([uniqueID isEqualToString:@"3"] || [uniqueID isEqualToString:@"5"])
    {
        NSDictionary *events = [[NSDictionary alloc] initWithObjectsAndKeys:@"Events", CONTENT_TITLE, @"Events at Imago Dei", CONTENT_DESCRIPTION, @"http://www.yahoo.com", CONTENT_SMALL_PHOTO_URL, @"9", CONTENT_UNIQUE_ID, @"http://www.imagodeichurch.org/events/", CONTENT_URL_LINK, nil];
        
        NSDictionary *kidsAtImago = [[NSDictionary alloc] initWithObjectsAndKeys:@"Kids at Imago Dei", CONTENT_TITLE, @"How Kids fit in at Imago Dei", CONTENT_DESCRIPTION, @"http://www.yahoo.com", CONTENT_SMALL_PHOTO_URL, @"10", CONTENT_UNIQUE_ID, @"http://www.imagodeichurch.org/connect/kids-at-imago/", CONTENT_URL_LINK, nil];
        
        NSDictionary *localCommunity = [[NSDictionary alloc] initWithObjectsAndKeys:@"Local Community", CONTENT_TITLE, @"Local Community", CONTENT_DESCRIPTION, @"http://www.yahoo.com", CONTENT_SMALL_PHOTO_URL, @"11", CONTENT_UNIQUE_ID, @"http://www.imagodeichurch.org/connect/local-community/", CONTENT_URL_LINK, nil];
        
        NSDictionary *give = [[NSDictionary alloc] initWithObjectsAndKeys:@"Give", CONTENT_TITLE, @"How to give to Imago Dei, and Why", CONTENT_DESCRIPTION, @"http://www.yahoo.com", CONTENT_SMALL_PHOTO_URL, @"12", CONTENT_UNIQUE_ID, @"http://www.imagodeichurch.org/connect/give/", CONTENT_URL_LINK, nil];
        
        NSDictionary *onlineCommunity = [[NSDictionary alloc] initWithObjectsAndKeys:@"Online Community", CONTENT_TITLE, @"Online Community of Imago Dei church", CONTENT_DESCRIPTION, @"http://www.yahoo.com", CONTENT_SMALL_PHOTO_URL, @"13", CONTENT_UNIQUE_ID, @"http://www.imagodeichurch.org/connect/imagodei-online-community/", CONTENT_URL_LINK, nil];
        
        NSDictionary *weddings = [[NSDictionary alloc] initWithObjectsAndKeys:@"Weddings", CONTENT_TITLE, @"Weddings at Imago Dei Church", CONTENT_DESCRIPTION, @"http://www.yahoo.com", CONTENT_SMALL_PHOTO_URL, @"14", CONTENT_UNIQUE_ID, @"http://www.imagodeichurch.org/weddings/", CONTENT_URL_LINK, nil];
        
        tmpArray = [[NSArray alloc] initWithObjects: events, kidsAtImago, localCommunity, give, onlineCommunity, weddings, nil];
    }
    
    if ([uniqueID isEqualToString:@"4"])
    {
        NSDictionary *news = [[NSDictionary alloc] initWithObjectsAndKeys:@"News", CONTENT_TITLE, @"News from Imago Dei", CONTENT_DESCRIPTION, @"http://www.yahoo.com", CONTENT_SMALL_PHOTO_URL, @"8", CONTENT_UNIQUE_ID, @"http://www.imagodeichurch.org/news/", CONTENT_URL_LINK, nil];
        
        tmpArray = [[NSArray alloc] initWithObjects: news, nil];
    }
    
    if ([uniqueID isEqualToString:@"6"])
    {
        NSDictionary *teachings = [[NSDictionary alloc] initWithObjectsAndKeys:@"Teachings", CONTENT_TITLE, @"Teachings from Imago Dei", CONTENT_DESCRIPTION, @"http://www.yahoo.com", CONTENT_SMALL_PHOTO_URL, @"8", CONTENT_UNIQUE_ID, @"http://www.imagodeichurch.org/teachings/", CONTENT_URL_LINK, nil];
        tmpArray = [[NSArray alloc] initWithObjects:teachings, nil];
    }
    
    return tmpArray;
}

+ (NSDictionary *)DictionaryForImagoDeiLayout
{
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"JSONImagoDei" ofType:@"txt"];
    NSLog(@"%@", filePath);
    NSData *jsonData = [NSData dataWithContentsOfFile:filePath];
    NSError *error = nil;
    NSDictionary *results = jsonData ? [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&error] : nil;
    
    NSDictionary *tmpDictionary = [results valueForKeyPath:@"imagodei"];
    if ([tmpDictionary isKindOfClass:[NSDictionary class]]) return tmpDictionary;
    else return nil;
}

@end
