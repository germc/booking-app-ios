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

#import "CreateAccountViewController.h"
#import "FlatCheckMark.h"

@interface CreateAccountViewController () <UITextFieldDelegate, UIGestureRecognizerDelegate>
{
    UITextField* _activeField;
}

@property (weak, nonatomic) IBOutlet FlatButton *createAccountButton;
@property (weak, nonatomic) IBOutlet FlatButton *cancelButton;

@property (weak, nonatomic) IBOutlet UIView *firstNameView;
@property (weak, nonatomic) IBOutlet UITextField *firstNameTextField;
@property (weak, nonatomic) IBOutlet UIView *lastNameView;
@property (weak, nonatomic) IBOutlet UITextField *lastNameTextField;
@property (weak, nonatomic) IBOutlet UIView *phoneNumberView;
@property (weak, nonatomic) IBOutlet UITextField *phoneNumberTextField;
@property (weak, nonatomic) IBOutlet UIView *emailView;
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UIView *passwordView;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UIView *confirmPasswordView;
@property (weak, nonatomic) IBOutlet UITextField *confirmPasswordTextField;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@property (nonatomic, strong) WaitDialog* waitDialog;
@property (weak, nonatomic) IBOutlet FlatCheckMark *tosCheckMark;
@property (weak, nonatomic) IBOutlet UILabel *tosLabel;
@property (weak, nonatomic) IBOutlet FlatButton *tosShowButton;

- (IBAction)cancelButtonPressed:(id)sender;
- (IBAction)createAccountButtonPressed:(id)sender;
- (IBAction)showTosButtonPressed:(id)sender;

@end

@implementation CreateAccountViewController

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
    
    if ([CabOfficeSettings tosMustAcceptOnSignup])
    {
        [_tosLabel setFont:[UIFont lightOpenSansOfSize:13]];
        [_tosLabel setTextColor:[UIColor blackColor]];
        [_tosLabel setText:NSLocalizedString(@"register_form_terms_and_conditions", @"")];
        _tosLabel.numberOfLines = 2;

        [_tosShowButton setTitle:NSLocalizedString(@"register_form_button_show_terms_and_conditions", @"") forState:UIControlStateNormal];
        [_tosShowButton setTitleColor:[UIColor colorWithRed:58.0/255.0 green:176.0/255.0 blue:215.0/255.0 alpha:1.0] forState:UIControlStateNormal];
        [_tosShowButton setButtonBackgroundColor:[UIColor clearColor]];
        [_tosShowButton setTitleFont:[UIFont lightOpenSansOfSize:13]];
        if (IS_IPAD)
        {
            [_tosShowButton setTextAlignment:UITextAlignmentRight];
        }
        
        _tosCheckMark.checked = NO;
        
    }
    else
    {
        _tosCheckMark.hidden = YES;
        _tosLabel.hidden = YES;
        _tosShowButton.hidden = YES;
        _tosCheckMark.checked = YES; //to avoid additional check for tosMustAccept later.
    }
    
    _firstNameView.backgroundColor = [UIColor textFieldBackgroundColor];
    _firstNameTextField.font = [UIFont lightOpenSansOfSize:17];
    _firstNameTextField.placeholder = NSLocalizedString(@"register_form_first_name_hint", @"");
    
    _lastNameView.backgroundColor = [UIColor textFieldBackgroundColor];
    _lastNameTextField.font = [UIFont lightOpenSansOfSize:17];
    _lastNameTextField.placeholder =  NSLocalizedString(@"register_form_last_name_hint", @"");

    _phoneNumberView.backgroundColor = [UIColor textFieldBackgroundColor];
    _phoneNumberTextField.font = [UIFont lightOpenSansOfSize:17];
    _phoneNumberTextField.placeholder =  NSLocalizedString(@"register_form_phone_hint", @"");

    _emailView.backgroundColor = [UIColor textFieldBackgroundColor];
    _emailTextField.font = [UIFont lightOpenSansOfSize:17];
    _emailTextField.placeholder =  NSLocalizedString(@"register_form_email_hint", @"");

    _passwordView.backgroundColor = [UIColor textFieldBackgroundColor];
    _passwordTextField.font = [UIFont lightOpenSansOfSize:17];
    _passwordTextField.placeholder =  NSLocalizedString(@"register_form_password_1_hint", @"");

    _confirmPasswordView.backgroundColor = [UIColor textFieldBackgroundColor];
    _confirmPasswordTextField.font = [UIFont lightOpenSansOfSize:17];
    _confirmPasswordTextField.placeholder =  NSLocalizedString(@"register_form_password_2_hint", @"");
    
    [_createAccountButton setTitleColor:[UIColor buttonTextColor] forState:UIControlStateNormal];
    [_createAccountButton setTitle: NSLocalizedString(@"register_form_button_register", @"") forState:UIControlStateNormal];

    [_cancelButton setTitleColor:[UIColor buttonTextColor] forState:UIControlStateNormal];
    [_cancelButton setTitle: NSLocalizedString(@"register_form_button_cancel", @"") forState:UIControlStateNormal];

    UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc] init];
    [tap addTarget:self action:@selector(tapGesture:)];
    tap.delegate = self;
    tap.numberOfTapsRequired = 1;
    [self.view addGestureRecognizer:tap];
    
    self.waitDialog = [[WaitDialog alloc] init];
    
	// Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardDidShowNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];
}

