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

- (void)redirectToView:(nonnull NSNumber *)reactTag exec:(ResponseViewBlock)exec callback:(RCTResponseSenderBlock)callback {
    [self getView:reactTag callback:^(RNTVRPlayer *view) {
        if (!view) {
            NSArray *error = [[NSArray alloc] initWithObjects:@"Invalid view returned from registry", nil];
            callback(error);
            return;
        }
        exec(view);
        callback([[NSArray alloc] initWithObjects:@"", nil]);
    }];
}

RCT_EXPORT_METHOD(setMode:(nonnull NSNumber *)reactTag mode:(nonnull NSNumber *)mode callback:(RCTResponseSenderBlock)callback) {
    [self redirectToView:reactTag exec:^(RNTVRPlayer *view) {
        [view setMode:[mode intValue]];
    } callback:callback];
}

RCT_EXPORT_METHOD(setCodec:(nonnull NSNumber *)reactTag codec:(nonnull NSNumber *)codec callback:(RCTResponseSenderBlock)callback) {
    [self redirectToView:reactTag exec:^(RNTVRPlayer *view) {
        [view setCodec:[codec intValue]];
    } callback:callback];
}

RCT_EXPORT_METHOD(setDegree:(nonnull NSNumber *)reactTag codec:(nonnull NSNumber *)degree callback:(RCTResponseSenderBlock)callback) {
    [self redirectToView:reactTag exec:^(RNTVRPlayer *view) {
        [view setViewPortDegree:[degree intValue]];
    } callback:callback];
}

RCT_EXPORT_METHOD(setRotateDegree:(nonnull NSNumber *)reactTag degree:(nonnull NSNumber *)degree callback:(RCTResponseSenderBlock)callback) {
    [self redirectToView:reactTag exec:^(RNTVRPlayer *view) {
        [view setRotateDegree:[degree intValue]];
    } callback:callback];
}

RCT_EXPORT_METHOD(open:(nonnull NSNumber *)reactTag uri:(NSString *)uri callback:(RCTResponseSenderBlock)callback) {
    
    [self getView:reactTag callback:^(RNTVRPlayer *view) {
        if (!view) {
            NSArray *error = [[NSArray alloc] initWithObjects:@"Invalid view returned from registry", nil];
            callback(error);
            return;
        }
        [view open:uri callback:^(NSString *err) {
            callback([[NSArray alloc] initWithObjects:err, nil]);
        }];
    }];
}

RCT_EXPORT_METHOD(seek:(nonnull NSNumber *)reactTag pos:(nonnull NSNumber *)pos callback:(RCTResponseSenderBlock)callback) {
    [self redirectToView:reactTag exec:^(RNTVRPlayer *view) {
        [view seek:[pos doubleValue]];
    } callback:callback];
}

RCT_EXPORT_METHOD(play:(nonnull NSNumber *)reactTag callback:(RCTResponseSenderBlock)callback) {
    [self redirectToView:reactTag exec:^(RNTVRPlayer *view) {
        [view play:YES];
    } callback:callback];
}

RCT_EXPORT_METHOD(pause:(nonnull NSNumber *)reactTag callback:(RCTResponseSenderBlock)callback) {
    [self redirectToView:reactTag exec:^(RNTVRPlayer *view) {
        [view play:NO];
    } callback:callback];
}
RCT_EXPORT_METHOD(playRenderer:(nonnull NSNumber *)reactTag callback:(RCTResponseSenderBlock)callback) {
    [self redirectToView:reactTag exec:^(RNTVRPlayer *view) {
        [view playRenderer:YES];
    } callback:callback];
}

RCT_EXPORT_METHOD(pauseRenderer:(nonnull NSNumber *)reactTag callback:(RCTResponseSenderBlock)callback) {
    [self redirectToView:reactTag exec:^(RNTVRPlayer *view) {
        [view playRenderer:NO];
    } callback:callback];
}

RCT_EXPORT_METHOD(close:(nonnull NSNumber *)reactTag callback:(RCTResponseSenderBlock)callback) {
    [self redirectToView:reactTag exec:^(RNTVRPlayer *view) {
        [view close];
    } callback:callback];
}

@end
