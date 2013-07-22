//
//  SGViewController.m
//  ViewPager
//
//  Copyright (c) 2012 Simon Grätzer
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

#import "SGAnnotatedPagerController.h"

#define TITLE_CONTROL_HEIGHT 28.0
#define TITLE_CONTROL_FONT_SIZE 15.0

@interface SGAnnotatedPagerController ()

@property (strong) NSMutableArray* titleLabels;

@end

@implementation SGAnnotatedPagerController
@synthesize scrollView, titleScrollView;
@dynamic pageIndex;

- (void)loadView {
    [super loadView];
    self.view.backgroundColor = [UIColor scrollViewTexturedBackgroundColor];
    
    if (IS_IPAD)
    {
        self.view.frame = CGRectMake(0,0, self.contentSizeForViewInPopover.width, self.contentSizeForViewInPopover.height);
    }
    
    NSLog(@"rect: %@", NSStringFromCGRect(self.view.frame));
    
    CGRect frame = CGRectMake(-2, -2, self.view.bounds.size.width+4, TITLE_CONTROL_HEIGHT+2);
    titleScrollView = [[UIScrollView alloc] initWithFrame:frame];
    titleScrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    titleScrollView.backgroundColor = [UIColor searchDialogBackgroundColor];
    [titleScrollView setCanCancelContentTouches:NO];
    titleScrollView.showsHorizontalScrollIndicator = NO;
    titleScrollView.clipsToBounds = YES;
    titleScrollView.scrollEnabled = YES;
    titleScrollView.userInteractionEnabled = NO;
    [titleScrollView.layer setBorderWidth:2.0];
    [titleScrollView.layer setBorderColor:[UIColor searchDialogSeparatorColor].CGColor ];
    
    frame = CGRectMake(0, TITLE_CONTROL_HEIGHT, self.view.bounds.size.width,
                                    self.view.bounds.size.height - TITLE_CONTROL_HEIGHT);
    scrollView = [[UIScrollView alloc] initWithFrame:frame];
    scrollView.delegate = self;
    scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight |
    UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    scrollView.autoresizesSubviews = YES;
    scrollView.backgroundColor = [UIColor searchDialogBackgroundColor];
    scrollView.canCancelContentTouches = NO;
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.clipsToBounds = YES;
    scrollView.scrollEnabled = YES;
    scrollView.pagingEnabled = YES;
    
    
    self.titleLabels = [[NSMutableArray alloc] initWithCapacity:5];
    
    UISwipeGestureRecognizer* swipeDown = [[UISwipeGestureRecognizer alloc] initWithTarget:self
                                                                                    action:@selector(onSwipeDown:)];
    [swipeDown setDirection:UISwipeGestureRecognizerDirectionDown];
    [self.view addGestureRecognizer:swipeDown];
    
    [self.view addSubview:scrollView];
    [self.view addSubview:titleScrollView];
    [self reloadPages];
}

- (void)onSwipeDown:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation duration:(NSTimeInterval)duration {
    _lockPageChange = YES;
    [self reloadPages];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    _lockPageChange = NO;
    [self setPageIndex:self.pageIndex animated:NO];
}

- (CGSize)contentSizeForViewInPopover
{
    return CGSizeMake(320, 480);
}

#pragma mark Add and remove
- (void)setViewControllers:(NSArray *)viewControllers animated:(BOOL)animated {
    if (self.childViewControllers.count > 0) {
        self.pageIndex = 0;
        for (UIViewController *vC in self.childViewControllers) {
            [vC willMoveToParentViewController:nil];
            [vC removeFromParentViewController];
        }
    }
    
    for (UIViewController *vC in viewControllers) {
        [self addChildViewController:vC];
        [vC didMoveToParentViewController:self];
    }
    if (self.scrollView)
        [self reloadPages];
    //TODO animations
}

#pragma mark Properties
- (void)setPageIndex:(NSUInteger)pageIndex {
    [self setPageIndex:pageIndex animated:NO];
}

- (void)setPageIndex:(NSUInteger)index animated:(BOOL)animated; {
    _pageIndex = index;
    /*
	 *	Change the scroll view
	 */
    CGRect frame = scrollView.frame;
    frame.origin.x = frame.size.width * index;
    frame.origin.y = 0;
	
    if (frame.origin.x < scrollView.contentSize.width) {
        [scrollView scrollRectToVisible:frame animated:animated];
    }
}

- (NSUInteger)pageIndex {
    return _pageIndex;
}

