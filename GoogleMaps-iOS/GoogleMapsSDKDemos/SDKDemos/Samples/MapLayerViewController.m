#import "MapLayerViewController.h"
#import <GoogleMaps/GoogleMaps.h>

@implementation MapLayerViewController {
  GMSMapView *mapView_;
}

- (void)viewDidLoad {
  [super viewDidLoad];
  GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:-37.81969
                                                          longitude:144.966085
                                                               zoom:4];
  mapView_ = [GMSMapView mapWithFrame:CGRectZero camera:camera];
  self.view = mapView_;

  dispatch_async(dispatch_get_main_queue(), ^{
    mapView_.myLocationEnabled = YES;
  });

  UIBarButtonItem *myLocationButton =
      [[UIBarButtonItem alloc] initWithTitle:@"Fly to My Location"
                                       style:UIBarButtonItemStylePlain
                                      target:self
                                      action:@selector(didTapMyLocation)];
  self.navigationItem.rightBarButtonItem = myLocationButton;

}

- (void)didTapMyLocation {
  CLLocation *location = mapView_.myLocation;
  if (!location || !CLLocationCoordinate2DIsValid(location.coordinate)) {
    return;
  }

  // Access the GMSMapLayer directly to modify the following properties with a
  // specified timing function and duration.

  CAMediaTimingFunction *curve =
      [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
  CABasicAnimation *animation;

  animation = [CABasicAnimation animationWithKeyPath:kGMSLayerCameraLatitudeKey];
  animation.duration = 2.0f;
  animation.timingFunction = curve;
  animation.toValue = @(location.coordinate.latitude);
  [mapView_.layer addAnimation:animation forKey:kGMSLayerCameraLatitudeKey];

  animation = [CABasicAnimation animationWithKeyPath:kGMSLayerCameraLongitudeKey];
  animation.duration = 2.0f;
  animation.timingFunction = curve;
  animation.toValue = @(location.coordinate.longitude);
  [mapView_.layer addAnimation:animation forKey:kGMSLayerCameraLongitudeKey];

  animation = [CABasicAnimation animationWithKeyPath:kGMSLayerCameraBearingKey];
  animation.duration = 2.0f;
  animation.timingFunction = curve;
  animation.toValue = @(0.0);
  [mapView_.layer addAnimation:animation forKey:kGMSLayerCameraBearingKey];

  // Fly out to the minimum zoom and then zoom back to the current zoom!
  CGFloat zoom = mapView_.camera.zoom;
  NSArray *keyValues = @[@(zoom), @(-100.0), @(zoom)];
  CAKeyframeAnimation *keyFrameAnimation =
      [CAKeyframeAnimation animationWithKeyPath:kGMSLayerCameraZoomLevelKey];
  keyFrameAnimation.duration = 2.0f;
  keyFrameAnimation.values = keyValues;
  [mapView_.layer addAnimation:keyFrameAnimation forKey:kGMSLayerCameraZoomLevelKey];
}

@end
