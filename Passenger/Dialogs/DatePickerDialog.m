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

#import "DatePickerDialog.h"

@interface DatePickerDialog()

@property (weak, nonatomic) IBOutlet UIDatePicker *picker;
@property (weak, nonatomic) IBOutlet UIButton *selectButton;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;

- (IBAction)selectButtonPressed:(id)sender;
- (IBAction)cancelButtonPressed:(id)sender;

@property (nonatomic, copy) DatePickerCompletionBlock completionBlock;

@end


@implementation DatePickerDialog

- (id)init
{
    self = [super initWithNibName:@"DatePickerDialog"];
    if (self) {
        
        [_selectButton setTitle:NSLocalizedString(@"new_booking_dialog_picker_button_select", @"") forState:UIControlStateNormal];
        [_cancelButton setTitle:NSLocalizedString(@"new_booking_dialog_picker_button_cancel", @"") forState:UIControlStateNormal];
        // Initialization code
    }
    return self;
}

+ (void)showTimePicker:(DatePickerCompletionBlock)completionBlock withMinimumDate:(NSDate *)date
{
    DatePickerDialog* d = [[DatePickerDialog alloc] init];
    d.picker.datePickerMode = UIDatePickerModeTime;

    d.picker.minimumDate = date;
    d.completionBlock = completionBlock;
    [d show];
}

+ (void)showDatePicker:(DatePickerCompletionBlock)completionBlock
{
    DatePickerDialog* d = [[DatePickerDialog alloc] init];
    d.picker.datePickerMode = UIDatePickerModeDate;
    NSDate* maxDate = [NSDate date];
    
    NSInteger maxDaysAhead = [CabOfficeSettings newBookingsMaxDaysAhead];
    
    maxDate = [maxDate dateByAddingTimeInterval:maxDaysAhead*24*60*60];
    d.picker.maximumDate = maxDate;
    d.picker.minimumDate = [NSDate date];
    d.completionBlock = completionBlock;
    [d show];
}

- (IBAction)selectButtonPressed:(id)sender {
    
    NSLog(@"selected date: %@", _picker.date);
    
    if (_completionBlock)
        _completionBlock(_picker.date);
    [self dismiss];
}

- (IBAction)cancelButtonPressed:(id)sender {
    [self dismiss];
}
@end
