//
//  Mugslide
//  Copyright © 2016 Evan Coleman. All rights reserved.
//

import Foundation
import ReactiveCocoa
import Result

public class ViewModel {
    let active = MutableProperty<Bool>(false)
    let (errors, errorSink) = Signal<NSError, NoError>.pipe()
    
    private(set) lazy var didBecomeActiveSignal: SignalProducer<ViewModel, NoError> = {
        return self.active.producer
            .filter { $0 }
            .map { _ in self }
    }()
    private(set) lazy var didBecomeInactiveSignal: SignalProducer<ViewModel, NoError> = {
        return self.active.producer
            .filter { !$0 }
            .map { _ in self }
    }()
}