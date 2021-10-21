//
//  SleepAddVC.swift
//  ClubAfib
//
//  Created by Rener on 8/7/20.
//  Copyright © 2020 ETU. All rights reserved.
//

import UIKit

class SleepAddVC: UIViewController {
    
    @IBOutlet weak var btnAdd: UIButton!
    
    @IBOutlet weak var viewInBed: UIView!
    @IBOutlet weak var viewAsleep: UIView!
    
    @IBOutlet weak var imgInBedMark: UIImageView!
    @IBOutlet weak var imgAsleepMark: UIImageView!
    
    @IBOutlet weak var startDatePicker: UIDatePicker!
    @IBOutlet weak var endDatePicker: UIDatePicker!
    
    var cells: [HealthDataAddViewCell?] = [nil, nil, nil]
    
    let dateFormatter = DateFormatter()
    
    var startDate = Date()
    var endDate = Date()
    var isAsleep = false

    override func viewDidLoad() {
        super.viewDidLoad()

        dateFormatter.dateFormat = "MMMM d, yyyy hh:mm a"
        
        let inBedTap = UITapGestureRecognizer(target: self, action: #selector(self.inBedTapped(_:)))
        viewInBed.isUserInteractionEnabled = true
        viewInBed.addGestureRecognizer(inBedTap)
        let asleepTap = UITapGestureRecognizer(target: self, action: #selector(self.asleepTapped(_:)))
        viewAsleep.isUserInteractionEnabled = true
        viewAsleep.addGestureRecognizer(asleepTap)
        
        let dateStr = dateFormatter.string(from: Date())
        startDate = dateFormatter.date(from: dateStr)!
        endDate = dateFormatter.date(from: dateStr)!
        imgInBedMark.isHidden = isAsleep
        imgAsleepMark.isHidden = !isAsleep
        
        btnAdd.isEnabled = true
        startDatePicker.isHidden = true
        startDatePicker.maximumDate = startDate
        endDatePicker.isHidden = true
        endDatePicker.maximumDate = endDate
    }
    
    private func onSleepTypeChange(_ isInBed: Bool) {
        isAsleep = !isInBed
        imgInBedMark.isHidden = isAsleep
        imgAsleepMark.isHidden = !isAsleep
    }
    
    @IBAction func startDatePickerChanged(_ sender: Any) {
        startDate = startDatePicker.date
        cells[0]?.lblValue.text = dateFormatter.string(from: startDate)
        
        if startDate > endDate {
            endDatePicker.date = startDate
            cells[1]?.lblValue.text = dateFormatter.string(from: startDate)
        }
        print(endDate.timeIntervalSince(startDate))
        btnAdd.isEnabled = !(endDate.timeIntervalSince(startDate) > 24 * 3600 * 4)
    }
    
    @IBAction func endDatePickerChanged(_ sender: Any) {
        endDate = endDatePicker.date
        cells[1]?.lblValue.text = dateFormatter.string(from: endDate)
        
        if startDate > endDate {
            startDatePicker.date = endDate
            cells[0]?.lblValue.text = dateFormatter.string(from: endDate)
        }
        btnAdd.isEnabled = !(endDate.timeIntervalSince(startDate) > 24 * 3600 * 4)
    }
    
    @objc func inBedTapped(_ sender: Any) {
        onSleepTypeChange(true)
    }
    
    @objc func asleepTapped(_ sender: Any) {
        onSleepTypeChange(false)
    }
    
    @IBAction func onCancelButtonPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }

    @IBAction func onAddButtonPressed(_ sender: Any) {
        HealthKitHelper.default.saveSleepData(startDate: startDate, endDate : endDate, isAsleep: isAsleep) { data, error in
            DispatchQueue.main.async {
                if error != nil {
                    print("Error: \(String(describing: error))")
                    if error is HealthKitHelper.HealthkitSetupError {
                        self.showSimpleAlert(title: "HealthKit Permission Denied", message: "Please go to Settings -> Privacy -> Health -> App and turn on all permissions", complete: nil)
                    } else {
                        self.showSimpleAlert(title: "Error", message: "Error on adding blood pressure data, please try again later", complete: nil)
                    }
                } else {
                    NotificationCenter.default.post(name: Notification.Name(USER_NOTIFICATION_HEALTHDATA_CHANGED), object: nil)
                }
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
}

extension SleepAddVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "healthdataadd_viewcell", for: indexPath) as! HealthDataAddViewCell
        
        switch indexPath.row {
        case 0:
            cell.lblTitle.text = "Start"
            cell.lblValue.isHidden = false
            cell.lblValue.text = dateFormatter.string(from: startDate)
            cell.tfValue.isHidden = true
            break
        case 1:
            cell.lblTitle.text = "End"
            cell.lblValue.isHidden = false
            cell.lblValue.text = dateFormatter.string(from: endDate)
            cell.tfValue.isHidden = true
            break
        default:
            break
        }
        
        cells[indexPath.row] = cell
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        startDatePicker.isHidden = true
        endDatePicker.isHidden = true
        cells[0]?.lblValue.textColor = .black
        cells[1]?.lblValue.textColor = .black
        
        switch indexPath.row {
        case 0:
            cells[0]?.lblValue.textColor = .systemBlue
            startDatePicker.isHidden = false
            break
        case 1:
            cells[1]?.lblValue.textColor = .systemBlue
            endDatePicker.isHidden = false
            break
        default:
            break
        }
    }

}
