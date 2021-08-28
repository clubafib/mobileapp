//
//  ECGDetailChartVC.swift
//  ClubAfib
//
//  Created by mac on 10/2/20.
//  Copyright © 2020 ETU. All rights reserved.
//

import UIKit
import PDFGenerator
import PDFKit
import HealthKit

class ECGDetailChartVC: UIViewController {

    @IBOutlet var lblType: UILabel!
    @IBOutlet var lblTime: UILabel!
    @IBOutlet var lblBPM: UILabel!
    @IBOutlet var scvwContent: UIScrollView!
    @IBOutlet var vwChart: ECGDetailChartVw!
    @IBOutlet var vwContent: UIView!
    
    public var m_data: Ecg!
    override func viewDidLoad() {
        super.viewDidLoad()
        lblBPM.text = String(format:"%d BPM Average", Int(m_data.avgHeartRate))
        let df = DateFormatter()
        df.dateFormat = "MM/dd/yyyy, hh:mm a"
        lblTime.text = df.string(from: m_data.date)
        
        vwChart.frame.size = CGSize(width: scvwContent.frame.size.width + 20, height: 180)
        let voltageData = m_data.getVoltageData()
        let voltagesFromData = m_data.setVoltagesFromData(voltageData)
        if voltagesFromData.count > 0 {
            vwChart.frame.size = CGSize(width: CGFloat(voltagesFromData.last!.time * 150), height: 180)
        }
        vwContent.frame.size = CGSize(width: vwChart.frame.size.width + 20, height: scvwContent.frame.size.height)
        scvwContent.contentSize = vwContent.frame.size
        vwChart.setData(voltagesFromData)
        
        switch HKElectrocardiogram.Classification(rawValue: m_data.type) {
        case .sinusRhythm:
            lblType.text = "Sinus Rhythm"
            break
        case .atrialFibrillation:
            lblType.text = "Atrial Fibrillation"
            break
        case .inconclusiveLowHeartRate:
            lblType.text = "Low And High Heart Rate"
            break
        case .inconclusiveHighHeartRate:
            lblType.text = "Low And High Heart Rate"
            break
        case .inconclusiveOther:
            lblType.text = "Inconclusive"
            break
        case .inconclusivePoorReading:
            lblType.text = "Inconclusive"
            break
        default:
            break
        }
    }
    
    @IBAction func onBack(){
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func onShare(){
        shareScreenshot()
    }
    
    @IBAction func onPDF(){
        let dst = URL(fileURLWithPath: NSTemporaryDirectory().appending("ECG.pdf"))
            // writes to Disk directly.
            do {
                let img = vwContent.toImage()
                let width = img.size.width * img.scale
                let height = img.size.height * img.scale
                let img1 = cropImage(image: img, rect: CGRect(x:0, y:0, width: width / 3, height: height))
                let img2 = cropImage(image: img, rect: CGRect(x:width / 3, y:0, width: width / 3, height: height))
                let img3 = cropImage(image: img, rect: CGRect(x:width / 3 * 2, y:0, width: width / 3, height: height))
                try PDFGenerator.generate([img1, img2, img3], to: dst)
                let vc = HOME_STORYBOARD.instantiateViewController(withIdentifier: "PDFViewerVC") as! PDFViewerVC
                present(vc, animated: true, completion: nil)
            } catch (let error) {
                print(error)
            }
    }
    
    func cropImage(image: UIImage, rect: CGRect) -> UIImage {
        let cgImage = image.cgImage! // better to write "guard" in realm app
        let croppedCGImage = cgImage.cropping(to: rect)
        return UIImage(cgImage: croppedCGImage!)
    }
}

class ECGDetailChartVw: UIView {
    var _points = [CGPoint]()
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        var path = UIBezierPath()
        if _points.count > 0 {
            UIColor.red.set()
            path.lineWidth = 1.5
            path.move(to: _points[0])
            for i in 1..<_points.count {
                path.addLine(to: _points[i])
            }
            path.stroke()
        }
              
        var i = 0
        path = UIBezierPath()
        self.borderColor?.set()
        path.lineWidth = 1
        while true {
            let startPos = CGPoint(x:i * 150, y: 0)
            if startPos.x > self.frame.size.width{
                break
            }
            path.move(to: startPos)
            path.addLine(to: CGPoint(x:startPos.x, y:self.frame.size.height))
            i += 1
        }
        path.stroke()
        
        i = 0
        while true {
            path = UIBezierPath()
            let startPos = CGPoint(x:0, y: 6 * i)
            if startPos.y > self.frame.size.height {
                break
            }
            if i % 5 == 0 {
                path.lineWidth = 0.5
            } else {
                path.lineWidth = 0.3
            }
            path.move(to: startPos)
            path.addLine(to: CGPoint(x:self.frame.size.width, y:startPos.y))
            i += 1
            path.stroke()
        }
        
        i = 0
        while(true) {
            path = UIBezierPath()
            let startPos = CGPoint(x:6 * i, y: 0)
            if startPos.x > self.frame.size.width{
                break
            }
            if i % 5 == 0 {
                path.lineWidth = 0.5
            } else {
                path.lineWidth = 0.3
            }
            path.move(to: startPos)
            path.addLine(to: CGPoint(x: startPos.x, y: self.frame.size.height))
            i += 1
            path.stroke()
        }
        
    }
    
    public func setData(_ values:[EcgItem]) {
        _points.removeAll()
        for vw in self.subviews {
            vw.removeFromSuperview()
        }
        let maxVal:CGFloat = 3000
        for item in values {
            let x = CGFloat(item.time) * 150
            let y = self.frame.size.height - (CGFloat(item.value + 1000) / maxVal) * self.frame.size.height
            _points.append(CGPoint(x:x, y:y))
        }

        var i = 0
        while true {
            let startPos = CGPoint(x:CGFloat(i * 150), y: self.frame.size.height + 5)
            if startPos.x > self.frame.size.width {
                break
            }
            let xlbl = UILabel(frame: CGRect(x: startPos.x + 5, y: startPos.y, width: 50, height: 10))
            xlbl.text = String(format:"%d", i + 1) + "s"
            xlbl.textColor = self.borderColor
            xlbl.font = UIFont.systemFont(ofSize: 14)
            xlbl.textAlignment = .left
            xlbl.sizeToFit()
            self.addSubview(xlbl)
            
            let line = UIView(frame: CGRect.zero)
            line.frame.origin = CGPoint(x:CGFloat(i * 150), y: self.frame.size.height)
            line.frame.size = CGSize(width: 1, height: 20)
            line.backgroundColor = self.borderColor
            self.addSubview(line)
            i += 1
        }
        self.setNeedsDisplay()
    }
}
