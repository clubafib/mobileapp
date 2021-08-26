//
//  AlcoholUseVC.swift
//  ClubAfib
//
//  Created by Rener on 8/27/20.
//  Copyright © 2020 ETU. All rights reserved.
//

import UIKit
import HealthKit

class AlcoholUseVC: UIViewController {
        
    @IBOutlet weak var typeSC: UISegmentedControl!
    @IBOutlet weak var vwChartECG: BarChartView!
    @IBOutlet weak var alcoholChartView: BarChartView!
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
        
    var dayStepEntries = [BarChartDataEntry]()
    var weekStepEntries = [BarChartDataEntry]()
    var monthStepEntries = [BarChartDataEntry]()
    var yearStepEntries = [BarChartDataEntry]()
    var ecgAFEntries = [BarChartDataEntry]()
    var ecgData = [Ecg]()
    var ecgAF = [Ecg]()
    
    var selectedDataType: ChartDataViewType = .Week
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        typeSC.selectedSegmentIndex = self.selectedDataType.rawValue
        typeSC.addTarget(self, action: #selector(self.chartDataViewTypeChanged), for:.valueChanged)
        typeSC.addTarget(self, action: #selector(self.chartDataViewTypeChanged), for:.touchUpInside)
        
        allChartViews = [vwChartECG, alcoholChartView]
        
        initChartView()
        initDates()
        
        let viewAllDataTap = UITapGestureRecognizer(target: self, action: #selector(onViewAllDataTapped))
        self.viewAllData.isUserInteractionEnabled = true
        self.viewAllData.addGestureRecognizer(viewAllDataTap)
        
        getECGData()
        getAlcoholUses()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.healthDataChanged), name: NSNotification.Name(USER_NOTIFICATION_HEALTHDATA_CHANGED), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        HealthDataManager.default.getECGDataFromDevice()
    }
    
    @objc private func healthDataChanged(notification: NSNotification){
        DispatchQueue.main.async {
            self.getECGData()
            self.getAlcoholUses()
        }
    }
    
    private func initChartView() {
        let chartViews: [BarLineChartViewBase] = [vwChartECG, alcoholChartView]
        
        vwChartECG.drawBarShadowEnabled = false
        vwChartECG.drawValueAboveBarEnabled = false
        alcoholChartView.drawBarShadowEnabled = false
        alcoholChartView.drawValueAboveBarEnabled = false
        
        
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
        
        alcoholChartView.xAxis.drawLabelsEnabled = true

        let ecgMarker = EcgMarker(color: UIColor(white: 230/250, alpha: 1), font: .systemFont(ofSize: 12), textColor: .black, insets: UIEdgeInsets(top: 8, left: 8, bottom: 20, right: 8))
        ecgMarker.chartView = vwChartECG
        ecgMarker.minimumSize = CGSize(width: 80, height: 40)
        vwChartECG.marker = ecgMarker

        let alcoholUsesMarker = SimpleDataMarkerView(color: UIColor(white: 230/250, alpha: 1), font: .systemFont(ofSize: 12), textColor: .black, insets: UIEdgeInsets(top: 8, left: 8, bottom: 20, right: 8))
        alcoholUsesMarker.healthType = .AlcoholUse
        alcoholUsesMarker.chartView = alcoholChartView
        alcoholUsesMarker.minimumSize = CGSize(width: 80, height: 40)
        alcoholChartView.marker = alcoholUsesMarker
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
    
    private func getAlcoholUses() {
        let alcoholUseData = HealthDataManager.default.alcoholUseData.sorted(by: { $0.date.compare($1.date) == .orderedAscending })
        self.processDataset(alcoholUseData, healthType: .AlcoholUse)
        DispatchQueue.main.async {
            self.resetChartView()
        }
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
            var dateComponents = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: dayStartDate)
            var day = 0, dailyCount = 0, dailySum: Double = 0, dailyMin = 5000.0, dailyMax = 0.0
            var month = 1, monthlyCount = 0, monthlySum: Double = 0, monthlyMin = 5000.0, monthlyMax = 0.0
            var startOfDay = dayStartDate
            var startOfMonth = monthStartDate
            
            switch healthType {
            case .AlcoholUse:
                dayStepEntries.removeAll()
                weekStepEntries.removeAll()
                monthStepEntries.removeAll()
                yearStepEntries.removeAll()
                break
            default:                
                break
            }
            
            for data in dataset {
                if (data.date >= dayStartDate && data.date < dayEndDate) {
                    switch healthType {
                    case .AlcoholUse:
                        let entry = BarChartDataEntry(x: 0.5 + GetXValueFromDate(date: data.date, type: .Day), y: data.value)
                        dayStepEntries.append(entry)
                        break
                    default:
                        break
                    }
                }
                
                dateComponents = calendar.dateComponents([.year, .month, .day, .weekday], from: data.date)
                
                if (day != dateComponents.day) {
                    monthlySum += dailySum
                    if (dailyMin < monthlyMin) { monthlyMin = dailyMin }
                    if (dailyMax > monthlyMax) { monthlyMax = dailyMax }
                    if (dailySum > 0) {
                        monthlyCount += 1
                    }
                    
                    if (dailyCount > 0 && data.date >= weekStartDate && data.date < weekEndDate) {
                        switch healthType {
                        case .AlcoholUse:
                            let entry = BarChartDataEntry(x: 0.5 + GetXValueFromDate(date: startOfDay, type: .Week), y: round(dailySum))
                            weekStepEntries.append(entry)
                            break
                        default:
                            break
                        }
                    }
                    if (dailyCount > 0 && data.date >= monthStartDate && data.date < monthEndDate) {
                        switch healthType {
                        case .AlcoholUse:
                            let entry = BarChartDataEntry(x: 0.5 + GetXValueFromDate(date: startOfDay, type: .Month), y: round(dailySum))
                            monthStepEntries.append(entry)
                            break
                        default:
                            break
                        }
                    }

                    if (month != dateComponents.month) {
                        let xValue = 0.5 + GetXValueFromDate(date: startOfMonth, type: .Year)
                        
                        if (monthlyCount > 0 && data.date >= yearStartDate && data.date < yearEndDate) {
                            switch healthType {
                            case .AlcoholUse:
                                let entry = BarChartDataEntry(x: xValue, y: monthlySum / Double(monthlyCount))
                                yearStepEntries.append(entry)
                                break
                            default:
                                break
                            }
                        }
                        
                        let components = calendar.dateComponents([.year, .month], from: data.date)
                        startOfMonth = calendar.date(from: components)!
                        month = dateComponents.month!
                        monthlySum = 0
                        monthlyCount = 0
                        monthlyMin = 500.0
                        monthlyMax = 0.0
                    }
                    
                    startOfDay = calendar.date(from: dateComponents)!
                    day = dateComponents.day!
                    dailyCount = 0
                    dailySum = 0
                    dailyMin = 5000.0
                    dailyMax = 0.0
                }
                
                dailySum += data.value
                if (data.value < dailyMin) { dailyMin = data.value }
                if (data.value > dailyMax) { dailyMax = data.value }
                if (data.value > 0) { dailyCount += 1 }
            }
            
            if (dailyCount > 0) {
                monthlySum += dailySum
                if (dailyMin < monthlyMin) { monthlyMin = dailyMin }
                if (dailyMax > monthlyMax) { monthlyMax = dailyMax }
                if (dailyCount > 0) {
                    monthlyCount += 1
                }
                
                switch healthType {
                case .AlcoholUse:
                    let entry = BarChartDataEntry(x: 0.5 + GetXValueFromDate(date: startOfDay, type: .Week), y: round(dailySum))
                    weekStepEntries.append(entry)
                    monthStepEntries.append(entry)
                    break
                default:
                    break
                }
            }

            if (monthlyCount > 0) {
                let xValue = 0.5 + GetXValueFromDate(date: startOfMonth, type: .Year)
                let entry = BarChartDataEntry(x: xValue, y: monthlySum / Double(monthlyCount))
                yearStepEntries.append(entry)
            }
        }
    }
    
