//
//  Cat or Not
//  Copyright © 2016 Evan Coleman. All rights reserved.
//

import Foundation
import Mortar
import ReactiveCocoa
import Then
import UIKit

class CameraViewController: ViewController<CameraViewModel> {
    
    override init(viewModel: CameraViewModel) {
        super.init(viewModel: viewModel)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // MARK: Create Subviews
        
        let imageView = UIImageView().then {
            $0.contentMode = .ScaleAspectFill
        }
        
        // MARK: Add Subviews
        
        self.view.addSubview(imageView)
        
        // MARK: Layout
        
        imageView |=| self.view
        
        // MARK: Logic/Bindings
        
        self.viewModel.camera.parentView = imageView
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        self.viewModel.camera.start()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.viewModel.camera.stop()
    }
}
