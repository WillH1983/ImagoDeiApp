//
//  RSSParser.m
//  ImagoDei
//
//  Created by Will Hindenburg on 4/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "RSSParser.h"

@interface RSSParser () <NSXMLParserDelegate>
- (void)parseXMLFileAtURL:(NSString *)URL;

@property (nonatomic, weak) id <RSSParserDelegate> rssParserDelegate;
@property (nonatomic, strong) NSXMLParser *rssParser;
@property (nonatomic, strong) NSMutableArray *stories;
@property (nonatomic, strong) NSString *currentElement;
@property (nonatomic, strong) NSMutableDictionary *item;
@property (nonatomic, strong) NSMutableString *currentTitle, *currentDate, *currentSummary, *currentLink;
@end

@implementation RSSParser
@synthesize rssParser = _rssParser, stories = _stories, currentElement = _currentElement, item = _item;
@synthesize currentTitle = _currentTitle, currentDate = _currentDate, currentSummary = _currentSummary, currentLink = _currentLink;
@synthesize rssParserDelegate = _rssParserDelegate;

- (id)initWithXMLFileToParseAtURL:(NSString *)URL withDelegate:(id<RSSParserDelegate>)delegate
{
    self = [self init];
    self.rssParserDelegate = delegate;
    [self parseXMLFileAtURL:URL];
    return self;
}

- (void)parseXMLFileAtURL:(NSString *)URL
{
    self.stories = [[NSMutableArray alloc] init];
    
    //you must then convert the path to a proper NSURL or it won't work
    NSURL *xmlURL = [NSURL URLWithString:URL];
    
    // here, for some reason you have to use NSClassFromString when trying to alloc NSXMLParser, otherwise you will get an object not found error
    // this may be necessary only for the toolchain
    self.rssParser = [[NSXMLParser alloc] initWithContentsOfURL:xmlURL];
    
    // Set self as the delegate of the parser so that it will receive the parser delegate methods callbacks.
    [self.rssParser setDelegate:self];
    
    // Depending on the XML document you're parsing, you may want to enable these features of NSXMLParser.
    [self.rssParser setShouldProcessNamespaces:NO];
    [self.rssParser setShouldReportNamespacePrefixes:NO];
    [self.rssParser setShouldResolveExternalEntities:NO];
    [self.rssParser parse];
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError {
    NSString * errorString = [NSString stringWithFormat:@"Unable to download story feed from web site (Error code %i )", [parseError code]];
    NSLog(@"error parsing XML: %@", errorString);
    UIAlertView * errorAlert = [[UIAlertView alloc] initWithTitle:@"Error loading content" message:errorString delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [errorAlert show];
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict{
    //NSLog(@"found this element: %@", elementName);
    self.currentElement = [elementName copy];
    if ([elementName isEqualToString:@"item"]) {
        // clear out our story item caches...
        self.item = [[NSMutableDictionary alloc] init];
        self.currentTitle = [[NSMutableString alloc] init];
        self.currentDate = [[NSMutableString alloc] init];
        self.currentSummary = [[NSMutableString alloc] init];
        self.currentLink = [[NSMutableString alloc] init];
    }
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName{
    //NSLog(@"ended element: %@", elementName);
    if ([elementName isEqualToString:@"item"]) {
        // save values to an item, then store that item into the array...
        [self.item setObject:self.currentTitle forKey:@"title"];
        [self.item setObject:self.currentLink forKey:@"link"];
        [self.item setObject:self.currentSummary forKey:@"summary"];
        [self.item setObject:self.currentDate forKey:@"date"];
        [self.stories addObject:[self.item copy]];
        NSLog(@"adding story: %@", self.currentTitle);
    }
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string{
    //NSLog(@"found characters: %@", string);
    // save the characters for the current item...
    if ([self.currentElement isEqualToString:@"title"]) {
        [self.currentTitle appendString:string];
    } else if ([self.currentElement isEqualToString:@"link"]) {
        [self.currentLink appendString:string];
    } else if ([self.currentElement isEqualToString:@"description"]) {
        [self.currentSummary appendString:string];
    } else if ([self.currentElement isEqualToString:@"pubDate"]) {
        [self.currentDate appendString:string];
    }
}

- (void)parserDidEndDocument:(NSXMLParser *)parser {
    NSLog(@"all done!");
    NSLog(@"stories array has %d items", [self.stories count]);
    [self.rssParserDelegate RSSParser:self RSSParsingCompleteWithArray:self.stories];
    
}
@end
