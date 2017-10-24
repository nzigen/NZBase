//
//  NZNetworkIndicator.swift
//  FBSnapshotTestCase
//
//  Created by 澤良弘 on 2017/10/24.
//

import UIKit

class NZNetworkIndicator: NSObject {
    static let shared = NZNetworkIndicator()
    var indicatorStopTimer: Timer?
    
    func startIndicator() {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        self.invalidateStopTimer()
        self.indicatorStopTimer = Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(self.stopIndicator), userInfo: nil, repeats: false)
    }
    
    @objc func stopIndicator() {
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

