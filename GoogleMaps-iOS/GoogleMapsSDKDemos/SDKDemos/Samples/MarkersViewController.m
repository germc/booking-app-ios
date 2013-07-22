#import "MarkersViewController.h"
#import <GoogleMaps/GoogleMaps.h>

@implementation MarkersViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:-37.81969
                                                          longitude:144.966085
                                                               zoom:4];
  GMSMapView *mapView = [GMSMapView mapWithFrame:CGRectZero camera:camera];

  GMSMarker *sydneyMarker = [[GMSMarker alloc] init];
  sydneyMarker.title = @"Sydney";
  sydneyMarker.snippet = @"Population: 4,605,992";
  sydneyMarker.position = CLLocationCoordinate2DMake(-33.8683, 151.2086);
  sydneyMarker.map = mapView;

  GMSMarker *melbourneMarker = [[GMSMarker alloc] init];
  melbourneMarker.title = @"Melbourne";
  melbourneMarker.snippet = @"Population: 4,169,103";
  melbourneMarker.position = CLLocationCoordinate2DMake(-37.81969, 144.966085);
  melbourneMarker.map = mapView;

  // Set the marker in Sydney to be selected
  mapView.selectedMarker = sydneyMarker;

  self.view = mapView;
}

@end