    private func getECGData(){
        self.ecgData = HealthDataManager.default.ecgData.sorted(by: { $0.date.compare($1.date) == .orderedAscending })
        self.processECGDataset()
        DispatchQueue.main.async {
            self.resetChartView()
        }
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
        (alcoholChartView.marker as! SimpleDataMarkerView).currentXAxisType = selectedDataType
        
        var minX = 0.0, maxX = 0.0
        var alcoholUseEntries: [BarChartDataEntry]
        switch selectedDataType {
        case .Day:
            alcoholUseEntries = dayStepEntries
            minX = GetXValueFromDate(date: dayStartDate, type: .Day)
            maxX = GetXValueFromDate(date: dayEndDate, type: .Day)
            break
        case .Week:
            alcoholUseEntries = weekStepEntries
            minX = GetXValueFromDate(date: weekStartDate, type: .Week)
            maxX = GetXValueFromDate(date: weekEndDate, type: .Week)
            break
        case .Month:
            alcoholUseEntries = monthStepEntries
            minX = GetXValueFromDate(date: monthStartDate, type: .Month)
            maxX = GetXValueFromDate(date: monthEndDate, type: .Month)
            break
        default:
            alcoholUseEntries = yearStepEntries
            minX = GetXValueFromDate(date: yearStartDate, type: .Year)
            maxX = GetXValueFromDate(date: yearEndDate, type: .Year)
            break
        }
        
        vwChartECG.xAxis.axisMinimum = minX
        vwChartECG.xAxis.axisMaximum = maxX
        alcoholChartView.xAxis.axisMinimum = minX
        alcoholChartView.xAxis.axisMaximum = maxX
        
        if let alcoholUseSet = alcoholChartView.barData?.dataSets.first as? BarChartDataSet {
            alcoholUseSet.replaceEntries(alcoholUseEntries)
            alcoholChartView.data?.notifyDataChanged()
            alcoholChartView.notifyDataSetChanged()
        } else {
            let alcoholUseSet = BarChartDataSet(entries: alcoholUseEntries, label: "")
            alcoholUseSet.colors = [.systemGray]
            alcoholUseSet.drawValuesEnabled = false
            let alcoholUseData = BarChartData(dataSet: alcoholUseSet)
            alcoholUseData.setValueFont(UIFont(name: "HelveticaNeue-Light", size: 10)!)
            if alcoholUseEntries.count > 0 {
                alcoholChartView.data = alcoholUseData
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
            if ecgAFEntries.count > 0 {
                vwChartECG.data = data
            }
        }
        
        switch selectedDataType {
        case .Day:
            vwChartECG.setVisibleXRange(minXRange: 24, maxXRange: 24)
            vwChartECG.xAxis.axisMaxLabels = 5
            vwChartECG.barData?.barWidth = 0.5
            alcoholChartView.setVisibleXRange(minXRange: 24, maxXRange: 24)
            alcoholChartView.xAxis.axisMaxLabels = 5
            alcoholChartView.barData?.barWidth = 0.5
            break
        case .Week:
            vwChartECG.setVisibleXRange(minXRange: 7, maxXRange: 7)
            vwChartECG.xAxis.axisMaxLabels = 7
            vwChartECG.xAxis.axisMinLabels = 7
            vwChartECG.barData?.barWidth = 0.2
            alcoholChartView.setVisibleXRange(minXRange: 7, maxXRange: 7)
            alcoholChartView.xAxis.axisMaxLabels = 7
            alcoholChartView.xAxis.axisMinLabels = 7
            alcoholChartView.barData?.barWidth = 0.2
            break
        case .Month:
            vwChartECG.setVisibleXRange(minXRange: 30, maxXRange: 30)
            vwChartECG.xAxis.axisMaxLabels = 5
            vwChartECG.barData?.barWidth = 0.7
            alcoholChartView.setVisibleXRange(minXRange: 30, maxXRange: 30)
            alcoholChartView.xAxis.axisMaxLabels = 5
            alcoholChartView.barData?.barWidth = 0.7
            break
        default:
            vwChartECG.setVisibleXRange(minXRange: 12, maxXRange: 12)
            vwChartECG.xAxis.axisMaxLabels = 12
            vwChartECG.xAxis.axisMinLabels = 12
            vwChartECG.barData?.barWidth = 0.32
            alcoholChartView.setVisibleXRange(minXRange: 12, maxXRange: 12)
            alcoholChartView.xAxis.axisMaxLabels = 12
            alcoholChartView.xAxis.axisMinLabels = 12
            alcoholChartView.barData?.barWidth = 0.32
            break
        }
        
        vwChartECG.moveViewToX(maxX)
        alcoholChartView.moveViewToX(maxX)

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
        let addVC = HOME_STORYBOARD.instantiateViewController(withIdentifier: "AlcoholUseAddVC") as! AlcoholUseAddVC
        self.navigationController?.pushViewController(addVC, animated: true)
    }
    
    @objc func onViewAllDataTapped() {
        let alcoholUseData = HealthDataManager.default.alcoholUseData.sorted(by: { $0.date.compare($1.date) == .orderedDescending })
        if alcoholUseData.count == 0 {
            showSimpleAlert(title: "Warning", message: "No data has been added by the user.  You can add data using the + found on top right corner of the page.", complete: nil)
            return
        }
        if dayStartDate != Date.Max() {
            let dataListVC = HOME_STORYBOARD.instantiateViewController(withIdentifier: "AlcoholUseDataListVC") as! AlcoholUseDataListVC
            dataListVC.data = alcoholUseData
            self.navigationController?.pushViewController(dataListVC, animated: true)
        }
    }
    
}

extension AlcoholUseVC: ChartViewDelegate {
    
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
            var alcoholUseEntries: [BarChartDataEntry]
            switch selectedDataType {
            case .Day:
//                heartRateEntries = dayHeartRateEntries
                alcoholUseEntries = dayStepEntries
                break
            case .Week:
//                heartRateEntries = weekHeartRateEntries
                alcoholUseEntries = weekStepEntries
                break
            case .Month:
//                heartRateEntries = monthHeartRateEntries
                alcoholUseEntries = monthStepEntries
                break
            default:
//                heartRateEntries = yearHeartRateEntries
                alcoholUseEntries = yearStepEntries
                break
            }
            
