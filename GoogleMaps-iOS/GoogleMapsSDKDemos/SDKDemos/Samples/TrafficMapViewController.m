#import "TrafficMapViewController.h"
#import <GoogleMaps/GoogleMaps.h>

@implementation TrafficMapViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:-33.868
                                                          longitude:151.2086
                                                               zoom:12];

  GMSMapView *mapView = [GMSMapView mapWithFrame:CGRectZero camera:camera];
  mapView.trafficEnabled = YES;
  self.view = mapView;
}

@end
