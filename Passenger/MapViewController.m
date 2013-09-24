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

#import <AddressBookUI/AddressBookUI.h>
#import <GoogleMaps/GoogleMaps.h>

#import "MapViewController.h"
#import "PKRevealController.h"
#import "LocationSelectorViewController.h"
#import "LocationSelectionListViewController.h"
#import "MapAnnotation.h"
#import "UserSettings.h"
#import "ConfirmBookingDialog.h"
#import "GMSMapView+Additions.h"
#import "SearchViewController.h"

@interface MapViewController () <GMSMapViewDelegate, UIPopoverControllerDelegate>
{
    NSTimer *_nearbyCabsTimer;
    BOOL _zoomToUserLocation;
}

@property (weak, nonatomic) IBOutlet UIButton *aButton;
@property (weak, nonatomic) IBOutlet UIButton *bButton;

@property (weak, nonatomic) IBOutlet UIButton *myLocationButton;
@property (weak, nonatomic) IBOutlet UIView *abView;
@property (weak, nonatomic) IBOutlet UIView *priceView;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
@property (weak, nonatomic) IBOutlet UILabel *distanceLabel;
@property (weak, nonatomic) IBOutlet UIButton *bookButton;
@property (weak, nonatomic) IBOutlet UIView *pickupDropoffView;
@property (weak, nonatomic) IBOutlet FlatAutoScrollButton *pickupButton;
@property (weak, nonatomic) IBOutlet FlatAutoScrollButton *dropoffButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicatorView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *bookingActivityIndicator;
@property (weak, nonatomic) IBOutlet UIButton *createNewBookingButton;
@property (strong, nonatomic) UIPopoverController* searchPopover;
@property (weak, nonatomic) IBOutlet GMSMapView *googleMapView;
@property (strong, nonatomic) NSMutableArray* googleMapOverlays;

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

- (NSString*)dropoffLine
{
    if ([CabOfficeSettings useAlternativeDropoffLabel])
    {
        return NSLocalizedString(@"dropoff_line_alternative", @"");
    }
    else
    {
        return NSLocalizedString(@"dropoff_line_default", @"");
    }
}

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
    [_pickupButton setTextAlignment:UITextAlignmentLeft];
    
    [_dropoffButton setTitleFont:[UIFont semiboldOpenSansOfSize:16]];
    _dropoffButton.buttonBackgroundColor = [UIColor clearColor];
    [_dropoffButton setTitleColor:[UIColor dropoffTextColor] forState:UIControlStateNormal];
    [_dropoffButton setTitle:[self dropoffLine] forState:UIControlStateNormal];
    [_dropoffButton setTextAlignment:UITextAlignmentLeft];
        
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
    
    _googleMapView.myLocationEnabled = YES;
    _googleMapView.delegate = self;
    self.googleMapOverlays = [[NSMutableArray alloc] initWithCapacity:3];

	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (![UserSettings tourHasBeenShown] && IS_IPAD)
    {
        [self performSegueWithIdentifier:@"showTourViewController" sender:self];
        [UserSettings setTourHasBeenShown:YES];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.googleMapView addObserver:self
                         forKeyPath:@"myLocation"
                            options:(NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld)
                            context:NULL];
    
    if( [CabOfficeSettings trackNearbyCabs])
    {
        [self downloadNearbyCabs];
        [_nearbyCabsTimer invalidate];
        _nearbyCabsTimer = [NSTimer scheduledTimerWithTimeInterval:30
                                                            target:self
                                                          selector:@selector(nearbyCabsTimerFired:)
                                                          userInfo:nil
                                                           repeats:YES];
    }
}

- (void)nearbyCabsTimerFired:(NSTimer*)sender
{
    [self downloadNearbyCabs];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.googleMapView removeObserver:self forKeyPath:@"myLocation" context:NULL];

    [_nearbyCabsTimer invalidate];
    _nearbyCabsTimer = nil;
}