            var maxAlcoholUse = 0.0, sumAlcoholUse = 0.0, alcoholUseCounts = 0
            for entry in alcoholUseEntries {
                if (entry.x >= alcoholChartView.lowestVisibleX && entry.x <= alcoholChartView.highestVisibleX) {
                    if (entry.y > maxAlcoholUse) { maxAlcoholUse = entry.y }
                    if (entry.y > 0 ) {
                        sumAlcoholUse += entry.y
                        alcoholUseCounts += 1
                    }
                }
            }
            
            var strType = "", alcoholUses = 0.0
            
            let formatter = DateIntervalFormatter()
            let startDate = GetDateFromChartEntryX(value: alcoholChartView.lowestVisibleX, type: selectedDataType)
            var endDate = GetDateFromChartEntryX(value: alcoholChartView.highestVisibleX, type: selectedDataType)
            
            switch selectedDataType {
            case .Day:
                strType = "TOTAL".localized()
                alcoholUses = round(sumAlcoholUse)
                formatter.dateTemplate = "MMM d, h a"
                break
            case .Week:
                strType = "AVERAGE".localized()
                alcoholUses = alcoholUseCounts > 0 ? round(sumAlcoholUse / Double(alcoholUseCounts)) : 0
                formatter.dateTemplate = "MMM d, yyyy"
                break
            case .Month:
                strType = "AVERAGE".localized()
                alcoholUses = alcoholUseCounts > 0 ? round(sumAlcoholUse / Double(alcoholUseCounts)) : 0
                formatter.dateTemplate = "MMM d, yyyy"
                break
            default:
                strType = "AVERAGE".localized()
                alcoholUses = alcoholUseCounts > 0 ? round(sumAlcoholUse / Double(alcoholUseCounts)) : 0
                formatter.dateTemplate = "yyyy"
                
                endDate = Calendar.current.date(byAdding: .day, value: -1, to: endDate)! // sometimes it's the first day of new year
                break
            }
            
