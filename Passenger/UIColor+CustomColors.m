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

#import "UIColor+CustomColors.h"

@implementation UIColor (CustomColors)

+ (UIColor *) backgroundColor
{
    return [UIColor colorWithHexString:@"FFFFFF"];
}

+ (UIColor *) buttonTextColor
{
    return [UIColor colorWithHexString:@"#555555"];
}

+ (UIColor *) buttonHighlightColor
{
    return [UIColor colorWithHexString:@"#0099cc"];
}

+ (UIColor *) buttonColor
{
    return [UIColor colorWithHexString:@"#eeeeee"];
}

+ (UIColor *) mapRouteColor
{
    return [UIColor colorWithHexString:@"#88ff0000"]; //map_route_fg
}

+ (UIColor *) mapOverlayColor
{
    return [UIColor colorWithHexString:@"#e6ffffff"]; //map_overlay_bg
}

+ (UIColor *) mapFareDistanceColor
{
    return [UIColor colorWithHexString:@"7f7f7f"];
}

+ (UIColor *) pickupTextColor
{
    return [UIColor colorWithHexString:@"#25AAE1"]; //pickup_location
}

+ (UIColor *) dropoffTextColor
{
    return [UIColor colorWithHexString:@"#2BB673"]; //dropoff_location
}

+ (UIColor *) tourTextColor
{
    return [UIColor colorWithHexString:@"#011544"];
}

+ (UIColor *) accountTitleLabelColor
{
    return [UIColor colorWithHexString:@"#aaaaaa"];
}

+ (UIColor *) accountLabelColor
{
    return [UIColor colorWithHexString:@"#444444"];
}

+ (UIColor *) officeTitleLabelColor
{
    return [UIColor colorWithHexString:@"#aaaaaa"];
}

+ (UIColor *) officeLabelColor
{
    return [UIColor colorWithHexString:@"#444444"];
}

+ (UIColor *) tableCellBackgroundDarkColor
{
    return [UIColor colorWithHexString:@"eeeeee"]; //booking_list_bg_even
}

+ (UIColor *) tableCellBackgroundLightColor
{
    return [UIColor colorWithHexString:@"ffffff"]; //booking_list_bg_odd
}

+ (UIColor *) tableCellBackgroundSelectedColor
{
    return [UIColor colorWithHexString:@"#EFDFBD"];
}

+ (UIColor *) locationBackgroundColor
{
    return [UIColor colorWithHexString:@"#cccccc"];
}

+ (UIColor *) locationTextBackgroundColor
{
    return [UIColor colorWithHexString:@"#bbbbbb"];
}

+ (UIColor *) locationTextColor
{
    return [UIColor colorWithHexString:@"#555555"];
}

+ (UIColor *) dialogHeaderErrorColor
{
    return [UIColor colorWithHexString:@"#dddb887d"];
}

+ (UIColor *) dialogHeaderColor
{
    return [UIColor colorWithHexString:@"#dd81dc81"];
}

+ (UIColor *) dialogConfirmationColor
{
    return [UIColor colorWithHexString:@"#ddc6a242"];
}

+ (UIColor *) dialogHeaderTextColor
{
    return [UIColor colorWithHexString:@"#ff000000"];
}

+ (UIColor *) dialogTextColor
{
    return [UIColor colorWithHexString:@"#555555"];
}

+ (UIColor *) dialogBackgroundColor
{
    return [UIColor colorWithHexString:@"#dddddd"];
}

+ (UIColor *) textFieldBackgroundColor
{
    return [UIColor colorWithHexString:@"#eeeeee"];
}

+ (UIColor *)demoWarningBackgroundColor
{
    return [UIColor colorWithHexString:@"#88ff0000"];
}

+ (UIColor *)demoWarningTextColor
{
    return [UIColor colorWithHexString:@"#ffffff"];
}

+ (UIColor *)pullToRefreshArrowColor
{
    return [UIColor colorWithHexString:@"#888888"];
}

+ (UIColor *)pullToRefreshTextColor
{
    return [UIColor colorWithHexString:@"#888888"];   
}

+ (UIColor *)searchDialogBackgroundColor
{
    return [UIColor colorWithHexString:@"#FFFFFF"];
}

+ (UIColor *)searchDialogSelectedTitleColor
{
    return [UIColor colorWithHexString:@"070707"];
}

+ (UIColor *)searchDialogNotSelectedTitleColor
{
    return [UIColor colorWithHexString:@"#6E6E6E"];
}

+ (UIColor *)searchDialogTextColor
{
    return [UIColor colorWithHexString:@"#6E6E6E"];
}

+ (UIColor *)searchDialogSeparatorColor
{
    return [UIColor colorWithHexString:@"#33B5E5"];
}


//helper function

+ (UIColor *) colorWithHexString: (NSString *) stringToConvert
{
	NSString *cString = [[stringToConvert stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
	
	// strip 0X if it appears
	if ([cString hasPrefix:@"0X"]) cString = [cString substringFromIndex:2];
	if ([cString hasPrefix:@"#"]) cString = [cString substringFromIndex:1];
    
    NSString *aString;
    NSString *rString;
    NSString *gString;
    NSString *bString;
    NSRange range;
    range.length = 2;
    
    if ([cString length] == 6) //no alpha
    {
        aString = @"FF";
        
        range.location = 0;
        rString = [cString substringWithRange:range];
        
        range.location = 2;
        gString = [cString substringWithRange:range];
        
        range.location = 4;
        bString = [cString substringWithRange:range];
    }
    else if ([cString length] == 8) //with alpha alpha
    {
        range.location = 0;
        aString = [cString substringWithRange:range];
        
        range.location = 2;
        rString = [cString substringWithRange:range];
        
        range.location = 4;
        gString = [cString substringWithRange:range];
        
        range.location = 6;
        bString = [cString substringWithRange:range];
    }
	else
    {
        return [UIColor clearColor];
    }
    
	// Scan values
	unsigned int a, r, g, b;
	[[NSScanner scannerWithString:aString] scanHexInt:&a];
	[[NSScanner scannerWithString:rString] scanHexInt:&r];
	[[NSScanner scannerWithString:gString] scanHexInt:&g];
	[[NSScanner scannerWithString:bString] scanHexInt:&b];
	
	return [UIColor colorWithRed:((float) r / 255.0f)
						   green:((float) g / 255.0f)
							blue:((float) b / 255.0f)
						   alpha:((float) a / 255.0f)];
}

@end
