//
//  RNTVRPlayer.h
//  RNVRPlayer
//
//  Created by 单强 on 2017/6/20.
//  Copyright © 2017年 单强. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>

#import <React/RCTBridge.h>

#include "Renderer.h"

@interface RNTVRPlayer : GLKView<GLKViewDelegate>
- (instancetype)init:(RCTBridge *)bridge;
- (void)setURI:(NSString *)uri;
- (void)open:(NSString *)uri;
- (void)seek:(double)seek;
- (void)play:(BOOL)playOrPause;
- (void)close:(BOOL)isClose;
- (void)setMode:(int)mode;
- (void)setCodec:(int)codec;
- (void)setResolution:(int)resolution;
- (void)setRotateDegree:(int)degree;
- (void)setViewPortDegree:(int)degree;
- (void)pauseRenderer:(BOOL)isPause;

- (void)customMethod;

- (void)updateProgress;
@end
