//
//  Config.h
//  iPhoneAvailability
//
//  Created by 吴天 on 2016/9/27.
//  Copyright © 2016年 wutian. All rights reserved.
//

#ifndef Config_h
#define Config_h

#define StoresURL @"https://reserve.cdn-apple.com/CN/zh_CN/reserve/iPhone/stores.json"
#define AvailabilityURL @"https://reserve.cdn-apple.com/CN/zh_CN/reserve/iPhone/availability.json"

// TargetModel: 例如 @"MN8L2ZP/A" 代表 iPhone 7 128GB 黑色 https://reserve.cdn-apple.com/CN/zh_CN/reserve/iPhone/availability.json
#define TargetModel @""

// TargetModel: 例如 @"北京"，请从 Apple 的接口中找到合适的名称 https://reserve.cdn-apple.com/CN/zh_CN/reserve/iPhone/stores.json
#define TargetCity @""

#error 请先进行 Target 配置. Please set the target before building

#endif /* Config_h */
