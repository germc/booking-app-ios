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

#import "CabOfficeSettings.h"

@implementation CabOfficeSettings

+ (NSDictionary*)cabOfficeDefaults
{
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"CabOfficeSettings" ofType:@"plist"];
    NSDictionary *plistData = [NSDictionary dictionaryWithContentsOfFile:filePath];
    return plistData;
}

+ (BOOL)dropoffLocationIsMandatory
{
    NSDictionary *s = [CabOfficeSettings cabOfficeDefaults];
    NSNumber* r = s[@"caboffice_settings_dropoff_location_is_mandatory"];
    return [r boolValue];
}

+ (CGFloat)startLocationLatitude
{
    NSDictionary *s = [CabOfficeSettings cabOfficeDefaults];
    NSNumber* r = s[@"caboffice_start_location_latitude"];
    return [r floatValue];
}

+ (CGFloat)startLocationLongitude
{
    NSDictionary *s = [CabOfficeSettings cabOfficeDefaults];
    NSNumber* r = s[@"caboffice_start_location_longitude"];
    return [r floatValue];
}

+ (NSInteger)maxActiveBookings
{
    NSDictionary *s = [CabOfficeSettings cabOfficeDefaults];
    NSNumber* r = s[@"caboffice_settings_max_active_bookings"];
    return [r integerValue];
}

+ (NSInteger)newBookingsMaxDaysAhead
{
    NSDictionary *s = [CabOfficeSettings cabOfficeDefaults];
    NSNumber* r = s[@"caboffice_settings_new_bookings_max_days_ahead"];
    return [r integerValue];
}

@end