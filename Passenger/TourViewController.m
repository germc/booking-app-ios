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

#import "TourViewController.h"
#import "SMPageControl.h"

@interface TourViewController () <UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet FlatButton *okButton;

@property (weak, nonatomic) IBOutlet UILabel *label1_1;
@property (weak, nonatomic) IBOutlet UILabel *label1_2;
@property (weak, nonatomic) IBOutlet UILabel *label2_1;
@property (weak, nonatomic) IBOutlet UILabel *label2_2;
@property (weak, nonatomic) IBOutlet UILabel *label3_1;
@property (weak, nonatomic) IBOutlet UILabel *label4_1;
@property (weak, nonatomic) IBOutlet SMPageControl *pageControl;

- (IBAction)buttonOkPressed:(id)sender;
@end

@implementation TourViewController

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
    
    _scrollView.delegate = self;
    
    [_label1_1 setFont:[UIFont lightOpenSansOfSize:17]];
    [_label1_1 setTextColor:[UIColor tourTextColor]];
    _label1_1.text = NSLocalizedString(@"tour_01_text_01", @"");
    [_label1_2 setFont:[UIFont lightOpenSansOfSize:17]];
    [_label1_2 setTextColor:[UIColor tourTextColor]];
    _label1_2.text = NSLocalizedString(@"tour_01_text_02", @"");
    [_label2_1 setFont:[UIFont lightOpenSansOfSize:17]];
    [_label2_1 setTextColor:[UIColor tourTextColor]];
    _label2_1.text = NSLocalizedString(@"tour_02_text_01", @"");
    [_label2_2 setFont:[UIFont lightOpenSansOfSize:17]];
    [_label2_2 setTextColor:[UIColor tourTextColor]];
    _label2_2.text = NSLocalizedString(@"tour_02_text_02", @"");
    [_label3_1 setFont:[UIFont lightOpenSansOfSize:17]];
    [_label3_1 setTextColor:[UIColor tourTextColor]];
    _label3_1.text = NSLocalizedString(@"tour_03_text_01", @"");
    [_label4_1 setFont:[UIFont lightOpenSansOfSize:17]];
    [_label4_1 setTextColor:[UIColor tourTextColor]];
    _label4_1.text = NSLocalizedString(@"tour_04_text_01", @"");
 
    [_okButton setTitle:NSLocalizedString(@"tour_button_ok", @"") forState:UIControlStateNormal];
    [_okButton setTitleColor:[UIColor buttonTextColor] forState:UIControlStateNormal];

    _pageControl.numberOfPages = 4;
    _pageControl.pageIndicatorTintColor = [UIColor blackColor];
    _pageControl.currentPageIndicatorTintColor = [UIColor lightGrayColor];
    
	// Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    NSInteger numberOfPages = 4;
    _scrollView.contentSize = CGSizeMake(_scrollView.frame.size.width * numberOfPages, _scrollView.frame.size.height);
    _scrollView.contentOffset = CGPointMake(0, 0);
    _pageControl.numberOfPages = numberOfPages;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setScrollView:nil];
    [self setPageControl:nil];
    [self setLabel1_2:nil];
    [self setLabel2_1:nil];
    [self setLabel2_2:nil];
    [self setLabel3_1:nil];
    [self setLabel4_1:nil];
    [self setOkButton:nil];
    [self setPageControl:nil];
    [super viewDidUnload];
}

- (void)scrollViewDidScroll: (UIScrollView *)sender
{
    CGFloat pageWidth = self.scrollView.frame.size.width;
    int page = floor((self.scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    self.pageControl.currentPage = page;
}

- (IBAction)buttonOkPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
