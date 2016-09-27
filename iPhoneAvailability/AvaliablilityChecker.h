//
//  AvaliablilityChecker.h
//  iPhoneAvailability
//
//  Created by wutian on 2016/9/26.
//  Copyright © 2016年 wutian. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AvaliablilityChecker : NSObject

+ (instancetype)sharedChecker;

- (void)queryAvailabilityInfoWithCompletion:(void (^)(NSDictionary * storeNameToBoolMap, NSError *))completion;

@end
