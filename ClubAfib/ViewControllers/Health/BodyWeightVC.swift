//
//  BodyWeightVC.swift
//  ClubAfib
//
//  Created by Rener on 8/5/20.
//  Copyright © 2020 ETU. All rights reserved.
//

import UIKit
import HealthKit

class BodyWeightVC: UIViewController {
    
    
    @IBOutlet weak var typeSC: UISegmentedControl!
    @IBOutlet weak var vwChartECG: BarChartView!
    @IBOutlet weak var weightChartView: LineChartView!
    @IBOutlet weak var lblMeasurement: UILabel!
    @IBOutlet weak var lblAmount: UILabel!
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var viewAllData: UIView!
    
    var allChartViews: [ChartViewBase] = []
    
    let dayInSeconds: Double = 24 * 3600
    var XAxisValueFormatter: DayAxisValueFormatter? = nil
    
    var dayStartDate = Date.Max()
    var dayEndDate = Date()
    var weekStartDate = Date()
    var weekEndDate = Date()
    var monthStartDate = Date()
    var monthEndDate = Date()
    var yearStartDate = Date()
    var yearEndDate = Date()
        
    var dayWeightEntries = [ChartDataEntry]()
    var weekWeightEntries = [ChartDataEntry]()
    var monthWeightEntries = [ChartDataEntry]()
    var yearWeightEntries = [ChartDataEntry]()
    var ecgAFEntries = [BarChartDataEntry]()
    var ecgData = [Ecg]()
    var ecgAF = [Ecg]()
    
    var selectedDataType: ChartDataViewType = .Week    
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        typeSC.selectedSegmentIndex = self.selectedDataType.rawValue
        typeSC.addTarget(self, action: #selector(self.chartDataViewTypeChanged), for:.valueChanged)
        typeSC.addTarget(self, action: #selector(self.chartDataViewTypeChanged), for:.touchUpInside)
        
        allChartViews = [vwChartECG, weightChartView]
        
        initChartView()
        initDates()
        
        let viewAllDataTap = UITapGestureRecognizer(target: self, action: #selector(onViewAllDataTapped))
        self.viewAllData.isUserInteractionEnabled = true
        self.viewAllData.addGestureRecognizer(viewAllDataTap)
        
        getECGData()
        getWeights()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.healthDataChanged), name: NSNotification.Name(USER_NOTIFICATION_HEALTHDATA_CHANGED), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        HealthDataManager.default.getHeartRatesFromDevice()
        HealthDataManager.default.getWeightsFromDevice()
    }
    
    @objc private func healthDataChanged(notification: NSNotification){
        DispatchQueue.main.async {
            self.getECGData()
            self.getWeights()
        }
    }
    
    private func initChartView() {
        let chartViews: [BarLineChartViewBase] = [vwChartECG, weightChartView]
        
        vwChartECG.drawBarShadowEnabled = false
        vwChartECG.drawValueAboveBarEnabled = false
        
        
        for chartView in chartViews {
            chartView.chartDescription?.enabled = false

            chartView.dragEnabled = true
            chartView.setScaleEnabled(false)
            chartView.pinchZoomEnabled = false

            chartView.delegate = self

            chartView.drawBordersEnabled = true
            chartView.chartDescription?.enabled = true
            chartView.legend.enabled = false

            let xAxis = chartView.xAxis
            xAxis.labelPosition = .bottom
            xAxis.centerAxisLabelsEnabled = true
            xAxis.labelFont = .systemFont(ofSize: 10)
            xAxis.drawLabelsEnabled = false
            xAxis.granularity = 1
            xAxis.labelCount = 5
            XAxisValueFormatter = DayAxisValueFormatter(chart: chartView)
            XAxisValueFormatter?.currentXAxisType = .Month
            xAxis.valueFormatter = XAxisValueFormatter

            let leftAxis = chartView.leftAxis
            leftAxis.enabled = false
            leftAxis.spaceTop = 0.1
            leftAxis.spaceBottom = 0
            leftAxis.axisMinimum = 0

            let rightAxis = chartView.rightAxis
            rightAxis.enabled = true
            rightAxis.labelFont = .systemFont(ofSize: 10)
            rightAxis.labelCount = 3
            rightAxis.minWidth = 35.0
            rightAxis.maxWidth = 35.0
            rightAxis.spaceTop = 0.1
            rightAxis.spaceBottom = 0
            rightAxis.axisMinimum = 0
        }
        
        weightChartView.xAxis.drawLabelsEnabled = true

        let ecgMarker = EcgMarker(color: UIColor(white: 230/250, alpha: 1), font: .systemFont(ofSize: 12), textColor: .black, insets: UIEdgeInsets(top: 8, left: 8, bottom: 20, right: 8))
        ecgMarker.chartView = vwChartECG
        ecgMarker.minimumSize = CGSize(width: 80, height: 40)
        vwChartECG.marker = ecgMarker

        let weightMarker = SimpleDataMarkerView(color: UIColor(white: 230/250, alpha: 1), font: .systemFont(ofSize: 12), textColor: .black, insets: UIEdgeInsets(top: 8, left: 8, bottom: 20, right: 8))
        weightMarker.healthType = .BodyWeight
        weightMarker.chartView = weightChartView
        weightMarker.minimumSize = CGSize(width: 80, height: 40)
        weightChartView.marker = weightMarker
    }
    
    private func initDates() {
        let calendar = Calendar.current
        let now = Date()
        
        // Set the anchor date to start of today
        let anchorDate = calendar.startOfDay(for: now)
        
        // set the day end date to tomorrow
        if let dayEndDate = calendar.date(byAdding: .day, value: 1, to: anchorDate) {
            self.dayEndDate = dayEndDate
        }
        
        // get the week start date
        var dateComponents = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: anchorDate)
        guard let firstDayOfWeek = calendar.date(from: dateComponents) else {
            return
        }
        // set the month end date to the first day of next month
        if let weekEndDate = calendar.date(byAdding: .day, value: 8, to: firstDayOfWeek) {
            self.weekEndDate = weekEndDate
        }
        
        
        // get the start date of month
        dateComponents = calendar.dateComponents([.year, .month], from: anchorDate)
        guard let firstDayOfMonth = calendar.date(from: dateComponents) else {
            return
        }
        // set the month end date to the first day of next month
        if let monthEndDate = calendar.date(byAdding: .month, value: 1, to: firstDayOfMonth) {
            self.monthEndDate = monthEndDate
        }
        
        // get the start day of year
        dateComponents = calendar.dateComponents([.year], from: anchorDate)
        guard let firstDayOfYear = calendar.date(from: dateComponents) else {
            return
        }
        // set the month end date to the first day of next month
        if let yearEndDate = calendar.date(byAdding: .year, value: 1, to: firstDayOfYear) {
            self.yearEndDate = yearEndDate
        }
    }
    
