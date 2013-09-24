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

#import "ConfirmBookingDialog.h"
#import "DatePickerDialog.h"

@interface ConfirmBookingDialog()

@property (weak, nonatomic) IBOutlet UIButton *header;
@property (weak, nonatomic) IBOutlet FlatButton *bookButton;
@property (weak, nonatomic) IBOutlet FlatButton *cancelButton;
@property (weak, nonatomic) IBOutlet UIImageView *dropoffImageView;
@property (weak, nonatomic) IBOutlet UILabel *pickupLabel;
@property (weak, nonatomic) IBOutlet UILabel *dropoffLabel;
@property (weak, nonatomic) IBOutlet FlatButton *timeButton;
@property (weak, nonatomic) IBOutlet FlatButton *dateButton;
@property (weak, nonatomic) IBOutlet UIView *timeView;
@property (weak, nonatomic) IBOutlet UIView *dateView;
@property (weak, nonatomic) IBOutlet UIView *pickupView;
@property (weak, nonatomic) IBOutlet UIView *dropoffView;

@property (strong, nonatomic) NSDate *selectedTime;
@property (strong, nonatomic) NSDate *selectedDate;

- (IBAction)bookButtonPressed:(id)sender;
- (IBAction)cancelButtonPressed:(id)sender;
- (IBAction)timeButtonPressed:(id)sender;
- (IBAction)dateButtonPressed:(id)sender;

@property (nonatomic, copy) DialogConfirmationBlock confirmationBlock;

@end

@implementation ConfirmBookingDialog

- (id)init
{
    self = [super initWithNibName:@"ConfirmBookingDialog"];
    if (self) {
    }
    return self;
}

+ (ConfirmBookingDialog*) showDialog:(NSString *)pickup
                             dropoff:(NSString *)dropoff
                   confirmationBlock:(DialogConfirmationBlock)confirmationBlock

{
    ConfirmBookingDialog* dialog = [[ConfirmBookingDialog alloc] init];
    dialog.pickupLabel.text = pickup;
    
    if (dropoff)
    {
        dialog.dropoffView.hidden = NO;
        dialog.dropoffLabel.text = dropoff;
    }
    else
    {
        dialog.dropoffView.hidden = YES;
    }
    if (confirmationBlock)
        dialog.confirmationBlock = confirmationBlock;
    [dialog show];
    return dialog;
}

- (void)show
{
    UIFont *font = [UIFont semiboldOpenSansOfSize:17];
    
    self.contentView.backgroundColor = [UIColor dialogBackgroundColor];

    _pickupLabel.font = font;
    _pickupLabel.textColor = [UIColor pickupTextColor];
    
    _dropoffLabel.font = font;
    _dropoffLabel.textColor = [UIColor dropoffTextColor];
    
    [_header setTitle:NSLocalizedString(@"new_booking_dialog_title", @"") forState:UIControlStateNormal];
    [_header.titleLabel setFont:[UIFont lightOpenSansOfSize:20]];
    [_header setTitleColor:[UIColor buttonTextColor] forState:UIControlStateNormal];
    [_header setBackgroundColor:[UIColor buttonColor]];

    [_cancelButton setTitleFont:[UIFont lightOpenSansOfSize:20]];
    [_cancelButton setTitle:NSLocalizedString(@"new_booking_dialog_button_cancel", @"") forState:UIControlStateNormal];
    
    [_bookButton setTitleFont:[UIFont semiboldOpenSansOfSize:20]];
    [_bookButton setTitle:NSLocalizedString(@"new_booking_dialog_button_ok", @"") forState:UIControlStateNormal];
    
    [_timeButton setTitleFont:[UIFont semiboldOpenSansOfSize:18]];
    [_timeButton setTitleColor:[UIColor pickupTextColor] forState:UIControlStateNormal];
    [_timeButton setTitle:NSLocalizedString(@"new_booking_dialog_pickup_time_now", @"") forState:UIControlStateNormal];

    [_dateButton setTitleFont:[UIFont semiboldOpenSansOfSize:18]];
    [_dateButton setTitleColor:[UIColor pickupTextColor] forState:UIControlStateNormal];
    [_dateButton setTitle:NSLocalizedString(@"new_booking_dialog_pickup_date_now", @"") forState:UIControlStateNormal];

    CGRect frame = self.contentView.frame;
    frame.size.height -= 60;
    _dateView.hidden = YES;
    if (_dropoffView.hidden)
    {
        frame.size.height -= 60;
    }
    self.contentView.frame = frame;

    frame = _pickupView.frame;
    frame.origin.y -= 60;
    _pickupView.frame = frame;

    frame = _dropoffView.frame;
    frame.origin.y -= 60;
    _dropoffView.frame = frame;
    
    NSInteger minimumTimeOffset = [CabOfficeSettings minimumAllowedPickupTimeOffsetInMinutes];
    if (minimumTimeOffset)
    {
        NSDate *now = [NSDate date];
        now = [now dateByAddingTimeInterval:minimumTimeOffset * 60];
        self.selectedTime = now;
        self.selectedDate = [NSDate date];
        
        [self setButtonsTitles:_selectedTime day:_selectedDate];
        
        [self enableDateButton];
    }

    [super show];
}

