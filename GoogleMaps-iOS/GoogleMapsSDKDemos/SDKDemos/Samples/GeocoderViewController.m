#import "GeocoderViewController.h"
#import <GoogleMaps/GoogleMaps.h>

@implementation GeocoderViewController {
  GMSMapView *mapView_;
  GMSGeocoder *geocoder_;
}

- (void)viewDidLoad {
  [super viewDidLoad];
  GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:-33.868
                                                          longitude:151.2086
                                                               zoom:12];

  mapView_ = [GMSMapView mapWithFrame:CGRectZero camera:camera];
  mapView_.delegate = self;

  geocoder_ = [[GMSGeocoder alloc] init];

  self.view = mapView_;
}

- (void)mapView:(GMSMapView *)mapView
    didLongPressAtCoordinate:(CLLocationCoordinate2D)coordinate {
  // On a long press, reverse geocode this location.
  GMSReverseGeocodeCallback handler = ^(GMSReverseGeocodeResponse *response,
                                        NSError *error) {
    if (response && response.firstResult) {
      GMSMarker *marker = [[GMSMarker alloc] init];
      marker.position = coordinate;
      marker.title = response.firstResult.addressLine1;
      marker.snippet = response.firstResult.addressLine2;
      marker.animated = YES;
      marker.map = mapView_;
    } else {
      NSLog(@"Could not reverse geocode point (%f,%f): %@",
          coordinate.latitude, coordinate.longitude, error);
    }
  };
  [geocoder_ reverseGeocodeCoordinate:coordinate
                    completionHandler:handler];
}

@end
