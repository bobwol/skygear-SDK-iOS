//
//  ODUserLoginOperationTests.m
//  ODKit
//
//  Created by Patrick Cheung on 25/2/15.
//  Copyright (c) 2015 Kwok-kuen Cheung. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ODKit/ODKit.h>
#import <OHHTTPStubs/OHHTTPStubs.h>

SpecBegin(ODUserLoginOperation)

describe(@"login", ^{
    it(@"make ODRequest", ^{
        ODUserLoginOperation *operation = [[ODUserLoginOperation alloc] initWithEmail:@"user@example.com" password:@"password"];
        [operation prepareForRequest];
        ODRequest *request = operation.request;
        expect([request class]).to.beSubclassOf([ODRequest class]);
        expect(request.action).to.equal(@"auth:login");
        expect(request.payload[@"email"]).to.equal(@"user@example.com");
        expect(request.payload[@"password"]).to.equal(@"password");
    });

    it(@"make request", ^{
        ODUserLoginOperation *operation = [[ODUserLoginOperation alloc] initWithEmail:@"user@example.com" password:@"password"];
        
        [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
            return YES;
        } withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
            NSDictionary *parameters = @{
                                         @"user_id": @"USER_ID",
                                         @"access_token": @"ACCESS_TOKEN",
                                         };
            NSData *payload = [NSJSONSerialization dataWithJSONObject:@{@"result": parameters}
                                                              options:0
                                                                error:nil];
            
            return [OHHTTPStubsResponse responseWithData:payload
                                              statusCode:200
                                                 headers:@{}];
        }];
        
        waitUntil(^(DoneCallback done) {
            operation.loginCompletionBlock = ^(ODUserRecordID *recordID, ODAccessToken *accessToken, NSError *error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    expect(recordID.recordName).to.equal(@"USER_ID");
                    expect(accessToken.tokenString).to.equal(@"ACCESS_TOKEN");
                    expect(error).to.beNil();
                    done();
                });
            };

            [[[NSOperationQueue alloc] init] addOperation:operation];
        });
    });
    
    afterEach(^{
        [OHHTTPStubs removeAllStubs];
    });

});

SpecEnd