    private func getWeights() {
        let weightData = HealthDataManager.default.weightData.sorted(by: { $0.date.compare($1.date) == .orderedAscending })
        self.processDataset(weightData, healthType: .BodyWeight)
        self.resetChartView()
    }
    
    func resetStartDate(){
        let calendar = Calendar.current
        // get the week start date from start date
        var dateComponents = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: dayStartDate)
        if let weekStartDate = calendar.date(from: dateComponents) {
            self.weekStartDate = weekStartDate
        }
        // get the month start date from start date
        dateComponents = calendar.dateComponents([.year, .month], from: dayStartDate)
        if let monthStartDate = calendar.date(from: dateComponents) {
            self.monthStartDate = monthStartDate
        }
        // get the year start date from start date
        dateComponents = calendar.dateComponents([.year], from: dayStartDate)
        if let yearStartDate = calendar.date(from: dateComponents) {
            self.yearStartDate = yearStartDate
        }
    }
    
    private func processDataset(_ dataset: [SingleValueHealthData], healthType: HealthCategoryType) {
        if (dataset.count > 0) {
            let calendar = Calendar.current
            for data in dataset {
                if (data.value > 0) {
                    if data.date < dayStartDate {
                        dayStartDate = data.date
                        break
                    }
                }
            }
            resetStartDate()
            
            // get the week start date from start date
            var dateComponents = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: dayStartDate)
            if let weekStartDate = calendar.date(from: dateComponents) {
                self.weekStartDate = weekStartDate
            }
            // get the month start date from start date
            dateComponents = calendar.dateComponents([.year, .month], from: dayStartDate)
            if let monthStartDate = calendar.date(from: dateComponents) {
                self.monthStartDate = monthStartDate
            }
            // get the year start date from start date
            dateComponents = calendar.dateComponents([.year], from: dayStartDate)
            if let yearStartDate = calendar.date(from: dateComponents) {
                self.yearStartDate = yearStartDate
            }
            
            var day = 0, dailyCount = 0, dailyLast: Double = 0, dailyMin = 5000.0, dailyMax = 0.0
            var month = 1, monthlyCount = 0, monthlyLast: Double = 0, monthlyMin = 5000.0, monthlyMax = 0.0
            var startOfDay = dayStartDate
            var startOfMonth = monthStartDate
            
            switch healthType {
            case .BodyWeight:
                dayWeightEntries.removeAll()
                weekWeightEntries.removeAll()
                monthWeightEntries.removeAll()
                yearWeightEntries.removeAll()
                break
            default:
                break
            }
            
            for data in dataset {
                if (data.date >= dayStartDate && data.date < dayEndDate) {
                    switch healthType {
                    case .BodyWeight:
                        let entry = ChartDataEntry(x: 0.5 + GetXValueFromDate(date: data.date, type: .Day), y: data.value)
                        dayWeightEntries.append(entry)
                        break
                    default:
                        break
                    }
                }
                
                dateComponents = calendar.dateComponents([.year, .month, .day, .weekday], from: data.date)
                
                if (day != dateComponents.day) {
                    monthlyLast = dailyLast
                    if (dailyMin < monthlyMin) { monthlyMin = dailyMin }
                    if (dailyMax > monthlyMax) { monthlyMax = dailyMax }
                    if (dailyLast > 0) {
                        monthlyCount += 1
                    }
                    
                    if (dailyCount > 0 && data.date >= weekStartDate && data.date < weekEndDate) {
                        switch healthType {
                        case .BodyWeight:
                            let entry = ChartDataEntry(x: 0.5 + GetXValueFromDate(date: startOfDay, type: .Week), y: dailyLast)
                            weekWeightEntries.append(entry)
                            break
                        default:
                            break
                        }
                    }
                    if (dailyCount > 0 && data.date >= monthStartDate && data.date < monthEndDate) {
                        switch healthType {
                        case .BodyWeight:
                            let entry = ChartDataEntry(x: 0.5 + GetXValueFromDate(date: startOfDay, type: .Month), y: dailyLast)
                            monthWeightEntries.append(entry)
                            break
                        default:
                            break
                        }
                    }

                    if (month != dateComponents.month) {
                        let xValue = 0.5 + GetXValueFromDate(date: startOfMonth, type: .Year)
                        
                        if (monthlyCount > 0 && data.date >= yearStartDate && data.date < yearEndDate) {
                            switch healthType {
                            case .BodyWeight:
                                let entry = ChartDataEntry(x: xValue, y: monthlyLast)
                                yearWeightEntries.append(entry)
                                break
                            default:
                                break
                            }
                        }
                        
                        let components = calendar.dateComponents([.year, .month], from: data.date)
                        startOfMonth = calendar.date(from: components)!
                        month = dateComponents.month!
                        monthlyLast = 0
                        monthlyCount = 0
                        monthlyMin = 500.0
                        monthlyMax = 0.0
                    }
                    
                    startOfDay = calendar.date(from: dateComponents)!
                    day = dateComponents.day!
                    dailyCount = 0
                    dailyLast = 0
                    dailyMin = 5000.0
                    dailyMax = 0.0
                }
                
                if (data.value > 0) { dailyLast = data.value }
                if (data.value < dailyMin) { dailyMin = data.value }
                if (data.value > dailyMax) { dailyMax = data.value }
                if (data.value > 0) { dailyCount += 1 }
            }
            
            if (dailyCount > 0) {
                monthlyLast = dailyLast
                if (dailyMin < monthlyMin) { monthlyMin = dailyMin }
                if (dailyMax > monthlyMax) { monthlyMax = dailyMax }
                if (dailyCount > 0) {
                    monthlyCount += 1
                }
                
                switch healthType {
                case .BodyWeight:
                    let entry = ChartDataEntry(x: 0.5 + GetXValueFromDate(date: startOfDay, type: .Week), y: dailyLast)
                    weekWeightEntries.append(entry)
                    monthWeightEntries.append(entry)
                    break
                default:
                    break
                }
            }

            if (monthlyCount > 0) {
                let xValue = 0.5 + GetXValueFromDate(date: startOfMonth, type: .Year)
                
                switch healthType {
                case .BodyWeight:
                    let entry = ChartDataEntry(x: xValue, y: monthlyLast)
                    yearWeightEntries.append(entry)
                    break
                default:
                    break
                }
            }
        }
    }
    
    private func getECGData(){
        self.ecgData = HealthDataManager.default.ecgData.sorted(by: { $0.date.compare($1.date) == .orderedAscending })
        self.processECGDataset()
        self.resetChartView()
    }
    
    private func processECGDataset() {
        ecgAFEntries.removeAll()
        ecgAF.removeAll()
        for item in self.ecgData {
            if HKElectrocardiogram.Classification(rawValue: item.type) == .atrialFibrillation {
                ecgAF.append(item)
            }
//            if HKElectrocardiogram.Classification(rawValue: item.type) == .sinusRhythm {
//                ecgAF.append(item)
//            }
        }
        self.initEcgEntries(ecgAF)
    }
    
    func initEcgEntries(_ ecgs:[Ecg]) {
        var entry:BarChartDataEntry! = nil
        let offset = 0.3
        let df = DateFormatter()
        var prevDate = ""
        var newDate = ""
        if let first = ecgs.first {
            if first.date < dayStartDate {
                dayStartDate = first.date
            }
        }
        resetStartDate()
        for item in ecgs {
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
            if entry == nil {
                entry = BarChartDataEntry(x: offset + GetXValueFromDate(date: item.date, type: self.selectedDataType), y: 0)
                prevDate = newDate
            }
            if newDate == prevDate {
                entry.y += 1
            } else {
                ecgAFEntries.append(entry)
                entry = BarChartDataEntry(x: offset + GetXValueFromDate(date: item.date, type: self.selectedDataType), y: 1)
                prevDate = newDate
            }
        }
        
        if entry != nil {
            if entry.y != 0 {
                ecgAFEntries.append(entry)
            }
        }
    }
    
    private func resetChartView() {
        
        XAxisValueFormatter?.currentXAxisType = selectedDataType
        (vwChartECG.marker as! EcgMarker).currentXAxisType = selectedDataType
        (weightChartView.marker as! SimpleDataMarkerView).currentXAxisType = selectedDataType
        
        var minX = 0.0, maxX = 0.0
        var weightEntries: [ChartDataEntry]
        switch selectedDataType {
        case .Day:
            weightEntries = dayWeightEntries
            
            minX = GetXValueFromDate(date: dayStartDate, type: .Day)
            maxX = GetXValueFromDate(date: dayEndDate, type: .Day)
            break
        case .Week:
            weightEntries = weekWeightEntries
            
            minX = GetXValueFromDate(date: weekStartDate, type: .Week)
            maxX = GetXValueFromDate(date: weekEndDate, type: .Week)
            break
        case .Month:
            weightEntries = monthWeightEntries
            
            minX = GetXValueFromDate(date: monthStartDate, type: .Month)
            maxX = GetXValueFromDate(date: monthEndDate, type: .Month)
            break
        default:
            weightEntries = yearWeightEntries
            
            minX = GetXValueFromDate(date: yearStartDate, type: .Year)
            maxX = GetXValueFromDate(date: yearEndDate, type: .Year)
            break
        }
        
        vwChartECG.xAxis.axisMinimum = minX
        vwChartECG.xAxis.axisMaximum = maxX
        weightChartView.xAxis.axisMinimum = minX
        weightChartView.xAxis.axisMaximum = maxX
        
        if
            let weightSet = weightChartView.lineData?.dataSets.first as? LineChartDataSet {
            weightSet.replaceEntries(weightEntries)
                            
            weightChartView.data?.notifyDataChanged()
            weightChartView.notifyDataSetChanged()
        } else {
            let weightSet = LineChartDataSet(entries: weightEntries, label: "")
            weightSet.colors = [.systemPurple]
            weightSet.setCircleColor(.systemPurple)
            weightSet.highlightColor = .systemPurple
            weightSet.circleRadius = 5
            weightSet.circleHoleRadius = 2.5
            weightSet.lineWidth = 1.5
            weightSet.drawValuesEnabled = false
            let weightData = LineChartData(dataSet: weightSet)
            weightData.setValueFont(UIFont(name: "HelveticaNeue-Light", size: 10)!)
            if weightSet.count > 0 {
                weightChartView.data = weightData
            }
        }
        
        if vwChartECG.barData != nil {
            if let dataSet = vwChartECG.barData!.dataSets.first as? BarChartDataSet {
                dataSet.replaceEntries(ecgAFEntries)
                vwChartECG.data!.notifyDataChanged()
                vwChartECG.notifyDataSetChanged()
            }
        } else {
            let dataSet = BarChartDataSet(entries: ecgAFEntries, label: "")
            dataSet.colors = [UIColor.systemPink]
            dataSet.drawValuesEnabled = false
            let data = BarChartData(dataSet: dataSet)
            data.setValueFont(UIFont(name: "HelveticaNeue-Light", size: 10)!)
            if dataSet.count > 0 {
                vwChartECG.data = data
            }
        }
        
        switch selectedDataType {
        case .Day:
            vwChartECG.setVisibleXRange(minXRange: 24, maxXRange: 24)
            vwChartECG.xAxis.axisMaxLabels = 5
            vwChartECG.barData?.barWidth = 0.5
            weightChartView.setVisibleXRange(minXRange: 24, maxXRange: 24)
            weightChartView.xAxis.axisMaxLabels = 5
            break
        case .Week:
            vwChartECG.setVisibleXRange(minXRange: 7, maxXRange: 7)
            vwChartECG.xAxis.axisMaxLabels = 7
            vwChartECG.xAxis.axisMinLabels = 7
            vwChartECG.barData?.barWidth = 0.2
            weightChartView.setVisibleXRange(minXRange: 7, maxXRange: 7)
            weightChartView.xAxis.axisMaxLabels = 7
            weightChartView.xAxis.axisMinLabels = 7
            break
        case .Month:
            vwChartECG.setVisibleXRange(minXRange: 30, maxXRange: 30)
            vwChartECG.xAxis.axisMaxLabels = 5
            vwChartECG.barData?.barWidth = 0.7
            weightChartView.setVisibleXRange(minXRange: 30, maxXRange: 30)
            weightChartView.xAxis.axisMaxLabels = 5
            break
        default:
            vwChartECG.setVisibleXRange(minXRange: 12, maxXRange: 12)
            vwChartECG.xAxis.axisMaxLabels = 12
            vwChartECG.xAxis.axisMinLabels = 12
            vwChartECG.barData?.barWidth = 0.32
            weightChartView.setVisibleXRange(minXRange: 12, maxXRange: 12)
            weightChartView.xAxis.axisMaxLabels = 12
            weightChartView.xAxis.axisMinLabels = 12
            break
        }
        
        vwChartECG.moveViewToX(maxX)
        weightChartView.moveViewToX(maxX)

        updateChartYScale()
        updateMeasurements()
    }
    
    @objc func chartDataViewTypeChanged(segment: UISegmentedControl) {
        selectedDataType = ChartDataViewType(rawValue: segment.selectedSegmentIndex) ?? .Day
        self.processECGDataset()
        resetChartView()
    }
    
    @IBAction func onBackPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }

    @IBAction func onShareButtonPressed(_ sender: Any) {
        shareScreenshot()
    }
    
    @IBAction func onAddButtonPressed(_ sender: Any) {
        let addVC = HOME_STORYBOARD.instantiateViewController(withIdentifier: "BodyWeightAddVC") as! BodyWeightAddVC
        self.navigationController?.pushViewController(addVC, animated: true)
    }
    
    @objc func onViewAllDataTapped() {        
        let weightData = HealthDataManager.default.weightData.sorted(by: { $0.date.compare($1.date) == .orderedDescending })
        if weightData.count == 0 {
            showSimpleAlert(title: "Warning", message: "No data has been added by the user.  You can add data using the + found on top right corner of the page.", complete: nil)
            return
        }
        if dayStartDate != Date.Max() {
            let dataListVC = HOME_STORYBOARD.instantiateViewController(withIdentifier: "BodyWeightDataListVC") as! BodyWeightDataListVC            
            dataListVC.data = weightData
            self.navigationController?.pushViewController(dataListVC, animated: true)
        }
    }
    
}

