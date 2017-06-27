//
//  RNTVRPlayer.m
//  RNVRPlayer
//
//  Created by 单强 on 2017/6/27.
//  Copyright © 2017年 单强. All rights reserved.
//

#import "RNTVRPlayer.h"
#import <React/RCTEventDispatcher.h>
#import <React/UIView+React.h>

@implementation RNTVRPlayer {
    RCTBridge *_bridge;
    NSTimer *_timer;
}

- (instancetype)init:(RCTBridge *)bridge {
    _bridge = bridge;
    return [super init];
}

- (void)open:(NSString *)uri callback:(CallbackBlock)callback {
    _timer = [NSTimer scheduledTimerWithTimeInterval:0.5
                                              target:self
                                            selector:@selector(updateProgress)
                                            userInfo:nil
                                             repeats:YES];
    [super open:uri callback:callback];
}

- (void)close {
    [_timer invalidate];
    [super close];
}

- (void)updateProgress {
    NSMutableDictionary *event = [NSMutableDictionary dictionaryWithDictionary:[super getProgress]];
    [event setValue:self.reactTag forKey:@"target"];
    [event setValue:@"onProgress" forKey:@"message"];
    [_bridge.eventDispatcher sendInputEventWithName:@"topChange" body:event];
}

- (void)reactSetFrame:(CGRect)frame
{
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    CGRect screenNativeBounds = [[UIScreen mainScreen] nativeBounds];
    int width = screenNativeBounds.size.width;
    int height = screenNativeBounds.size.height;
    if (screenBounds.size.width > screenBounds.size.height) {
        int tmp = width;
        width = height;
        height = tmp;
    }
    double wScale = width / screenBounds.size.width;
    double hScale = height / screenBounds.size.height;
    width = 1.0 * frame.size.width * wScale;
    height = 1.0 * frame.size.height * hScale;
    
    [super initRenderer:width height:height];
    [super reactSetFrame: frame];
}

@end
