//
//  AvaliablilityChecker.m
//  iPhoneAvailability
//
//  Created by wutian on 2016/9/26.
//  Copyright © 2016年 wutian. All rights reserved.
//

#import "AvaliablilityChecker.h"
#import <AFNetworking/AFNetworking.h>
#import "Config.h"

@interface AvaliablilityChecker ()

@property (nonatomic, strong) NSDictionary<NSString *, NSString *> * storeIDToNameMap;
//@property (nonatomic, strong) NSDictionary * storeNameToIDMap;
@property (nonatomic, strong) NSDictionary<NSString *, NSArray<NSString *> *> * storeCityToStoreIDsMap;
@property (nonatomic, strong) NSString * reservationURL;

@property (nonatomic, strong) AFURLSessionManager * sessionManager;
@property (nonatomic, strong) NSError * storeError;

@end

@implementation AvaliablilityChecker

+ (instancetype)sharedChecker
{
    static AvaliablilityChecker * checker = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        checker = [[[self class] alloc] init];
    });
    return checker;
}

- (instancetype)init
{
    if (self = [super init]) {
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
        manager.responseSerializer = [AFJSONResponseSerializer serializer];
        _sessionManager = manager;
    }
    return self;
}

- (void)requestURL:(NSString *)url completion:(void (^)(id responseObject, NSError * error))completion
{
    NSURLRequest * request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    [[_sessionManager dataTaskWithRequest:request completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        if (completion) {
            completion(responseObject, error);
        }
    }] resume];
}

- (void)reloadStoreInfoWithCompletion:(void (^)(void))completion
{
    [self requestURL:StoresURL completion:^(id responseObject, NSError *error) {
        _storeError = error;
        if (!error) {
            _reservationURL = responseObject[@"reservationURL"];
            NSArray * stores = responseObject[@"stores"];
            NSMutableDictionary * storeIDMap = [NSMutableDictionary dictionary];
            NSMutableDictionary * storeCityMap = [NSMutableDictionary dictionary];
            
            for (NSDictionary * store in stores) {
                NSString * city = store[@"storeCity"];
                NSString * name = store[@"storeName"];
                NSString * number = store[@"storeNumber"];
                NSMutableArray * cityArray = storeCityMap[city];
                if (!cityArray) {
                    cityArray = [NSMutableArray array];
                    storeCityMap[city] = cityArray;
                }
                [cityArray addObject:number];
                
                storeIDMap[number] = name;
            }
            _storeIDToNameMap = storeIDMap;
            _storeCityToStoreIDsMap = storeCityMap;
        }
        if (completion) {
            completion();
        }
    }];
}

- (void)queryAvailabilityInfoWithCompletion:(void (^)(NSDictionary *, NSError *))completion
{
    if (!completion) {
        return;
    }

    void (^work)(void) = ^{
        if (!_storeIDToNameMap) {
            completion(nil, _storeError);
            return;
        }
        
        [self requestURL:AvailabilityURL completion:^(id responseObject, NSError *error) {
            if (error) {
                completion(nil, error);
                return;
            }
            
//            if (![responseObject count]) {
//                NSString * path = [[NSBundle mainBundle] pathForResource:@"mock" ofType:@"json"];
//                NSData * mock = [NSData dataWithContentsOfFile:path];
//                responseObject = [NSJSONSerialization JSONObjectWithData:mock options:NSJSONReadingAllowFragments error:NULL];
//            }
//            
            NSString * model = TargetModel;
            NSMutableDictionary * result = [NSMutableDictionary dictionary];
            NSArray * beijingStores = _storeCityToStoreIDsMap[TargetCity];
            
            for (NSString * storeID in beijingStores) {
                NSDictionary * store = responseObject[storeID];
                NSString * value = store[model];
                NSString * name = _storeIDToNameMap[storeID] ? : storeID;
                if ([value.lowercaseString isEqual:@"none"]) {
                    result[name] = @0;
                } else {
                    result[name] = @1;
                }
            }
            completion(result, nil);
        }];
    };
    
    if (_storeIDToNameMap && _storeCityToStoreIDsMap) {
        work();
    } else {
        [self reloadStoreInfoWithCompletion:work];
    }
}

@end