extension BodyWeightVC: ChartViewDelegate {
    
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        for tempChart in allChartViews {
            if tempChart != chartView {
                tempChart.highlightValue(highlight)
            }
        }
    }
    
    func chartValueNothingSelected(_ chartView: ChartViewBase) {
        for tempChart in allChartViews {
            if tempChart != chartView {
                tempChart.highlightValue(nil)
            }
        }
        if chartView == vwChartECG {
            if let lastEntry = chartView.lastActivated {
                let entry = chartView.data?.entryForHighlight(lastEntry)
                let date = GetDateFromChartEntryX(value: entry!.x, type: self.selectedDataType)
                let vc = HOME_STORYBOARD.instantiateViewController(withIdentifier: "ECGChartsVC") as! ECGChartsVC
                vc.ecgData = ecgAF
                vc.m_date = date
                vc.selectedDataType = self.selectedDataType
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
    func chartTranslated(_ chartView: ChartViewBase, dX: CGFloat, dY: CGFloat) {
        let mainMatrix = chartView.viewPortHandler.touchMatrix
        
        for tempChart in allChartViews {
            if tempChart != chartView {
                tempChart.viewPortHandler.refresh(newMatrix: mainMatrix, chart: tempChart, invalidate: true)
            }
        }
    }

    func chartViewDidEndPanning(_ chartView: ChartViewBase) {
        updateChartYScale()
        updateMeasurements()
    }
    
    private func updateChartYScale() {
    }
    
    private func updateMeasurements() {
        if dayStartDate != Date.Max() {
//            var heartRateEntries: [RangeBarChartDataEntry]
            var weightEntries: [ChartDataEntry]
            switch selectedDataType {
            case .Day:
//                heartRateEntries = dayHeartRateEntries
                weightEntries = dayWeightEntries
                break
            case .Week:
//                heartRateEntries = weekHeartRateEntries
                weightEntries = weekWeightEntries
                break
            case .Month:
//                heartRateEntries = monthHeartRateEntries
                weightEntries = monthWeightEntries
                break
            default:
//                heartRateEntries = yearHeartRateEntries
                weightEntries = yearWeightEntries
                break
            }
            
            var lastWeight = 0.0, weightCounts = 0
            for entry in weightEntries {
                if (entry.x >= weightChartView.lowestVisibleX && entry.x <= weightChartView.highestVisibleX) {
                    if (entry.y > 0 ) {
                        lastWeight = entry.y
                        weightCounts += 1
                    }
                }
            }
            
            let strType = "LAST".localized()
            let weight = lastWeight
            
            let formatter = DateIntervalFormatter()
            let startDate = GetDateFromChartEntryX(value: weightChartView.lowestVisibleX, type: selectedDataType)
            var endDate = GetDateFromChartEntryX(value: weightChartView.highestVisibleX, type: selectedDataType)
            
            switch selectedDataType {
            case .Day:
                formatter.dateTemplate = "MMM d, h a"
                break
            case .Week:
                formatter.dateTemplate = "MMM d, yyyy"
                break
            case .Month:
                formatter.dateTemplate = "MMM d, yyyy"
                break
            default:
                formatter.dateTemplate = "yyyy"
                
                endDate = Calendar.current.date(byAdding: .day, value: -1, to: endDate)! // sometimes it's the first day of new year
                break
            }

            lblMeasurement.text = strType

            let yFormatter = NumberFormatter()
            yFormatter.maximumFractionDigits = 1
            let attributes1 = [NSAttributedString.Key.font: UIFont(name: "Avenir-Black", size: 24)!, NSAttributedString.Key.foregroundColor: UIColor.black]
            let attributesString1 = NSMutableAttributedString(string: yFormatter.string(from: NSNumber(floatLiteral: weight))!, attributes: attributes1)
            let attributes2 = [NSAttributedString.Key.font: UIFont(name: "Avenir-Black", size: 12)!, NSAttributedString.Key.foregroundColor: UIColor(red: 0.4, green: 0.4, blue: 0.4, alpha: 1.0)]
            let attributesString2 = NSMutableAttributedString(string: " lbs" , attributes: attributes2)
            let weightAmountString = NSMutableAttributedString()
            if weightCounts > 0 {
                weightAmountString.append(attributesString1)
                weightAmountString.append(attributesString2)
            } else {
                weightAmountString.append(NSMutableAttributedString(string: "NO DATA".localized() , attributes: attributes1))
            }
            
            lblAmount.attributedText = weightAmountString
            
            
            let strDate = formatter.string(from: startDate, to: endDate)
            lblDate.text = strDate
        }
        else {
            lblMeasurement.text = ""
            let attributes = [NSAttributedString.Key.font: UIFont(name: "Avenir-Black", size: 24)!, NSAttributedString.Key.foregroundColor: UIColor.black]
            let weightAmountString = NSMutableAttributedString(string: "NO DATA".localized() , attributes: attributes)
            lblAmount.attributedText = weightAmountString
            lblDate.text = ""
        }
    }

}
