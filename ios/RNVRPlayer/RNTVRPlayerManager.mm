//
//  RNTVRPlayerManager.mm
//  RNVRPlayer
//
//  Created by 单强 on 2017/06/20.
//  Copyright © 2017年 单强. All rights reserved.
//

#import "RNTVRPlayerManager.h"
#import "RNTVRPlayer.h"

#import <React/RCTUIManager.h>

@implementation RNTVRPlayerManager {
}

RCT_EXPORT_MODULE()

- (UIView *)view
{
    return [[RNTVRPlayer alloc] init:self.bridge];
}

typedef void (^ResponseViewBlock)(RNTVRPlayer *view);
- (void)getView:(nonnull NSNumber *)reactTag callback:(ResponseViewBlock)callback {
    [self.bridge.uiManager addUIBlock:^(RCTUIManager *uiManager, NSDictionary<NSNumber *, UIView *> *viewRegistry) {
        UIView *view = viewRegistry[reactTag];
        if (![view isKindOfClass:[RNTVRPlayer class]]) {
            RCTLog(@"Invalid view returned from registry, expecting RNTVRPlayer, got: %@", view);
            callback(nil);
            return;
        }
        RNTVRPlayer *playerView = (RNTVRPlayer *)view;
        // Call your native component's method here
        callback(playerView);
    }];
}

RCT_EXPORT_METHOD(setMode:(nonnull NSNumber *)reactTag mode:(NSNumber *)mode callback:(RCTResponseSenderBlock)callback) {
    [self getView:reactTag callback:^(RNTVRPlayer *view) {
        if (!view) {
            NSArray *error = [[NSArray alloc] initWithObjects:@"Invalid view returned from registry", nil];
            callback(error);
            return;
        }
        [view setMode:[mode intValue]];
        callback([[NSArray alloc] initWithObjects:@"", nil]);
    } ];
}

RCT_EXPORT_METHOD(setCodec:(nonnull NSNumber *)reactTag codec:(NSNumber *)codec callback:(RCTResponseSenderBlock)callback) {
    [self getView:reactTag callback:^(RNTVRPlayer *view) {
        if (!view) {
            NSArray *error = [[NSArray alloc] initWithObjects:@"Invalid view returned from registry", nil];
            callback(error);
            return;
        }
        [view setCodec:[codec intValue]];
        callback([[NSArray alloc] initWithObjects:@"", nil]);
    } ];
}

RCT_EXPORT_METHOD(open:(nonnull NSNumber *)reactTag uri:(NSString *)uri callback:(RCTResponseSenderBlock)callback) {
    [self getView:reactTag callback:^(RNTVRPlayer *view) {
        if (!view) {
            NSArray *error = [[NSArray alloc] initWithObjects:@"Invalid view returned from registry", nil];
            callback(error);
            return;
        }
        [view open:uri];
        callback([[NSArray alloc] initWithObjects:@"", nil]);
    } ];
}

RCT_EXPORT_METHOD(play:(nonnull NSNumber *)reactTag callback:(RCTResponseSenderBlock)callback) {
    [self getView:reactTag callback:^(RNTVRPlayer *view) {
        if (!view) {
            NSArray *error = [[NSArray alloc] initWithObjects:@"Invalid view returned from registry", nil];
            callback(error);
            return;
        }
        [view play:YES];
        callback([[NSArray alloc] initWithObjects:@"", nil]);
    } ];
}

RCT_EXPORT_METHOD(pause:(nonnull NSNumber *)reactTag callback:(RCTResponseSenderBlock)callback) {
    [self getView:reactTag callback:^(RNTVRPlayer *view) {
        if (!view) {
            NSArray *error = [[NSArray alloc] initWithObjects:@"Invalid view returned from registry", nil];
            callback(error);
            return;
        }
        [view play:NO];
        callback([[NSArray alloc] initWithObjects:@"", nil]);
    } ];
}

RCT_CUSTOM_VIEW_PROPERTY(src, String, RNTVRPlayer)
{
    NSString *uri = [RCTConvert NSString:json];
    [view setURI:uri];
    return;
}

RCT_CUSTOM_VIEW_PROPERTY(play, BOOL, RNTVRPlayer)
{
    BOOL playOrPause = [RCTConvert BOOL:json];
    [view play:playOrPause];
    return;
}

RCT_CUSTOM_VIEW_PROPERTY(pauseRenderer, BOOL, RNTVRPlayer)
{
    BOOL isPauseRenderer = [RCTConvert BOOL:json];
    [view pauseRenderer:isPauseRenderer];
    return;
}

RCT_CUSTOM_VIEW_PROPERTY(codec, int, RNTVRPlayer)
{
    int codec = [RCTConvert int:json];
    [view setCodec:codec];
    return;
}

RCT_CUSTOM_VIEW_PROPERTY(close, BOOL, RNTVRPlayer)
{
    BOOL isClose = [RCTConvert BOOL:json];
    [view close:isClose];
    return;
}

RCT_CUSTOM_VIEW_PROPERTY(seek, double, RNTVRPlayer)
{
    double seek = [RCTConvert double:json];
    [view seek:seek];
    return;
}

RCT_CUSTOM_VIEW_PROPERTY(mode, int, RNTVRPlayer)
{
    int mode = [RCTConvert int:json];
    [view setMode:mode];
    return;
}

RCT_CUSTOM_VIEW_PROPERTY(rotateDegree, int, RNTVRPlayer)
{
    int degree = [RCTConvert int:json];
    [view setRotateDegree:degree];
    return;
}

RCT_CUSTOM_VIEW_PROPERTY(degree, int, RNTVRPlayer)
{
    int degree = [RCTConvert int:json];
    [view setViewPortDegree:degree];
    return;
}

@end