- (void)enableDateButton
{
    if (_dateView.hidden)
    {
        CGRect frame = self.contentView.frame;
        frame.size.height += 60;
        _dateView.hidden = NO;
        self.contentView.frame = frame;
        
        frame = _pickupView.frame;
        frame.origin.y += 60;
        _pickupView.frame = frame;
        
        frame = _dropoffView.frame;
        frame.origin.y += 60;
        _dropoffView.frame = frame;
    }
}

- (IBAction)bookButtonPressed:(id)sender
{
    [self dismiss];
    
    NSDate *date = nil;
    
    if (_selectedTime || _selectedDate)
    {
        NSDateComponents* sdc;
        if (_selectedDate)
            sdc = [[NSCalendar currentCalendar] components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:_selectedDate];
        else
            sdc = [[NSCalendar currentCalendar] components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:[NSDate date]];

        NSDateComponents* stc;
        if (_selectedTime)
            stc = [[NSCalendar currentCalendar] components:(NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit) fromDate:_selectedTime];
        else
            stc = [[NSCalendar currentCalendar] components:(NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit) fromDate:[NSDate date]];
        
        date = [[NSCalendar currentCalendar] dateFromComponents:sdc];
        date = [[NSCalendar currentCalendar] dateByAddingComponents:stc toDate:date options:NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit];
    }
    
    if (_confirmationBlock)
        _confirmationBlock(date);
}

- (IBAction)cancelButtonPressed:(id)sender
{
    [self dismiss];
}

- (void)setButtonsTitles:(NSDate *)time day:(NSDate *)day
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"HH:mm"];
    NSString* t = [dateFormatter stringFromDate:time];
    [_timeButton setTitle:t forState:UIControlStateNormal];
    
    [dateFormatter setDateFormat:@"EEEE, LLLL dd yyyy"];
    NSString* str = [dateFormatter stringFromDate:day];
    [_dateButton setTitle:str forState:UIControlStateNormal];
}

- (BOOL)isDateToday:(NSDate *)date
{
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *components = [cal components:(NSEraCalendarUnit|NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit) fromDate:[NSDate date]];
    NSDate *today = [cal dateFromComponents:components];
    components = [cal components:(NSEraCalendarUnit|NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit) fromDate:date];
    NSDate *otherDate = [cal dateFromComponents:components];
    
    if([today isEqualToDate:otherDate]) {
        return YES;
    }
    return NO;
}

- (IBAction)timeButtonPressed:(id)sender {

    NSDate* minimumDate = nil;
    NSInteger minimumTimeOffset = [CabOfficeSettings minimumAllowedPickupTimeOffsetInMinutes];
    
    if (_selectedDate)
    {
        if ([self isDateToday:_selectedDate])
        {
            minimumDate = [[NSDate date] dateByAddingTimeInterval:minimumTimeOffset * 60];
        }
    }
    else
    {
        minimumDate = [[NSDate date] dateByAddingTimeInterval:minimumTimeOffset * 60];
    }
    
    [DatePickerDialog showTimePicker:^(NSDate *date){
        
        [self enableDateButton];
        
        self.selectedTime = date;
        if (!_selectedDate)
        {
            self.selectedDate = [NSDate date];
        }
        [self setButtonsTitles:date day:_selectedDate];
    } withMinimumDate:minimumDate];
}

- (IBAction)dateButtonPressed:(id)sender {
    [DatePickerDialog showDatePicker:^(NSDate *date){
        self.selectedDate = date;
        if (!_selectedTime || [self isDateToday:_selectedDate])
        {
            self.selectedTime = [NSDate date];
        }
        [self setButtonsTitles:_selectedTime day:date];
    }];
}

@end
