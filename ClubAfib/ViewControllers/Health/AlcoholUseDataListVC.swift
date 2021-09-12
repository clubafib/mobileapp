//
//  AlcoholUseDataListVC.swift
//  ClubAfib
//
//  Created by Rener on 9/2/20.
//  Copyright © 2020 ETU. All rights reserved.
//

import UIKit

class AlcoholUseDataViewCell: UITableViewCell {

    @IBOutlet weak var lblValue: UILabel!
    @IBOutlet weak var lblDate: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}

class AlcoholUseDataListVC: UIViewController {
    
    @IBOutlet weak var lblUnit: UILabel!
    @IBOutlet weak var tblData: UITableView!
    
    var data = [AlcoholUse]()
    
    let valueFormatter = NumberFormatter()
    var simpleDateFormatter = DateFormatter()
    var fullDateFormatter = DateFormatter()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.valueFormatter.numberStyle = .decimal
        self.simpleDateFormatter.dateFormat = "MMM d, hh:mm a"
        self.fullDateFormatter.dateFormat = "MMM d, yyyy at hh:mm a"
        
        
        self.lblUnit.text = "TIMES"
    }
    
    private func removeData(_ index: Int) {
        if index < self.data.count {
            let alcoholUse = self.data[index]
            self.data.remove(at: index)
//            ApiManager.sharedInstance.deleteAlcoholUseData(alcoholUse) { (success, errorMsg) in
//                if success {
//                    try! RealmManager.default.realm.write {
//                        alcoholUse.status = 2 // delete status
//                    }
////                    HealthDataManager.default.deleteAlcoholUseData(alcoholUse)
//                }
//                else {
//                    print("error on saving alcoholUse data: \(errorMsg ?? "")")
//                }
//            }
        }
    }
    
    @IBAction func onBackPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
}

extension AlcoholUseDataListVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "alcoholusedata_viewcell", for: indexPath) as! AlcoholUseDataViewCell
        let alcoholUse = data[indexPath.row]
        cell.lblValue.text = self.valueFormatter.string(for: alcoholUse.value)
        cell.lblDate.text = alcoholUse.date.isInThisYear ? self.simpleDateFormatter.string(from: alcoholUse.date) : self.fullDateFormatter.string(from: alcoholUse.date)
        
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
