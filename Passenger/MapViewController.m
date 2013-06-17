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

#import <MapKit/MapKit.h>
#import <AddressBookUI/AddressBookUI.h>

#import "MapViewController.h"
#import "PKRevealController.h"
#import "LocationSelectorViewController.h"
#import "MapAnnotation.h"
#import "UserSettings.h"
#import "ConfirmBookingDialog.h"

@interface MapViewController () <MKMapViewDelegate>
{
    NSTimer *_nearbyCabsTimer;
    BOOL _zoomToUserLocation;
}

@property (weak, nonatomic) IBOutlet UIButton *aButton;
@property (weak, nonatomic) IBOutlet UIButton *bButton;

@property (weak, nonatomic) IBOutlet UIButton *myLocationButton;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UIView *abView;
@property (weak, nonatomic) IBOutlet UIView *priceView;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
@property (weak, nonatomic) IBOutlet UILabel *distanceLabel;
@property (weak, nonatomic) IBOutlet UIButton *bookButton;
@property (weak, nonatomic) IBOutlet UIView *pickupDropoffView;
@property (weak, nonatomic) IBOutlet FlatButton *pickupButton;
@property (weak, nonatomic) IBOutlet FlatButton *dropoffButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicatorView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *bookingActivityIndicator;
@property (weak, nonatomic) IBOutlet UIButton *createNewBookingButton;

- (IBAction)leftButtonPressed:(id)sender;
- (IBAction)rightButtonPressed:(id)sender;
- (IBAction)buttonAPressed:(id)sender;
- (IBAction)buttonBPressed:(id)sender;
- (IBAction)myLocationButtonPressed:(id)sender;
- (IBAction)bookButtonPressed:(id)sender;
- (IBAction)createNewBookingButtonPressed:(id)sender;

@property (nonatomic, strong) MapAnnotation* startAnnotation;
@property (nonatomic, strong) MapAnnotation* endAnnotation;

@property (nonatomic, strong) MapAnnotation* startRouteAnnotation;
@property (nonatomic, strong) MapAnnotation* endRouteAnnotation;

@property (nonatomic, strong) NSMutableArray* nearbyCabs;

@property (nonatomic, strong) CLGeocoder* geocoder;
@property (nonatomic, strong) NSString* locationName;
@property (nonatomic, strong) NSString* zipCode;

@end