// Called when the UIKeyboardDidShowNotification is sent.
- (void)keyboardWasShown:(NSNotification*)aNotification
{
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    _scrollView.contentInset = UIEdgeInsetsMake(0, 0, kbSize.height, 0);
    _scrollView.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0, kbSize.height, 0);
    
    CGFloat y = [_activeField convertPoint:_activeField.frame.origin toView:_scrollView].y;
    
    CGPoint scrollPoint = CGPointMake(0.0, y - _firstNameView.frame.origin.y - 8);
    [_scrollView setContentOffset:scrollPoint animated:YES];
}

// Called when the UIKeyboardWillHideNotification is sent
- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    _scrollView.contentInset = contentInsets;
    _scrollView.scrollIndicatorInsets = contentInsets;
    [_scrollView setContentOffset:CGPointZero animated:YES];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (_scrollView.contentInset.bottom)
    {
        CGFloat y = [textField convertPoint:textField.frame.origin toView:_scrollView].y;

        CGPoint scrollPoint = CGPointMake(0.0, y - _firstNameView.frame.origin.y - 8);
        [_scrollView setContentOffset:scrollPoint animated:YES];
    }
    _activeField = textField;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    _activeField = nil;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
    
    if ([touch.view isKindOfClass:[UIButton class]]) {
        return NO;
    }
    return YES;
}

- (void)tapGesture:(UITapGestureRecognizer*)gesture
{
    [_firstNameTextField resignFirstResponder];
    [_lastNameTextField resignFirstResponder];
    [_emailTextField resignFirstResponder];
    [_phoneNumberTextField resignFirstResponder];
    [_passwordTextField resignFirstResponder];
    [_confirmPasswordTextField resignFirstResponder];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)cancelButtonPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)createAccountButtonPressed:(id)sender {

    [self tapGesture:nil]; //hide keyboard!

    if (_tosCheckMark.checked == NO)
    {
        NSString* title = NSLocalizedString(@"dialog_error_title", @"");
        [MessageDialog showError:NSLocalizedString(@"register_form_dialog_error_tos", @"") withTitle:title];
        return;
    }
    
    NSString* title = NSLocalizedString(@"dialog_error_title", @"");
    
    if (_firstNameTextField.text.length == 0)
    {
        [MessageDialog showError:NSLocalizedString(@"register_form_dialog_error_first_name", @"") withTitle:title];
        return;
    }
    else if (_lastNameTextField.text.length == 0)
    {
        [MessageDialog showError:NSLocalizedString(@"register_form_dialog_error_last_name", @"") withTitle:title];
        return;
    }
    else if (_phoneNumberTextField.text.length == 0)
    {
        [MessageDialog showError:NSLocalizedString(@"register_form_dialog_error_phone", @"") withTitle:title];
        return;
    }
    else if (_emailTextField.text.length == 0)
    {
        [MessageDialog showError:NSLocalizedString(@"register_form_dialog_error_email", @"") withTitle:title];
        return;
    }
    else if (_passwordTextField.text.length == 0)
    {
        [MessageDialog showError:NSLocalizedString(@"register_form_dialog_error_password", @"") withTitle:title];
        return;
    }
    else if (![_passwordTextField.text isEqualToString:_confirmPasswordTextField.text])
    {
        [MessageDialog showError:NSLocalizedString(@"register_form_dialog_error_password_verification", @"") withTitle:title];
        return;
    }
    
    [_waitDialog show];
    
    [[NetworkEngine getInstance] createAccount:_firstNameTextField.text
                                      lastName:_lastNameTextField.text
                                         email:_emailTextField.text
                                         phone:_phoneNumberTextField.text
                                      password:_passwordTextField.text
                               completionBlock:^(NSObject *o) {
                                   [_delegate loginFinished:YES];
                                   [_waitDialog dismiss];
                               }
                                  failureBlock:^(NSError *e) {
                                      [_waitDialog dismiss];
                                      [MessageDialog showError:e.localizedDescription withTitle:NSLocalizedString(@"dialog_error_title", @"")];
                                  }];
}

- (IBAction)showTosButtonPressed:(id)sender {
    NSURL *url = [NSURL URLWithString:[CabOfficeSettings tosUrl]];
    [[UIApplication sharedApplication] openURL:url];
}

- (void)viewDidUnload {
    [self setCreateAccountButton:nil];
    [self setFirstNameView:nil];
    [self setFirstNameTextField:nil];
    [self setLastNameView:nil];
    [self setLastNameTextField:nil];
    [self setPhoneNumberView:nil];
    [self setPhoneNumberTextField:nil];
    [self setEmailView:nil];
    [self setEmailTextField:nil];
    [self setPasswordView:nil];
    [self setPasswordTextField:nil];
    [self setConfirmPasswordView:nil];
    [self setConfirmPasswordTextField:nil];
    [self setCancelButton:nil];
    [self setScrollView:nil];
    [self setTosCheckMark:nil];
    [self setTosLabel:nil];
    [self setTosShowButton:nil];
    [super viewDidUnload];
}
@end
