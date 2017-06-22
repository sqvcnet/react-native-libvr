'use strict';
import {PropTypes, Component} from 'react';
import ReactNative, {NativeModules, requireNativeComponent} from 'react-native';

var VRPlayerViewManager = NativeModules.VRPlayerViewManager;

class VRPlayerView extends Component {
    open() {
        VRPlayerViewManager.open(ReactNative.findNodeHandle(this), (error, result) => {
            return;
        });
    }

    render() {
        return (<RNVRPlayerView {...this.props} />);
    }
}

VRPlayerView
    .propTypes = {
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
}
;

var RNVRPlayerView = requireNativeComponent('VRPlayerViewManager', VRPlayerView, {
    nativeOnly: {
        'onLayout': true,
        'scaleX': true,
        'scaleY': true,
        'testID': true,
        'decomposedMatrix': true,
        'backgroundColor': true,
        'accessibilityComponentType': true,
        'renderToHardwareTextureAndroid': true,
        'translateY': true,
        'translateX': true,
        'accessibilityLabel': true,
        'accessibilityLiveRegion': true,
        'importantForAccessibility': true,
        'rotation': true,
        'opacity': true,
    }
});

module.exports = VRPlayerView;
