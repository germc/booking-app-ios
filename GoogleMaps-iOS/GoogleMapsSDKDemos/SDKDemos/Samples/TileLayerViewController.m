#import "TileLayerViewController.h"
#import <GoogleMaps/GoogleMaps.h>

@implementation TileLayerViewController {
  UISegmentedControl *switcher_;
  GMSMapView *mapView_;
  GMSTileLayer *tileLayer_;
  NSInteger floor_;
}

- (void)viewDidLoad {
  [super viewDidLoad];
  GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:37.78318
                                                          longitude:-122.403874
                                                               zoom:18];

  mapView_ = [GMSMapView mapWithFrame:CGRectZero camera:camera];
  mapView_.buildingsEnabled = NO;
  mapView_.indoorEnabled = NO;
  self.view = mapView_;

  // The possible floors that might be shown.
  NSArray *types = @[@"1", @"2", @"3"];

  // Create a UISegmentedControl that is the navigationItem's titleView.
  switcher_ = [[UISegmentedControl alloc] initWithItems:types];
  switcher_.selectedSegmentIndex = 0;
  switcher_.segmentedControlStyle = UISegmentedControlStyleBar;
  switcher_.autoresizingMask = UIViewAutoresizingFlexibleWidth;
  switcher_.frame =
      CGRectMake(0, 0, 300, switcher_.frame.size.height);
  self.navigationItem.titleView = switcher_;

  // Listen to touch events on the UISegmentedControl, force initial update.
  [switcher_ addTarget:self action:@selector(didChangeSwitcher)
      forControlEvents:UIControlEventValueChanged];
  [self didChangeSwitcher];
}

- (void)didChangeSwitcher {
  NSString *title =
      [switcher_ titleForSegmentAtIndex:switcher_.selectedSegmentIndex];
  NSInteger floor = [title integerValue];
  if (floor_ != floor) {
    // Clear existing tileLayer, if any.
    tileLayer_.map = nil;

    // Create a new GMSTileLayer with the new floor choice.
    GMSTileURLConstructor urls = ^(NSUInteger x, NSUInteger y, NSUInteger zoom) {
      NSString *url = [NSString stringWithFormat:@"http://www.gstatic.com/io2010maps/tiles/9/L%d_%d_%d_%d.png", floor, zoom, x, y];
      return [NSURL URLWithString:url];
    };
    tileLayer_ = [GMSURLTileLayer tileLayerWithURLConstructor:urls];
    tileLayer_.map = mapView_;
    floor_ = floor;
  }
}

@end
