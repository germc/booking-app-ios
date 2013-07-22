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

#import "MapAnnotation.h"

@implementation MapAnnotation

- (id)initWithCoordinate:(CLLocationCoordinate2D)c
               withTitle:(NSString *)title
           withImageName:(NSString* )imageName
{
    self = [super init];
    if (self)
    {
        self.position = c;
        self.title = title;
        self.icon = [UIImage imageNamed:imageName];
    }
	return self;
}

- (id)initWithCoordinate:(CLLocationCoordinate2D)c
               withTitle:(NSString *)title
           withImageName:(NSString* )imageName
             withZipCode:(NSString *)zipCode
{
    self = [self initWithCoordinate:c withTitle:title withImageName:imageName];
    if (self)
    {
        self.zipCode = zipCode;
    }
	return self;
}

@end
