#import "FitBoundsViewController.h"
#import <GoogleMaps/GoogleMaps.h>

@interface FitBoundsViewController () <GMSMapViewDelegate>
@end

@implementation FitBoundsViewController {
  GMSMapView *mapView_;
  NSMutableArray *markers_;
}

- (void)viewDidLoad {
  [super viewDidLoad];
  GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:-37.81969
                                                          longitude:144.966085
                                                               zoom:4];
  mapView_ = [GMSMapView mapWithFrame:CGRectZero camera:camera];
  mapView_.delegate = self;
  self.view = mapView_;

  // Add a default marker around Sydney.
  GMSMarker *sydneyMarker = [[GMSMarker alloc] init];
  sydneyMarker.title = @"Sydney!";
  sydneyMarker.icon = [UIImage imageNamed:@"glow-marker"];
  sydneyMarker.position = CLLocationCoordinate2DMake(-33.8683, 151.2086);
  sydneyMarker.map = mapView_;

  // Create a list of markers, adding the Sydney marker.
  markers_ = [NSMutableArray arrayWithObject:sydneyMarker];

  // Create a button that, when pressed, updates the camera to fit the bounds
  // of the specified markers.
  UIBarButtonItem *fitBoundsButton =
      [[UIBarButtonItem alloc] initWithTitle:@"Fit Bounds"
                                       style:UIBarButtonItemStylePlain
                                      target:self
                                      action:@selector(didTapFitBounds)];
  self.navigationItem.rightBarButtonItem = fitBoundsButton;
}

- (void)didTapFitBounds {
  GMSCoordinateBounds *bounds;
  for (GMSMarker *marker in markers_) {
    if (bounds == nil) {
      bounds = [[GMSCoordinateBounds alloc] initWithCoordinate:marker.position
                                                    coordinate:marker.position];
    }
    bounds = [bounds includingCoordinate:marker.position];
  }
  GMSCameraUpdate *update = [GMSCameraUpdate fitBounds:bounds
                                           withPadding:50.0f];
  [mapView_ moveCamera:update];
}

#pragma mark - GMSMapViewDelegate

- (void)mapView:(GMSMapView *)mapView
    didLongPressAtCoordinate:(CLLocationCoordinate2D)coordinate {
  GMSMarker *marker = [[GMSMarker alloc] init];
  marker.title = [NSString stringWithFormat:@"Marker at: %.2f,%.2f",
                  coordinate.latitude, coordinate.longitude];
  marker.position = coordinate;
  marker.animated = YES;
  marker.map = mapView_;

  // Add the new marker to the list of markers.
  [markers_ addObject:marker];
}

@end
