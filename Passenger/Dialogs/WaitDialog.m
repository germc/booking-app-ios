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

#import "WaitDialog.h"

@interface WaitDialog()

@property (weak, nonatomic) IBOutlet UILabel *waitLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@end

@implementation WaitDialog

- (id)init
{
    self = [super initWithNibName:@"WaitDialog"];
    if (self) {
    }
    return self;
}

- (void)show
{
    self.contentView.backgroundColor = [UIColor dialogBackgroundColor];
    
    _waitLabel.font = [UIFont lightOpenSansOfSize:20];
    _waitLabel.text = NSLocalizedString(@"tdfragment_please_wait", @"");
    _waitLabel.textColor = [UIColor buttonTextColor];
    
    [_activityIndicator startAnimating];
    
    [super show];
}

@end
