//
//  ViewController.m
//  contentFilter
//
//  Created by haohaojiang0409 on 2025/11/18.
//

#import "ViewController.h"

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // Do any additional setup after loading the view.
}


- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}
- (IBAction)startFilter:(id)sender {
    // 1. 获取共享的过滤器管理器（推荐使用 sharedManager）
    self.manager = [NEFilterManager sharedManager];
    
    // 2. 先尝试加载现有配置（避免覆盖或冲突）
    [self.manager loadFromPreferencesWithCompletionHandler:^(NSError * _Nullable error) {
        if (error) {
            NSLog(@"⚠️ 无现有配置，将创建新配置: %@", error.localizedDescription);
        }
        
        // ⚠️ 替换为你的 Network Extension Target 的实际 Bundle ID
        self.manager.providerConfiguration.filterDataProviderBundleIdentifier = @"com.eagleyun.test.contentFilter.FilterProvider";
        // 5. 设置管理器属性
        self.manager.localizedDescription = @"My Content Filter"; // 用户可见名称
        self.manager.enabled = YES;
        
        // 6. 保存到系统偏好设置（会触发用户授权弹窗！）
        [self.manager saveToPreferencesWithCompletionHandler:^(NSError * _Nullable saveError) {
            if (saveError) {
                NSLog(@"❌ 启用内容过滤失败: %@", saveError);
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSAlert *alert = [[NSAlert alloc] init];
                    [alert setMessageText:@"启用内容过滤失败"];
                    [alert setInformativeText:[NSString stringWithFormat:@"错误：%@", saveError.localizedDescription]];
                    [alert setAlertStyle:NSAlertStyleWarning];
                    [alert addButtonWithTitle:@"确定"];
                    [alert beginSheetModalForWindow:self.view.window
                                  completionHandler:^(NSModalResponse returnCode) {
                        // 可选：处理用户点击（此处无操作）
                    }];
                });
            } else {
                NSLog(@"✅ 内容过滤器已成功启用");
                dispatch_async(dispatch_get_main_queue(), ^{
                    // 可更新 UI，如按钮状态、标签等
                    // 例如：
                    // self.statusLabel.stringValue = @"过滤器已启用";
                });
            }
        }];
    }];
}

- (IBAction)stopFilter:(id)sender {
    
}

@end