@implementation MapViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _abView.hidden = NO;

    _priceView.hidden = YES;
    
    UIImage *nb = [[UIImage imageNamed:@"map_button_normal_bg"] resizableImageWithCapInsets:UIEdgeInsetsMake(14, 14, 14, 14)];
    UIImage *pb = [[UIImage imageNamed:@"map_button_pressed_bg"] resizableImageWithCapInsets:UIEdgeInsetsMake(14, 14, 14, 14)];
    
    _pickupDropoffView.backgroundColor = [UIColor mapOverlayColor];
    [_pickupDropoffView.layer setCornerRadius:8.0f];

    [_priceView.layer setCornerRadius:8.0f];
    _priceView.backgroundColor = [UIColor mapOverlayColor];

    [_myLocationButton setBackgroundImage:nb forState:UIControlStateNormal];
    [_myLocationButton setBackgroundImage:pb forState:UIControlStateHighlighted];

    [_bookButton setBackgroundImage:nb forState:UIControlStateNormal];
    [_bookButton setBackgroundImage:pb forState:UIControlStateHighlighted];
    
    [_createNewBookingButton setBackgroundImage:nb forState:UIControlStateNormal];
    [_createNewBookingButton setBackgroundImage:pb forState:UIControlStateHighlighted];
    _createNewBookingButton.hidden = YES;

    _priceLabel.font = [UIFont lightOpenSansOfSize:23];
    _priceLabel.textColor = [UIColor blackColor];
    _distanceLabel.font = [UIFont lightOpenSansOfSize:13];
    _distanceLabel.textColor = [UIColor mapFareDistanceColor];
    
    [_pickupButton setTitleFont:[UIFont semiboldOpenSansOfSize:16]];
    _pickupButton.buttonBackgroundColor = [UIColor clearColor];
    [_pickupButton setTitleColor:[UIColor pickupTextColor] forState:UIControlStateNormal];
    [_pickupButton setTitle:NSLocalizedString(@"pickup_line_default", @"") forState:UIControlStateNormal];
    [_pickupButton setTextAlignment:NSTextAlignmentLeft];
    
    [_dropoffButton setTitleFont:[UIFont semiboldOpenSansOfSize:16]];
    _dropoffButton.buttonBackgroundColor = [UIColor clearColor];
    [_dropoffButton setTitleColor:[UIColor dropoffTextColor] forState:UIControlStateNormal];
    [_dropoffButton setTitle:NSLocalizedString(@"dropoff_line_default", @"") forState:UIControlStateNormal];
    [_dropoffButton setTextAlignment:NSTextAlignmentLeft];
        
    UILongPressGestureRecognizer *longPressA = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
    _aButton.tag = 1;
    [_aButton addGestureRecognizer:longPressA];
    UILongPressGestureRecognizer *longPressB = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
    _bButton.tag = 2;
    [_bButton addGestureRecognizer:longPressB];
    UILongPressGestureRecognizer *longPressC = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
    _myLocationButton.tag = 3;
    [_myLocationButton addGestureRecognizer:longPressC];
    
    self.geocoder = [[CLGeocoder alloc] init];
    
    _bookingActivityIndicator.hidden = YES;
    
    _zoomToUserLocation = YES;
    
    _bookButton.enabled = NO;

	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.mapView.userLocation addObserver:self
                                forKeyPath:@"location"
                                   options:(NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld)
                                   context:NULL];
    
    if ([UserSettings refreshToken])
    {
        [[NetworkEngine getInstance] getAccessTokenForRefreshToken:[UserSettings refreshToken]
                                                   completionBlock:^(NSObject *o) {
                                                       [self downloadNearbyCabs];
                                                       _nearbyCabsTimer = [NSTimer scheduledTimerWithTimeInterval:30
                                                                                                           target:self
                                                                                                         selector:@selector(nearbyCabsTimerFired:)
                                                                                                         userInfo:nil
                                                                                                          repeats:YES];

                                                   }
                                                      failureBlock:^(NSError *e){
                                                          [UserSettings setRefreshToken:nil];
                                                          [self.navigationController popToRootViewControllerAnimated:YES];
                                                      }];
    }
}

- (void)nearbyCabsTimerFired:(NSTimer*)sender
{
    [self downloadNearbyCabs];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.mapView.userLocation removeObserver:self forKeyPath:@"location" context:NULL];

    [_nearbyCabsTimer invalidate];
    _nearbyCabsTimer = nil;
}

- (void)downloadNearbyCabs
{
    [[NetworkEngine getInstance] getNearbyCabs:_mapView.userLocation.location.coordinate
                               completionBlock:^(NSObject *o)
                                    {
                                        for (MapAnnotation *m in _nearbyCabs)
                                        {
                                            [_mapView removeAnnotation:m];
                                        }
                                        
                                        self.nearbyCabs = [[NSMutableArray alloc] init];
                                        NSArray *cabs = (NSArray *)o;
                                        for (NSDictionary *d in cabs)
                                        {
                                            NSNumber* lat = d[@"lat"];
                                            NSNumber* lng = d[@"lng"];
                                            
                                            MapAnnotation *m = [[MapAnnotation alloc] initWithCoordinate:CLLocationCoordinate2DMake([lat floatValue], [lng floatValue]) withTitle:@"" withImageName:@"map_marker_nearby_cab"];
                                            [_mapView addAnnotation:m];
                                            [_nearbyCabs addObject:m];
                                        }
                                    }
                                  failureBlock:^(NSError *e)
                                    {
                                    }
     ];
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    
    if ([keyPath isEqualToString:@"location"])
    {
        if (_zoomToUserLocation) {
            if (_mapView.userLocation.location)
            {
                [self resetMapZoomAndSetLocationTo:_mapView.userLocation.location.coordinate];
                _zoomToUserLocation = NO;
            }
            else
            {
                CGFloat lat = [CabOfficeSettings startLocationLatitude];
                CGFloat lng = [CabOfficeSettings startLocationLongitude];
                [self resetMapZoomAndSetLocationTo:CLLocationCoordinate2DMake(lat, lng)];
            }
        }
    }
}


