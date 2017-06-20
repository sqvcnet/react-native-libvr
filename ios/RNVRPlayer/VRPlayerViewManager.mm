//
//  VRPlayerViewManager.mm
//  RNVRPlayer
//
//  Created by 单强 on 2017/06/20.
//  Copyright © 2017年 单强. All rights reserved.
//

#import "VRPlayerViewManager.h"
#import "VRPlayerView.h"

#import <Views/RCTUIManager.h>

@implementation VRPlayerViewManager {
}

RCT_EXPORT_MODULE()

- (UIView *)view
{
    return [[VRPlayerView alloc] init:self.bridge];
}

RCT_EXPORT_METHOD(customMethod:(NSNumber *)reactTag callback:(RCTResponseSenderBlock)callback) {
    [self.bridge.uiManager addUIBlock:^(RCTUIManager *uiManager, NSDictionary<NSNumber *, UIView *> *viewRegistry) {
        UIView *view = viewRegistry[reactTag];
        if (![view isKindOfClass:[VRPlayerView class]]) {
            RCTLog(@"Invalid view returned from registry, expecting MyCoolView, got: %@", view);
            return;
        }
        VRPlayerView *playerView = (VRPlayerView *)view;
        // Call your native component's method here
        [playerView customMethod];
    }];
}

RCT_CUSTOM_VIEW_PROPERTY(src, String, VRPlayerView)
{
    NSString *uri = [RCTConvert NSString:json];
    [view open:uri];
    return;
}

RCT_CUSTOM_VIEW_PROPERTY(play, BOOL, VRPlayerView)
{
    BOOL playOrPause = [RCTConvert BOOL:json];
    [view play:playOrPause];
    return;
}

RCT_CUSTOM_VIEW_PROPERTY(pauseRenderer, BOOL, VRPlayerView)
{
    BOOL isPauseRenderer = [RCTConvert BOOL:json];
    [view pauseRenderer:isPauseRenderer];
    return;
}

RCT_CUSTOM_VIEW_PROPERTY(codec, int, VRPlayerView)
{
    int codec = [RCTConvert int:json];
    [view setCodec:codec];
    return;
}

RCT_CUSTOM_VIEW_PROPERTY(close, BOOL, VRPlayerView)
{
    BOOL isClose = [RCTConvert BOOL:json];
    [view close:isClose];
    return;
}

RCT_CUSTOM_VIEW_PROPERTY(seek, double, VRPlayerView)
{
    double seek = [RCTConvert double:json];
    [view seek:seek];
    return;
}

RCT_CUSTOM_VIEW_PROPERTY(mode, int, VRPlayerView)
{
    int mode = [RCTConvert int:json];
    [view setMode:mode];
    return;
}

RCT_CUSTOM_VIEW_PROPERTY(rotateDegree, int, VRPlayerView)
{
    int degree = [RCTConvert int:json];
    [view setRotateDegree:degree];
    return;
}

RCT_CUSTOM_VIEW_PROPERTY(degree, int, VRPlayerView)
{
    int degree = [RCTConvert int:json];
    [view setViewPortDegree:degree];
    return;
}

@end
