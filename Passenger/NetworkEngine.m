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

#import <CoreLocation/CoreLocation.h>

#import "NetworkEngine.h"
#import "MKNetworkKit.h"
#import "UserSettings.h"

#define PASSENGER_SERVER_URL @"api.tdispatch.com"
#error "add your api key/secret/id here"
#define FLEET_API_KEY @"YOUR API KEY"
#define PASSENGER_CLIENT_ID @"YOUR CLIENT ID@tdispatch.com"
#define PASSENGER_CLIENT_SECRET @"YOUR SECRET"

#define PASSENGER_AUTH_URL @"http://api.tdispatch.com/passenger/oauth2/auth"
#define PASSENGER_TOKEN_URL @"http://api.tdispatch.com/passenger/oauth2/token"

// API
#define PASSENGER_API_PATH @"passenger/v1"

@interface NetworkEngine()

@property (nonatomic, strong) NSString* accessToken;

@end

@implementation NetworkEngine

+ (NetworkEngine *)getInstance
{
	static NetworkEngine *ineInstance;
	
	@synchronized(self)
	{
		if (!ineInstance)
		{
			ineInstance = [[NetworkEngine alloc] initWithHostName:PASSENGER_SERVER_URL
                                                          apiPath:PASSENGER_API_PATH
                                               customHeaderFields:@{@"Accept-Encoding" : @"gzip"}
                           ];
		}
		return ineInstance;
	}
}

- (NSError *)errorFromResponse:(NSDictionary *)response andError:(NSError *)error
{
    id message = response[@"message"];
    if (message)
    {
        if ([message isKindOfClass:[NSString class]])
        {
            return [NSError errorWithDescription:message];
        }
        else
        {
            NSDictionary *msg = message;
            NSString *text = msg[@"text"];
            if (text)
            {
                return [NSError errorWithDescription:text];
            }
        }
    }
    return error;
}

- (NSString*)redirectUrl
{
    return @"http://127.0.0.1";
}

