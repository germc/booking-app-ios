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

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

#import "MKNetworkEngine.h"

//completion blocks types
typedef void (^NetworkEngineCompletionBlock)(NSObject* response);
typedef void (^NetworkEngineFailureBlock)(NSError* error);

@interface NetworkEngine : MKNetworkEngine

@property (nonatomic, strong) NSDictionary* accountPreferences;

+ (NetworkEngine *)getInstance;

//OAuth login
- (NSString*)authUrl;

- (NSString*)redirectUrl;

- (void)getRefreshToken:(NSString*)authorizationCode
        completionBlock:(NetworkEngineCompletionBlock)completionBlock
           failureBlock:(NetworkEngineFailureBlock)failureBlock;

- (void)getAccessTokenForRefreshToken:(NSString*)token
                      completionBlock:(NetworkEngineCompletionBlock)completionBlock
                         failureBlock:(NetworkEngineFailureBlock)failureBlock;

- (void)createAccount:(NSString *)firstName
             lastName:(NSString *)lastName
                email:(NSString *)email
                phone:(NSString *)phone
             password:(NSString *)password
    completionBlock:(NetworkEngineCompletionBlock)completionBlock
         failureBlock:(NetworkEngineFailureBlock)failureBlock;

- (void)getTravelFare:(CLLocationCoordinate2D)start
                   to:(CLLocationCoordinate2D)to
      completionBlock:(NetworkEngineCompletionBlock)completionBlock
         failureBlock:(NetworkEngineFailureBlock)failureBlock;

- (void)getLatestBookings:(NetworkEngineCompletionBlock)completionBlock
             failureBlock:(NetworkEngineFailureBlock)failureBlock;

- (void)getAccountPreferences:(NetworkEngineCompletionBlock)completionBlock
                 failureBlock:(NetworkEngineFailureBlock)failureBlock;

- (void)getFleetData:(NetworkEngineCompletionBlock)completionBlock
        failureBlock:(NetworkEngineFailureBlock)failureBlock;

- (void)createBooking:(NSString *)pickupName
        pickupZipCode:(NSString *)pickupZipCode
       pickupLocation:(CLLocationCoordinate2D)pickupLocation
          dropoffName:(NSString *)dropoffName
       dropoffZipCode:(NSString *)dropoffZipCode
      dropoffLocation:(CLLocationCoordinate2D)dropoffLocation
           pickupDate:(NSDate *)pickupDate
      completionBlock:(NetworkEngineCompletionBlock)completionBlock
         failureBlock:(NetworkEngineFailureBlock)failureBlock;

- (void)cancelBooking:(NSString *)pk
      completionBlock:(NetworkEngineCompletionBlock)completionBlock
         failureBlock:(NetworkEngineFailureBlock)failureBlock;

- (void)getNearbyCabs:(CLLocationCoordinate2D )location
      completionBlock:(NetworkEngineCompletionBlock)completionBlock
         failureBlock:(NetworkEngineFailureBlock)failureBlock;

typedef enum LocationType
{
    LocationTypePickup = 0,
    LocationTypeDropoff
}LocationType;

- (void)searchForLocation:(NSString *)location
                     type:(LocationType)type
                    limit:(NSInteger)limit
          completionBlock:(NetworkEngineCompletionBlock)completionBlock
             failureBlock:(NetworkEngineFailureBlock)failureBlock;

//google map API
- (void)getDirectionsFrom:(CLLocationCoordinate2D)start
                       to:(CLLocationCoordinate2D)to
          completionBlock:(NetworkEngineCompletionBlock)completionBlock
             failureBlock:(NetworkEngineFailureBlock)failureBlock;

- (void)cancelReverseForLocationOperations;

- (void)getReverseForLocation:(CLLocationCoordinate2D)location
              completionBlock:(NetworkEngineCompletionBlock)completionBlock
                 failureBlock:(NetworkEngineFailureBlock)failureBlock;

@end
