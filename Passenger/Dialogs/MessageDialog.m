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

#import "MessageDialog.h"

@interface MessageDialog()

@property (weak, nonatomic) IBOutlet UIButton *header;
@property (weak, nonatomic) IBOutlet FlatButton *okButton;
@property (weak, nonatomic) IBOutlet FlatButton *yesButton;
@property (weak, nonatomic) IBOutlet FlatButton *noButton;
@property (weak, nonatomic) IBOutlet UITextView *textView;

@property (strong, nonatomic) NSString* dialogMessage;
@property (strong, nonatomic) NSString* dialogTitle;
@property (copy, nonatomic) MessageDialogConfirmationBlock confirmationBlock;
@property (assign, nonatomic) BOOL confirmationDialog;

- (IBAction)okButtonPressed:(id)sender;
- (IBAction)yesButtonPressed:(id)sender;
- (IBAction)noButtonPressed:(id)sender;

@end

@implementation MessageDialog

- (id)initWithTitle:(NSString *)title andMessage:(NSString *)message;
{
    self = [super initWithNibName:@"MessageDialog"];
    if (self) {
        self.dialogMessage = message;
        self.dialogTitle = title;
    }
    return self;
}

+ (MessageDialog*) showMessage:(NSString *)message
                     withTitle:(NSString *)title
{
    MessageDialog* dialog = [[MessageDialog alloc] initWithTitle:title
                                                      andMessage:message];
    dialog.header.backgroundColor = [UIColor dialogHeaderColor];
    dialog.confirmationDialog = NO;
    [dialog show];
    return dialog;
}

+ (MessageDialog*) showError:(NSString *)message
                   withTitle:(NSString *)title
{
    MessageDialog* dialog = [[MessageDialog alloc] initWithTitle:title
                                                      andMessage:message];
    dialog.header.backgroundColor = [UIColor dialogHeaderErrorColor];
    dialog.confirmationDialog = NO;
    [dialog show];
    return dialog;
}

+ (MessageDialog*) askConfirmation:(NSString *)message
                         withTitle:(NSString *)title
                 confirmationBlock:(MessageDialogConfirmationBlock)confirmationBlock
{
    MessageDialog* dialog = [[MessageDialog alloc] initWithTitle:title
                                                      andMessage:message];
    dialog.header.backgroundColor = [UIColor dialogConfirmationColor];
    dialog.confirmationDialog = YES;
    dialog.confirmationBlock = confirmationBlock;
    [dialog show];
    return dialog;
}

- (void)show
{
    UIFont *font = [UIFont lightOpenSansOfSize:17];
    
    self.contentView.backgroundColor = [UIColor dialogBackgroundColor];
    
    [_textView setTextColor:[UIColor dialogTextColor]];
    [_textView setFont:font];
    [_textView setBackgroundColor:[UIColor dialogBackgroundColor]];
    [_textView setText:_dialogMessage];

    CGSize cr = _textView.contentSize;

#define SPACE 50
    
    NSInteger height = cr.height;
    if (height > 200) height = 200;

    CGRect frame = _textView.frame;
    frame.size.height = height;
    frame.origin.y += (SPACE/2);
    _textView.frame = frame;
    
    frame = self.contentView.frame;
    frame.size.height = height + 60 + 60 + SPACE; //button and header height + space
    self.contentView.frame = frame;
    
    [_header setTitle:_dialogTitle forState:UIControlStateNormal];
    [_header setTitleColor:[UIColor dialogHeaderTextColor] forState:UIControlStateNormal];
    [_header.titleLabel setFont:[UIFont lightOpenSansOfSize:20]];

    frame = _okButton.frame;
    frame.origin.y = _textView.frame.origin.y + _textView.frame.size.height + (SPACE/2);
    _okButton.frame = frame;
    [_okButton setTitleFont:[UIFont lightOpenSansOfSize:20]];
    [_okButton setTitle:NSLocalizedString(@"dialog_button_ok", @"") forState:UIControlStateNormal];

    frame = _noButton.frame;
    frame.origin.y = _textView.frame.origin.y + _textView.frame.size.height + (SPACE/2);
    _noButton.frame = frame;
    [_noButton setTitleFont:[UIFont lightOpenSansOfSize:20]];
    [_noButton setTitle:NSLocalizedString(@"dialog_button_no", @"") forState:UIControlStateNormal];

    frame = _yesButton.frame;
    frame.origin.y = _textView.frame.origin.y + _textView.frame.size.height + (SPACE/2);
    _yesButton.frame = frame;
    [_yesButton setTitleFont:[UIFont lightOpenSansOfSize:20]];
    [_yesButton setTitle:NSLocalizedString(@"dialog_button_yes", @"") forState:UIControlStateNormal];

    if (_confirmationDialog)
    {
        _yesButton.hidden = NO;
        _noButton.hidden = NO;
        _okButton.hidden = YES;
    }
    else
    {
        _yesButton.hidden = YES;
        _noButton.hidden = YES;
        _okButton.hidden = NO;
    }

    [super show];
}

- (IBAction)okButtonPressed:(id)sender
{
    [self dismiss];
}

- (IBAction)noButtonPressed:(id)sender
{
    [self dismiss];
}

- (IBAction)yesButtonPressed:(id)sender
{
    if (_confirmationBlock)
        _confirmationBlock();
    [self dismiss];
}

@end