- (void)resetMapZoomAndSetLocationTo:(CLLocationCoordinate2D)coordinate
{
    MKCoordinateRegion region;
    region.center = coordinate;
    MKCoordinateSpan span;
    span.latitudeDelta = .008;
    span.longitudeDelta = .008;
    region.span=span;
    [_mapView setRegion:region animated:YES];
}

- (void)longPress:(UILongPressGestureRecognizer*)gesture {
    if ( gesture.state == UIGestureRecognizerStateBegan) {
        NSInteger tag = gesture.view.tag;
        if (tag == 1)
        {
            if (_startAnnotation)
            {
                [_mapView removeAnnotation:_startAnnotation];
                self.startAnnotation = nil;
            }
            [_pickupButton setTitle:NSLocalizedString(@"pickup_line_default", @"") forState:UIControlStateNormal];

            _bookButton.enabled = NO;
            
            [self removeRoutes];
            _priceView.hidden = YES;
        }
        else if (tag == 2)
        {
            if (_endAnnotation)
            {
                [_mapView removeAnnotation:_endAnnotation];
                self.endAnnotation = nil;
            }
            [_dropoffButton setTitle:NSLocalizedString(@"dropoff_line_default", @"") forState:UIControlStateNormal];

            if ([CabOfficeSettings dropoffLocationIsMandatory] || !_startAnnotation)
                _bookButton.enabled = NO;
            
            [self removeRoutes];
            _priceView.hidden = YES;
        }
        else if (tag == 3)
        {
            [self resetMapZoomAndSetLocationTo:_mapView.userLocation.location.coordinate];
        }
    }
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setMapView:nil];
    [self setAbView:nil];
    [self setPriceView:nil];
    [self setPriceLabel:nil];
    [self setDistanceLabel:nil];
    [self setBookButton:nil];
    [self setPickupDropoffView:nil];
    [self setPickupButton:nil];
    [self setDropoffButton:nil];
    [self setMyLocationButton:nil];
    [self setAButton:nil];
    [self setBButton:nil];
    [self setActivityIndicatorView:nil];
    [self setBookingActivityIndicator:nil];
    [self setCreateNewBookingButton:nil];
    [super viewDidUnload];
}

- (void)removeRoutes
{
    NSArray* ovr = _mapView.overlays;
    for (id o in ovr)
    {
        [_mapView removeOverlay:o];
    }
    
    if (_startRouteAnnotation)
        [_mapView removeAnnotation:_startRouteAnnotation];
    if (_endRouteAnnotation)
        [_mapView removeAnnotation:_endRouteAnnotation];
    
    self.startRouteAnnotation = nil;
    self.endRouteAnnotation = nil;
}

- (void)calculateRoute
{
    if (_startAnnotation && _endAnnotation)
    {
        _priceView.hidden = YES;
        _bookingActivityIndicator.hidden = NO;
        _bookButton.enabled = NO;
        [_bookingActivityIndicator startAnimating];

        [[NetworkEngine getInstance] getDirectionsFrom:_startAnnotation.coordinate
                                                    to:_endAnnotation.coordinate
                                       completionBlock:^(NSObject *o)
                                        {
                                            _priceView.hidden = NO;
                                            _bookingActivityIndicator.hidden = YES;
                                            _bookButton.enabled = YES;

                                            NSArray* points = (NSArray*)o;
                                            
                                            if (points.count)
                                            {
                                                MKMapPoint * pointsArray = malloc(sizeof(MKMapPoint) * points.count);
                                                
                                                NSInteger i = 0;
                                                for (CLLocation *loc in points)
                                                {
                                                    pointsArray[i++] = MKMapPointForCoordinate(loc.coordinate);
                                                }
                                                
                                                MKPolyline *  routeLine = [MKPolyline polylineWithPoints:pointsArray count:points.count];
                                                free(pointsArray);
                                                
                                                routeLine.title = @"route";

                                                [self removeRoutes];
                                                [_mapView addOverlay:routeLine];
                                                
                                                CLLocation* startLocation = points[0];
                                                self.startRouteAnnotation = [[MapAnnotation alloc] initWithCoordinate:startLocation.coordinate
                                                                                                            withTitle:@""
                                                                                        withImageName:@"map_marker_cab_pickup"];
                                                [_mapView addAnnotation:_startRouteAnnotation];
                                                [self addLiveOverlayFrom:startLocation.coordinate to:_startAnnotation.coordinate title:@"pickup"];
                                                
                                                CLLocation* endLocation = [points lastObject];
                                                self.endRouteAnnotation = [[MapAnnotation alloc] initWithCoordinate:endLocation.coordinate
                                                                                                            withTitle:@""
                                                                                                        withImageName:@"map_marker_cab_dropoff"];
                                                [_mapView addAnnotation:_endRouteAnnotation];
                                                
                                                [self addLiveOverlayFrom:endLocation.coordinate to:_endAnnotation.coordinate title:@"dropoff"];
                                            }

                                        }
                                          failureBlock:^(NSError *e)
                                            {
                                                _bookingActivityIndicator.hidden = YES;
                                                _bookButton.enabled = YES;
                                                _priceView.hidden = NO;
                                                NSLog(@"failed to get route: %@", e);
                                            }];
    }
}

