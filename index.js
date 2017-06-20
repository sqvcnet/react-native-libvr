'use strict';
import {PropTypes, Component} from 'react';
import {requireNativeComponent} from 'react-native';

class VRPlayerView extends Component {
    render() {
        return <VRPlayerViewManager {...this.props} />;
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

var VRPlayerViewManager = requireNativeComponent('VRPlayerViewManager', VRPlayerView, {
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
