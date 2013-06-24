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

typedef enum BookingSelectionType
{
    BookingSelectionTypePickup = 0,
    BookingSelectionTypePickupOnlyShow,
    BookingSelectionTypeDropoff,
    BookingSelectionTypeDropoffOnlyShow,
    BookingSelectionTypePickupDropoff
}BookingSelectionType;

typedef void (^BookingSelectionBlock)(NSInteger index, BookingSelectionType);
typedef void (^BookingCancellationBlock)(NSInteger index);

@interface BookingsHistoryViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *pickupLabel;
@property (weak, nonatomic) IBOutlet UILabel *dropoffLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UIButton *pickupButton;
@property (weak, nonatomic) IBOutlet UIButton *dropoffButton;
@property (weak, nonatomic) IBOutlet UIButton *pickupAndDropoffButton;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;

@property (nonatomic, copy) BookingSelectionBlock selectionBlock;
@property (nonatomic, copy) BookingCancellationBlock cancellationBlock;
@property (nonatomic, assign) NSInteger index;

@end
