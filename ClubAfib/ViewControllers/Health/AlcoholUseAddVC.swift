//
//  AlcoholUseAddVC.swift
//  ClubAfib
//
//  Created by Rener on 8/27/20.
//  Copyright © 2020 ETU. All rights reserved.
//

import UIKit

class AlcoholUseAddVC: UIViewController {
    
    @IBOutlet weak var btnAdd: UIButton!
    
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var timePicker: UIDatePicker!
    
    var cells: [HealthDataAddViewCell?] = [nil, nil, nil]
    
    let dateFormatter = DateFormatter()
    let timeFormatter = DateFormatter()
    
    var date = Date()
    var alcohol: Double = 0

    override func viewDidLoad() {
        super.viewDidLoad()

        dateFormatter.dateFormat = "MMMM d, yyyy"
        timeFormatter.dateFormat = "hh:mm a"
        
        btnAdd.isEnabled = false
        datePicker.isHidden = true
        datePicker.maximumDate = date
        timePicker.isHidden = true
    }
    
    private func updateForm() {
        combineDateTime()
        cells[0]?.lblValue.text = dateFormatter.string(from: date)
        cells[1]?.lblValue.text = timeFormatter.string(from: date)
    }
    
    private func combineDateTime() {
        let calendar = Calendar.current
        var dateComponents = calendar.dateComponents([.year, .month, .day], from: datePicker.date)
        let timeComponents = calendar.dateComponents([.hour, .minute], from: timePicker.date)
        
        dateComponents.hour = timeComponents.hour!
        dateComponents.minute = timeComponents.minute!
        
        date = calendar.date(from: dateComponents)!
    }
    
    @objc private func alcoholPercentChange(_ sender: Any) {
        alcohol = Double(cells[2]?.tfValue.text ?? "") ?? 0
        btnAdd.isEnabled = !(cells[2]?.tfValue.text ?? "").isEmpty && alcohol <= MAX_ALCOHOL_USE
    }
    
    @IBAction func datePickerChanged(_ sender: Any) {
        updateForm()
    }
    
    @IBAction func onCancelButtonPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }

    @IBAction func onAddButtonPressed(_ sender: Any) {
        // no need to save to health store
        showLoadingProgress(view: self.view)
//        ApiManager.sharedInstance.addAlcoholUseData((date, alcohol)) { (alcholUseData, errorMsg) in
            self.dismissLoadingProgress(view: self.view)
//            if let alcholUseData = alcholUseData {
////                HealthDataManager.default.addAlcoholUseData(alcholUseData)
//                DispatchQueue.main.async {
//                    self.navigationController?.popViewController(animated: true)
//                }
//            }
//            else {
//                print("error on saving alcohol use data: \(errorMsg ?? "")")
//            }
//        }
    }
    
}

extension AlcoholUseAddVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "healthdataadd_viewcell", for: indexPath) as! HealthDataAddViewCell
        
        switch indexPath.row {
        case 0:
            cell.lblTitle.text = "Date"
            cell.lblValue.isHidden = false
            cell.lblValue.text = dateFormatter.string(from: date)
            cell.tfValue.isHidden = true
            break
        case 1:
            cell.lblTitle.text = "Time"
            cell.lblValue.isHidden = false
            cell.lblValue.text = timeFormatter.string(from: date)
            cell.tfValue.isHidden = true
            break
        case 2:
            cell.lblTitle.text = "Number of drinks"
            cell.lblValue.isHidden = true
            cell.tfValue.isHidden = false
            cell.tfValue.keyboardType = .numberPad
            cell.tfValue.addTarget(self, action: #selector(self.alcoholPercentChange(_:)), for: .editingChanged)
            break
        default:
            break
        }
        
        cells[indexPath.row] = cell
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        datePicker.isHidden = true
        timePicker.isHidden = true
        cells[0]?.lblValue.textColor = .black
        cells[1]?.lblValue.textColor = .black
        
        switch indexPath.row {
        case 0:
            cells[0]?.lblValue.textColor = .systemBlue
            datePicker.isHidden = false
            cells[2]?.tfValue.resignFirstResponder()
            break
        case 1:
            cells[1]?.lblValue.textColor = .systemBlue
            timePicker.isHidden = false
            cells[2]?.tfValue.resignFirstResponder()
            break
        case 2:
            cells[2]?.tfValue.becomeFirstResponder()
            break
        default:
            break
        }
    }

}
