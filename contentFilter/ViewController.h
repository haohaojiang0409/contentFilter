//
//  ViewController.h
//  contentFilter
//
//  Created by haohaojiang0409 on 2025/11/18.
//

#import <Cocoa/Cocoa.h>
#import <NetworkExtension/NetworkExtension.h>

@interface ViewController : NSViewController

//过滤器控制对象
@property (nonatomic , nonnull) NEFilterManager* manager;

@end

