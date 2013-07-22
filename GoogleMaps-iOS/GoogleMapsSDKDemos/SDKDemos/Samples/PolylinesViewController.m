#import "PolylinesViewController.h"
#import <GoogleMaps/GoogleMaps.h>

static CLLocationCoordinate2D kSydneyAustralia = {-33.866901, 151.195988};
static CLLocationCoordinate2D kHawaiiUSA = {21.291982, -157.821856};
static CLLocationCoordinate2D kFiji = {-18.142599, 178.431};
static CLLocationCoordinate2D kMountainViewUSA = {37.423802, -122.091859};

@implementation PolylinesViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:0
                                                          longitude:-180
                                                               zoom:3];
  GMSMapView *mapView = [GMSMapView mapWithFrame:CGRectZero camera:camera];

  // Create a 'normal' polyline.
  GMSPolyline *polyline = [[GMSPolyline alloc] init];
  GMSMutablePath *path = [GMSMutablePath path];
  [path addCoordinate:kSydneyAustralia];
  [path addCoordinate:kFiji];
  [path addCoordinate:kHawaiiUSA];
  [path addCoordinate:kMountainViewUSA];
  polyline.path = path;
  polyline.strokeColor = [UIColor redColor];
  polyline.strokeWidth = 2.f;
  polyline.zIndex = 15;  // above the larger geodesic line
  polyline.map = mapView;

  // Copy the previous polyline, change its color, and mark it as geodesic.
  polyline = [polyline copy];
  polyline.strokeColor = [UIColor blueColor];
  polyline.geodesic = YES;
  polyline.strokeWidth = 8.f;
  polyline.zIndex = 10;
  polyline.map = mapView;

  // Create a new polyline which is geodesic all the way from Sydney to SF.
  [path removeAllCoordinates];
  [path addCoordinate:kSydneyAustralia];
  [path addCoordinate:kMountainViewUSA];
  polyline = [GMSPolyline polylineWithPath:path];
  polyline.strokeColor = [UIColor greenColor];
  polyline.geodesic = YES;
  polyline.strokeWidth = 4.f;
  polyline.zIndex = 5;
  polyline.map = mapView;

  self.view = mapView;
}

@end