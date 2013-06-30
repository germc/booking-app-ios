/******************************************************************************
 *
 * Copyright (C) 2013 T Dispatch Ltd
 *
 * Licensed under the GPL License, Version 3.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.gnu.org/licenses/gpl-3.0.html
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 ******************************************************************************
 *
 * @author Marcin Orlowski <marcin.orlowski@webnet.pl>
 *
 ****/

//based on libCocolize: https://github.com/paul-delange/cocolize

#import "AndroidXMLReader.h"

@interface AndroidXMLReader () <NSXMLParserDelegate>
{
    NSError* _error;
    NSMutableDictionary* _strings;
    NSMutableString *_currentString;
    NSString *_currentKey;
}

@end

@implementation AndroidXMLReader

+ (NSDictionary *)parseXMLData:(NSData *)data error:(NSError **)error
{
    AndroidXMLReader *xml = [[AndroidXMLReader alloc] init];
    
    xml->_error = nil;
    
    NSDictionary* root = [xml parse:data];

    if (error)
    {
        *error = xml->_error;
    }

    return root;
}

- (NSDictionary *)parse:(NSData *)data
{
    _strings = [[NSMutableDictionary alloc] init];
    
    // Parse the XML
    NSXMLParser *parser = [[NSXMLParser alloc] initWithData:data];
    parser.delegate = self;
    BOOL success = [parser parse];
    
    // Return the stack's root dictionary on success
    if (success)
    {
        return _strings;
    }
    
    return nil;
}

#pragma mark NSXMLParserDelegate methods

- (void)parser:(NSXMLParser *)parser
didStartElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI
 qualifiedName:(NSString *)qName
    attributes:(NSDictionary *)attributeDict
{
    _currentString = [[NSMutableString alloc] init];
    if ([elementName isEqualToString:@"string"])
    {
        _currentKey = attributeDict[@"name"];
    }
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    if ([elementName isEqualToString:@"string"])
    {
        if (_currentString.length)
        {
            [_currentString replaceOccurrencesOfString:@"\""
                                            withString:@""
                                               options:0
                                                 range:NSMakeRange(0, 1)];
            [_currentString replaceOccurrencesOfString:@"\""
                                            withString:@""
                                               options:0
                                                 range:NSMakeRange(_currentString.length-1, 1)];
            [_currentString replaceOccurrencesOfString:@"\%s"
                                            withString:@"\%@"
                                               options:0
                                                 range:NSMakeRange(0, _currentString.length)];
            [_currentString replaceOccurrencesOfString:@"\\'"
                                            withString:@"'"
                                               options:0
                                                 range:NSMakeRange(0, _currentString.length)];
            [_currentString replaceOccurrencesOfString:@"\\\""
                                            withString:@"\""
                                               options:0
                                                 range:NSMakeRange(0, _currentString.length)];
        }
        _strings[_currentKey] = [_currentString stringByReplacingOccurrencesOfString:@"\\n" withString:@" "];
        _currentString = nil;
    }
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    [_currentString appendString:string];
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError
{
    // Set the error pointer to the parser's error object
    _error = parseError;
}

@end