- (void) addLiveOverlayFrom:(CLLocationCoordinate2D)start
                         to:(CLLocationCoordinate2D)end
                      title:(NSString *)title
{
    MKMapPoint * pointsArray = malloc(sizeof(MKMapPoint) * 2);
    
    pointsArray[0] = MKMapPointForCoordinate(start);
    pointsArray[1] = MKMapPointForCoordinate(end);
    
    MKPolyline *  routeLine = [MKPolyline polylineWithPoints:pointsArray count:2];
    free(pointsArray);
    
    routeLine.title = title;
    
    [_mapView addOverlay:routeLine];
}

- (void)calculateFare
{
    if (_startAnnotation && _endAnnotation)
    {
        _priceView.hidden = YES;
        _bookingActivityIndicator.hidden = NO;
        _bookButton.enabled = NO;
        [_bookingActivityIndicator startAnimating];

        [[NetworkEngine getInstance] getTravelFare:_startAnnotation.coordinate
                                                to:_endAnnotation.coordinate
                                   completionBlock:^(NSObject *o)
                                    {
                                        _bookingActivityIndicator.hidden = YES;
                                        _bookButton.enabled = YES;
                                        _priceView.hidden = NO;
                                        NSDictionary* d = (NSDictionary*)o;
                                        _priceLabel.text = d[@"fare"][@"formatted_total_cost"];
                                        
                                        NSString *text;
                                        BOOL isMetric = [[[NSLocale currentLocale] objectForKey:NSLocaleUsesMetricSystem] boolValue];
                                        if (!isMetric)
                                        {
                                            NSString *m = d[@"fare"][@"distance"][@"miles"];
                                            text = [NSString stringWithFormat:NSLocalizedString(@"journey_distance_imperial_fmt", @""), m];
                                        }
                                        else
                                        {
                                            NSString *m = d[@"fare"][@"distance"][@"km"];
                                            text = [NSString stringWithFormat:NSLocalizedString(@"journey_distance_metrics_fmt", @""), m];
                                        }

                                        _distanceLabel.text = text;
                                        [self calculateRoute];
                                    }
                                      failureBlock:^(NSError *e)
                                    {
                                        _bookingActivityIndicator.hidden = YES;
                                        _bookButton.enabled = NO;
                                        _priceView.hidden = YES;
                                    }];
    }
}

#pragma mark map delegate

- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id <MKOverlay>)overlay
{
    MKPolylineView* _routeLineView = [[MKPolylineView alloc] initWithPolyline:overlay];
    
    UIColor *color = [UIColor mapRouteColor];
    if ([overlay.title isEqualToString:@"pickup"])
    {
        color = [UIColor pickupTextColor];
        _routeLineView.lineDashPhase = 5;
        _routeLineView.lineDashPattern = @[@10, @10];
    }
    else if ([overlay.title isEqualToString:@"dropoff"])
    {
        color = [UIColor dropoffTextColor];
        _routeLineView.lineDashPhase = 5;
        _routeLineView.lineDashPattern = @[@10, @10];
    }

    _routeLineView.fillColor = color;
    _routeLineView.strokeColor = color;
    _routeLineView.lineWidth = 4;
    _routeLineView.lineCap = kCGLineCapRound;
    
    return _routeLineView;
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation {
    
	MKAnnotationView *test = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"locID"];
	test.annotation = annotation;
	test.canShowCallout = NO;
	test.userInteractionEnabled = NO;
    
    if ([annotation isKindOfClass:[MapAnnotation class]])
    {
        MapAnnotation* a = (MapAnnotation*)annotation;
        test.image = [UIImage imageNamed:a.imageName];
        
        if (a.title.length != 0)
            test.centerOffset = CGPointMake(0, -test.image.size.height / 2);
    }
	return test;
}


