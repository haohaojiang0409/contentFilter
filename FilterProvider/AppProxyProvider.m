//
//  AppProxyProvider.m
//  FilterProvider
//
//  Created by haohaojiang0409 on 2025/11/18.
//

#import "AppProxyProvider.h"

@implementation FilterDataProvider


- (NEFilterNewFlowVerdict *) handleNewFlow:(NEFilterFlow *) flow{
    //peekInboundBytes:用于控制 Network Extension 系统在调用 handleInboundDataFromFlow: 之前，最多缓存并传递多少字节的入站数据,后续数据仍会继续通过 handleInboundDataFromFlow: 分块传递
    return [NEFilterNewFlowVerdict filterDataVerdictWithFilterInbound:YES peekInboundBytes:64 filterOutbound:NO peekOutboundBytes:0];
}

//主App调用loadFromPreferences，扩展APP自动调用该方法传给主APP配置
- (void)applySettings:(nullable NEFilterSettings *)settings completionHandler:(nonnull void (^)(NSError * _Nullable __strong))completionHandler __attribute__((availability(macos, introduced=10.15))) __attribute__((availability(ios, unavailable))) __attribute__((availability(watchos, unavailable))) __attribute__((availability(tvos, unavailable))) {
    
}

//对一部分传入数据做出筛选决策
//调用时机：当在handleNewFlow中返回了filterDataVerdict且设置了filterInbound:YES，系统会自动在数据入站时自动使用此方法
- (nonnull NEFilterDataVerdict *)handleInboundDataFromFlow:(nonnull NEFilterFlow *)flow readBytesStartOffset:(NSUInteger)offset readBytes:(nonnull NSData *)readBytes __attribute__((availability(macos, introduced=10.15))) __attribute__((availability(ios, introduced=9.0))) __attribute__((availability(watchos, unavailable))) __attribute__((availability(tvos, unavailable))) {
    
    NSLog(@"[%s] do something",__FUNCTION__);
    //1.将数据转换为字符串编码
    NSString* text = [[NSString alloc] initWithData:readBytes encoding:NSUTF8StringEncoding];
    
    //2.判空
    if(!text){
        //如果为空说明非文本，直接放行
        return [NEFilterDataVerdict allowVerdict];
    }
    
    //3.定义黑名单关键词
    NSArray<NSString*> *blockKeywords = @[@"赌博", @"色情" , @"fuck" , @"操"];
    for(NSString* keyword in blockKeywords){
        if([text containsString:keyword]){
            NSLog(@"[%s] 检测内容非法!!!",__FUNCTION__);
            return [NEFilterDataVerdict dropVerdict];
        }
    }
    //4.未检测出来正常返回
    return [NEFilterDataVerdict allowVerdict];
}

//整个数据出站时完成调用
//✅ 在某个网络流（flow）的出站（outbound）数据传输完全结束时，通知你的扩展进行收尾处理。
- (nonnull NEFilterDataVerdict *)handleOutboundDataCompleteForFlow:(nonnull NEFilterFlow *)flow __attribute__((availability(macos, introduced=10.15))) __attribute__((availability(ios, introduced=9.0))) __attribute__((availability(watchos, unavailable))) __attribute__((availability(tvos, unavailable))) {
    NSLog(@"[%s] do something",__FUNCTION__);
    return [NEFilterDataVerdict allowVerdict];
}

//处理出站数据，方向和handleInboundData相反
- (nonnull NEFilterDataVerdict *)handleOutboundDataFromFlow:(nonnull NEFilterFlow *)flow readBytesStartOffset:(NSUInteger)offset readBytes:(nonnull NSData *)readBytes __attribute__((availability(macos, introduced=10.15))) __attribute__((availability(ios, introduced=9.0))) __attribute__((availability(watchos, unavailable))) __attribute__((availability(tvos, unavailable))) {
    NSLog(@"[%s] do something",__FUNCTION__);
    
    //1.转化为字符串对象
    NSString* text = [[NSString alloc] initWithData:readBytes encoding:NSUTF8StringEncoding];
    
    //2.判断是否为空
    if(!text){
        //如果为空说明不是字符串，可以全部放行
        return [NEFilterDataVerdict allowVerdict];
    }
    
    //3.检测敏感词:用正则表达式检测身份证号
    NSRegularExpression* regex = [NSRegularExpression regularExpressionWithPattern:@"\\d{17}[\\dXx]" options:0 error:nil];
    if([regex numberOfMatchesInString:text options:0 range:NSMakeRange(0 , text.length)] > 0){
        NSLog(@"检测到身份证号外传，阻断连接to %ld",(long)flow.direction);
        return [NEFilterDataVerdict dropVerdict];
    }
    
    if([text doesContain:@"password="] || [text doesContain:@"银行卡"]){
        return [NEFilterDataVerdict dropVerdict];
    }
    
    return [NEFilterDataVerdict allowVerdict];
}

//如果你在 handleNewFlow 中返回了 pauseVerdict，之后可以通过此方法恢复流并给出最终 verdict。
- (void)resumeFlow:(nonnull NEFilterFlow *)flow withVerdict:(nonnull NEFilterVerdict *)verdict __attribute__((availability(macos, introduced=10.15))) __attribute__((availability(ios, unavailable))) __attribute__((availability(watchos, unavailable))) __attribute__((availability(tvos, unavailable))) {
    
}


//动态更新已有流的行为
- (void)updateFlow:(nonnull NEFilterSocketFlow *)flow usingVerdict:(nonnull NEFilterDataVerdict *)verdict forDirection:(NETrafficDirection)direction __attribute__((availability(macos, introduced=10.15.4))) __attribute__((availability(ios, unavailable))) __attribute__((availability(watchos, unavailable))) __attribute__((availability(tvos, unavailable))) {
}

@end
