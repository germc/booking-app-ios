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

#import "MyAccountViewController.h"

@interface MyAccountViewController ()

@property (weak, nonatomic) IBOutlet FlatButton *okButton;
@property (weak, nonatomic) IBOutlet UILabel *fullNameTitle;
@property (weak, nonatomic) IBOutlet UILabel *fullNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *phoneNumberTitle;
@property (weak, nonatomic) IBOutlet UILabel *phoneNumberLabel;
@property (weak, nonatomic) IBOutlet UILabel *emailAddressTitle;
@property (weak, nonatomic) IBOutlet UILabel *emailAddressLabel;
- (IBAction)okButtonPressed:(id)sender;

@end

@implementation MyAccountViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [_fullNameTitle setFont:[UIFont lightOpenSansOfSize:18]];
    [_fullNameTitle setTextColor:[UIColor accountTitleLabelColor]];
    [_fullNameTitle setText:NSLocalizedString(@"profile_name", @"")];
    
    [_phoneNumberTitle setFont:[UIFont lightOpenSansOfSize:18]];
    [_phoneNumberTitle setTextColor:[UIColor accountTitleLabelColor]];
    [_phoneNumberTitle setText:NSLocalizedString(@"profile_phone", @"")];
    
    [_emailAddressTitle setFont:[UIFont lightOpenSansOfSize:18]];
    [_emailAddressTitle setTextColor:[UIColor accountTitleLabelColor]];
    [_emailAddressTitle setText:NSLocalizedString(@"profile_email", @"")];
    
    [_fullNameLabel setFont:[UIFont lightOpenSansOfSize:24]];
    [_fullNameLabel setTextColor:[UIColor accountLabelColor]];
    [_fullNameLabel setText:[NSString stringWithFormat:@"%@ %@", _accountPreferences[@"first_name"], _accountPreferences[@"last_name"]]];
    
    [_phoneNumberLabel setFont:[UIFont lightOpenSansOfSize:24]];
    [_phoneNumberLabel setTextColor:[UIColor accountLabelColor]];
    NSString* phone = _accountPreferences[@"phone"];
    [_phoneNumberLabel setText:phone];
    
    [_emailAddressLabel setFont:[UIFont lightOpenSansOfSize:24]];
    [_emailAddressLabel setTextColor:[UIColor accountLabelColor]];
    NSString* email = _accountPreferences[@"email"];
    [_emailAddressLabel setText:email];

    [_okButton setTitle:NSLocalizedString(@"profile_button_ok", @"") forState:UIControlStateNormal];
    [_okButton setTitleColor:[UIColor buttonTextColor] forState:UIControlStateNormal];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setOkButton:nil];
    [self setFullNameTitle:nil];
    [self setFullNameLabel:nil];
    [self setPhoneNumberTitle:nil];
    [self setPhoneNumberLabel:nil];
    [self setEmailAddressTitle:nil];
    [self setEmailAddressLabel:nil];
    [super viewDidUnload];
}
- (IBAction)okButtonPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
