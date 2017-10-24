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
    
    public func start() {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        self.invalidateStopTimer()
        self.indicatorStopTimer = Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(self.stop), userInfo: nil, repeats: false)
    }
    
    @objc public func stop() {
        self.invalidateStopTimer()
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
    
    private func invalidateStopTimer() {
        if self.indicatorStopTimer != nil {
            self.indicatorStopTimer?.invalidate()
            self.indicatorStopTimer = nil
        }
    }
}

