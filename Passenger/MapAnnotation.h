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

#import <MapKit/MapKit.h>

@interface MapAnnotation : NSObject<MKAnnotation>
{
	CLLocationCoordinate2D coordinate;
	NSString *title;
	NSString *subtitle;
}

@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;
@property (nonatomic, readonly, copy) NSString *title;
@property (nonatomic, readonly, copy) NSString *subtitle;
@property (nonatomic, strong) NSString* imageName;
@property (nonatomic, strong) NSString *zipCode;

- (id)initWithCoordinate:(CLLocationCoordinate2D) coordinate withTitle:(NSString *)markTitle withImageName:(NSString* )imageName;
- (NSString *)subtitle;
- (NSString *)title;

@end
