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

#import "LocationSelectionListViewController.h"

#import "MapAnnotation.h"

@interface LocationSelectionListViewController () <UITableViewDataSource, UITableViewDelegate>

@end

@implementation LocationSelectionListViewController

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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _places.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 48;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"locationSelectionListCell";
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    MapAnnotation *m = _places[indexPath.row];
    
    cell.textLabel.text = m.title;
    cell.textLabel.font = [UIFont lightOpenSansOfSize:13];
    cell.textLabel.textColor = [UIColor searchDialogTextColor];
    
    cell.imageView.contentMode = UIViewContentModeScaleAspectFit;
    
    switch(self.stationType)
    {
        case StationTypeTrain:
            cell.imageView.image = [UIImage imageNamed:@"station_type_train"];
            break;
        case StationTypeAirport:
            cell.imageView.image = [UIImage imageNamed:@"station_type_aairport"];
            break;
        case StationTypeBus:
            cell.imageView.image = [UIImage imageNamed:@"station_type_bus"];
            break;
        case StationTypeShip:
            cell.imageView.image = [UIImage imageNamed:@"station_type_ship"];
            break;
        default:
        case StationTypeDefault:
            cell.imageView.image = [UIImage imageNamed:@"station_type_default"];
            break;
    }
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    MapAnnotation* m = _places[indexPath.row];
    if (self.completionBlock)
    {
        self.completionBlock(self.locationType, m);
    }
}

@end
