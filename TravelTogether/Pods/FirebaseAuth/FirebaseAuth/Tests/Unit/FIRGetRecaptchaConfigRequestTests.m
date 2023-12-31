/*
 * Copyright 2022 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#import <XCTest/XCTest.h>

#import "FirebaseAuth/Sources/Backend/FIRAuthBackend.h"
#import "FirebaseAuth/Sources/Backend/RPC/FIRGetRecaptchaConfigRequest.h"
#import "FirebaseAuth/Sources/Backend/RPC/FIRGetRecaptchaConfigResponse.h"
#import "FirebaseAuth/Tests/Unit/FIRFakeBackendRPCIssuer.h"

/** @var kGetRecaptchaConfigEndPoint
    @brief The "getRecaptchaConfig" endpoint.
 */
static NSString *const kGetRecaptchaConfigEndPoint = @"recaptchaConfig";

/** @var kTestAPIKey
    @brief Fake API key used for testing.
 */
static NSString *const kTestAPIKey = @"APIKey";

/** @var kTestFirebaseAppID
    @brief Fake Firebase app ID used for testing.
 */
static NSString *const kTestFirebaseAppID = @"appID";

/** @var kAPIURLFormat
    @brief URL format for server API calls.
 */
static NSString *const kAPIURLFormat = @"https://identitytoolkit.googleapis.com/v2/%@?key=%@";

/** @var gAPIHost
    @brief Host for server API calls.
 */
static NSString *gAPIHost = @"www.googleapis.com";

@interface FIRGetRecaptchaConfigRequestTests : XCTestCase
@end

@implementation FIRGetRecaptchaConfigRequestTests {
  /** @var _RPCIssuer
      @brief This backend RPC issuer is used to fake network responses for each test in the suite.
          In the @c setUp method we initialize this and set @c FIRAuthBackend's RPC issuer to it.
   */
  FIRFakeBackendRPCIssuer *_RPCIssuer;
}

- (void)setUp {
  [super setUp];
  FIRFakeBackendRPCIssuer *RPCIssuer = [[FIRFakeBackendRPCIssuer alloc] init];
  [FIRAuthBackend setDefaultBackendImplementationWithRPCIssuer:RPCIssuer];
  _RPCIssuer = RPCIssuer;
}

- (void)tearDown {
  _RPCIssuer = nil;
  [FIRAuthBackend setDefaultBackendImplementationWithRPCIssuer:nil];
  [super tearDown];
}

/** @fn testGetRecaptchaConfigRequest
    @brief Tests get Recaptcha config request.
 */
- (void)testGetRecaptchaConfigRequest {
  FIRAuthRequestConfiguration *requestConfiguration =
      [[FIRAuthRequestConfiguration alloc] initWithAPIKey:kTestAPIKey appID:kTestFirebaseAppID];
  FIRGetRecaptchaConfigRequest *request =
      [[FIRGetRecaptchaConfigRequest alloc] initWithRequestConfiguration:requestConfiguration];

  [FIRAuthBackend getRecaptchaConfig:request
                            callback:^(FIRGetRecaptchaConfigResponse *_Nullable response,
                                       NSError *_Nullable error){

                            }];
  XCTAssertFalse([request containsPostBody]);
  // Confirm that the quest has no decoded body as it is get request.
  XCTAssertNil(_RPCIssuer.decodedRequest);
  NSMutableString *URLString =
      [NSMutableString stringWithFormat:kAPIURLFormat, kGetRecaptchaConfigEndPoint, kTestAPIKey];
  [URLString appendFormat:@"&%@=%@&%@=%@", @"clientType", @"CLIENT_TYPE_IOS", @"version",
                          @"RECAPTCHA_ENTERPRISE"];
  XCTAssertEqualObjects(URLString, [request requestURL].absoluteString);
}

@end
