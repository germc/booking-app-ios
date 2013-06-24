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

#import "NSBundle+AndroidStrings.h"
#import "AndroidXMLReader.h"

#import <objc/runtime.h>

static char* kNSBundleAndroidStringsTableAssociationKey = "NSBundle.stringsTables";

@interface NSBundle () <NSXMLParserDelegate>

@property (nonatomic, strong) NSMutableDictionary* stringsTable;

@end

@implementation NSBundle (AndroidStrings)

- (NSDictionary*) stringsTable {
    return objc_getAssociatedObject(self, &kNSBundleAndroidStringsTableAssociationKey);
}

- (void) setStringsTable:(NSDictionary *)stringsTable {
    objc_setAssociatedObject(self, &kNSBundleAndroidStringsTableAssociationKey, stringsTable, OBJC_ASSOCIATION_RETAIN);
}

- (void) addStringFiles:(NSArray *)stringFilesArray forLanguage:(NSString *)language
{
    for (NSString *file in stringFilesArray)
    {
        [self addStringFile:file forLanguage:language];
    }
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName attributes:(NSDictionary *)attributeDict{
    
    if ([elementName isEqualToString:@"string"]) {
        NSString* name = [attributeDict valueForKey:@"name"];
        NSLog(@"name: %@", name);
    }
}

- (void) addStringFile:(NSString *)stringFile forLanguage:(NSString *)language
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        self.stringsTable = [NSMutableDictionary dictionary];
    });

    NSString *subdir = [NSString stringWithFormat:@"values-%@", language];
    NSString* tablePath = [[NSBundle mainBundle] pathForResource: stringFile ofType: @"xml" inDirectory:subdir];
    NSData* tableData = [NSData dataWithContentsOfFile: tablePath];

    if (!tableData)
        return;
    
    NSError* error = nil;
    
    NSDictionary* table = [AndroidXMLReader parseXMLData:tableData error:&error];
    
    if( error )
    {
        NSException* exception = [NSException exceptionWithName: @"Strings Table"
                                                         reason: @"There was an error creating the strings table"
                                                       userInfo: @{ @"TableName" : stringFile, @"Underlying Error" : error }];
        [exception raise];
    }
    else
    {
        NSMutableDictionary* stringsForLanguage = [self.stringsTable objectForKey:language];
        if (stringsForLanguage == nil)
        {
            stringsForLanguage = [[NSMutableDictionary alloc] init];
            [self.stringsTable setObject:stringsForLanguage forKey:language];
        }

        if( table )
        {
            [stringsForLanguage addEntriesFromDictionary:table];
        }
        else
        {
            NSException* exception = [NSException exceptionWithName: @"Strings Table"
                                                             reason: @"There was no strings table created"
                                                           userInfo: @{ @"TableName" : stringFile}];
            [exception raise];
        }
    }
}

- (NSString*) localizedAndroidStringForKey:(NSString *)key
{
    if( !key )
        return nil;
    
    @synchronized(self) {
        
        NSString* language = [[NSLocale preferredLanguages] objectAtIndex:0];
        NSMutableDictionary *lStrings = [self.stringsTable objectForKey:language];
        if (lStrings == nil)
        {
            lStrings = [self.stringsTable objectForKey:@"en"];
        }
        
        NSString *value = [lStrings objectForKey:key];
        
        if (value == nil && ![language isEqualToString:@"en"])
        {
            lStrings = [self.stringsTable objectForKey:@"en"];
            value = [lStrings objectForKey:key];
        }
        
        return value == nil ? key : value;
    }
}

@end
