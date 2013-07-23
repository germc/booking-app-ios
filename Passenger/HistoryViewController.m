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

#import "HistoryViewController.h"
#import "UIScrollView+SVPullToRefresh.h"
#import "BookingsHistoryViewCell.h"

@interface HistoryViewController () <UITableViewDataSource, UITableViewDelegate>
{
    NSInteger _selectedRow;
}
@property (weak, nonatomic) IBOutlet UIView *errorView;
@property (weak, nonatomic) IBOutlet UIView *pleaseWaitView;
@property (weak, nonatomic) IBOutlet UILabel *errorLabel;
@property (weak, nonatomic) IBOutlet FlatButton *tryAgainButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UILabel *pleaseWaitLabel;
@property (weak, nonatomic) IBOutlet UILabel *noBookingsLabel;

@property (weak, nonatomic) IBOutlet UIView *messageView;
@property (strong, nonatomic) IBOutlet UITableView *tableView;

- (IBAction)tryAgainButtonPressed:(id)sender;

@property (nonatomic, strong) NSMutableArray* bookings;

@end

@implementation HistoryViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)addBooking:(NSDictionary *)booking
{
    //only add to the list if it exists. If not, whole list will be downloaed when screen becomes visible.
    if (_bookings)
    {
        [_bookings insertObject:booking atIndex:0];

        if (_bookings.count > 20)
            [_bookings removeLastObject];
        
        [self reloadData];
    }
}

- (void)showNoBookingsView
{
    _messageView.hidden = NO;
    _errorView.hidden = YES;
    _pleaseWaitView.hidden = YES;
    _noBookingsLabel.hidden = NO;
}

- (void)showErrorView
{
    _messageView.hidden = NO;
    _errorView.hidden = NO;
    _pleaseWaitView.hidden = YES;
    _noBookingsLabel.hidden = YES;
}

- (void)showPleaseWaitView
{
    _messageView.hidden = NO;
    _errorView.hidden = YES;
    _pleaseWaitView.hidden = NO;
    _noBookingsLabel.hidden = YES;
    [_activityIndicator startAnimating];
}

- (void)showTableView
{
    _messageView.hidden = YES;
}

- (void)reloadData
{
    [_tableView reloadData];
    if (_bookings.count)
    {
        [self showTableView];
    }
    else
    {
        [self showNoBookingsView];
    }
}