            lblMeasurement.text = strType

            let yFormatter = NumberFormatter()
            yFormatter.numberStyle = .decimal
            yFormatter.groupingSeparator = ","
            let attributes1 = [NSAttributedString.Key.font: UIFont(name: "Avenir-Black", size: 24)!, NSAttributedString.Key.foregroundColor: UIColor.black]
            let attributesString1 = NSMutableAttributedString(string: yFormatter.string(from: NSNumber(floatLiteral: alcoholUses))!, attributes: attributes1)
            let attributes2 = [NSAttributedString.Key.font: UIFont(name: "Avenir-Black", size: 12)!, NSAttributedString.Key.foregroundColor: UIColor(red: 0.4, green: 0.4, blue: 0.4, alpha: 1.0)]
            let attributesString2 = NSMutableAttributedString(string: alcoholUses > 1 ? " drinks" : " drink" , attributes: attributes2)
            let alcoholUseAmountString = NSMutableAttributedString()
            alcoholUseAmountString.append(attributesString1)
            alcoholUseAmountString.append(attributesString2)
            
            lblAmount.attributedText = alcoholUseAmountString
            
            
            let strDate = formatter.string(from: startDate, to: endDate)
            lblDate.text = strDate
        }
        else {
            lblMeasurement.text = ""
            let attributes = [NSAttributedString.Key.font: UIFont(name: "Avenir-Black", size: 24)!, NSAttributedString.Key.foregroundColor: UIColor.black]
            let alcoholUseAmountString = NSMutableAttributedString(string: "NO DATA".localized() , attributes: attributes)
            lblAmount.attributedText = alcoholUseAmountString
            lblDate.text = ""
        }
    }
    
}
