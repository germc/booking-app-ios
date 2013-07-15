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

@synthesize coordinate, title, subtitle;

- (NSString *)subtitle{
	return subtitle;
}
- (NSString *)title{
	return title;
}

- (id)initWithCoordinate:(CLLocationCoordinate2D)c
               withTitle:(NSString *)markTitle
           withImageName:(NSString* )imageName
{
	title = markTitle;
	subtitle = @"";
	coordinate = c;
    self.imageName = imageName;
	return self;
}

- (id)initWithCoordinate:(CLLocationCoordinate2D)c
               withTitle:(NSString *)markTitle
           withImageName:(NSString* )imageName
             withZipCode:(NSString *)zipCode
{
	title = markTitle;
	subtitle = @"";
	coordinate = c;
    self.imageName = imageName;
    self.zipCode = zipCode;
	return self;
}

@end
