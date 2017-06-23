//
//  RNTVRPlayer.mm
//  RNVRPlayer
//
//  Created by 单强 on 2017/6/20.
//  Copyright © 2017年 单强. All rights reserved.
//


#import "RNTVRPlayer.h"
#include "Player.hpp"
#import <VideoToolbox/VideoToolbox.h>

#import <React/RCTEventDispatcher.h>
#import <React/UIView+React.h>

@implementation RNTVRPlayer {
    geeek::Player *_player;
    Renderer *_renderer;
    RCTBridge *_bridge;
    NSString *_uri;
    NSTimer *_timer;
    NSThread *_renderThread;
    CADisplayLink *_displayLink;
}

- (instancetype)init:(RCTBridge *)bridge
{
    _player = new geeek::Player(nullptr);
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
    
    //监听屏幕退出
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(onAppGoBack)
                                                 name: @"onAppGoBack"
                                               object: nil];

    //app载入事件
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(onAppWillFore)
                                                 name: @"onAppWillFore"
                                               object: nil];
    
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

- (void)threadMain {
    [_displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    
    CFRunLoopRun();
}

- (void)dealloc
{
    if (_player) {
        delete _player;
        _player = nullptr;
    }
    NSLog(@"remove observer in player view");
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void) onAppGoBack{
    _player->pause();
    [self playRenderer:false];
    NSDictionary *event = @{
                            @"target": self.reactTag,
                            @"message": @"onPause"
                            };
    [_bridge.eventDispatcher sendInputEventWithName:@"topChange" body:event];
    
    NSLog(@"applicationDidEnterBackground in player view");
}

- (void) onAppWillFore{
    NSDictionary *event = @{
                            @"target": self.reactTag,
                            @"message": @"onResume"
                            };
    [_bridge.eventDispatcher sendInputEventWithName:@"topChange" body:event];
    
    NSLog(@"applicationWillEnterForeground in player view");
}

- (void)setURI:(NSString *)uri {
    _uri = uri;
}

- (void)open:(NSString *)uri {
    if (!uri || [uri isEqualToString:@""]) {
        return;
    }

    _uri = uri;
    
    _displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(render:)];
    [_displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    //    _renderThread = [[NSThread alloc] initWithTarget:self
    //                                            selector:@selector(threadMain)
    //                                              object:nil];
    //    [_renderThread start];
    
    _timer = [NSTimer scheduledTimerWithTimeInterval:0.5
                                              target:self
                                            selector:@selector(updateProgress)
                                            userInfo:nil
                                             repeats:YES];
    
    _player->open([_uri UTF8String]);
}

- (void)updateProgress {
    NSDictionary *event = @{
                            @"target": self.reactTag,
                            @"message": @"onProgress",
                            @"uri": _uri,
                            @"progress": [[NSNumber alloc] initWithFloat:_player->getProgress()],
                            @"cacheProgress": [[NSNumber alloc] initWithFloat:_player->getCacheProgress()],
                            @"totalTime": [[NSNumber alloc] initWithFloat:_player->getTotalTime()],
                            @"error": [[NSNumber alloc] initWithInt:_player->getLastError()]
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
        _player->play();
    } else {
        _player->pause();
    }
}

- (void)setCodec:(int)codec {
    _player->setCodec(codec);
}

- (void)close {
    [_timer invalidate];
    _player->close();

    //这里必须invalidate，否则_displayLink 隐式hold住self导致self不能被gc, dealloc的断点不会进入，_displayLink和self都不会被释放！！！
    [_displayLink invalidate];
}

- (void)seek:(double)seek {
    _player->seek(seek);
}

- (void)setMode:(int)mode {
    Renderer *renderer = _player->getRenderer();
    switch (mode) {
        case 0:
            renderer->set3D();
            break;
        case 1:
            renderer->set360();
            break;
        case 2:
            renderer->set360UpDown();
            break;
        case 3:
            renderer->setPlane();
            break;
        case 4:
            renderer->set360SingleView();
            break;
        default:
            renderer->set360();
            break;
    }
}

- (void)setRotateDegree:(int)degree {
    _player->getRenderer()->setRotateDegree(degree);
}

- (void)setViewPortDegree:(int)degree {
    _player->getRenderer()->setViewPortDegree(degree);
}

- (void)playRenderer:(BOOL)isPlay {
    _displayLink.paused = isPlay;
}

- (void)reactSetFrame:(CGRect)frame
{
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    CGRect screenNativeBounds = [[UIScreen mainScreen] nativeBounds];
    int width = screenNativeBounds.size.width;
    int height = screenNativeBounds.size.height;
    if (height > width) {
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
//    GLKMatrix4 head_from_start_matrix = [headTransform headPoseInStartSpace];
//    _renderer->render(head_from_start_matrix.m);
    GLKMatrix4 head_from_start_matrix;
    _renderer->render(head_from_start_matrix.m);
}

@end
