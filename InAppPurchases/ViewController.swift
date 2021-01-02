//
//  ViewController.swift
//  InAppPurchases
//
//  Created by Mohammed on 12/28/20.
//

import UIKit
import StoreKit

enum Product: String, CaseIterable {
    
    case removeAds = "com.mohammed.InAppPurchases.removeAds"
    case unlockEverything = "com.mohammed.InAppPurchases.unlockEverything"
    case getCoins = "com.mohammed.InAppPurchases.getCoins"
}


class ViewController: UIViewController, SKPaymentTransactionObserver, SKProductsRequestDelegate {
    
    @IBOutlet var tableView: UITableView!
    private var models = [SKProduct]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initTableView()
        fetchProudacts()
        SKPaymentQueue.default().add(self)
        
    }
    
    private func fetchProudacts(){
        
        let request = SKProductsRequest(productIdentifiers:
                                            Set(Product.allCases.compactMap({ $0.rawValue } )))
        request.delegate = self
        request.start()
        
    }
    
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        
        DispatchQueue.main.async {
            print("Count: \(response.products.count)")
            self.models = response.products
            self.tableView.reloadData()
        }
    }
    
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        
        transactions.forEach({
            
            switch $0.transactionState{
            
            case .purchasing:
                print("Transaction is purchasing")
            case .purchased:
                print("Transaction is purchased")
                SKPaymentQueue.default().finishTransaction($0)
            case .failed:
                print("Transaction is failed")
                SKPaymentQueue.default().finishTransaction($0)
            case .restored:
                break
            case .deferred:
                break
            @unknown default:
                break
                
            }
        })
    }
    
}


extension ViewController: UITableViewDelegate, UITableViewDataSource{
    
    func initTableView(){
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return models.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let product = models[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.text = "\(product.localizedTitle): \(product.localizedDescription) -> \(product.priceLocale.currencySymbol ?? "$")\(product.price)"
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        //show purchase
        if SKPaymentQueue.canMakePayments(){
            
            let payment = SKPayment(product: models[indexPath.row])
            SKPaymentQueue.default().add(payment)
            
        }else {
            print("The user can't make transaction")
        }
        
    }
    
}

