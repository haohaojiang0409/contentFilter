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
    NSString* extensionBundleId = @"com.eagleyun.test.contentFilter.FilterProvider";
    NSLog(@"正在激活系统拓展:%@",extensionBundleId);
    
    OSSystemExtensionRequest* request = [OSSystemExtensionRequest activationRequestForExtension:extensionBundleId queue:dispatch_get_main_queue()];
    
    request.delegate = self;
    
    // 保存回调，用于后续配置
    __weak typeof(self) weakSelf = self;
    self.activationCompletion = ^(BOOL success) {
        __strong typeof(self) strongSelf = weakSelf;
        if (success) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [strongSelf configureNetworkExtension];
            });
        }
    };
    
    [[OSSystemExtensionManager sharedManager] submitRequest:request];
}

-(void)configureNetworkExtension{
    // 1. 获取共享的过滤器管理器（推荐使用 sharedManager）
    self.manager = [NEFilterManager sharedManager];
    
    // 2. 先尝试加载现有配置（避免覆盖或冲突）
    [self.manager loadFromPreferencesWithCompletionHandler:^(NSError * _Nullable error) {
        if (error) {
            NSLog(@"⚠️ 无现有配置，将创建新配置: %@", error.localizedDescription);
        }
        
        NEFilterProviderConfiguration *newConfiguration = [NEFilterProviderConfiguration new];
        newConfiguration.username = @"testdemo";
        newConfiguration.filterSockets = YES;
        newConfiguration.filterPackets = NO;
        newConfiguration.filterDataProviderBundleIdentifier = @"com.eagleyun.test.contentFilter.FilterProvider";
        // ⚠️ 替换为你的 Network Extension Target 的实际 Bundle ID
        self.manager.providerConfiguration = newConfiguration;
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
                    //安装网络扩展到系统中
                    
                });
            }
        }];
    }];
}

// MARK: - OSSystemExtensionRequestDelegate

- (void)requestNeedsUserApproval:(OSSystemExtensionRequest *)request {
    NSLog(@"请用户前往「系统设置 > 隐私与安全性」批准扩展");
    dispatch_async(dispatch_get_main_queue(), ^{
        [self showAlert:@"需要授权"
                  message:@"请前往「系统设置 > 隐私与安全性」，在底部点击“批准”以允许网络扩展。"];
    });
}

- (void)request:(OSSystemExtensionRequest *)request didFailWithError:(NSError *)error {
    NSLog(@"激活扩展失败: %@", error);
    dispatch_async(dispatch_get_main_queue(), ^{
        [self showAlert:@"激活失败" message:error.localizedDescription];
    });
    if (self.activationCompletion) self.activationCompletion(NO);
}

- (void)request:(OSSystemExtensionRequest *)request didFinishWithResult:(OSSystemExtensionRequestResult)result {
    BOOL success = (result == OSSystemExtensionRequestCompleted);
    if (success) {
        NSLog(@"✅ 系统扩展激活成功");
    } else {
        NSLog(@"❌ 激活结果异常: %ld", (long)result);
    }
    if (self.activationCompletion) self.activationCompletion(success);
}

- (OSSystemExtensionReplacementAction)request:(nonnull OSSystemExtensionRequest *)request actionForReplacingExtension:(nonnull OSSystemExtensionProperties *)existing withExtension:(nonnull OSSystemExtensionProperties *)ext { 
    NSLog(@"Method '%s' invoked with %@, %@ -> %@", __PRETTY_FUNCTION__, request.identifier, existing.bundleShortVersion, ext.bundleShortVersion);
    return OSSystemExtensionReplacementActionReplace;
}


// MARK: - Helper
- (void)showAlert:(NSString *)title message:(NSString *)message {
    NSAlert *alert = [[NSAlert alloc] init];
    [alert setMessageText:title];
    [alert setInformativeText:message];
    [alert setAlertStyle:NSAlertStyleWarning];
    [alert addButtonWithTitle:@"确定"];
    [alert beginSheetModalForWindow:self.view.window completionHandler:nil];
}

- (IBAction)stopFilter:(id)sender {
    
}

@end
