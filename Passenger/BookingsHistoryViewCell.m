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

#define PICKUP_BUTTON_LONGTAP_IDENTIFIER 1
#define DROPOFF_BUTTON_LONGTAP_IDENTIFIER 2
#define PICKUP_DROPOFF_BUTTON_LONGTAP_IDENTIFIER 3

- (void)awakeFromNib
{
    [super awakeFromNib];

    UILongPressGestureRecognizer *longPressA = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
    _pickupButton.tag = PICKUP_BUTTON_LONGTAP_IDENTIFIER;
    [_pickupButton addGestureRecognizer:longPressA];
    UILongPressGestureRecognizer *longPressB = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
    _dropoffButton.tag = DROPOFF_BUTTON_LONGTAP_IDENTIFIER;
    [_dropoffButton addGestureRecognizer:longPressB];
    UILongPressGestureRecognizer *longPressAB = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
    _pickupAndDropoffButton.tag = PICKUP_DROPOFF_BUTTON_LONGTAP_IDENTIFIER;
    [_pickupAndDropoffButton addGestureRecognizer:longPressAB];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
    }
    return self;
}


- (void)longPress:(UILongPressGestureRecognizer*)gesture {
    if ( gesture.state == UIGestureRecognizerStateBegan) {
        NSInteger tag = gesture.view.tag;
        if (tag == PICKUP_BUTTON_LONGTAP_IDENTIFIER)
        {
            if (_selectionBlock)
                _selectionBlock(_index, BookingSelectionTypePickupOnlyShow);
        }
        else if (tag == DROPOFF_BUTTON_LONGTAP_IDENTIFIER)
        {
            if (_selectionBlock)
                _selectionBlock(_index, BookingSelectionTypeDropoffOnlyShow);
        }
        else if (tag == PICKUP_DROPOFF_BUTTON_LONGTAP_IDENTIFIER)
        {
            if (_selectionBlock)
                _selectionBlock(_index, BookingSelectionTypePickupOnlyShow);
        }
    }
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
