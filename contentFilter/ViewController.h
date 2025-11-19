//
//  ViewController.h
//  contentFilter
//
//  Created by haohaojiang0409 on 2025/11/18.
//

#import <Cocoa/Cocoa.h>
#import <NetworkExtension/NetworkExtension.h>
#include <SystemExtensions/SystemExtensions.h>

@interface ViewController : NSViewController <OSSystemExtensionRequestDelegate>

//过滤器控制对象
@property (nonatomic , nonnull) NEFilterManager* manager;

@property (nonatomic, copy) void (^ _Nullable activationCompletion)(BOOL success);
@end

