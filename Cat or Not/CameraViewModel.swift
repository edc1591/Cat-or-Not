//
//  Cat or Not
//  Copyright © 2016 Evan Coleman. All rights reserved.
//

import Foundation
import ReactiveCocoa

class CameraViewModel: ViewModel {
    // MARK: Public Properties
    
    let camera = CvVideoCamera().then {
        $0.defaultAVCaptureDevicePosition = .Back
        $0.defaultAVCaptureSessionPreset = AVCaptureSessionPreset640x480
        $0.defaultAVCaptureVideoOrientation = .Portrait
        $0.defaultFPS = 30
        $0.grayscaleMode = false
    }
    
    // MARK: Public Actions
    
    
    // MARK: Private Properties
    
    private let detector = FaceDetector()
    
    // MARK: Private Actions
    
    
    // MARK: Initializers
    
    override init() {
        self.camera.delegate = self.detector
    }
}
