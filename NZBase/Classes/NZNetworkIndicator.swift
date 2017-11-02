//
//  NZNetworkIndicator.swift
//  FBSnapshotTestCase
//
//  Created by 澤良弘 on 2017/10/24.
//

import UIKit

open class NZNetworkIndicator: NSObject {
    public static let shared = NZNetworkIndicator()
    var indicatorStopTimer: Timer?
    
    func dispatchMainSync(_ block: () -> Void) {
        if Thread.isMainThread {
            block()
        } else {
            DispatchQueue.main.sync() { () -> Void in
                block()
            }
        }
    }
    
    @objc public func forceStop() {
        dispatchMainSync {
            self.invalidateStopTimer()
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
        }
    }
    
    public func start() {
        dispatchMainSync {
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
            self.invalidateStopTimer()
            self.indicatorStopTimer = Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(self.forceStop), userInfo: nil, repeats: false)
        }
    }
    
    @objc public func stop() {
        self.invalidateStopTimer()
        self.indicatorStopTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.forceStop), userInfo: nil, repeats: false)
    }
    
    private func invalidateStopTimer() {
        if self.indicatorStopTimer != nil {
            self.indicatorStopTimer?.invalidate()
            self.indicatorStopTimer = nil
        }
    }
}

