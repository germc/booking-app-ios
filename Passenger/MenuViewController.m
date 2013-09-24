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
@property (weak, nonatomic) IBOutlet UILabel *appVersionLabel;
@property (weak, nonatomic) IBOutlet UIView *menuView;

- (IBAction)logoutButtonPressed:(id)sender;

@property (nonatomic, strong) NSDictionary* officeData;

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
    
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];

    [_appVersionLabel setFont:[UIFont lightOpenSansOfSize:17]];
    [_appVersionLabel setText:[NSString stringWithFormat:@"v%@",version]];
    [_appVersionLabel setTextColor:[UIColor colorWithWhite:0.8 alpha:1.0]];
    
    [_myAccountButton setTitleFont:[UIFont lightOpenSansOfSize:31]];
    [_myAccountButton setButtonBackgroundColor:[UIColor clearColor]];
    [_myAccountButton setTitle:NSLocalizedString(@"menu_button_account", @"") forState:UIControlStateNormal];
    [_myAccountButton setTextAlignment:UITextAlignmentLeft];
    
    [_cabOfficeButton setTitleFont:[UIFont lightOpenSansOfSize:31]];
    [_cabOfficeButton setButtonBackgroundColor:[UIColor clearColor]];
    [_cabOfficeButton setTitle:NSLocalizedString(@"menu_button_cab_office", @"")forState:UIControlStateNormal];
    [_cabOfficeButton setTextAlignment:UITextAlignmentLeft];

    [_tourButton setTitleFont:[UIFont lightOpenSansOfSize:31]];
    [_tourButton setButtonBackgroundColor:[UIColor clearColor]];
    [_tourButton setTitle:NSLocalizedString(@"menu_button_tour", @"") forState:UIControlStateNormal];
    [_tourButton setTextAlignment:UITextAlignmentLeft];

    [_logoutButton setTitleFont:[UIFont lightOpenSansOfSize:31]];
    [_logoutButton setButtonBackgroundColor:[UIColor clearColor]];
    [_logoutButton setTitle:NSLocalizedString(@"menu_button_logout", @"") forState:UIControlStateNormal];
    [_logoutButton setTextAlignment:UITextAlignmentLeft];

    [[NetworkEngine getInstance] getFleetData:^(NSObject *o) {
                                                self.officeData = (NSDictionary *)o;
                                            }
                                          failureBlock:^(NSError * error) {
                                          }];

	// Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    _menuView.center = self.view.center;
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
    [self setAppVersionLabel:nil];
    [super viewDidUnload];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"showMyAccountViewController"])
    {
        MyAccountViewController* vc = segue.destinationViewController;
        vc.accountPreferences = [NetworkEngine getInstance].accountPreferences;
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
