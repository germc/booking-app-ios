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

#import "MainViewController.h"
#import "HistoryViewController.h"
#import "MapViewController.h"

@interface MainViewController ()
@end

@implementation MainViewController

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

    UIViewController* left;
    HistoryViewController *right;
    MapViewController *front;
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:DEVICE_STORYBOARD
                                                         bundle:nil];
    left = [storyboard instantiateViewControllerWithIdentifier:@"menuViewController"];
    right = [storyboard instantiateViewControllerWithIdentifier:@"historyViewController"];
    front = [storyboard instantiateViewControllerWithIdentifier:@"mapViewController"];
    
    right.selectionDelegate = front;

    self.leftViewController = left;
    self.rightViewController = right;
    self.frontViewController = front;
    [self setMinimumWidth:270.0 maximumWidth:300.0 forViewController:self.leftViewController];
    [self setMinimumWidth:270.0 maximumWidth:300.0 forViewController:self.rightViewController];

    // Do any additional setup after loading the view.
}

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)orientation{
    if(orientation == UIInterfaceOrientationPortrait || orientation == UIInterfaceOrientationPortraitUpsideDown)
    {
        return YES;
    }
    return NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
