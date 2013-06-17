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

#import "CustomDialog.h"

@interface CustomDialog()

@property (nonatomic, strong) UIView* backgroundView;

@end

@implementation CustomDialog

- (id)initWithNibName:(NSString *)name
{
    self = [super init];
    if (self) {
        self.backgroundView = [[UIView alloc] init];
        _backgroundView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:136.0/255.0];
        [self addSubview:_backgroundView];

        NSArray* array = [[NSBundle mainBundle] loadNibNamed:name
                                                       owner:self
                                                     options:nil];
        
        self.contentView = [array objectAtIndex:0];
        
        [self.contentView.layer setCornerRadius:8.0];
        self.contentView.layer.masksToBounds = YES;
        
        [self.contentView.layer setBorderColor:[UIColor whiteColor].CGColor];
        [self.contentView.layer setBorderWidth:1.5];
                
        self.alpha = 0.0;
        self.hidden = YES;
    }
    return self;
}

- (void)show
{
    UIWindow* window = [[[UIApplication sharedApplication] delegate] window];

    self.frame = window.bounds;
    [window addSubview:self];
    
    self.hidden = NO;
    [UIView animateWithDuration:0.25 animations:^(void) {
        self.alpha = 1.0;
    }];
}

- (void)dismiss
{
    [UIView animateWithDuration:0.25 animations:^(void) {
        self.alpha = 0.0;
    } completion:^(BOOL finished) {
        if(finished) {
            [self removeFromSuperview];
        }
    }];
}

- (void)setContentView:(UIView *)view
{
    [_contentView removeFromSuperview];
    _contentView = view;
    [self addSubview:view];
    [self setNeedsLayout];
}

- (void)layoutSubviews
{
    CGSize size = self.bounds.size;
    CGSize s = _contentView.frame.size;
    
    _backgroundView.frame = self.bounds;
    _contentView.frame = CGRectMake((size.width - s.width) / 2, (size.height - s.height) / 2, s.width, s.height);
}

@end
