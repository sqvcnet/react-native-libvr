'use strict';
import React, {PropTypes, Component} from 'react';
import ReactNative, {NativeModules, requireNativeComponent} from 'react-native';

var RNTVRPlayerManager = NativeModules.RNTVRPlayerManager;

var VRPlayerNative = requireNativeComponent('RNTVRPlayer', VRPlayer);

class VRPlayer extends React.Component {
    static propTypes = {
        src: PropTypes.string,
        play: PropTypes.bool,
        pauseRenderer: PropTypes.bool,
        codec: PropTypes.number,
        close: PropTypes.bool,
        seek: PropTypes.number,
        mode: PropTypes.number,
        rotateDegree: PropTypes.number,
        degree: PropTypes.number,
        onChange: PropTypes.func,
    };

    constructor(props) {
        super(props);
        this.props = props;
    }

    open(uri, cb) {
        var tag = ReactNative.findNodeHandle(this.refs.native);
        RNTVRPlayerManager.open(tag, uri, (error, result) => {
            cb ? cb() : null;
        });
    }

    seek(pos, cb) {
        RNTVRPlayerManager.seek(ReactNative.findNodeHandle(this.refs.native), pos, (error, result) => {
            cb ? cb() : null;
        });
    }

    play(cb) {
        RNTVRPlayerManager.play(ReactNative.findNodeHandle(this.refs.native), (error, result) => {
            cb ? cb() : null;
        });
    }

    pause(cb) {
        RNTVRPlayerManager.pause(ReactNative.findNodeHandle(this.refs.native), (error, result) => {
            cb ? cb() : null;
        });
    }

    playRenderer(cb) {
        RNTVRPlayerManager.playRenderer(ReactNative.findNodeHandle(this.refs.native), (error, result) => {
            cb ? cb() : null;
        });
    }

    pauseRenderer(cb) {
        RNTVRPlayerManager.pauseRenderer(ReactNative.findNodeHandle(this.refs.native), (error, result) => {
            cb ? cb() : null;
        });
    }

    close(cb) {
        RNTVRPlayerManager.close(ReactNative.findNodeHandle(this.refs.native), (error, result) => {
            cb ? cb() : null;
        });
    }

    static MODE_3D = 0;
    static MODE_360 = 1;
    static MODE_360_UP_DOWN = 2;
    static MODE_3D_LEFT_RIGHT = 3;
    static MODE_360_SINGLE = 4;
    setMode(mode, cb) {
        RNTVRPlayerManager.setMode(ReactNative.findNodeHandle(this.refs.native), mode, (error, result) => {
            cb ? cb() : null;
        });
    }

    static CODEC_SOFT = 0;
    static CODEC_HARD = 1;
    setCodec(codec, cb) {
        RNTVRPlayerManager.setCodec(ReactNative.findNodeHandle(this.refs.native), codec, (error, result) => {
            cb ? cb() : null;
        });
    }

    _onChange(event: Event) {
        if (!this.props.onChange) {
            return;
        }
        this.props.onChange(event.nativeEvent);
    }

    render() {
        return (
            <VRPlayerNative
                ref="native"
                {...this.props}
                onChange={this._onChange.bind(this)}>
            </VRPlayerNative>
        );
    }
}

module.exports = VRPlayer;
