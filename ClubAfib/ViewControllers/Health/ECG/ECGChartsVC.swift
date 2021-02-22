//
//  ECGChartsVC.swift
//  ClubAfib
//
//  Created by mac on 10/2/20.
//  Copyright © 2020 ETU. All rights reserved.
//

import UIKit
import HealthKit
class ECGChartsVC: UIViewController {

    public var ecgData:[Ecg]!
    public var m_tblData = [Ecg]()
    @IBOutlet var lblTitle: UILabel!
    @IBOutlet weak var tblData: UITableView!
    
    var selectedDataType: ChartDataViewType = .Week
    var m_date: Date!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if ecgData.count > 0 {
            switch HKElectrocardiogram.Classification(rawValue: ecgData[0].type) {
            case .sinusRhythm:
                lblTitle.text = "Sinus Rhythm"
                break
            case .atrialFibrillation:
                lblTitle.text = "Atrial Fibrillation"
                break
            case .inconclusiveLowHeartRate:
                lblTitle.text = "Low And High Heart Rate"
                break
            case .inconclusiveHighHeartRate:
                lblTitle.text = "Low And High Heart Rate"
                break
            case .inconclusiveOther:
                lblTitle.text = "Inconclusive"
                break
            case .inconclusivePoorReading:
                lblTitle.text = "Inconclusive"
                break
            default:
                break
            }
        }
        let df = DateFormatter()
        var prevDate = ""
        var newDate = ""
        for item in ecgData {
            switch self.selectedDataType {
            case .Day:
                df.dateFormat = "yyyy-MM-dd HH"
                break
            case .Week:
                df.dateFormat = "yyyy-MM-dd"
                break
            case .Month:
                df.dateFormat = "yyyy-MM-dd"
                break
            case .Year:
                df.dateFormat = "yyyy-MM"
                break
            }
            newDate = df.string(from: item.date)
            prevDate = df.string(from: m_date)

            if newDate == prevDate {
                m_tblData.append(item)
            }
        }
        
        tblData.reloadData()
    }
    
    @IBAction func onBack(){
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func onShare(){
        shareScreenshot()
    }
}

extension ECGChartsVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return m_tblData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CellEcgCharts
        cell.setData(m_tblData[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 200
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = HOME_STORYBOARD.instantiateViewController(withIdentifier: "ECGDetailChartVC") as! ECGDetailChartVC
        vc.m_data = m_tblData[indexPath.row]
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

class CellEcgCharts:UITableViewCell {
    @IBOutlet var lblBPM: UILabel!
    @IBOutlet var lblTime: UILabel!
    @IBOutlet var vwChart: ECGPrevGraphVw!
    
    public func setData(_ data:Ecg) {
        lblBPM.text = String(format:"%d BPM Average", Int(data.avgHeartRate))
        let df = DateFormatter()
        df.dateFormat = "MM/dd/yyyy, hh:mm a"
        lblTime.text = df.string(from: data.date)
        vwChart.setData(data.voltages)
    }
}

class ECGPrevGraphVw: UIView {
    var _points = [CGPoint]()
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        if _points.count > 0 {
            let path = UIBezierPath()
            UIColor.red.set()
            path.lineWidth = 1.5
            path.move(to: _points[0])
            for i in 1..<_points.count {
                path.addLine(to: _points[i])
            }
            path.stroke()
        }
        
        let path = UIBezierPath()
        self.borderColor?.set()
        path.lineWidth = 0.8
        for i in 0..<4 {
            path.move(to: CGPoint(x:Int(self.frame.size.width / 3.1) * i, y:0))
            path.addLine(to: CGPoint(x:self.frame.size.width / 3.1 * CGFloat(i), y:self.frame.size.height))
        }
        path.stroke()
    }
    
    public func setData(_ values:[EcgItem]) {
        _points.removeAll()
        for vw in self.subviews {
            vw.removeFromSuperview()
        }
        let maxX:CGFloat = 3.1
        let maxVal:CGFloat = 3000
        for item in values {
            if CGFloat(item.time) > maxX {
                break
            }
            let x = CGFloat(item.time) / maxX * self.frame.size.width
            let y = self.frame.size.height - (CGFloat(item.value + 1000) / maxVal) * self.frame.size.height
            _points.append(CGPoint(x:x, y:y))
        }
//
//        for i in 0..<4 {
//            let xlbl = UILabel(frame: CGRect(x: Int(self.frame.size.width / 3.1) * i + 5, y: Int(self.frame.size.height) + 12, width: 50, height: 10))
//            xlbl.text = String(format:"%d", i + 1) + "s"
//            xlbl.textColor = self.borderColor
//            xlbl.font = UIFont.systemFont(ofSize: 12)
//            xlbl.textAlignment = .left
//            xlbl.sizeToFit()
//            self.addSubview(xlbl)
//        }
        self.setNeedsDisplay()
    }
}