- (void)downloadBookings
{
    [self showPleaseWaitView];

    [[NetworkEngine getInstance] getLatestBookings:^(NSObject *o) {
                                        self.bookings = [NSMutableArray arrayWithArray:(NSArray *)o];
                                        [self reloadData];
                                      }
                                      failureBlock:^(NSError *e) {
                                          [self showErrorView];
                                      }];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _errorLabel.font = [UIFont lightOpenSansOfSize:17];
    _errorLabel.textColor = [UIColor grayColor];
    _errorLabel.lineBreakMode = NSLineBreakByWordWrapping;
    _errorLabel.text = NSLocalizedString(@"booking_list_download_error_message", @"");
    
    [_tryAgainButton setTitle:NSLocalizedString(@"booking_list_download_error_button", @"") forState:UIControlStateNormal];
    
    _pleaseWaitLabel.font = [UIFont lightOpenSansOfSize:21];
    _pleaseWaitLabel.textColor = [UIColor grayColor];
    _pleaseWaitLabel.text = NSLocalizedString(@"tdfragment_please_wait", @"");

    _noBookingsLabel.font = [UIFont lightOpenSansOfSize:21];
    _noBookingsLabel.textColor = [UIColor grayColor];
    _noBookingsLabel.text = NSLocalizedString(@"booking_list_no_bookings", @"");
    
    _selectedRow = NSNotFound;

    __block HistoryViewController* hvc = self;
    [_tableView addPullToRefreshWithActionHandler:^{
        [[NetworkEngine getInstance] getLatestBookings:^(NSObject *o) {
            [hvc.tableView.pullToRefreshView stopAnimating];
            
            hvc.bookings = [NSMutableArray arrayWithArray:(NSArray *)o];
            if (hvc.bookings.count)
            {
                [hvc showTableView];
            }
            else
            {
                [hvc showNoBookingsView];
            }
        }
                                          failureBlock:^(NSError *e) {
                                              [hvc.tableView.pullToRefreshView stopAnimating];
                                              [hvc showErrorView];
                                          }];
    }];
    
    _tableView.pullToRefreshView.arrowColor = [UIColor pullToRefreshArrowColor];
    _tableView.pullToRefreshView.textColor = [UIColor pullToRefreshTextColor];
    _tableView.pullToRefreshView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
    [_tableView.pullToRefreshView setTitle:NSLocalizedString(@"booking_list_pull_to_refresh_loading", @"") forState:SVPullToRefreshStateLoading];
    [_tableView.pullToRefreshView setTitle:NSLocalizedString(@"booking_list_pull_to_refresh_pull", @"") forState:SVPullToRefreshStateStopped];
    [_tableView.pullToRefreshView setTitle:NSLocalizedString(@"booking_list_pull_to_refresh_release", @"") forState:SVPullToRefreshStateTriggered];
    _tableView.pullToRefreshView.titleLabel.font = [UIFont lightOpenSansOfSize:15];
    
    [self downloadBookings];
    
	// Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [_tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark table view source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _bookings.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == _selectedRow)
    {
        return 176.0;
    }
    else
    {
        return 120.0;
    }
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary* booking = [_bookings objectAtIndex:indexPath.row];
    
    static NSString *cellIdentifier = @"historyTableViewCell";
    BookingsHistoryViewCell* cell = (BookingsHistoryViewCell*)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];

    cell.pickupLabel.font = [UIFont semiboldOpenSansOfSize:16];
    cell.pickupLabel.textColor = [UIColor pickupTextColor];
    NSDictionary* pickup = booking[@"pickup_location"];
    BOOL pickupButtonHidden = NO;
    if (!IS_NULL(pickup))
    {
        cell.pickupLabel.text = pickup[@"address"];
    }
    else
    {
        cell.pickupLabel.text = @"---";
        pickupButtonHidden = YES;
    }
    
    cell.dropoffLabel.font = [UIFont semiboldOpenSansOfSize:16];
    cell.dropoffLabel.textColor = [UIColor dropoffTextColor];
    NSDictionary* dropoff = booking[@"dropoff_location"];
    if (!IS_NULL(dropoff))
    {
        cell.dropoffLabel.text = dropoff[@"address"];
        if (indexPath.row != _selectedRow)
        {
            cell.pickupButton.hidden = YES;
            cell.dropoffButton.hidden = YES;
            cell.pickupAndDropoffButton.hidden = YES;
        }
        else
        {
            cell.pickupButton.hidden = pickupButtonHidden;
            cell.dropoffButton.hidden = NO;
            cell.pickupAndDropoffButton.hidden = pickupButtonHidden;
        }
    }
    else
    {
        cell.dropoffLabel.text = @"---";
        cell.dropoffButton.hidden = YES;
        if (indexPath.row != _selectedRow)
        {
            cell.pickupAndDropoffButton.hidden = YES;
            cell.pickupButton.hidden = YES;
        }
        else
        {
            cell.pickupAndDropoffButton.hidden = pickupButtonHidden;
            cell.pickupButton.hidden = pickupButtonHidden;
        }
    }

    if (indexPath.row == _selectedRow)
    {
        NSString *status = booking[@"status"];
        if ([status isEqualToString:@"incoming"] ||
            [status isEqualToString:@"from_partner"] ||
            [status isEqualToString:@"dispatched"] ||
            [status isEqualToString:@"confirmed"])
        {
            cell.cancelButton.hidden = NO;
        }
        else
        {
            cell.cancelButton.hidden = YES;
        }
    }
    else
    {
        cell.cancelButton.hidden = YES;
    }
    
    cell.timeLabel.font = [UIFont lightOpenSansOfSize:13];
    cell.timeLabel.textColor = [UIColor lightGrayColor]; //FIXME
    static NSDateFormatter *_timeIntervalFormatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _timeIntervalFormatter = [[NSDateFormatter alloc] init];
        
        NSLocale *locale = [NSLocale currentLocale];
        [_timeIntervalFormatter setTimeStyle:NSDateFormatterShortStyle];
        [_timeIntervalFormatter setDateStyle:NSDateFormatterMediumStyle];
        [_timeIntervalFormatter setDoesRelativeDateFormatting:YES];
        [_timeIntervalFormatter setLocale:locale];
    });
    
    NSString* pickupTime = booking[@"pickup_time"];
    NSDate* pt = [pickupTime dateFromRFC3339String];
    cell.timeLabel.text = [_timeIntervalFormatter stringFromDate:pt];
    
    [cell.pickupButton.imageView setContentMode:UIViewContentModeScaleAspectFit];
    [cell.dropoffButton.imageView setContentMode:UIViewContentModeScaleAspectFit];
    [cell.pickupAndDropoffButton.imageView setContentMode:UIViewContentModeScaleAspectFit];
    
    if (indexPath.row == _selectedRow)
    {
        cell.contentView.backgroundColor = [UIColor tableCellBackgroundSelectedColor];
    }
    else
    {
        if (indexPath.row & 1)
            cell.contentView.backgroundColor = [UIColor tableCellBackgroundDarkColor];
        else
            cell.contentView.backgroundColor = [UIColor tableCellBackgroundLightColor];
    }
    
    cell.index = indexPath.row;
    
    cell.cancellationBlock = ^(NSInteger index) {
        NSDictionary* booking = _bookings[index];
        __block NSInteger idx = index;
        
        [MessageDialog askConfirmation:NSLocalizedString(@"booking_cancel_confirmation_message", @"")
                             withTitle:NSLocalizedString(@"dialog_confirmation_title", @"")
                     confirmationBlock:^(){
                                 [self showPleaseWaitView];
                                 [[NetworkEngine getInstance] cancelBooking:booking[@"pk"]
                                                            completionBlock:^(NSObject *object)
                                  {
                                      _selectedRow = NSNotFound;
                                      [self.bookings removeObjectAtIndex:idx];
                                      [self showTableView];
                                      [self reloadData];
                                  }
                                                               failureBlock:^(NSError *error)
                                  {
                                      [MessageDialog showError:error.localizedDescription withTitle:NSLocalizedString(@"dialog_error_title", @"")];
                                      [self showTableView];
                                  }];
                             }];
    };
    
    cell.selectionBlock = ^(NSInteger index, BookingSelectionType type) {
        NSDictionary *booking = _bookings[index];
        NSString *pickupName = nil;
        NSString *pickupZipCode = nil;
        CLLocationCoordinate2D pickupCoordinate;
        NSString *dropoffName = nil;
        NSString *dropoffZipCode = nil;
        CLLocationCoordinate2D dropoffCoordinate = CLLocationCoordinate2DMake(0, 0);
        
        NSDictionary* pickup = booking[@"pickup_location"];
        NSDictionary* dropoff = booking[@"dropoff_location"];

        NSNumber* lat = pickup[@"location"][@"lat"];
        NSNumber* lng = pickup[@"location"][@"lng"];
        pickupCoordinate = CLLocationCoordinate2DMake([lat doubleValue], [lng doubleValue]);

        if (dropoff != nil && dropoff != (id)[NSNull null])
        {
            lat = dropoff[@"location"][@"lat"];
            lng = dropoff[@"location"][@"lng"];
            dropoffCoordinate = CLLocationCoordinate2DMake([lat doubleValue], [lng doubleValue]);
        }

        BOOL onlyShow = NO;
        
        switch (type)
        {
            case BookingSelectionTypePickupOnlyShow:
                onlyShow = YES;
            case BookingSelectionTypePickup:
            {
                pickupName = pickup[@"address"];
                pickupZipCode = pickup[@"postcode"];
            }
            break;

            case BookingSelectionTypeDropoffOnlyShow:
                onlyShow = YES;
            case BookingSelectionTypeDropoff:
            {
                dropoffName = dropoff[@"address"];
                dropoffZipCode = dropoff[@"postcode"];
            }
            break;

            case BookingSelectionTypePickupDropoff:
            {
                dropoffName = dropoff[@"address"];
                dropoffZipCode = dropoff[@"postcode"];
                pickupName = pickup[@"address"];
                pickupZipCode = pickup[@"postcode"];
            }
            break;
        }
        
        [_selectionDelegate selectedBookingWithPickup:pickupName
                                     andPickupZipCode:pickupZipCode
                                    andPickupLocation:pickupCoordinate
                                       andDropoffName:dropoffName
                                     andDropoffZipCode:dropoffZipCode
                                   andDropoffLocation:dropoffCoordinate
                                             onlyShow:onlyShow];
    };
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    [tableView beginUpdates];
    
    if (_selectedRow == indexPath.row)
    {
        _selectedRow = NSNotFound;
    }
    else
    {
        _selectedRow = indexPath.row;
    }

    [tableView reloadData];
    [tableView endUpdates];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return YES if you want the specified item to be editable.
    return NO;
}

- (void)viewDidUnload {
    [self setTableView:nil];
    [self setMessageView:nil];
    [self setErrorView:nil];
    [self setPleaseWaitView:nil];
    [self setErrorLabel:nil];
    [self setTryAgainButton:nil];
    [self setActivityIndicator:nil];
    [self setPleaseWaitLabel:nil];
    [self setNoBookingsLabel:nil];
    [super viewDidUnload];
}

- (IBAction)tryAgainButtonPressed:(id)sender {
    [self downloadBookings];
}

@end
