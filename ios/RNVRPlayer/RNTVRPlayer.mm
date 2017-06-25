//
//  RNTVRPlayer.mm
//  RNVRPlayer
//
//  Created by 单强 on 2017/6/20.
//  Copyright © 2017年 单强. All rights reserved.
//


#import "RNTVRPlayer.h"
#import "RNTSensor.h"
#include "Player.hpp"
#import <VideoToolbox/VideoToolbox.h>

#import <React/RCTEventDispatcher.h>
#import <React/UIView+React.h>

@implementation RNTVRPlayer {
    geeek::Player *_player;
    Renderer *_renderer;
    RCTBridge *_bridge;
    NSString *_uri;
    int _mode;
    NSTimer *_timer;
    NSThread *_renderThread;
    CADisplayLink *_displayLink;
}

- (instancetype)init:(RCTBridge *)bridge
{
    _player = new geeek::Player();
    _renderer = _player->getRenderer();
    
    _bridge = bridge;
    
    EAGLContext *eaglContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES3];
    if (eaglContext == nil) {
        eaglContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    }
    [EAGLContext setCurrentContext:eaglContext];
    
    self = [self initWithFrame:CGRectZero];

    self.context = eaglContext;
    self.delegate = self;

    if ([[UIDevice currentDevice] orientation] == UIDeviceOrientationLandscapeLeft) {
        _renderer->setLandscape(true);
    } else {
        _renderer->setLandscape(false);
    }
    [[NSNotificationCenter defaultCenter]
     addObserver:self selector:@selector(orientationChanged:)
     name:UIDeviceOrientationDidChangeNotification
     object:[UIDevice currentDevice]];
    
    return self;
}

- (void) orientationChanged:(NSNotification *)note
{
    UIDevice * device = note.object;
    switch(device.orientation)
    {
        case UIDeviceOrientationLandscapeLeft:
            _renderer->setLandscape(true);
            break;
        case UIDeviceOrientationLandscapeRight:
            _renderer->setLandscape(false);
            break;
        default:
            break;
    };
}

- (void)dealloc
{
    if (_player) {
        delete _player;
        _player = nullptr;
    }
}

- (void)setURI:(NSString *)uri {
    _uri = uri;
}

- (void)threadMain {
    [_displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    CFRunLoopRun();
}

- (void)open:(NSString *)uri callback:(CallbackBlock)callback {
    if (!uri || [uri isEqualToString:@""]) {
        return;
    }

    _uri = uri;
    
    _displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(render:)];
//    [_displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    _renderThread = [[NSThread alloc] initWithTarget:self
                                            selector:@selector(threadMain)
                                              object:nil];
    [_renderThread start];
    
    _timer = [NSTimer scheduledTimerWithTimeInterval:0.5
                                              target:self
                                            selector:@selector(updateProgress)
                                            userInfo:nil
                                             repeats:YES];
    
    _player->open([_uri UTF8String], [=](const string &err) -> void {
        callback([NSString stringWithUTF8String:err.c_str()]);
    });
}

- (void)updateProgress {
    NSDictionary *event = @{
                            @"target": self.reactTag,
                            @"message": @"onProgress",
                            @"uri": _uri,
                            @"progress": [[NSNumber alloc] initWithFloat:_player->getProgress()],
                            @"cacheProgress": [[NSNumber alloc] initWithFloat:_player->getCacheProgress()],
                            @"totalTime": [[NSNumber alloc] initWithFloat:_player->getTotalTime()],
                            @"error": [[NSNumber alloc] initWithInt:static_cast<int>(_player->getLastError())]
                            };
//    self._DEBUG_reactShadowView
    [_bridge.eventDispatcher sendInputEventWithName:@"topChange" body:event];
}

- (void)play:(BOOL)isPlay {
    if (nullptr == _player) {
        NSException *e = [NSException
                          exceptionWithName:@"please open firstly"
                          reason:@"_player is nullptr"
                          userInfo:nil];
        @throw e;
        return;
    }
    if (isPlay) {
        [self startSensorRenderer];
        _player->play();
    } else {
        _player->pause();
        [self saveCost];
    }
}

//- (void)playRenderer:(BOOL)isPlay {
//    _displayLink.paused = !isPlay;
//    if (isPlay) {
//        [self setMode:-1];
//    } else {
//        [[RNTSensor inst] stop];
//    }
//}

- (void)setCodec:(int)codec {
    _player->setCodec(codec);
}

- (void)close {
    [_timer invalidate];
    
    _displayLink.paused = false;
    _player->close();

    [self stopSensorRenderer];
    //这里必须invalidate，否则_displayLink 隐式hold住self导致self不能被gc, dealloc的断点不会进入，_displayLink和self都不会被释放！！！
    [_displayLink invalidate];
    [_renderThread cancel];
}

- (void)seek:(double)seek {
    _player->seek(seek);
}

- (void)startSensorRenderer {
    [[RNTSensor inst] start];
    _displayLink.paused = false;
}

- (void)stopSensorRenderer {
    [[RNTSensor inst] stop];
    _displayLink.paused = true;
}

- (void)saveCost {
    Renderer::Mode tmp = static_cast<Renderer::Mode>(_mode);
    switch (tmp) {
        case Renderer::Mode::MODE_3D:
            [self stopSensorRenderer];
            break;
        case Renderer::Mode::MODE_360:
            [self startSensorRenderer];
            break;
        case Renderer::Mode::MODE_360_UP_DOWN:
            [self startSensorRenderer];
            break;
        case Renderer::Mode::MODE_3D_LEFT_RIGHT:
            [self stopSensorRenderer];
            break;
        case Renderer::Mode::MODE_360_SINGLE:
            [self startSensorRenderer];
            break;
        default:
            [self startSensorRenderer];
            break;
    }
}

- (void)setMode:(int)mode {
    if (mode != -1) {
        _mode = mode;
    }
    Renderer::Mode tmp = static_cast<Renderer::Mode>(_mode);
    _player->getRenderer()->setMode(tmp);
    [self saveCost];
}

- (void)setRotateDegree:(int)degree {
    _player->getRenderer()->setRotateDegree(degree);
}

- (void)setViewPortDegree:(int)degree {
    _player->getRenderer()->setViewPortDegree(degree);
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
    
    _renderer->init(width, height);
    
    [super reactSetFrame: frame];
}

- (void)render:(CADisplayLink*)displayLink {
    [self display];
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    GLKMatrix4 head_from_start_matrix = [[RNTSensor inst] modelView];
    _renderer->render(head_from_start_matrix.m);
}

@end
