#import "CameraViewController.h"
#import <GoogleMaps/GoogleMaps.h>

@implementation CameraViewController {
  GMSMapView *mapView_;
  NSTimer *timer;
}

- (void)viewDidLoad {
  [super viewDidLoad];
  // Do any additional setup after loading the view.

  GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:-37.809487
                                                          longitude:144.965699
                                                               zoom:20
                                                            bearing:0
                                                       viewingAngle:0];
  mapView_ = [GMSMapView mapWithFrame:CGRectZero camera:camera];
  mapView_.settings.zoomGestures = NO;
  mapView_.settings.scrollGestures = NO;
  mapView_.settings.rotateGestures = NO;
  mapView_.settings.tiltGestures = NO;

  self.view = mapView_;
}

- (void)moveCamera {
  GMSCameraPosition *camera = mapView_.camera;
  float zoom = fmax(camera.zoom - 0.1, 17.5);

  GMSCameraPosition *newCamera =
      [[GMSCameraPosition alloc] initWithTarget:camera.target
                                           zoom:zoom
                                        bearing:camera.bearing + 10
                                   viewingAngle:camera.viewingAngle + 10];
  [mapView_ animateToCameraPosition:newCamera];
}

- (void)viewDidAppear:(BOOL)animated {
  timer = [NSTimer scheduledTimerWithTimeInterval:1.f/30.f
                                           target:self
                                         selector:@selector(moveCamera)
                                         userInfo:nil
                                          repeats:YES];
}

- (void)viewDidDisappear:(BOOL)animated {
  [timer invalidate];
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  [timer invalidate];
}

@end
