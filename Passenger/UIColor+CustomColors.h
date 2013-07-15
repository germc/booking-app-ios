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

#import <UIKit/UIKit.h>

@interface UIColor (CustomColors)

+ (UIColor *) backgroundColor;

+ (UIColor *) buttonTextColor;
+ (UIColor *) buttonHighlightColor;
+ (UIColor *) buttonColor;

+ (UIColor *) mapRouteColor;
+ (UIColor *) mapOverlayColor;
+ (UIColor *) mapFareDistanceColor;

+ (UIColor *) pickupTextColor;
+ (UIColor *) dropoffTextColor;

+ (UIColor *) tourTextColor;

+ (UIColor *) accountTitleLabelColor;
+ (UIColor *) accountLabelColor;

+ (UIColor *) officeTitleLabelColor;
+ (UIColor *) officeLabelColor;

+ (UIColor *) tableCellBackgroundDarkColor;
+ (UIColor *) tableCellBackgroundLightColor;
+ (UIColor *) tableCellBackgroundSelectedColor;

+ (UIColor *) locationBackgroundColor;
+ (UIColor *) locationTextBackgroundColor;
+ (UIColor *) locationTextColor;

+ (UIColor *) dialogHeaderErrorColor;
+ (UIColor *) dialogHeaderColor;
+ (UIColor *) dialogConfirmationColor;
+ (UIColor *) dialogHeaderTextColor;
+ (UIColor *) dialogTextColor;
+ (UIColor *) dialogBackgroundColor;

+ (UIColor *) textFieldBackgroundColor;

+ (UIColor *)demoWarningBackgroundColor;
+ (UIColor *)demoWarningTextColor;

+ (UIColor *)pullToRefreshArrowColor;
+ (UIColor *)pullToRefreshTextColor;

+ (UIColor *)searchDialogBackgroundColor;
+ (UIColor *)searchDialogSelectedTitleColor;
+ (UIColor *)searchDialogNotSelectedTitleColor;
+ (UIColor *)searchDialogTextColor;
+ (UIColor *)searchDialogSeparatorColor;

@end
