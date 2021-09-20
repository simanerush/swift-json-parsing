//
//  KivaLoanTableViewController.swift
//  KivaLoan
//
//  Created by Simon Ng on 4/10/2016.
//  Updated by Simon Ng on 6/12/2017.
//  Copyright © 2016 AppCoda. All rights reserved.
//

import UIKit

class KivaLoanTableViewController: UITableViewController {
    
    private let kivaLoanURL = "https://api.kivaws.org/v1/loans/newest.json"
    private var loans = [Loan]()
    
    enum Section {
        case all
    }
    
    lazy var dataSource = ConfigureDataSource()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getLatestLoans()
        tableView.estimatedRowHeight = 92.0
        tableView.rowHeight = UITableView.automaticDimension
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getLatestLoans() {
        //instaniate the URL structure, returns the optional, so we use the guard value
        guard let loanURL = URL(string: kivaLoanURL) else {
            return
        }
        
        let request = URLRequest(url: loanURL)
        //creating a URLSession, works woth HTTP/HTTPS protocols
        let task = URLSession.shared.dataTask(with: request, completionHandler: {
            (data, response, error) -> Void in
            
            if let error = error {
                print(error)
                return
            }
            
            //Parse JSON data if there are no errors
            if let data = data {
                self.loans = self.parseJsonData(data: data) //return JSON data
                
                //update table view's data
                OperationQueue.main.addOperation({
                    self.updateSnapshot()
                })
            }
        })
        
        task.resume() //initiate the data task
    }
    
//    func parseJsonData(data: Data) -> [Loan] {
//        var loans = [Loan]()
//
//        do {
//            let jsonResult = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers) as? NSDictionary //convert to Foundation object
//            //TOP LEVEL ITEMS ARE KEYS
//            //Parse JSON data
//            let jsonLoans = jsonResult?["loans"] as! [AnyObject]
//            //loop through the array that was returned, convert to a dictionary
//            for jsonLoan in jsonLoans {
//                var loan = Loan()
//                loan.name = jsonLoan["name"] as! String
//                loan.amount = jsonLoan["loan_amount"] as! Int
//                loan.use = jsonLoan["use"] as! String
//                let location = jsonLoan["location"] as! [String: AnyObject]
//                loan.country = location["country"] as! String
//                loans.append(loan)
//            }
//        } catch {
//            print(error)
//        }
//
//        return loans
//    }
    
    func parseJsonData(data: Data) -> [Loan] {
        var loans = [Loan]()
        
        let decoder = JSONDecoder()
        
        do {
            let loanDataStore = try decoder.decode(LoanDataStore.self, from: data)
            loans = loanDataStore.loans
        } catch {
            print(error)
        }
        
        return loans
    }
    
    func ConfigureDataSource() -> UITableViewDiffableDataSource<Section, Loan> {
        
        let cellIdentifier = "Cell"
        
        let dataSource = UITableViewDiffableDataSource<Section, Loan>(
            tableView: tableView,
            cellProvider: {tableView, indexPath, loan in
                let cell =
                    tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! KivaLoanTableViewCell
                
                cell.nameLabel.text = loan.name
                cell.countryLabel.text = loan.country
                cell.useLabel.text = loan.use
                cell.amountLabel.text = "$\(loan.amount)"
                
                return cell
            }
        )
        
        return dataSource
    }
    
    func updateSnapshot(animatingChange: Bool = false) {
        //create a snapshot and populate the data
        var snapshot = NSDiffableDataSourceSnapshot<Section, Loan>()
        snapshot.appendSections([.all])
        snapshot.appendItems(loans, toSection: .all)
        
        dataSource.apply(snapshot, animatingDifferences: animatingChange)
    }

}
