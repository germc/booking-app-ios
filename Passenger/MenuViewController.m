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

#import "MenuViewController.h"
#import "MyAccountViewController.h"
#import "CabOfficeViewController.h"
#import "UserSettings.h"

@interface MenuViewController ()

@property (weak, nonatomic) IBOutlet FlatButton *myAccountButton;
@property (weak, nonatomic) IBOutlet FlatButton *cabOfficeButton;
@property (weak, nonatomic) IBOutlet FlatButton *tourButton;
@property (weak, nonatomic) IBOutlet FlatButton *logoutButton;

- (IBAction)logoutButtonPressed:(id)sender;

@property (nonatomic, strong) NSDictionary* officeData;
@property (nonatomic, strong) NSDictionary* accountPreferences;

@end

@implementation MenuViewController

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
    
    [_myAccountButton setTitleFont:[UIFont lightOpenSansOfSize:31]];
    [_myAccountButton setButtonBackgroundColor:[UIColor clearColor]];
    [_myAccountButton setTitle:NSLocalizedString(@"menu_button_account", @"") forState:UIControlStateNormal];
    [_myAccountButton setTextAlignment:NSTextAlignmentLeft];
    
    [_cabOfficeButton setTitleFont:[UIFont lightOpenSansOfSize:31]];
    [_cabOfficeButton setButtonBackgroundColor:[UIColor clearColor]];
    [_cabOfficeButton setTitle:NSLocalizedString(@"menu_button_cab_office", @"")forState:UIControlStateNormal];
    [_cabOfficeButton setTextAlignment:NSTextAlignmentLeft];

    [_tourButton setTitleFont:[UIFont lightOpenSansOfSize:31]];
    [_tourButton setButtonBackgroundColor:[UIColor clearColor]];
    [_tourButton setTitle:NSLocalizedString(@"menu_button_tour", @"") forState:UIControlStateNormal];
    [_tourButton setTextAlignment:NSTextAlignmentLeft];

    [_logoutButton setTitleFont:[UIFont lightOpenSansOfSize:31]];
    [_logoutButton setButtonBackgroundColor:[UIColor clearColor]];
    [_logoutButton setTitle:NSLocalizedString(@"menu_button_logout", @"") forState:UIControlStateNormal];
    [_logoutButton setTextAlignment:NSTextAlignmentLeft];

    [[NetworkEngine getInstance] getAccountPreferences:^(NSObject *o) {
                                                self.accountPreferences = (NSDictionary *)o;
                                            }
                                          failureBlock:^(NSError * error) {
                                          }];

    [[NetworkEngine getInstance] getFleetData:^(NSObject *o) {
                                                self.officeData = (NSDictionary *)o;
                                            }
                                          failureBlock:^(NSError * error) {
                                          }];

	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setMyAccountButton:nil];
    [self setCabOfficeButton:nil];
    [self setTourButton:nil];
    [self setLogoutButton:nil];
    [super viewDidUnload];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"showMyAccountViewController"])
    {
        MyAccountViewController* vc = segue.destinationViewController;
        vc.accountPreferences = _accountPreferences;
    }
    else if ([segue.identifier isEqualToString:@"showCabOfficeViewController"])
    {
        CabOfficeViewController* vc = segue.destinationViewController;
        vc.officeData = _officeData;
    }
}

- (IBAction)logoutButtonPressed:(id)sender {
    [UserSettings setRefreshToken:nil];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

@end