- (NSString*)authUrl
{
    NSString* url = [NSString stringWithFormat:@"%@?response_type=code&client_id=%@&redirect_uri=%@&scope=&key=%@", PASSENGER_AUTH_URL, PASSENGER_CLIENT_ID, [self redirectUrl], FLEET_API_KEY];
    return [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}


- (void)getRefreshToken:(NSString*)authorizationCode
        completionBlock:(NetworkEngineCompletionBlock)completionBlock
           failureBlock:(NetworkEngineFailureBlock)failureBlock
{
    MKNetworkOperation *op = [self operationWithURLString:PASSENGER_TOKEN_URL
                                                   params:@{@"code":authorizationCode,
                                                            @"client_id":PASSENGER_CLIENT_ID,
                                                            @"client_secret":PASSENGER_CLIENT_SECRET,
                                                            @"redirect_url":@"",
                                                            @"grant_type":@"authorization_code"}
                                               httpMethod:@"POST"];
    
    [op setPostDataEncoding:MKNKPostDataEncodingTypeJSON];
    
    [op addCompletionHandler:^(MKNetworkOperation *operation) {
        NSDictionary* response = operation.responseJSON;

        self.accessToken = response[@"access_token"];
        [UserSettings setRefreshToken:response[@"refresh_token"]];
        completionBlock(nil);
        
    } errorHandler:^(MKNetworkOperation *errorOp, NSError* error) {
        failureBlock([self errorFromResponse:errorOp.responseJSON andError:error]);
    }];
    
    [self enqueueOperation:op];
}

- (void)getAccessTokenForRefreshToken:(NSString*)token
                      completionBlock:(NetworkEngineCompletionBlock)completionBlock
                         failureBlock:(NetworkEngineFailureBlock)failureBlock
{
    MKNetworkOperation *op = [self operationWithURLString:PASSENGER_TOKEN_URL
                                                   params:@{@"refresh_token":token,
                                                            @"client_id":PASSENGER_CLIENT_ID,
                                                            @"client_secret":PASSENGER_CLIENT_SECRET,
                                                            @"redirect_url":@"",
                                                            @"grant_type":@"refresh_token"}
                                               httpMethod:@"POST"];
    
    [op setPostDataEncoding:MKNKPostDataEncodingTypeJSON];
    
    [op addCompletionHandler:^(MKNetworkOperation *operation) {
        NSDictionary* response = operation.responseJSON;
        self.accessToken = response[@"access_token"];
        completionBlock(nil);
    } errorHandler:^(MKNetworkOperation *errorOp, NSError* error) {
        failureBlock([self errorFromResponse:errorOp.responseJSON andError:error]);
    }];
    
    [self enqueueOperation:op];
}

- (void)createAccount:(NSString *)firstName
             lastName:(NSString *)lastName
                email:(NSString *)email
                phone:(NSString *)phone
             password:(NSString *)password
      completionBlock:(NetworkEngineCompletionBlock)completionBlock
         failureBlock:(NetworkEngineFailureBlock)failureBlock
{
    NSMutableDictionary* params = [[NSMutableDictionary alloc] initWithDictionary:@{
                                        @"first_name": firstName,
                                        @"last_name" : lastName,
                                        @"email" : email,
                                        @"phone" : phone,
                                        @"password" : password,
                                        @"client_id" : PASSENGER_CLIENT_ID
                                   }];
    
    MKNetworkOperation *op = [self operationWithPath:[NSString stringWithFormat:@"accounts?key=%@", FLEET_API_KEY]
                                              params:params
                                          httpMethod:@"POST"
                                                 ssl:NO];
    
    [op setPostDataEncoding:MKNKPostDataEncodingTypeJSON];
    
    [op addCompletionHandler:^(MKNetworkOperation *operation) {
        NSDictionary* response = operation.responseJSON;
        self.accessToken = response[@"passenger"][@"access_token"];
        completionBlock(nil);
    } errorHandler:^(MKNetworkOperation *errorOp, NSError* error) {
        failureBlock([self errorFromResponse:errorOp.responseJSON andError:error]);
    }];
    
    [self enqueueOperation:op];
    
}

- (void)getTravelFare:(CLLocationCoordinate2D)start
                   to:(CLLocationCoordinate2D)to
      completionBlock:(NetworkEngineCompletionBlock)completionBlock
         failureBlock:(NetworkEngineFailureBlock)failureBlock
{
    MKNetworkOperation *op = [self operationWithPath:[NSString stringWithFormat:@"%@?access_token=%@", @"locations/fare", _accessToken]
                                              params:@{
                              @"pickup_location": @{
                                @"lat" : [NSNumber numberWithDouble:start.latitude],
                                @"lng" : [NSNumber numberWithDouble:start.longitude]
                              },
                              @"dropoff_location": @{
                                @"lat" : [NSNumber numberWithDouble:to.latitude],
                                @"lng" : [NSNumber numberWithDouble:to.longitude]
                              }
                              }
                                          httpMethod:@"POST"
                                                 ssl:NO];
    
    [op setPostDataEncoding:MKNKPostDataEncodingTypeJSON];
    
    [op addCompletionHandler:^(MKNetworkOperation *operation) {
        NSDictionary* response = operation.responseJSON;
        completionBlock(response);
    } errorHandler:^(MKNetworkOperation *errorOp, NSError* error) {
        failureBlock([self errorFromResponse:errorOp.responseJSON andError:error]);
    }];
    
    [self enqueueOperation:op];

}

- (void)getLatestBookings:(NetworkEngineCompletionBlock)completionBlock
             failureBlock:(NetworkEngineFailureBlock)failureBlock
{
    MKNetworkOperation *op = [self operationWithPath:[NSString stringWithFormat:@"%@?order_by=-pickup_time&limit=20&status=draft,incoming,completed,confirmed,active&access_token=%@", @"/bookings", _accessToken]
                                              params:nil
                                          httpMethod:@"GET"
                                                 ssl:NO];
    
    [op addCompletionHandler:^(MKNetworkOperation *operation) {
        NSDictionary* response = operation.responseJSON;
        completionBlock(response[@"bookings"]);
    } errorHandler:^(MKNetworkOperation *errorOp, NSError* error) {
        failureBlock([self errorFromResponse:errorOp.responseJSON andError:error]);
    }];
    
    [self enqueueOperation:op];
}

- (void)getAccountPreferences:(NetworkEngineCompletionBlock)completionBlock
                 failureBlock:(NetworkEngineFailureBlock)failureBlock
{

    MKNetworkOperation *op = [self operationWithPath:[NSString stringWithFormat:@"%@?access_token=%@", @"/accounts/preferences", _accessToken]
                                              params:nil
                                          httpMethod:@"GET"
                                                 ssl:NO];
    
    [op addCompletionHandler:^(MKNetworkOperation *operation) {
        NSDictionary* response = operation.responseJSON;
        completionBlock(response[@"preferences"]);
    } errorHandler:^(MKNetworkOperation *errorOp, NSError* error) {
        failureBlock([self errorFromResponse:errorOp.responseJSON andError:error]);
    }];
    
    [self enqueueOperation:op];
}

- (void)getFleetData:(NetworkEngineCompletionBlock)completionBlock
        failureBlock:(NetworkEngineFailureBlock)failureBlock
{
    MKNetworkOperation *op = [self operationWithPath:[NSString stringWithFormat:@"%@?access_token=%@", @"accounts/fleetdata", _accessToken]
                                              params:nil
                                          httpMethod:@"GET"
                                                 ssl:NO];
    
    [op addCompletionHandler:^(MKNetworkOperation *operation) {
        NSDictionary* response = operation.responseJSON;
        completionBlock(response[@"data"]);
    } errorHandler:^(MKNetworkOperation *errorOp, NSError* error) {
        failureBlock([self errorFromResponse:errorOp.responseJSON andError:error]);
    }];
    
    [self enqueueOperation:op];
}

- (void)searchForLocation:(NSString *)location
                     type:(LocationType)type
          completionBlock:(NetworkEngineCompletionBlock)completionBlock
             failureBlock:(NetworkEngineFailureBlock)failureBlock
{
    NSMutableString* path = [[NSMutableString alloc] init];
    
    location = [location stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    [path appendFormat:@"%@?q=%@&limit=6&access_token=%@", @"/locations/search", location, _accessToken];
    
    if (type == LocationTypePickup)
        [path appendString:@"&type=pickup"];
        
    MKNetworkOperation *op = [self operationWithPath:path
                                              params:nil
                                          httpMethod:@"GET"
                                                 ssl:NO];
    
    [op addCompletionHandler:^(MKNetworkOperation *operation) {
        NSDictionary* response = operation.responseJSON;
        completionBlock(response[@"locations"]);
    } errorHandler:^(MKNetworkOperation *errorOp, NSError* error) {
        failureBlock([self errorFromResponse:errorOp.responseJSON andError:error]);
    }];
    
    [self enqueueOperation:op];
}

- (void)getDirectionsFrom:(CLLocationCoordinate2D)start
                       to:(CLLocationCoordinate2D)to
          completionBlock:(NetworkEngineCompletionBlock)completionBlock
             failureBlock:(NetworkEngineFailureBlock)failureBlock
{
    NSMutableString* urlString = [[NSMutableString alloc] init];
    [urlString appendString:@"http://maps.googleapis.com/maps/api/directions/json"];
    [urlString appendFormat:@"?origin=%f,%f", start.latitude, start.longitude];
    [urlString appendFormat:@"&destination=%f,%f", to.latitude, to.longitude];
    [urlString appendString:@"&sensor=false&units=metric&mode=driving"];

    MKNetworkOperation *op = [self operationWithURLString:urlString
                                                   params:nil
                                               httpMethod:@"GET"];
    
    [op addCompletionHandler:^(MKNetworkOperation *operation) {
        NSDictionary* response = operation.responseJSON;
        
        NSMutableArray* pointsToDraw = nil;

        NSArray* routes = response[@"routes"];
        if (routes && routes.count)
        {
            NSString* points = routes[0][@"overview_polyline"][@"points"];
            pointsToDraw = [[NSMutableArray alloc] init];
        
            int len = points.length;
            int index = 0;
            int lat = 0;
            int lng = 0;
            
            while( index < len ) {
                int b;
                int shift = 0;
                int result = 0;
                do {
                    b = [points characterAtIndex:index] - 63;
                    index++;
                    result |= (b & 0x1f) << shift;
                    shift += 5;
                } while( b >= 0x20 );
                int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
                lat += dlat;
                
                shift = 0;
                result = 0;
                do {
                    b = [points characterAtIndex:index] - 63;
                    index++;
                    result |= (b & 0x1f) << shift;
                    shift += 5;
                } while( b >= 0x20 );
                int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
                lng += dlng;
                
                CLLocation* location = [[CLLocation alloc] initWithLatitude:lat / 1E5 longitude:lng / 1E5];
                [pointsToDraw addObject:location];
            }
        }
        
        completionBlock(pointsToDraw);
        
    } errorHandler:^(MKNetworkOperation *errorOp, NSError* error) {
        failureBlock(error);
    }];
    
    [self enqueueOperation:op];

}

- (void)getReverseForLocation:(CLLocationCoordinate2D)location
              completionBlock:(NetworkEngineCompletionBlock)completionBlock
                 failureBlock:(NetworkEngineFailureBlock)failureBlock
{
    NSMutableString* urlString = [[NSMutableString alloc] init];
    [urlString appendString:@"http://maps.googleapis.com/maps/api/geocode/json?latlng="];
    [urlString appendFormat:@"%f,%f", location.latitude, location.longitude];
    [urlString appendFormat:@"&sensor=true"];
    
    MKNetworkOperation *op = [self operationWithURLString:urlString
                                                   params:nil
                                               httpMethod:@"GET"];
    
    [op addCompletionHandler:^(MKNetworkOperation *operation) {
        NSDictionary* response = operation.responseJSON;
        
        NSString *status = response[@"status"];
        if ([status isEqualToString:@"OK"])
            completionBlock(response[@"results"]);
        else
            failureBlock([NSError errorWithDescription:[NSString stringWithFormat:@"status: %@", status]]);
    } errorHandler:^(MKNetworkOperation *errorOp, NSError* error) {
        failureBlock(error);
    }];
    
    [self enqueueOperation:op];
}

- (void)createBooking:(NSString *)pickupName
        pickupZipCode:(NSString *)pickupZipCode
       pickupLocation:(CLLocationCoordinate2D)pickupLocation
          dropoffName:(NSString *)dropoffName
       dropoffZipCode:(NSString *)dropoffZipCode
      dropoffLocation:(CLLocationCoordinate2D)dropoffLocation
           pickupDate:(NSDate *)pickupDate
      completionBlock:(NetworkEngineCompletionBlock)completionBlock
         failureBlock:(NetworkEngineFailureBlock)failureBlock

{
    
    NSMutableDictionary* params = [[NSMutableDictionary alloc] initWithDictionary:@{
                                                                                  @"pickup_location": @{
                                                                                          @"postcode" : pickupZipCode,
                                                                                          @"address" : pickupName,
                                                                                          @"location" : @{
                                                                                                  @"lat" : [NSNumber numberWithFloat:pickupLocation.latitude],
                                                                                                  @"lng" : [NSNumber numberWithFloat:pickupLocation.longitude]
                                                                                                  }
                                                                                          }
                                  }];
    
    if (dropoffName)
    {
        [params addEntriesFromDictionary:@{
                                            @"dropoff_location": @{
                                                @"postcode" : dropoffZipCode,
                                                @"address" : dropoffName,
                                                @"location" : @{
                                                    @"lat" : [NSNumber numberWithFloat:dropoffLocation.latitude],
                                                    @"lng" : [NSNumber numberWithFloat:dropoffLocation.longitude]
                                                }
                                            }
                                        }];
    }
    
    if (pickupDate)
    {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy'-'MM'-'dd'T'HH':'mm':'ssZZZZZ"];
        NSString* str = [dateFormatter stringFromDate:pickupDate];
        params[@"pickup_time"] = [str stringByReplacingOccurrencesOfString:@"GMT" withString:@""];;
    }
    
    params[@"status"] = @"incoming";
    
    MKNetworkOperation *op = [self operationWithPath:[NSString stringWithFormat:@"%@?access_token=%@", @"bookings", _accessToken]
                                              params:params
                                          httpMethod:@"POST"
                                                 ssl:NO];
    
    [op setPostDataEncoding:MKNKPostDataEncodingTypeJSON];
    
    [op addCompletionHandler:^(MKNetworkOperation *operation) {
        NSDictionary* response = operation.responseJSON;
        completionBlock(response[@"booking"]);
    } errorHandler:^(MKNetworkOperation *errorOp, NSError* error) {
        failureBlock([self errorFromResponse:errorOp.responseJSON andError:error]);
    }];
    
    [self enqueueOperation:op];

}

- (void)cancelBooking:(NSString *)pk
      completionBlock:(NetworkEngineCompletionBlock)completionBlock
         failureBlock:(NetworkEngineFailureBlock)failureBlock
{
    MKNetworkOperation *op = [self operationWithPath:[NSString stringWithFormat:@"bookings/%@/cancel?access_token=%@", pk, _accessToken]
                                              params:nil
                                          httpMethod:@"POST"
                                                 ssl:NO];
    
    [op setPostDataEncoding:MKNKPostDataEncodingTypeJSON];
    
    [op addCompletionHandler:^(MKNetworkOperation *operation) {
        completionBlock(nil);
    } errorHandler:^(MKNetworkOperation *errorOp, NSError* error) {
        failureBlock([self errorFromResponse:errorOp.responseJSON andError:error]);
    }];
    
    [self enqueueOperation:op];

}

- (void)getNearbyCabs:(CLLocationCoordinate2D )location
      completionBlock:(NetworkEngineCompletionBlock)completionBlock
         failureBlock:(NetworkEngineFailureBlock)failureBlock
{
    NSMutableDictionary* params = [[NSMutableDictionary alloc] initWithDictionary:@{
                                    @"limit" : [NSNumber numberWithInteger:15],
                                    @"radius" : [NSNumber numberWithFloat:10],
                                    @"offset" : [NSNumber numberWithInt:0],
                                    @"location" : @{
                                        @"lng" : [NSNumber numberWithDouble:location.longitude],
                                        @"lat" : [NSNumber numberWithDouble:location.latitude]
                                    }
                                   }];

    MKNetworkOperation *op = [self operationWithPath:[NSString stringWithFormat:@"%@?access_token=%@", @"drivers/nearby", _accessToken]
                                              params:params
                                          httpMethod:@"POST"
                                                 ssl:NO];
    
    [op setPostDataEncoding:MKNKPostDataEncodingTypeJSON];
    
    [op addCompletionHandler:^(MKNetworkOperation *operation) {
        completionBlock(operation.responseJSON[@"drivers"]);
    } errorHandler:^(MKNetworkOperation *errorOp, NSError* error) {
        failureBlock([self errorFromResponse:errorOp.responseJSON andError:error]);
    }];
    
    [self enqueueOperation:op];    
}

@end