- (void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated
{
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    _aButton.enabled = NO;
    _bButton.enabled = NO;
    _activityIndicatorView.hidden = NO;
    [_activityIndicatorView startAnimating];
    [self findAddressForLocation:_mapView.centerCoordinate completionBlock:^(NSString *address, NSString *zipCode) {

        _aButton.enabled = YES;
        _bButton.enabled = YES;
        _activityIndicatorView.hidden = YES;

        self.locationName = address;
        self.zipCode = zipCode;
    }];
}

- (void)mapViewDidFinishLoadingMap:(MKMapView *)mapView
{
}

- (IBAction)leftButtonPressed:(id)sender {
    PKRevealController *rc = self.revealController;
    [rc showViewController:rc.leftViewController];
}

- (IBAction)rightButtonPressed:(id)sender {
    PKRevealController *rc = self.revealController;
    [rc showViewController:rc.rightViewController];
}

- (void)findAddressForLocation:(CLLocationCoordinate2D)coordinate
               completionBlock:(void (^)(NSString* address, NSString *zipCode))completionBlock
{
    CLLocation *newLocation = [[CLLocation alloc] initWithLatitude:coordinate.latitude
                                                         longitude:coordinate.longitude];
    
    [_geocoder cancelGeocode];
    
    [_geocoder reverseGeocodeLocation:newLocation
                    completionHandler:^(NSArray *placemarks, NSError *error) {
                        
                        if (error) {
                            completionBlock(nil, nil);
                            NSLog(@"Geocode failed with error: %@", error);
                            return;
                        }
                        
                        if (placemarks.count > 0)
                        {
                            CLPlacemark *placemark = placemarks[0];
                            
                            NSDictionary *addressDictionary = placemark.addressDictionary;
                            
                            NSString* address = ABCreateStringWithAddressDictionary(addressDictionary, NO);
                            
                            completionBlock([address stringByReplacingOccurrencesOfString:@"\n" withString:@" "], placemark.postalCode);
                            
                            NSLog(@"%@ \n%@", addressDictionary, address);
                        }
                        else
                        {
                            completionBlock(nil, nil);
                            [MessageDialog showError:NSLocalizedString(@"map_aim_location_unknown_body", @"")
                                           withTitle:NSLocalizedString(@"dialog_error_title", @"")];
                        }
                        
                    }];
    
    
}

- (IBAction)buttonAPressed:(id)sender {
    if (_locationName)
    {
        [self removeRoutes];
        [self setPickupLocation:_mapView.centerCoordinate title:_locationName zipCode:_zipCode];
        [self calculateFare];
    }
}

- (IBAction)buttonBPressed:(id)sender {
    if (_locationName)
    {
        [self removeRoutes];
        [self setDropoffLocation:_mapView.centerCoordinate title:_locationName zipCode:_zipCode];
        [self calculateFare];
    }
}

- (IBAction)myLocationButtonPressed:(id)sender {
    [_mapView setCenterCoordinate:_mapView.userLocation.coordinate animated:YES];
}

- (IBAction)bookButtonPressed:(id)sender {
    if (_startAnnotation == nil)
    {
        [MessageDialog showError:NSLocalizedString(@"new_booking_no_pickup_location_body", @"")
                       withTitle:NSLocalizedString(@"dialog_error_title", @"")];
        return;
    }
    
    [ConfirmBookingDialog showDialog:_startAnnotation.title
                             dropoff:_endAnnotation.title
                   confirmationBlock:^(NSDate *date){
                       [[NetworkEngine getInstance] createBooking:_startAnnotation.title
                                                    pickupZipCode:_startAnnotation.zipCode
                                                   pickupLocation:_startAnnotation.coordinate
                                                      dropoffName:_endAnnotation.title
                                                   dropoffZipCode:_endAnnotation.zipCode
                                                  dropoffLocation:_endAnnotation.coordinate
                                                       pickupDate:date
                                                  completionBlock:^(NSObject *response) {
                                                      [MessageDialog showMessage:[NSString stringWithFormat:NSLocalizedString(@"new_booking_body_fmt", @""), _startAnnotation.title]
                                                                       withTitle:NSLocalizedString(@"new_booking_title", @"")];
                                                      
                                                      PKRevealController *rc = self.revealController;
                                                      HistoryViewController* h = (HistoryViewController *)rc.rightViewController;
                                                      [h addBooking:(NSDictionary *)response];
                                                      
                                                      _createNewBookingButton.hidden = NO;
                                                      _bookButton.hidden = YES;
                                                      _priceView.hidden = YES;
                                                      _abView.hidden = YES;
                                                      _pickupDropoffView.hidden = YES;
                                                      
                                                      [self removeRoutes];
                                                      
                                                      if (_startAnnotation)
                                                      {
                                                          [_mapView removeAnnotation:_startAnnotation];
                                                          self.startAnnotation = nil;
                                                      }
                                                      
                                                      if (_endAnnotation)
                                                      {
                                                          [_mapView removeAnnotation:_endAnnotation];
                                                          self.endAnnotation = nil;
                                                      }
                                                      
                                                      [_pickupButton setTitle:NSLocalizedString(@"pickup_line_default", @"") forState:UIControlStateNormal];
                                                      [_dropoffButton setTitle:NSLocalizedString(@"dropoff_line_default", @"") forState:UIControlStateNormal];

                                                  }
                                                     failureBlock:^(NSError *error) {
                                                         [MessageDialog showError:[NSString stringWithFormat:NSLocalizedString(@"new_booking_failed_body_fmt", @""), error.localizedDescription]
                                                                        withTitle:NSLocalizedString(@"dialog_error_title", @"")];
                                                     }];
                   }];
}

- (IBAction)createNewBookingButtonPressed:(id)sender {

    [self removeRoutes];
    
    if (_startAnnotation)
        [_mapView removeAnnotation:_startAnnotation];
    self.startAnnotation = nil;

    if (_endAnnotation)
        [_mapView removeAnnotation:_endAnnotation];
    self.endAnnotation = nil;

    _createNewBookingButton.hidden = YES;
    _bookButton.hidden = NO;
    _abView.hidden = NO;
    _pickupDropoffView.hidden = NO;
    _bookButton.enabled = NO;
}

- (void)setPickupLocation:(CLLocationCoordinate2D)location
                    title:(NSString *)title
                  zipCode:(NSString *)zipCode
{
    [_pickupButton setTitle:title forState:UIControlStateNormal];

    if (_startAnnotation)
        [_mapView removeAnnotation:_startAnnotation];
    self.startAnnotation = [[MapAnnotation alloc] initWithCoordinate:location
                                                           withTitle:title
                                                       withImageName:@"map_marker_pickup_big"];
    _startAnnotation.zipCode = zipCode;
    [_mapView addAnnotation:_startAnnotation];

    if ([CabOfficeSettings dropoffLocationIsMandatory])
    {
        if (_endAnnotation)
            _bookButton.enabled = YES;
        else
            _bookButton.enabled = NO;
    }
    else
    {
        _bookButton.enabled = YES;
    }
    
//    [self zoomToFitMapAnnotations];
    
}

- (void)setDropoffLocation:(CLLocationCoordinate2D)location
                     title:(NSString *)title
                   zipCode:(NSString *)zipCode
{
    [_dropoffButton setTitle:title forState:UIControlStateNormal];

    if (_endAnnotation)
        [_mapView removeAnnotation:_endAnnotation];
    self.endAnnotation = [[MapAnnotation alloc] initWithCoordinate:location
                                                         withTitle:title
                                                     withImageName:@"map_marker_dropoff"];
    _endAnnotation.zipCode = zipCode;
    [_mapView addAnnotation:_endAnnotation];
 
    if ([CabOfficeSettings dropoffLocationIsMandatory] && _startAnnotation)
        _bookButton.enabled = YES;
//    [self zoomToFitMapAnnotations];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"showLocationViewControllerForPickup"])
    {
        LocationSelectorViewController* vc = segue.destinationViewController;
        vc.logoImage = [UIImage imageNamed:@"map_marker_pickup"];
        if (_startAnnotation)
            vc.locationName = [_pickupButton titleForState:UIControlStateNormal];
        vc.placeholder = NSLocalizedString(@"address_search_pickup_hint", @"");
        vc.type = LocationTypePickup;
        vc.completionBlock = ^(NSDictionary *d) {
            NSNumber* lat = d[@"location"][@"lat"];
            NSNumber* lng = d[@"location"][@"lng"];
            CLLocationCoordinate2D c = CLLocationCoordinate2DMake([lat floatValue], [lng floatValue]);
            [self setPickupLocation:c title:d[@"address"] zipCode:d[@"postcode"]];
            
            [self calculateFare];
        };
    }
    else if ([segue.identifier isEqualToString:@"showLocationViewControllerForDropoff"])
    {
        LocationSelectorViewController* vc = segue.destinationViewController;
        vc.logoImage = [UIImage imageNamed:@"map_marker_dropoff"];
        if (_endAnnotation)
            vc.locationName = [_dropoffButton titleForState:UIControlStateNormal];
        vc.placeholder = NSLocalizedString(@"address_search_dropoff_hint", @"");
        vc.type = LocationTypeDropoff;
        vc.completionBlock = ^(NSDictionary *d) {
            NSNumber* lat = d[@"location"][@"lat"];
            NSNumber* lng = d[@"location"][@"lng"];
            CLLocationCoordinate2D c = CLLocationCoordinate2DMake([lat floatValue], [lng floatValue]);
            [self setDropoffLocation:c title:d[@"address"] zipCode:d[@"postcode"]];
            
            [self calculateFare];
        };
    }
    
}

- (void)zoomToFitMapAnnotations {
    
    if (_startAnnotation == nil && _endAnnotation == nil)
    {
        return;
    }
    else if (_startAnnotation && _endAnnotation == nil)
    {
        [self resetMapZoomAndSetLocationTo:_startAnnotation.coordinate];
        return;
    }
    
    CLLocationCoordinate2D topLeftCoord;
    CLLocationCoordinate2D bottomRightCoord;
    topLeftCoord.longitude = fmin(_endAnnotation.coordinate.longitude, _startAnnotation.coordinate.longitude);
    topLeftCoord.latitude = fmax(_endAnnotation.coordinate.latitude, _startAnnotation.coordinate.latitude);
    bottomRightCoord.longitude = fmax(_endAnnotation.coordinate.longitude, _startAnnotation.coordinate.longitude);
    bottomRightCoord.latitude = fmin(_endAnnotation.coordinate.latitude, _startAnnotation.coordinate.latitude);

    MKCoordinateRegion region;
    region.center.latitude = topLeftCoord.latitude - (topLeftCoord.latitude - bottomRightCoord.latitude) * 0.5;
    region.center.longitude = topLeftCoord.longitude + (bottomRightCoord.longitude - topLeftCoord.longitude) * 0.5;
    region.span.latitudeDelta = fabs(topLeftCoord.latitude - bottomRightCoord.latitude) * 1.5;
    
    // Add a little extra space on the sides
    region.span.longitudeDelta = fabs(bottomRightCoord.longitude - topLeftCoord.longitude) * 1.5;
    
    region = [_mapView regionThatFits:region];
    [_mapView setRegion:region animated:YES];
}

#pragma mark booking history selection delegate

- (void)selectedBookingWithPickup:(NSString *)pickupName
                 andPickupZipCode:(NSString *)pickupZipCode
                andPickupLocation:(CLLocationCoordinate2D)pickupLocation
                   andDropoffName:(NSString *)dropoffName
                andDropoffZipCode:(NSString *)dropoffZipCode
               andDropoffLocation:(CLLocationCoordinate2D)dropoffLocation
{
    PKRevealController *rc = self.revealController;
    [rc showViewController:rc.frontViewController];

    if (pickupName) {
        [self setPickupLocation:pickupLocation title:pickupName zipCode:pickupZipCode];
        [_mapView setCenterCoordinate:pickupLocation animated:YES];
    } else {
        [_mapView setCenterCoordinate:dropoffLocation animated:YES];
    }

    if (dropoffName)
        [self setDropoffLocation:dropoffLocation title:dropoffName zipCode:dropoffZipCode];

    [self calculateFare];
}

@end