#pragma mark -
#pragma mark UIScrollViewDelegate stuff
- (void)scrollViewDidScroll:(UIScrollView *)_scrollView
{
    //The scrollview tends to scroll to a different page when the screen rotates
    if (_lockPageChange)
        return;
    
    CGFloat newXOff = (_scrollView.contentOffset.x/_scrollView.contentSize.width)
                        *0.5*titleScrollView.bounds.size.width*self.childViewControllers.count;
    titleScrollView.contentOffset = CGPointMake(newXOff, 0);
    
	/*
	 *	We switch page at 50% across
	 */
    CGFloat pageWidth = _scrollView.frame.size.width;
    int page = floor((_scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    _pageIndex = page;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)sv {
    static NSInteger previousPage = 0;
    CGFloat pageWidth = sv.frame.size.width;
    float fractionalPage = sv.contentOffset.x / pageWidth;
    NSInteger page = lround(fractionalPage);
    if (previousPage != page) {
        UIViewController* prev = self.childViewControllers[previousPage];
        [prev viewDidDisappear:YES];
        UIViewController* current = self.childViewControllers[page];
        [current viewDidAppear:YES];
        
        UILabel* clabel = _titleLabels[page];
        clabel.textColor = [UIColor searchDialogSelectedTitleColor];
        clabel.font = [UIFont semiboldOpenSansOfSize:TITLE_CONTROL_FONT_SIZE];
        UIView *blue = [clabel viewWithTag:100];
        blue.backgroundColor = [UIColor searchDialogSeparatorColor];


        UILabel* plabel = _titleLabels[previousPage];
        plabel.textColor = [UIColor searchDialogNotSelectedTitleColor];
        plabel.font = [UIFont lightOpenSansOfSize:TITLE_CONTROL_FONT_SIZE];
        blue = [plabel viewWithTag:100];
        blue.backgroundColor = [UIColor clearColor];

        previousPage = page;
    }
}

- (void)reloadPages {
    for (UIView *view in titleScrollView.subviews) {
        [view removeFromSuperview];
    }
    for (UIView *view in scrollView.subviews) {
        [view removeFromSuperview];
    }
    
    [_titleLabels removeAllObjects];
    
	CGFloat cx = 0;
    CGFloat titleItemWidth = titleScrollView.bounds.size.width/2;
    CGFloat dx = titleItemWidth/2;
    
    NSUInteger count = self.childViewControllers.count;
	for (NSUInteger i = 0; i < count; i++) {
        UIViewController *vC = [self.childViewControllers objectAtIndex:i];
        
        CGRect frame = CGRectMake(dx, 0, titleItemWidth, titleScrollView.bounds.size.height);
        UIView *view = [[UIView alloc]initWithFrame:frame];
        view.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        view.backgroundColor = [UIColor searchDialogBackgroundColor];
        UIFont *font = [UIFont semiboldOpenSansOfSize:TITLE_CONTROL_FONT_SIZE];
        CGSize size = [vC.title sizeWithFont:font];
        frame = CGRectMake(0.5*(frame.size.width - size.width),
                          0, size.width, frame.size.height);
        UILabel *l = [[UILabel alloc] initWithFrame:frame];
        l.backgroundColor = [UIColor clearColor];
        l.font = [UIFont lightOpenSansOfSize:TITLE_CONTROL_FONT_SIZE];
        l.text = vC.title;
        l.textColor = [UIColor searchDialogNotSelectedTitleColor];
        [view addSubview:l];

        UIView *blue = [[UIView alloc]initWithFrame:CGRectMake(0, frame.size.height - 4, frame.size.width, 4)];
        blue.backgroundColor = [UIColor clearColor];
        blue.tag = 100;
        [l addSubview:blue];

        [titleScrollView addSubview:view];
        dx += titleItemWidth;
        
        [_titleLabels addObject:l];
        
        view = vC.view;
		CGRect rect = view.frame;
		rect.origin.x = cx;
		rect.origin.y = 0;
		view.frame = rect;
		[scrollView addSubview:view];
		cx += scrollView.frame.size.width;
	}
	[titleScrollView setContentSize:CGSizeMake(dx+titleItemWidth/2, titleScrollView.bounds.size.height)];
	[scrollView setContentSize:CGSizeMake(cx, scrollView.bounds.size.height)];
    
    if (_titleLabels.count)
    {
        UILabel *l = _titleLabels[0];
        l.textColor = [UIColor searchDialogSelectedTitleColor];
        l.font = [UIFont semiboldOpenSansOfSize:TITLE_CONTROL_FONT_SIZE];
        UIView *blue = [l viewWithTag:100];
        blue.backgroundColor = [UIColor searchDialogSeparatorColor];
    }
}

@end
