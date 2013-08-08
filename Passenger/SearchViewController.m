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


#import "SearchViewController.h"
#import "LocationSelectorViewController.h"
#import "LocationSelectionListViewController.h"

#import "DAPagesContainer.h"

@interface SearchViewController ()

@property (nonatomic, strong) DAPagesContainer* pagesContainer;

@end

@implementation SearchViewController

- (CGSize)contentSizeForViewInPopover
{
    return CGSizeMake(320, 320);
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.pagesContainer = [[DAPagesContainer alloc] init];
    [self.pagesContainer willMoveToParentViewController:self];
    self.pagesContainer.view.frame = self.view.bounds;
    self.pagesContainer.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:self.pagesContainer.view];
    [self.pagesContainer didMoveToParentViewController:self];

    LocationSelectorViewController* loc;
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:DEVICE_STORYBOARD
                                                         bundle:nil];
    loc = [storyboard instantiateViewControllerWithIdentifier:@"locationSelectorViewController"];
    loc.title = NSLocalizedString(@"address_search_page_search", @"");
    
    if ([CabOfficeSettings enableLocationSearchModules])
    {
        LocationSelectionListViewController* loc1;
        loc1 = [storyboard instantiateViewControllerWithIdentifier:@"locationSelectionListViewController"];
        loc1.title = NSLocalizedString(@"address_search_page_stations", @"");
        loc1.stationType = StationTypeTrain;
        
        MapAnnotation *a1 = [[MapAnnotation alloc] initWithCoordinate:CLLocationCoordinate2DMake(52.253708, 0.712454)
                                                            withTitle:@"Bury St Edmonds Station"
                                                        withImageName:nil
                                                          withZipCode:@"IP32 6AQ"];
        MapAnnotation *a2 = [[MapAnnotation alloc] initWithCoordinate:CLLocationCoordinate2DMake(51.736465, 0.468708)
                                                            withTitle:@"Chelmsford Station"
                                                        withImageName:nil
                                                          withZipCode:@"CM1 1HT"];
        MapAnnotation *a3 = [[MapAnnotation alloc] initWithCoordinate:CLLocationCoordinate2DMake(51.901230, 0.893736)
                                                            withTitle:@"Colchester Station"
                                                        withImageName:nil
                                                          withZipCode:@"CO4 5EY"];
        MapAnnotation *a4 = [[MapAnnotation alloc] initWithCoordinate:CLLocationCoordinate2DMake(52.391209, 0.265048)
                                                            withTitle:@"Ely Station"
                                                        withImageName:nil
                                                          withZipCode:@"CB7 4DJ"];
        MapAnnotation *a5 = [[MapAnnotation alloc] initWithCoordinate:CLLocationCoordinate2DMake(52.050720, 1.144216)
                                                            withTitle:@"Ipswich Station"
                                                        withImageName:nil
                                                          withZipCode:@"IP2 8AL"];
        MapAnnotation *a6 = [[MapAnnotation alloc] initWithCoordinate:CLLocationCoordinate2DMake(52.627151, 1.306835)
                                                            withTitle:@"Norwich Station"
                                                        withImageName:nil
                                                          withZipCode:@"NR1 1EH"];
        MapAnnotation *a7 = [[MapAnnotation alloc] initWithCoordinate:CLLocationCoordinate2DMake(51.666916, 0.383777)
                                                            withTitle:@"Ingatestone Station"
                                                        withImageName:nil
                                                          withZipCode:@"CM4 0BW"];
        
        loc1.places = @[a1, a2, a3, a4, a5, a6, a7];

        _pagesContainer.viewControllers = @[loc, loc1];
    }
    else
    {
        _pagesContainer.viewControllers =  @[loc];
    }

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    _pagesContainer.completionBlock = self.completionBlock;
    
    for (LocationSelectionBaseViewController *v in _pagesContainer.viewControllers)
    {
        v.completionBlock = self.completionBlock;
        v.annotation = self.annotation;
        v.locationType = self.locationType;
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
