//
//  Mugslide
//  Copyright © 2016 Evan Coleman. All rights reserved.
//

import Foundation
import ReactiveCocoa
import Result
import UIKit

public class ViewController<T: ViewModel>: UIViewController {
    let viewModel: T
    
    public init(viewModel: T) {
        self.viewModel = viewModel
        
        super.init(nibName: nil, bundle: nil)
        
        self.registerAsActivable(viewModel)
        self.installErrorHandler(viewModel)
    }
}

public class TableViewController<T: ViewModel>: UITableViewController {
    let viewModel: T
    
    public init(viewModel: T, style: UITableViewStyle) {
        self.viewModel = viewModel
        
        super.init(style: style)
        
        self.registerAsActivable(viewModel)
        self.installErrorHandler(viewModel)
    }
}

public class CollectionViewController<T: ViewModel>: UICollectionViewController {
    let viewModel: T
    
    public init(viewModel: T, layout: UICollectionViewLayout) {
        self.viewModel = viewModel
        
        super.init(collectionViewLayout: layout)
        
        self.registerAsActivable(viewModel)
        self.installErrorHandler(viewModel)
    }
}

extension UIViewController {
    func registerAsActivable(viewModel: ViewModel) {
        let appear = self.rac_signalForSelector(#selector(UIViewController.viewDidAppear(_:))).toSignalProducer().map { _ in true }.flatMapError { _ in SignalProducer<Bool, NoError>.empty }
        let disappear = self.rac_signalForSelector(#selector(UIViewController.viewWillDisappear(_:))).toSignalProducer().map { _ in false }.flatMapError { _ in SignalProducer<Bool, NoError>.empty }
        let presented = SignalProducer<SignalProducer<Bool, NoError>, NoError>(values: [appear, disappear]).flatten(.Merge)
        
        #if APP_EXTENSION
        let currentState = SignalProducer<Bool, NoError>(value: true)
        #else
        let currentState = SignalProducer<Bool, NoError>(value: (UIApplication.sharedApplication().applicationState == .Active))
        #endif
        let didBecomeActive = NSNotificationCenter.defaultCenter().rac_notifications(UIApplicationDidBecomeActiveNotification, object: nil).map { _ in true }
        let willResignActive = NSNotificationCenter.defaultCenter().rac_notifications(UIApplicationWillResignActiveNotification, object: nil).map { _ in false }
        let appActive = SignalProducer<SignalProducer<Bool, NoError>, NoError>(values: [currentState, didBecomeActive, willResignActive]).flatten(.Merge)
        
        combineLatest(presented, appActive)
            .map { (presented, active) in presented && active }
            .startWithNext { active in
                viewModel.active.value = active
            }
    }
    
    func installErrorHandler(viewModel: ViewModel) {
        viewModel.errors
            .filter { _ in viewModel.active.value }
            .observeOn(UIScheduler())
            .observeNext { [weak self] error in
                guard let `self` = self else { return }
                
                log.error(error)
                
                let title = error.localizedDescription
                let message = error.localizedRecoverySuggestion ?? error.localizedFailureReason
                let alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
                let cancelAction = UIAlertAction(title: "OK", style: .Cancel, handler: nil)
                alertController.addAction(cancelAction)
                self.presentViewController(alertController, animated: true, completion: nil)
            }
    }
}