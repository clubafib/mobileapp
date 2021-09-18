//
//  BloodPressureDataListVC.swift
//  ClubAfib
//
//  Created by Rener on 9/3/20.
//  Copyright © 2020 ETU. All rights reserved.
//

import UIKit

class BloodPressureDataViewCell: UITableViewCell {

    @IBOutlet weak var lblValue: UILabel!
    @IBOutlet weak var lblDate: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}

class BloodPressureDataListVC: UIViewController {
    
    @IBOutlet weak var lblUnit: UILabel!
    @IBOutlet weak var tblData: UITableView!
    
    var data = [BloodPressure]()
    
    let valueFormatter = NumberFormatter()
    var simpleDateFormatter = DateFormatter()
    var fullDateFormatter = DateFormatter()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.valueFormatter.numberStyle = .decimal
        self.simpleDateFormatter.dateFormat = "MMM d, hh:mm a"
        self.fullDateFormatter.dateFormat = "MMM d, yyyy at hh:mm a"
        
        
        self.lblUnit.text = "MMHG"
    }
    
    private func removeData(_ index: Int) {
        if index < self.data.count {
            let bloodPressure = self.data[index]
            self.data.remove(at: index)

            if !bloodPressure.sysUUID.isEmpty, !bloodPressure.diaUUID.isEmpty {
                HealthKitHelper.default.deleteBloodPressure(sysUUID: bloodPressure.sysUUID, diaUUID: bloodPressure.diaUUID) { success, error in
                    if let error = error {
                        print("Error: \(String(describing: error))")
                        if error is HealthKitHelper.HealthkitSetupError {
                            DispatchQueue.main.async {
                                self.showSimpleAlert(title: "HealthKit Permission Denied", message: "Please go to Settings -> Privacy -> Health -> App and turn on all permissions", complete: nil)
                            }
                        }
                    } else {
                        NotificationCenter.default.post(name: Notification.Name(USER_NOTIFICATION_HEALTHDATA_CHANGED), object: nil)
                    }
                }
            }
        }
    }
    
    @IBAction func onBackPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
}

extension BloodPressureDataListVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "bloodpressuredata_viewcell", for: indexPath) as! BloodPressureDataViewCell
        let bloodPressure = data[indexPath.row]
        cell.lblValue.text = "\(self.valueFormatter.string(for: bloodPressure.systolic)!)/\(self.valueFormatter.string(for: bloodPressure.diastolic)!)"
        cell.lblDate.text = bloodPressure.date.isInThisYear ? self.simpleDateFormatter.string(from: bloodPressure.date) : self.fullDateFormatter.string(from: bloodPressure.date)
        
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
