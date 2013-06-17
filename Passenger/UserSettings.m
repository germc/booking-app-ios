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

#import "UserSettings.h"

@implementation UserSettings

static NSString* const kUserSettingsKeyTour = @"kUserSettingsKeyTour";
static NSString* const kUserSettingsKeyRefreshToken = @"kUserSettingsKeyRefreshToken";

+ (void)setTourHasBeenShown:(BOOL)hasBeenShown
{
	NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
	[prefs setBool:hasBeenShown forKey:kUserSettingsKeyTour];
	[prefs synchronize];
}

+ (BOOL)tourHasBeenShown
{
	NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
	BOOL hasBeenShown = [prefs boolForKey:kUserSettingsKeyTour];
	return hasBeenShown;
}

+ (void)setRefreshToken:(NSString *)token
{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    if (token)
    {
        [prefs setValue:token forKey:kUserSettingsKeyRefreshToken];
    }
    else
    {
        [prefs removeObjectForKey:kUserSettingsKeyRefreshToken];
    }
	[prefs synchronize];
}

+ (NSString *)refreshToken
{
	NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString* token = [prefs objectForKey:kUserSettingsKeyRefreshToken];
    return token;
}

@end
