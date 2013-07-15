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

#import "CabOfficeViewController.h"
#import <MessageUI/MessageUI.h>

@interface CabOfficeViewController () <MFMailComposeViewControllerDelegate>

@property (weak, nonatomic) IBOutlet FlatButton *okButton;
@property (weak, nonatomic) IBOutlet UILabel *officeNameTitle;
@property (weak, nonatomic) IBOutlet UILabel *officeNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *phoneNumberTitle;
@property (weak, nonatomic) IBOutlet UILabel *emailAddressTitle;
@property (weak, nonatomic) IBOutlet FlatButton *phoneButton;
@property (weak, nonatomic) IBOutlet FlatButton *emailButton;

- (IBAction)okButtonPressed:(id)sender;
- (IBAction)phoneButtonPressed:(id)sender;
- (IBAction)emailButtonPressed:(id)sender;

@end

@implementation CabOfficeViewController

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
    
    [_officeNameTitle setFont:[UIFont lightOpenSansOfSize:18]];
    [_officeNameTitle setTextColor:[UIColor officeTitleLabelColor]];
    [_officeNameTitle setText:NSLocalizedString(@"office_name", @"")];
    
    [_phoneNumberTitle setFont:[UIFont lightOpenSansOfSize:18]];
    [_phoneNumberTitle setTextColor:[UIColor officeTitleLabelColor]];
    [_phoneNumberTitle setText:NSLocalizedString(@"office_phone", @"")];
    
    [_emailAddressTitle setFont:[UIFont lightOpenSansOfSize:18]];
    [_emailAddressTitle setTextColor:[UIColor officeTitleLabelColor]];
    [_emailAddressTitle setText:NSLocalizedString(@"office_email", @"")];
    
    [_officeNameLabel setFont:[UIFont lightOpenSansOfSize:24]];
    [_officeNameLabel setTextColor:[UIColor officeLabelColor]];
    [_officeNameLabel setText:_officeData[@"name"]];
    
    NSString* phone = _officeData[@"phone"];
    if (IS_NULL(phone) || phone.length == 0)
    {
        _phoneButton.hidden = YES;
        _phoneNumberTitle.hidden = YES;
    }
    else
    {
        [_phoneButton setTitle:phone forState:UIControlStateNormal];
    }

    NSString* email = _officeData[@"email"];
    if (IS_NULL(email) || email.length == 0)
    {
        _emailButton.hidden = YES;
        _emailAddressTitle.hidden = YES;
    }
    else
    {
        [_emailButton setTitle:email forState:UIControlStateNormal];
    }
    
    [_okButton setTitle:NSLocalizedString(@"office_button_ok", @"") forState:UIControlStateNormal];
    [_okButton setTitleColor:[UIColor buttonTextColor] forState:UIControlStateNormal];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setOkButton:nil];
    [self setOfficeNameTitle:nil];
    [self setOfficeNameLabel:nil];
    [self setPhoneNumberTitle:nil];
    [self setEmailAddressTitle:nil];
    [self setPhoneButton:nil];
    [self setEmailButton:nil];
    [super viewDidUnload];
}

- (IBAction)okButtonPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)phoneButtonPressed:(id)sender {
    NSString* phoneNumber = [_phoneButton titleForState:UIControlStateNormal];
    NSString *cleanedString = [[phoneNumber componentsSeparatedByCharactersInSet:[[NSCharacterSet characterSetWithCharactersInString:@"0123456789-+()"] invertedSet]] componentsJoinedByString:@""];
    NSURL *telURL = [NSURL URLWithString:[NSString stringWithFormat:@"tel:%@", cleanedString]];
    [[UIApplication sharedApplication] openURL:telURL];
}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
	// Notifies users about errors associated with the interface
	switch (result)
	{
		case MFMailComposeResultCancelled:
			break;
		case MFMailComposeResultSaved:
			break;
		case MFMailComposeResultSent:
			break;
		case MFMailComposeResultFailed:
			break;
			
		default:
			[MessageDialog showError:error.localizedDescription withTitle:NSLocalizedString(@"dialog_error_title", @"")];
			break;
	}
    
	[self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (IBAction)emailButtonPressed:(id)sender {
	if([MFMailComposeViewController canSendMail] == NO) {
		[MessageDialog showError:NSLocalizedString(@"office_failed_to_launch_mua", @"") withTitle:NSLocalizedString(@"dialog_error_title", @"")];
		return;
	}
	
	MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
	picker.mailComposeDelegate = self;
	
	[picker setSubject:NSLocalizedString(@"office_mail_title", @"")];
	[picker setToRecipients:@[[_emailButton titleForState:UIControlStateNormal]]];
	
	picker.navigationBar.barStyle = UIBarStyleBlack;
    picker.modalPresentationStyle = UIModalPresentationFormSheet;
    picker.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    
	[self presentViewController:picker animated:YES completion:^{
    }];
}

@end