- (void)downloadNearbyCabs
{
    [[NetworkEngine getInstance] getNearbyCabs:_googleMapView.myLocation.coordinate
                               completionBlock:^(NSObject *o)
                                    {
                                        for (MapAnnotation *m in _nearbyCabs)
                                        {
                                            [_googleMapView removeAnnotation:m];
                                        }
                                        
                                        self.nearbyCabs = [[NSMutableArray alloc] init];
                                        NSArray *cabs = (NSArray *)o;
                                        for (NSDictionary *d in cabs)
                                        {
                                            NSNumber* lat = d[@"lat"];
                                            NSNumber* lng = d[@"lng"];
                                            
                                            MapAnnotation *m = [[MapAnnotation alloc] initWithCoordinate:CLLocationCoordinate2DMake([lat floatValue], [lng floatValue]) withTitle:@"" withImageName:@"map_marker_nearby_cab" withZipCode:nil];
                                            [_googleMapView addAnnotation:m];
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
    
    if ([keyPath isEqualToString:@"myLocation"])
    {
        if (_zoomToUserLocation)
        {
            if (_googleMapView.myLocation)
            {
                [self resetMapZoomAndSetLocationTo:_googleMapView.myLocation.coordinate];
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
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:coordinate.latitude
                                                            longitude:coordinate.longitude
                                                                 zoom:15];

    [_googleMapView setCamera:camera];
}

- (void)setMapCoordinate:(CLLocationCoordinate2D)coordinate
{
    GMSCameraPosition* camera = [GMSCameraPosition cameraWithTarget:coordinate zoom:_googleMapView.camera.zoom];
    [_googleMapView setCamera:camera];
}

- (void)longPress:(UILongPressGestureRecognizer*)gesture {
    if ( gesture.state == UIGestureRecognizerStateBegan) {
        NSInteger tag = gesture.view.tag;
        if (tag == 1)
        {
            if (_startAnnotation)
            {
                [_googleMapView removeAnnotation:_startAnnotation];
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
                [_googleMapView removeAnnotation:_endAnnotation];
                self.endAnnotation = nil;
            }
            [_dropoffButton setTitle:[self dropoffLine] forState:UIControlStateNormal];

            if ([CabOfficeSettings dropoffLocationIsMandatory] || !_startAnnotation)
            {
                _bookButton.enabled = NO;
            }
            
            [self removeRoutes];
            _priceView.hidden = YES;
        }
        else if (tag == 3)
        {
            [self resetMapZoomAndSetLocationTo:_googleMapView.myLocation.coordinate];
        }
    }
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
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
    [self setGoogleMapView:nil];
    [super viewDidUnload];
}

- (void)removeRoutes
{
    for (GMSOverlay* o in _googleMapOverlays)
    {
        o.map = nil;
    }
    [_googleMapOverlays removeAllObjects];
    
    if (_startRouteAnnotation)
    {
        [_googleMapView removeAnnotation:_startRouteAnnotation];
    }
    if (_endRouteAnnotation)
    {
        [_googleMapView removeAnnotation:_endRouteAnnotation];
    }

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

        [[NetworkEngine getInstance] getDirectionsFrom:_startAnnotation.position
                                                    to:_endAnnotation.position
                                       completionBlock:^(NSObject *o)
                                        {
                                            _priceView.hidden = NO;
                                            _bookingActivityIndicator.hidden = YES;
                                            _bookButton.enabled = YES;

                                            NSArray* points = (NSArray*)o;
                                            if (points.count)
                                            {
                                                [self removeRoutes];

                                                GMSMutablePath *path = [GMSMutablePath path];
                                                for (CLLocation *loc in points)
                                                {
                                                    [path addCoordinate:loc.coordinate];
                                                }
                                                
                                                GMSPolyline *route = [GMSPolyline polylineWithPath:path];
                                                route.strokeColor = [UIColor mapRouteColor];
                                                route.map = _googleMapView;
                                                route.strokeWidth = 5;
                                                [_googleMapOverlays addObject:route];

                                                CLLocation* startLocation = points[0];
                                                self.startRouteAnnotation = [[MapAnnotation alloc] initWithCoordinate:startLocation.coordinate
                                                                                                            withTitle:@""
                                                                                        withImageName:@"map_marker_cab_pickup"
                                                                                                          withZipCode:nil];
                                                _startRouteAnnotation.groundAnchor = CGPointMake(0.5f, 0.5f);
                                                [_googleMapView addAnnotation:_startRouteAnnotation];
                                                [self addLiveOverlayFrom:startLocation.coordinate to:_startAnnotation.position color:[UIColor pickupTextColor]];
                                                
                                                CLLocation* endLocation = [points lastObject];
                                                self.endRouteAnnotation = [[MapAnnotation alloc] initWithCoordinate:endLocation.coordinate
                                                                                                            withTitle:@""
                                                                                                        withImageName:@"map_marker_cab_dropoff" withZipCode:nil];
                                                _endRouteAnnotation.groundAnchor = CGPointMake(0.5f, 0.5f);
                                                [_googleMapView addAnnotation:_endRouteAnnotation];
                                                
                                                [self addLiveOverlayFrom:endLocation.coordinate to:_endAnnotation.position color:[UIColor dropoffTextColor]];
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

- (void) addLiveOverlayFrom:(CLLocationCoordinate2D)begin
                         to:(CLLocationCoordinate2D)end
                      color:(UIColor *)color
{
	double diffLat = (end.latitude - begin.latitude);
    double diffLng = (end.longitude - begin.longitude);
    
    double zoom = (_googleMapView.camera.zoom) * 2;
    
    double divLat = diffLat / zoom;
    double divLng = diffLng / zoom;
    
    CLLocationCoordinate2D tmpLat = begin;
    
    for(int i = 0; i < zoom; i++) {
        CLLocationCoordinate2D loopLatLng = tmpLat;
        
        if( i == (zoom - 1) ) {
            loopLatLng = end;
        } else {
            if(i > 0) {
                loopLatLng = CLLocationCoordinate2DMake(tmpLat.latitude + (divLat * 0.25f), tmpLat.longitude + (divLng * 0.25f));
            }
        }
        
        GMSMutablePath *path = [GMSMutablePath path];
        [path addCoordinate:loopLatLng];
        [path addCoordinate:CLLocationCoordinate2DMake(tmpLat.latitude + divLat, tmpLat.longitude + divLng)];
        
        GMSPolyline *route = [GMSPolyline polylineWithPath:path];
        route.strokeColor = [UIColor mapRouteColor];
        route.map = _googleMapView;
        route.strokeWidth = 5;
        [_googleMapOverlays addObject:route];

        tmpLat = CLLocationCoordinate2DMake(tmpLat.latitude + divLat, tmpLat.longitude + divLng);
    }
}

- (void)calculateFare
{
    if (_startAnnotation && _endAnnotation)
    {
        _priceView.hidden = YES;
        _bookingActivityIndicator.hidden = NO;
        _bookButton.enabled = NO;
        [_bookingActivityIndicator startAnimating];

        [[NetworkEngine getInstance] getTravelFare:_startAnnotation.position
                                                to:_endAnnotation.position
                                   completionBlock:^(NSObject *o)
                                    {
                                        _bookingActivityIndicator.hidden = YES;
                                        _bookButton.enabled = YES;
                                        _priceView.hidden = NO;
                                        NSDictionary* d = (NSDictionary*)o;
                                        _priceLabel.text = d[@"fare"][@"formatted_total_cost"];
                                        
                                        NSString *text;
                                        BOOL isMetric = [[NSLocale currentLocale] isMetricSystem];
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

- (void)mapView:(GMSMapView *)mapView idleAtCameraPosition:(GMSCameraPosition *)position
{
    _aButton.enabled = NO;
    _bButton.enabled = NO;
    _activityIndicatorView.hidden = NO;
    [_activityIndicatorView startAnimating];
    _bookingActivityIndicator.hidden = NO;
    [_bookingActivityIndicator startAnimating];
    _bookButton.enabled = NO;
    [self findAddressForLocation:position.target completionBlock:^(NSString *address, NSString *zipCode) {
        
        _aButton.enabled = YES;
        _bButton.enabled = YES;
        _activityIndicatorView.hidden = YES;
        _bookingActivityIndicator.hidden = YES;
        
        if (_startAnnotation)
        {
            if ([CabOfficeSettings dropoffLocationIsMandatory])
            {
                if (_endAnnotation)
                {
                    _bookButton.enabled = YES;
                }
                else
                {
                    _bookButton.enabled = NO;
                }
            }
            else
            {
                _bookButton.enabled = YES;
            }
        }
        
        self.locationName = address;
        self.zipCode = zipCode;
    }];    
}


#pragma mark IBActions

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
    if (![CabOfficeSettings useGoogleGeolocator])
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
                                address = [address stringByReplacingOccurrencesOfString:@"\n" withString:@" "];
                                NSString* zipCode = placemark.postalCode;
                                
                                NSLog(@"%@ \n%@", addressDictionary, address);
                                
                                if (address == nil || zipCode == nil)
                                {
                                    completionBlock(nil, nil);
                                    [MessageDialog showError:NSLocalizedString(@"map_aim_location_unknown_body", @"")
                                                   withTitle:NSLocalizedString(@"dialog_error_title", @"")];
                                }
                                else
                                {
                                    completionBlock(address, zipCode);
                                }
                            }
                            else
                            {
                                completionBlock(nil, nil);
                                [MessageDialog showError:NSLocalizedString(@"map_aim_location_unknown_body", @"")
                                               withTitle:NSLocalizedString(@"dialog_error_title", @"")];
                            }
                            
                        }];
    }
    else
    {
        [[NetworkEngine getInstance] cancelReverseForLocationOperations];
        [[NetworkEngine getInstance] getReverseForLocation:coordinate
                                           completionBlock:^(NSObject *response){
                                               NSArray *results = (NSArray *)response;
                                               if (results.count)
                                               {
                                                   NSString* route = nil;
                                                   NSString* streetNumber = nil;
                                                   NSString* address2 = nil;
                                                   NSString* city = nil;
                                                   NSString* state = nil;
                                                   NSString* country = nil;
                                                   NSString* postCode = nil;

                                                   NSDictionary* result = results[0];
                                                   NSArray* adressComponents = result[@"address_components"];
                                                   for (NSDictionary *d in adressComponents)
                                                   {
                                                       NSString *longName = d[@"long_name"];
                                                       NSArray *types = d[@"types"];
                                                       if( longName.length != 0 ) {
                                                           for (NSString* type in types)
                                                           {
                                                               if([type isEqualToString:@"street_number"]) {
                                                                   streetNumber = longName;
                                                               }
                                                               else if([type isEqualToString:@"route"]) {
                                                                   route = longName;
                                                               }
                                                               else if([type isEqualToString:@"sublocality"]) {
                                                                   address2 = longName;
                                                               }
                                                               else if([type isEqualToString:@"locality"]) {
                                                                   city = longName;
                                                               }
                                                               else if([type isEqualToString:@"postal_town"]) {
                                                                   city = longName;
                                                               }
                                                               else if([type isEqualToString:@"administrative_area_level_1"]) {
                                                                   state = longName;
                                                               }
                                                               else if([type isEqualToString:@"country"]) {
                                                                   country = longName;
                                                               }
                                                               else if([type isEqualToString:@"postal_code"]) {
                                                                   postCode = longName;
                                                               }
                                                           }
                                                       }
                                                   }
                                                   NSMutableString* address = [[NSMutableString alloc] init];
                                                   if (route)
                                                       [address appendString:route];
                                                   if (streetNumber)
                                                       [address appendFormat:@" %@", streetNumber];
                                                   if (address2)
                                                       [address appendFormat:@", %@", address2];
                                                   if (city)
                                                       [address appendFormat:@", %@", city];
                                                   if (state)
                                                       [address appendFormat:@", %@", state];
                                                   if (country)
                                                       [address appendFormat:@", %@", country];
 
                                                   completionBlock(address, postCode);
                                               }
                                               else
                                               {
                                                   completionBlock(nil, nil);
                                                   [MessageDialog showError:NSLocalizedString(@"map_aim_location_unknown_body", @"")
                                                                  withTitle:NSLocalizedString(@"dialog_error_title", @"")];
                                               }
                                           }
                                              failureBlock:^(NSError *error) {
                                                  completionBlock(nil, nil);
                                                  NSLog(@"Geocode failed with error: %@", error);
                                              }];
    }
    
    
}

- (IBAction)buttonAPressed:(id)sender {
    if (_locationName)
    {
        [self removeRoutes];
        [self setPickupLocation:_googleMapView.camera.target title:_locationName zipCode:_zipCode];
        [self calculateFare];
    }
}

- (IBAction)buttonBPressed:(id)sender {
    if (_locationName)
    {
        [self removeRoutes];
        [self setDropoffLocation:_googleMapView.camera.target title:_locationName zipCode:_zipCode];
        [self calculateFare];
    }
}

- (IBAction)myLocationButtonPressed:(id)sender {
    [self setMapCoordinate:_googleMapView.myLocation.coordinate];
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

                       _bookButton.enabled = NO;
                       _bookingActivityIndicator.hidden = NO;
                       [_bookingActivityIndicator startAnimating];

                       [[NetworkEngine getInstance] createBooking:_startAnnotation.title
                                                    pickupZipCode:_startAnnotation.zipCode
                                                   pickupLocation:_startAnnotation.position
                                                      dropoffName:_endAnnotation.title
                                                   dropoffZipCode:_endAnnotation.zipCode
                                                  dropoffLocation:_endAnnotation.position
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
                                                      _bookButton.enabled = YES;
                                                      _bookingActivityIndicator.hidden = YES;
                                                      [_bookingActivityIndicator stopAnimating];
                                                      
                                                      [self removeRoutes];
                                                      
                                                      if (_startAnnotation)
                                                      {
                                                          [_googleMapView removeAnnotation:_startAnnotation];
                                                          self.startAnnotation = nil;
                                                      }
                                                      
                                                      if (_endAnnotation)
                                                      {
                                                          [_googleMapView removeAnnotation:_endAnnotation];
                                                          self.endAnnotation = nil;
                                                      }
                                                      
                                                      [_pickupButton setTitle:NSLocalizedString(@"pickup_line_default", @"") forState:UIControlStateNormal];
                                                      [_dropoffButton setTitle:[self dropoffLine] forState:UIControlStateNormal];

                                                  }
                                                     failureBlock:^(NSError *error) {
                                                         _bookButton.enabled = YES;
                                                         _bookingActivityIndicator.hidden = YES;
                                                         [_bookingActivityIndicator stopAnimating];
                                                         [MessageDialog showError:[NSString stringWithFormat:NSLocalizedString(@"new_booking_failed_body_fmt", @""), error.localizedDescription]
                                                                        withTitle:NSLocalizedString(@"dialog_error_title", @"")];
                                                     }];
                   }];
}

- (IBAction)createNewBookingButtonPressed:(id)sender {

    [self removeRoutes];
    
    if (_startAnnotation)
    {
        [_googleMapView removeAnnotation:_startAnnotation];
    }
    self.startAnnotation = nil;

    if (_endAnnotation)
    {
        [_googleMapView removeAnnotation:_endAnnotation];
    }
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
    {
        [_googleMapView removeAnnotation:_startAnnotation];
    }
    self.startAnnotation = [[MapAnnotation alloc] initWithCoordinate:location
                                                           withTitle:title
                                                       withImageName:@"map_marker_pickup_big"
                                                         withZipCode:zipCode];
    [_googleMapView addAnnotation:_startAnnotation];

    if ([CabOfficeSettings dropoffLocationIsMandatory])
    {
        if (_endAnnotation)
        {
            _bookButton.enabled = YES;
        }
        else
        {
            _bookButton.enabled = NO;
        }
    }
    else
    {
        _bookButton.enabled = YES;
    }
}

- (void)setDropoffLocation:(CLLocationCoordinate2D)location
                     title:(NSString *)title
                   zipCode:(NSString *)zipCode
{
    [_dropoffButton setTitle:title forState:UIControlStateNormal];

    if (_endAnnotation)
    {
        [_googleMapView removeAnnotation:_endAnnotation];
    }
    self.endAnnotation = [[MapAnnotation alloc] initWithCoordinate:location
                                                         withTitle:title
                                                     withImageName:@"map_marker_dropoff"
                                                       withZipCode:zipCode];
    [_googleMapView addAnnotation:_endAnnotation];
 
    if ([CabOfficeSettings dropoffLocationIsMandatory] && _startAnnotation)
    {
        _bookButton.enabled = YES;
    }
}

- (IBAction)pickupLocationButtonPressed:(id)sender {
    [self showLocatioSelectionViewController:LocationTypePickup sender:sender];
}

- (IBAction)dropoffLocationButtonPressed:(id)sender {
    [self showLocatioSelectionViewController:LocationTypeDropoff sender:sender];
}

- (void)showLocatioSelectionViewController:(LocationType)type sender:(UIView *)sender
{
    LocationSelectorCompletionBlock completionBlock = ^(LocationType type, MapAnnotation *a) {
        
        if (a)
        {
            if (type == LocationTypePickup)
            {
                [self setPickupLocation:a.position title:a.title zipCode:a.zipCode];
            }
            else
            {
                [self setDropoffLocation:a.position title:a.title zipCode:a.zipCode];
            }
            
            [self setMapCoordinate:a.position];
            
            [self calculateFare];
        }

        if (IS_IPAD)
        {
            [self.searchPopover dismissPopoverAnimated:YES];
        }
        else
        {
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    };

    SearchViewController *l = [[SearchViewController alloc] init];
    l.locationType = type;
    if (type == LocationTypeDropoff && _endAnnotation)
    {
        l.annotation = _endAnnotation;
    }
    else if (type == LocationTypePickup && _startAnnotation)
    {
        l.annotation = _startAnnotation;
    }
    l.completionBlock = completionBlock;
    
    if (IS_IPAD)
    {
        self.searchPopover = [[UIPopoverController alloc] initWithContentViewController:l];
        _searchPopover.delegate = self;
        [_searchPopover presentPopoverFromRect:sender.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
    }
    else
    {
        [self presentViewController:l animated:YES completion:nil];
    }
}

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    self.searchPopover = nil;
}

#pragma mark booking history selection delegate

- (void)selectedBookingWithPickup:(NSString *)pickupName
                 andPickupZipCode:(NSString *)pickupZipCode
                andPickupLocation:(CLLocationCoordinate2D)pickupLocation
                   andDropoffName:(NSString *)dropoffName
                andDropoffZipCode:(NSString *)dropoffZipCode
               andDropoffLocation:(CLLocationCoordinate2D)dropoffLocation
                         onlyShow:(BOOL)onlyShow
{
    PKRevealController *rc = self.revealController;
    [rc showViewController:rc.frontViewController];

    if (onlyShow)
    {
        if (pickupName)
        {
            [self setMapCoordinate:pickupLocation];
        }
        else
        {
            [self setMapCoordinate:dropoffLocation];
        }
    }
    else
    {
        if (pickupName)
        {
            [self setPickupLocation:pickupLocation title:pickupName zipCode:pickupZipCode];
            [self setMapCoordinate:pickupLocation];
        }
        else
        {
            [self setMapCoordinate:dropoffLocation];
        }
        
        if (dropoffName)
        {
            [self setDropoffLocation:dropoffLocation title:dropoffName zipCode:dropoffZipCode];
        }

        [self calculateFare];
    }
}

@end
