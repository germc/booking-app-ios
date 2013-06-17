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

#import "BookingsHistoryViewCell.h"

@implementation BookingsHistoryViewCell

- (IBAction)pickupButtonPressed:(id)sender {
    if (_selectionBlock)
        _selectionBlock(_index, BookingSelectionTypePickup);
}

- (IBAction)dropoffButtonPressed:(id)sender {
    if (_selectionBlock)
        _selectionBlock(_index, BookingSelectionTypeDropoff);
}

- (IBAction)pickupDropoffButtonPressed:(id)sender {
    if (_selectionBlock)
        _selectionBlock(_index, BookingSelectionTypePickupDropoff);
}

- (IBAction)cancelButtonPressed:(id)sender {
    if (_cancellationBlock)
        _cancellationBlock(_index);
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
