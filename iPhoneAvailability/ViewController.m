//
//  ViewController.m
//  iPhoneAvailability
//
//  Created by wutian on 2016/9/26.
//  Copyright © 2016年 wutian. All rights reserved.
//

#import "ViewController.h"
#import "AvaliablilityChecker.h"

@interface ViewController () <NSUserNotificationCenterDelegate>
@property (unsafe_unretained) IBOutlet NSTextView *textView;
@property (weak) IBOutlet NSButton *refreshButton;
@property (nonatomic, assign) BOOL observing;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    [[NSUserNotificationCenter defaultUserNotificationCenter] setDelegate:self];
    
    // Do any additional setup after loading the view.
}


- (void)setRepresentedObject:(id)representedObject
{
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}

- (void)setObserving:(BOOL)observing
{
    if (_observing != observing) {
        _observing = observing;
        
        if (observing) {
            [self refresh];
        } else {
            [NSObject cancelPreviousPerformRequestsWithTarget:self];
        }
    }
}

- (IBAction)startReservation:(id)sender
{
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"https://reserve.cdn-apple.com/CN/zh_CN/reserve/iPhone/availability?channel=1"]];
}

- (void)userNotificationCenter:(NSUserNotificationCenter *)center didActivateNotification:(NSUserNotification *)notification
{
    [self startReservation:nil];
}

- (void)refresh
{
    [[AvaliablilityChecker sharedChecker] queryAvailabilityInfoWithCompletion:^(NSDictionary *storeNameToBoolMap, NSError * error) {
        if (storeNameToBoolMap.count) {
            NSMutableAttributedString * text = self.textView.textStorage;
            [text setAttributedString:[[NSAttributedString alloc] initWithString:@""]];
            
            NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
            formatter.dateStyle = NSDateFormatterShortStyle;
            formatter.timeStyle = NSDateFormatterMediumStyle;
            
            NSAttributedString * (^append)(NSString *, NSColor * color) = ^NSAttributedString *(NSString * string, NSColor * color) {
                NSAttributedString * attr = [[NSAttributedString alloc] initWithString:string attributes:@{NSFontAttributeName: [NSFont systemFontOfSize:16], NSForegroundColorAttributeName: color ? : [NSColor blackColor]}];
                [text appendAttributedString:attr];
                return attr;
            };
            
            append(@"\n", nil);
            append([formatter stringFromDate:[NSDate date]], nil);
            append(@"\n\n", nil);
            NSString * __block validStore = nil;
            [storeNameToBoolMap enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
                BOOL value = [obj boolValue];
                NSString * string = [NSString stringWithFormat:@"%@: %@\n", key, value ? @"可预约" : @"无"];
                NSColor * color = value ? [NSColor colorWithRed:0 green:0.5 blue:0 alpha:1.0] : [NSColor redColor];
                append(string, color);
                if (value) {
                    validStore = key;
                }
            }];
            if (validStore) {
                [self sendNotificationWithStore:validStore];
            }
        } else {
            self.textView.string = [NSString stringWithFormat:@"请求失败: %@", error ? : @"可能是非预约时间"];
        }
        
        NSLog(@"%@", self.textView.string);
        
        if (self.observing) {
            [self performSelector:@selector(refresh) withObject:nil afterDelay:10];
        }
    }];
}

- (void)sendNotificationWithStore:(NSString *)storeName
{
    [NSApp hide:nil];

    NSUserNotification * notification = [[NSUserNotification alloc] init];
    notification.title = @"可以预约啦！";
    notification.subtitle = [NSString stringWithFormat:@"%@ 现在可以进行预约", storeName];
    
    [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:notification];
}

- (IBAction)refreshButtonPressed:(id)sender
{
    self.observing = !self.observing;
    self.refreshButton.title = self.observing ? @"正在监控" : @"开始监控";
}


@end
