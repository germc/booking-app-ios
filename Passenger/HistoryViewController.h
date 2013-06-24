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

@protocol BookingsHistorySelectionDelegate <NSObject>

- (void)selectedBookingWithPickup:(NSString *)pickupName
                 andPickupZipCode:(NSString *)pickupZipCode
                andPickupLocation:(CLLocationCoordinate2D)pickupLocation
                   andDropoffName:(NSString *)dropoffName
                andDropoffZipCode:(NSString *)dropoffZipCode
               andDropoffLocation:(CLLocationCoordinate2D)dropoffLocation
                         onlyShow:(BOOL)onlyShow;

@end

@interface HistoryViewController : UIViewController

@property (unsafe_unretained, nonatomic) id<BookingsHistorySelectionDelegate> selectionDelegate;

- (void) addBooking:(NSDictionary *)booking;

@end
