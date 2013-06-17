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

//https://gist.github.com/mwaterfall/953664

#import "NSString+RFC3339.h"

@implementation NSString (RFC3339)

- (NSDate *)dateFromRFC3339String
{
	// Create date formatter
	static NSDateFormatter *dateFormatter = nil;
	if (!dateFormatter) {
		NSLocale *en_US_POSIX = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
		dateFormatter = [[NSDateFormatter alloc] init];
		[dateFormatter setLocale:en_US_POSIX];
		[dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
	}
	
	// Process date
	NSDate *date = nil;
	NSString *RFC3339String = [[NSString stringWithString:self] uppercaseString];
	RFC3339String = [RFC3339String stringByReplacingOccurrencesOfString:@"Z" withString:@"-0000"];
	// Remove colon in timezone as iOS 4+ NSDateFormatter breaks. See https://devforums.apple.com/thread/45837
	if (RFC3339String.length > 20) {
		RFC3339String = [RFC3339String stringByReplacingOccurrencesOfString:@":"
																 withString:@""
																	options:0
																	  range:NSMakeRange(20, RFC3339String.length-20)];
	}
	if (!date) { // 1996-12-19T16:39:57-0800
		[dateFormatter setDateFormat:@"yyyy'-'MM'-'dd'T'HH':'mm':'ssZZZ"];
		date = [dateFormatter dateFromString:RFC3339String];
	}
	if (!date) { // 1937-01-01T12:00:27.87+0020
		[dateFormatter setDateFormat:@"yyyy'-'MM'-'dd'T'HH':'mm':'ss.SSSZZZ"];
		date = [dateFormatter dateFromString:RFC3339String];
	}
	if (!date) { // 1937-01-01T12:00:27
		[dateFormatter setDateFormat:@"yyyy'-'MM'-'dd'T'HH':'mm':'ss"];
		date = [dateFormatter dateFromString:RFC3339String];
	}
	if (!date) NSLog(@"Could not parse RFC3339 date: \"%@\" Possibly invalid format.", self);
	return date;
}

@end
