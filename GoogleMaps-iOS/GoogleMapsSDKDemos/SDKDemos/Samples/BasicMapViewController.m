#import "BasicMapViewController.h"
#import <GoogleMaps/GoogleMaps.h>

@implementation BasicMapViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:-33.868
                                                          longitude:151.2086
                                                               zoom:6];
  self.view = [GMSMapView mapWithFrame:CGRectZero camera:camera];
}

@end
