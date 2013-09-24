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

#import "StartViewController.h"
#import "LoginViewController.h"
#import "CreateAccountViewController.h"
#import "UserSettings.h"

@interface StartViewController () <LoginProtocolDelegate, UIPopoverControllerDelegate>
{
    UIPopoverController* _popover;
    BOOL _getAccessToken;
    NSInteger _tapCount;
}

@property (weak, nonatomic) IBOutlet FlatButton *signInButton;
@property (weak, nonatomic) IBOutlet FlatButton *registerButton;
@property (weak, nonatomic) IBOutlet UIView *demoView;
@property (weak, nonatomic) IBOutlet UILabel *demoLabel;
@property (weak, nonatomic) IBOutlet UIImageView *logoImageView;
@property (weak, nonatomic) IBOutlet UILabel *codeSignatureLabel;

@end

@implementation StartViewController

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
    
    [_signInButton setTitle:NSLocalizedString(@"main_login", @"") forState:UIControlStateNormal];
    [_signInButton setTitleColor:[UIColor buttonTextColor] forState:UIControlStateNormal];
    [_registerButton setTitle:NSLocalizedString(@"main_register", @"") forState:UIControlStateNormal];
    [_registerButton setTitleColor:[UIColor buttonTextColor] forState:UIControlStateNormal];

    _demoView.backgroundColor = [UIColor demoWarningBackgroundColor];
    _demoLabel.textColor = [UIColor demoWarningTextColor];
    _demoLabel.numberOfLines = 0;
    _demoLabel.text = NSLocalizedString(@"demo_warning", @"");
    
    CGFloat fontSize = [_demoLabel.text fontSizeWithFont:[UIFont lightOpenSansOfSize:14] constrainedToSize:_demoLabel.bounds.size];
    _demoLabel.font = [UIFont lightOpenSansOfSize:fontSize];
    
    if ([CabOfficeSettings hideDemoWarning])
    {
        _demoView.hidden = YES;
    }
    else
    {
        _demoView.hidden = NO;
    }
    
    _getAccessToken = YES;
    
    _logoImageView.userInteractionEnabled = YES;
    UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc] init];
    [tap addTarget:self action:@selector(tapGesture:)];
    tap.numberOfTapsRequired = 1;
    [_logoImageView addGestureRecognizer:tap];

    _codeSignatureLabel.hidden = YES;
    [_codeSignatureLabel setFont:[UIFont lightOpenSansOfSize:14]];
    [_codeSignatureLabel setTextColor:[UIColor blackColor]];
    
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];

    version = [NSString stringWithFormat:@"v%@ (%@)", version, @"2013092400"];
    [_codeSignatureLabel setText:version];
    
    
    _tapCount = 0;
}

- (void)tapGesture:(UITapGestureRecognizer*)gesture
{
    _tapCount++;
    if (_tapCount == 5)
    {
        _codeSignatureLabel.hidden = NO;
    }
    NSLog(@"logo image tap, count: %d", _tapCount);
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (![UserSettings tourHasBeenShown] && !IS_IPAD)
    {
        [self performSegueWithIdentifier:@"showTourViewController" sender:self];
        [UserSettings setTourHasBeenShown:YES];
    }
    
    if ([UserSettings refreshToken] && _getAccessToken)
    {
        [self getAccessTokenAndShowMainScreen];
    }
}


- (void) getAccessTokenAndShowMainScreen
{
    __block WaitDialog* wait = [[WaitDialog alloc] init];
    [wait show];
    [[NetworkEngine getInstance] getAccessTokenForRefreshToken:[UserSettings refreshToken]
                                               completionBlock:^(NSObject *o) {
                                                   [[NetworkEngine getInstance] getAccountPreferences:^(NSObject* response)
                                                    {
                                                        [wait dismiss];
                                                        [self performSegueWithIdentifier:@"showMainViewController" sender:self];
                                                    }
                                                                                         failureBlock:^(NSError *error)
                                                    {
                                                        [wait dismiss];
                                                        [MessageDialog showError:error.localizedDescription withTitle:NSLocalizedString(@"dialog_error_title", @"")];
                                                    }];
                                               }
                                                  failureBlock:^(NSError *e){
                                                      [wait dismiss];
                                                      [UserSettings setRefreshToken:nil];
                                                  }];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setSignInButton:nil];
    [self setRegisterButton:nil];
    [self setDemoView:nil];
    [self setDemoLabel:nil];
    [self setLogoImageView:nil];
    [self setCodeSignatureLabel:nil];
    [super viewDidUnload];
}

- (void)setPopoverDelegate:(UIStoryboardSegue *)segue
{
    if (IS_IPAD)
    {
        _popover = [(UIStoryboardPopoverSegue *)segue popoverController];
        _popover.delegate = self;
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showLoginViewController"])
    {
        LoginViewController* lvc = segue.destinationViewController;
        [self setPopoverDelegate:segue];
        lvc.delegate = self;
    }
    else if ([[segue identifier] isEqualToString:@"showCreateAccountViewController"])
    {
        CreateAccountViewController* cavc = segue.destinationViewController;
        [self setPopoverDelegate:segue];
        cavc.delegate = self;
    }
}

#pragma mark LoginProtocolDelegate

- (void)loginFailed:(NSError *)error
{
    [MessageDialog showError:error.localizedDescription withTitle:NSLocalizedString(@"dialog_error_title", @"")];
}

- (void)showMainViewController:(BOOL)accessTokenAvailable
{
    if (accessTokenAvailable)
    {
        __block WaitDialog* wait = [[WaitDialog alloc] init];
        [wait show];
        [[NetworkEngine getInstance] getAccountPreferences:^(NSObject* response)
         {
             [wait dismiss];
             [self performSegueWithIdentifier:@"showMainViewController" sender:self];
         }
                                              failureBlock:^(NSError *error)
         {
             [wait dismiss];
             [MessageDialog showError:error.localizedDescription withTitle:NSLocalizedString(@"dialog_error_title", @"")];
         }];
    }
    else
    {
        [self getAccessTokenAndShowMainScreen];
    }
}

- (void)loginFinished:(BOOL)withAccessToken
{
    _getAccessToken = NO;
    
    //ignore the object it is saved in networkengine
    if (IS_IPAD)
    {
        [_popover dismissPopoverAnimated:YES];
        [self showMainViewController:withAccessToken];
    }
    else
    {
        [self.navigationController dismissViewControllerAnimated:YES completion:^{
            [self showMainViewController:withAccessToken];
        }];
    }
}

#pragma mark UIPopoverControllerDelegate
- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    _popover = nil;
}

@end
