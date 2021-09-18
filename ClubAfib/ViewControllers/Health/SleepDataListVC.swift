//
//  SleepDataListVC.swift
//  ClubAfib
//
//  Created by Rener on 9/3/20.
//  Copyright © 2020 ETU. All rights reserved.
//

import UIKit

class SleepDataViewCell: UITableViewCell {

    @IBOutlet weak var lblType: UILabel!
    @IBOutlet weak var lblValue: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}

class SleepDataListVC: UIViewController {
    
    @IBOutlet weak var lblUnit: UILabel!
    @IBOutlet weak var tblData: UITableView!
    
    var data = [Sleep]()
    
    let valueFormatter = NumberFormatter()
    var simpleDateFormatter = DateIntervalFormatter()
    var fullDateFormatter = DateIntervalFormatter()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.valueFormatter.numberStyle = .decimal
        self.simpleDateFormatter.dateTemplate = "MMM d, hh:mm a"
        self.fullDateFormatter.dateTemplate = "MMM d, yyyy at hh:mm a"
        
        
        self.lblUnit.text = ""
    }
    
    private func removeData(_ index: Int) {
        if index < self.data.count {
            let sleep = self.data[index]
            self.data.remove(at: index)

            if !sleep.UUID.isEmpty {
                HealthKitHelper.default.deleteSleep(sleep.UUID) { success, error in
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

extension SleepDataListVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "sleepdata_viewcell", for: indexPath) as! SleepDataViewCell
        let sleep = data[indexPath.row]
        cell.lblType.text = sleep.type == 0 ? "In Bed" : "Asleep"

        let components = Calendar.current.dateComponents([.hour, .minute], from: sleep.start, to: sleep.end)
        let difference = "\(components.hour! == 0 ? "" : "\(components.hour!)hr") \(components.minute!)min"
        
        let periods = sleep.start.isInThisYear ? self.simpleDateFormatter.string(from: sleep.start, to: sleep.end) : self.fullDateFormatter.string(from: sleep.start, to: sleep.end)
        cell.lblValue.text = "\(difference) (\(periods))"
        
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
