//
//  NZPurchaser.swift
//  NZBase
//
//  Created by 澤良弘 on 2017/10/26.
//

import Foundation
import StoreKit

protocol NZPurchaserDelegate: class {
    func purchaser(_ purchaser: NZPurchaser, didDeferTransaction transaction: SKPaymentTransaction)
    func purchaser(_ purchaser: NZPurchaser, didFailWithError error: Error)
    func purchaser(_ purchaser: NZPurchaser, didFinishRestoring queue: SKPaymentQueue)
    func purchaser(_ purchaser: NZPurchaser, didFinishTransaction transaction: SKPaymentTransaction, callback: (Bool) -> Void)
}

class NZPurchaser: NSObject {
    
    static let main = NZPurchaser()
    
    var delegate: NZPurchaserDelegate?
    
    var isObserverSet = false
    var isRestoring = false
    var productIdentifier: String?
    
    func localizePrice(_ product: SKProduct) -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.formatterBehavior = .behavior10_4
        numberFormatter.numberStyle = .currency
        numberFormatter.locale = product.priceLocale
        return numberFormatter.string(from: product.price)!
    }
    
    func observe() {
        if self.isObserverSet {
            return
        }
        self.isObserverSet = true
        SKPaymentQueue.default().add(self)
    }
    
    func purchase(product: SKProduct) {
        var errorCode = 0
        var errorMessage = ""
        if !SKPaymentQueue.canMakePayments() {
            errorCode += 1
            errorMessage = "設定で購入が無効になっています。"
        }
        if self.productIdentifier != nil {
            errorCode += 10
            errorMessage = "課金処理中です。"
        }
        if self.isRestoring {
            errorCode += 100
            errorMessage = "リストア中です。"
        }
        
        if errorCode > 0 {
            let error = NSError(domain: "NZPurchaserPurchaseError", code: errorCode, userInfo: [NSLocalizedDescriptionKey: errorMessage])
            self.delegate?.purchaser(self, didFailWithError: error)
            return
        }
        
        let transactions = SKPaymentQueue.default().transactions
        if transactions.count > 0 {
            for transaction in transactions {
                if transaction.transactionState != .purchased {
                    continue
                }
                if transaction.payment.productIdentifier == product.productIdentifier {
                    SKPaymentQueue.default().finishTransaction(transaction)
                }
            }
        }
        let payment = SKMutablePayment(product: product)
        SKPaymentQueue.default().add(payment)
        self.productIdentifier = product.productIdentifier
    }
    
    func restore() {
        if self.isRestoring {
            return
        }
        self.isRestoring = true
        SKPaymentQueue.default().restoreCompletedTransactions()
    }
    
    func stopObserving() {
        if !self.isObserverSet {
            return
        }
        self.isObserverSet = false
        SKPaymentQueue.default().remove(self)
    }
    
    private func deferTransaction(transaction: SKPaymentTransaction) {
        self.productIdentifier = nil
        self.delegate?.purchaser(self, didDeferTransaction: transaction)
    }
    
    private func finishRestoringTrancation(transaction: SKPaymentTransaction) {
        self.delegate?.purchaser(self, didFinishTransaction: transaction) { (isFinished) in
            if isFinished {
                if transaction.payment.productIdentifier == self.productIdentifier {
                    self.productIdentifier = nil
                }
                SKPaymentQueue.default().finishTransaction(transaction)
            }
        }
    }
    
    private func finishTransactionWithError(transaction: SKPaymentTransaction) {
        if transaction.payment.productIdentifier == self.productIdentifier {
            self.productIdentifier = nil
        }
        self.delegate?.purchaser(self, didFailWithError: transaction.error!)
    }
    
    private func finishSuccessfulTransaction(transaction: SKPaymentTransaction) {
        self.delegate?.purchaser(self, didFinishTransaction: transaction) { (isFinished) in
            if isFinished {
                if transaction.payment.productIdentifier == self.productIdentifier {
                    self.productIdentifier = nil
                }
                SKPaymentQueue.default().finishTransaction(transaction)
            }
        }
    }
}

extension NZPurchaser: SKPaymentTransactionObserver {
    
    func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
        self.isRestoring = false
        self.delegate?.purchaser(self, didFinishRestoring: queue)
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, restoreCompletedTransactionsFailedWithError error: Error) {
        self.isRestoring = false
        self.delegate?.purchaser(self, didFailWithError: error)
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        transactions.forEach { (transaction) in
            switch transaction.transactionState {
            case .deferred:
                self.deferTransaction(transaction: transaction)
            case .failed:
                self.finishTransactionWithError(transaction: transaction)
            case .purchased:
                self.finishSuccessfulTransaction(transaction: transaction)
            case .restored:
                self.finishRestoringTrancation(transaction: transaction)
            default:
                break
            }
        }
    }
}
