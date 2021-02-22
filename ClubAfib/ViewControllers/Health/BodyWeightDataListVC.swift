//
//  BodyWeightDataListVC.swift
//  ClubAfib
//
//  Created by Rener on 9/2/20.
//  Copyright © 2020 ETU. All rights reserved.
//

import UIKit

class BodyWeightDataViewCell: UITableViewCell {

    @IBOutlet weak var lblValue: UILabel!
    @IBOutlet weak var lblDate: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}

class BodyWeightDataListVC: UIViewController {
    
    @IBOutlet weak var lblUnit: UILabel!
    @IBOutlet weak var tblData: UITableView!
    
    var data = [Weight]()
    
    let valueFormatter = NumberFormatter()
    var simpleDateFormatter = DateFormatter()
    var fullDateFormatter = DateFormatter()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.valueFormatter.maximumFractionDigits = 2
        self.simpleDateFormatter.dateFormat = "MMM d, hh:mm a"
        self.fullDateFormatter.dateFormat = "MMM d, yyyy at hh:mm a"
        
        
        self.lblUnit.text = "LBS"
    }
    
    private func removeData(_ index: Int) {
        if index < self.data.count {
            let weight = self.data[index]
            self.data.remove(at: index)
            ApiManager.sharedInstance.deleteWeightData(weight) { (success, errorMsg) in
                if success {
                    try! RealmManager.default.realm.write {
                        weight.status = 2 // delete status
                    }
                    HealthDataManager.default.deleteWeightData(weight)
                }
                else {
                    print("error on saving weight data: \(errorMsg ?? "")")
                }
            }
        }
    }
    
    @IBAction func onBackPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
}

extension BodyWeightDataListVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "bodyweightdata_viewcell", for: indexPath) as! BodyWeightDataViewCell
        let weight = data[indexPath.row]
        cell.lblValue.text = self.valueFormatter.string(for: weight.value)
        cell.lblDate.text = weight.date.isInThisYear ? self.simpleDateFormatter.string(from: weight.date) : self.fullDateFormatter.string(from: weight.date)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        switch editingStyle {
        case .delete:
            tableView.beginUpdates()

            self.removeData(indexPath.row)
            
            tableView.deleteRows(at: [indexPath], with: .automatic)
            tableView.endUpdates()
            
        default:
            break
        }
    }

}
