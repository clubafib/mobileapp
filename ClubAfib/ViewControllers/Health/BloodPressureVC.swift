//
//  BloodPressureVC.swift
//  ClubAfib
//
//  Created by Rener on 8/13/20.
//  Copyright © 2020 ETU. All rights reserved.
//

import UIKit
import HealthKit

class BloodPressureVC: UIViewController {
    let months = ["Jan", "Feb", "Mar",
                  "Apr", "May", "Jun",
                  "Jul", "Aug", "Sep",
                  "Oct", "Nov", "Dec"]
    
    @IBOutlet weak var typeSC: UISegmentedControl!
    @IBOutlet weak var vwChartECG: BarChartView!
    @IBOutlet weak var bpChartView: RangeBarChartView!
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
        
    var daySystolicEntries = [RangeBarChartDataEntry]()
    var dayDiastolicEntries = [RangeBarChartDataEntry]()
        
    var weekSystolicEntries = [RangeBarChartDataEntry]()
    var weekDiastolicEntries = [RangeBarChartDataEntry]()
        
    var monthSystolicEntries = [RangeBarChartDataEntry]()
    var monthDiastolicEntries = [RangeBarChartDataEntry]()
        
    var yearSystolicEntries = [RangeBarChartDataEntry]()
    var yearDiastolicEntries = [RangeBarChartDataEntry]()
    var ecgAFEntries = [BarChartDataEntry]()
    var ecgData = [Ecg]()
    var ecgAF = [Ecg]()
    
    var selectedDataType: ChartDataViewType = .Week    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        typeSC.selectedSegmentIndex = self.selectedDataType.rawValue
        typeSC.addTarget(self, action: #selector(self.chartDataViewTypeChanged), for:.valueChanged)
        typeSC.addTarget(self, action: #selector(self.chartDataViewTypeChanged), for:.touchUpInside)
        
        allChartViews = [vwChartECG, bpChartView]
        
        initChartView()
        initDates()
        
        let viewAllDataTap = UITapGestureRecognizer(target: self, action: #selector(onViewAllDataTapped))
        self.viewAllData.isUserInteractionEnabled = true
        self.viewAllData.addGestureRecognizer(viewAllDataTap)
        
        getECGData()
        getBloodPressure()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.healthDataChanged), name: NSNotification.Name(USER_NOTIFICATION_HEALTHDATA_CHANGED), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        HealthDataManager.default.getECGDataFromDevice()
        HealthDataManager.default.getBloodPressureFromDevice()
    }
    
    @objc private func healthDataChanged(notification: NSNotification){
        DispatchQueue.main.async {
            self.getECGData()
            self.getBloodPressure()
        }
    }
    
    private func initChartView() {
        let chartViews: [BarLineChartViewBase] = [vwChartECG, bpChartView]
        
        vwChartECG.drawBarShadowEnabled = false
        vwChartECG.drawValueAboveBarEnabled = false
        bpChartView.drawBarShadowEnabled = false
        bpChartView.drawValueAboveBarEnabled = false
        
        
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
            rightAxis.minWidth = 25.0
            rightAxis.maxWidth = 25.0
            rightAxis.spaceTop = 0.1
            rightAxis.spaceBottom = 0
            rightAxis.axisMinimum = 0
        }
        
        bpChartView.xAxis.drawLabelsEnabled = true

        let ecgMarker = EcgMarker(color: UIColor(white: 230/250, alpha: 1), font: .systemFont(ofSize: 12), textColor: .black, insets: UIEdgeInsets(top: 8, left: 8, bottom: 20, right: 8))
        ecgMarker.chartView = vwChartECG
        ecgMarker.minimumSize = CGSize(width: 80, height: 40)
        vwChartECG.marker = ecgMarker

        let bpMarker = BloodPressureMarkerView(color: UIColor(white: 230/250, alpha: 1), font: .systemFont(ofSize: 12), textColor: .black, insets: UIEdgeInsets(top: 8, left: 8, bottom: 20, right: 8))
        bpMarker.customLabelDelegate = self
        bpMarker.chartView = bpChartView
        bpMarker.minimumSize = CGSize(width: 80, height: 40)
        bpChartView.marker = bpMarker
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
    
    private func getBloodPressure() {
        let bloodPressureData = HealthDataManager.default.bloodPressureData.sorted(by: { $0.date.compare($1.date) == .orderedAscending })
        self.processBloodPressureDataset(bloodPressureData)
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
    
    private func processBloodPressureDataset(_ dataset: [RangeValueHealthData]) {
        if (dataset.count > 0) {
            let calendar = Calendar.current
            
            for data in dataset {
                if data.high > 0 && data.low > 0 {
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
            
            var day = 0, dailyCount = 0, dailySum: Double = 0, dailyMinLow = 5000.0, dailyMaxLow = 0.0, dailyMinHigh = 5000.0, dailyMaxHigh = 0.0
            var month = 1, monthlyCount = 0, monthlySum: Double = 0, monthlyMinLow = 5000.0, monthlyMaxLow = 0.0, monthlyMinHigh = 5000.0, monthlyMaxHigh = 0.0
            var startOfDay = dayStartDate
            var startOfMonth = monthStartDate
            

            daySystolicEntries.removeAll()
            weekSystolicEntries.removeAll()
            monthSystolicEntries.removeAll()
            yearSystolicEntries.removeAll()
            
            dayDiastolicEntries.removeAll()
            weekDiastolicEntries.removeAll()
            monthDiastolicEntries.removeAll()
            yearDiastolicEntries.removeAll()
            
            for data in dataset {
                if (data.date >= dayStartDate && data.date < dayEndDate) {
                    let entryLow = RangeBarChartDataEntry(x: 0.5 + GetXValueFromDate(date: data.date, type: .Day), start: data.low, end: data.low)
                    let entryHigh = RangeBarChartDataEntry(x: 0.5 + GetXValueFromDate(date: data.date, type: .Day), start: data.high, end: data.high)
                    daySystolicEntries.append(entryHigh)
                    dayDiastolicEntries.append(entryLow)
                }
                
                dateComponents = calendar.dateComponents([.year, .month, .day, .weekday], from: data.date)
                
                if (day != dateComponents.day) {
                    monthlySum += dailySum
                    if (dailyMinLow < monthlyMinLow) { monthlyMinLow = dailyMinLow }
                    if (dailyMaxLow > monthlyMaxLow) { monthlyMaxLow = dailyMaxLow }
                    if (dailyMinHigh < monthlyMinHigh) { monthlyMinHigh = dailyMinHigh }
                    if (dailyMaxHigh > monthlyMaxHigh) { monthlyMaxHigh = dailyMaxHigh }
                    if (dailySum > 0) {
                        monthlyCount += 1
                    }
                    let entryLow = RangeBarChartDataEntry(x: 0.5 + GetXValueFromDate(date: startOfDay, type: .Week), start: round(dailyMinLow), end: round(dailyMaxLow))
                    let entryHigh = RangeBarChartDataEntry(x: 0.5 + GetXValueFromDate(date: startOfDay, type: .Week), start: round(dailyMinHigh), end: round(dailyMaxHigh))
                    
                    if (dailyCount > 0 && data.date >= weekStartDate && data.date < weekEndDate) {
                        weekSystolicEntries.append(entryHigh)
                        weekDiastolicEntries.append(entryLow)
                    }
                    if (dailyCount > 0 && data.date >= monthStartDate && data.date < monthEndDate) {
                        monthSystolicEntries.append(entryHigh)
                        monthDiastolicEntries.append(entryLow)
                    }

                    if (month != dateComponents.month) {
                        let xValue = 0.5 + GetXValueFromDate(date: startOfMonth, type: .Year)
                        let entryLow = RangeBarChartDataEntry(x: xValue, start: round(monthlyMinLow), end: round(monthlyMaxLow))
                        let entryHigh = RangeBarChartDataEntry(x: xValue, start: round(monthlyMinHigh), end: round(monthlyMaxHigh))
                        
                        if (monthlyCount > 0 && data.date >= yearStartDate && data.date < yearEndDate) {
                            yearSystolicEntries.append(entryHigh)
                            yearDiastolicEntries.append(entryLow)
                        }
                        
                        let components = calendar.dateComponents([.year, .month], from: data.date)
                        startOfMonth = calendar.date(from: components)!
                        month = dateComponents.month!
                        monthlySum = 0
                        monthlyCount = 0
                        monthlyMinLow = 500.0
                        monthlyMaxLow = 0.0
                        monthlyMinHigh = 500.0
                        monthlyMaxHigh = 0.0
                    }
                    
                    startOfDay = calendar.date(from: dateComponents)!
                    day = dateComponents.day!
                    dailyCount = 0
                    dailySum = 0
                    dailyMinLow = 5000.0
                    dailyMaxLow = 0.0
                    dailyMinHigh = 5000.0
                    dailyMaxHigh = 0.0
                }
                
                if (data.low < dailyMinLow) { dailyMinLow = data.low }
                if (data.low > dailyMaxLow) { dailyMaxLow = data.low }
                if (data.high < dailyMinHigh) { dailyMinHigh = data.high }
                if (data.high > dailyMaxHigh) { dailyMaxHigh = data.high }
                if (data.high > 0) { dailyCount += 1 }
            }
            
            if (dailyCount > 0) {
                if (dailyMinLow < monthlyMinLow) { monthlyMinLow = dailyMinLow }
                if (dailyMaxLow > monthlyMaxLow) { monthlyMaxLow = dailyMaxLow }
                if (dailyMinHigh < monthlyMinHigh) { monthlyMinHigh = dailyMinHigh }
                if (dailyMaxHigh > monthlyMaxHigh) { monthlyMaxHigh = dailyMaxHigh }
                if (dailyCount > 0) {
                    monthlyCount += 1
                }
                let entryLow = RangeBarChartDataEntry(x: 0.5 + GetXValueFromDate(date: startOfDay, type: .Week), start: dailyMinLow, end: dailyMaxLow)
                let entryHigh = RangeBarChartDataEntry(x: 0.5 + GetXValueFromDate(date: startOfDay, type: .Week), start: dailyMinHigh, end: dailyMaxHigh)

                weekSystolicEntries.append(entryHigh)
                monthSystolicEntries.append(entryHigh)
                weekDiastolicEntries.append(entryLow)
                monthDiastolicEntries.append(entryLow)
            }

            if (monthlyCount > 0) {
                let xValue = 0.5 + GetXValueFromDate(date: startOfMonth, type: .Year)
                let entryLow = RangeBarChartDataEntry(x: xValue, start: monthlyMinLow, end: monthlyMaxLow)
                let entryHigh = RangeBarChartDataEntry(x: xValue, start: monthlyMinHigh, end: monthlyMaxHigh)

                yearSystolicEntries.append(entryHigh)
                yearDiastolicEntries.append(entryLow)
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
        (bpChartView.marker as! BloodPressureMarkerView).currentXAxisType = selectedDataType
        
        var minX = 0.0, maxX = 0.0
        var systolicEntries: [RangeBarChartDataEntry]
        var diastolicEntries: [RangeBarChartDataEntry]
        switch selectedDataType {
        case .Day:
            systolicEntries = daySystolicEntries
            diastolicEntries = dayDiastolicEntries
            
            minX = GetXValueFromDate(date: dayStartDate, type: .Day)
            maxX = GetXValueFromDate(date: dayEndDate, type: .Day)
            break
        case .Week:
            systolicEntries = weekSystolicEntries
            diastolicEntries = weekDiastolicEntries
            
            minX = GetXValueFromDate(date: weekStartDate, type: .Week)
            maxX = GetXValueFromDate(date: weekEndDate, type: .Week)
            break
        case .Month:
            systolicEntries = monthSystolicEntries
            diastolicEntries = monthDiastolicEntries
            
            minX = GetXValueFromDate(date: monthStartDate, type: .Month)
            maxX = GetXValueFromDate(date: monthEndDate, type: .Month)
            break
        default:
            systolicEntries = yearSystolicEntries
            diastolicEntries = yearDiastolicEntries
            
            minX = GetXValueFromDate(date: yearStartDate, type: .Year)
            maxX = GetXValueFromDate(date: yearEndDate, type: .Year)
            break
        }
        
        vwChartECG.xAxis.axisMinimum = minX
        vwChartECG.xAxis.axisMaximum = maxX
        bpChartView.xAxis.axisMinimum = minX
        bpChartView.xAxis.axisMaximum = maxX

        if let sleepSets = bpChartView.rangeBarData?.dataSets as? [RangeBarChartDataSet] {
                            
            if sleepSets.count > 1 {
                sleepSets[0].replaceEntries(systolicEntries)
                sleepSets[1].replaceEntries(diastolicEntries)
            }
            bpChartView.data?.notifyDataChanged()
            bpChartView.notifyDataSetChanged()
        } else {
            
            let systolicSet = RangeBarChartDataSet(entries: systolicEntries, label: "")
            systolicSet.colors = [.orange]
            systolicSet.drawValuesEnabled = false
            let diastolicSet = RangeBarChartDataSet(entries: diastolicEntries, label: "")
            diastolicSet.colors = [.black]
            diastolicSet.drawValuesEnabled = false
            let bpData = RangeBarChartData(dataSets: [systolicSet, diastolicSet])
            bpData.setValueFont(UIFont(name: "HelveticaNeue-Light", size: 10)!)
            if systolicSet.count > 0 || diastolicSet.count > 0 {
                bpChartView.data = bpData
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
            bpChartView.setVisibleXRange(minXRange: 24, maxXRange: 24)
            bpChartView.xAxis.axisMaxLabels = 5
            bpChartView.rangeBarData?.barWidth = 0.5
            break
        case .Week:
            vwChartECG.setVisibleXRange(minXRange: 7, maxXRange: 7)
            vwChartECG.xAxis.axisMaxLabels = 7
            vwChartECG.xAxis.axisMinLabels = 7
            vwChartECG.barData?.barWidth = 0.2
            bpChartView.setVisibleXRange(minXRange: 7, maxXRange: 7)
            bpChartView.xAxis.axisMaxLabels = 7
            bpChartView.xAxis.axisMinLabels = 7
            bpChartView.rangeBarData?.barWidth = 0.2
            break
        case .Month:
            vwChartECG.setVisibleXRange(minXRange: 30, maxXRange: 30)
            vwChartECG.xAxis.axisMaxLabels = 5
            vwChartECG.barData?.barWidth = 0.32
            bpChartView.setVisibleXRange(minXRange: 30, maxXRange: 30)
            bpChartView.xAxis.axisMaxLabels = 5
            bpChartView.rangeBarData?.barWidth = 0.32
            break
        default:
            vwChartECG.setVisibleXRange(minXRange: 12, maxXRange: 12)
            vwChartECG.xAxis.axisMaxLabels = 12
            vwChartECG.xAxis.axisMinLabels = 12
            vwChartECG.barData?.barWidth = 0.32
            bpChartView.setVisibleXRange(minXRange: 12, maxXRange: 12)
            bpChartView.xAxis.axisMaxLabels = 12
            bpChartView.xAxis.axisMinLabels = 12
            bpChartView.rangeBarData?.barWidth = 0.32
            break
        }
        
        vwChartECG.moveViewToX(maxX)
        bpChartView.moveViewToX(maxX)

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
        let addVC = HOME_STORYBOARD.instantiateViewController(withIdentifier: "BloodPressureAddVC") as! BloodPressureAddVC
        self.navigationController?.pushViewController(addVC, animated: true)
    }
    
    @objc func onViewAllDataTapped() {
        //No data has been added by the user.  You can add data using the + found on top right corner of the page.
        let bloodPressureData = HealthDataManager.default.bloodPressureData.sorted(by: { $0.date.compare($1.date) == .orderedDescending })
        if bloodPressureData.count == 0 {
            showSimpleAlert(title: "Warning", message: "No data has been added by the user.  You can add data using the + found on top right corner of the page.", complete: nil)
            return
        }
        if dayStartDate != Date.Max() {
            let dataListVC = HOME_STORYBOARD.instantiateViewController(withIdentifier: "BloodPressureDataListVC") as! BloodPressureDataListVC
            
            dataListVC.data = bloodPressureData
            self.navigationController?.pushViewController(dataListVC, animated: true)
        }
    }
    
}

extension BloodPressureVC: ChartViewDelegate {
    
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
            var systolicEntries: [RangeBarChartDataEntry]
            var diastolicEntries: [RangeBarChartDataEntry]
            switch selectedDataType {
            case .Day:
                systolicEntries = daySystolicEntries
                diastolicEntries = dayDiastolicEntries
                break
            case .Week:
                systolicEntries = weekSystolicEntries
                diastolicEntries = weekDiastolicEntries
                break
            case .Month:
                systolicEntries = monthSystolicEntries
                diastolicEntries = monthDiastolicEntries
                break
            default:
                systolicEntries = yearSystolicEntries
                diastolicEntries = yearDiastolicEntries
                break
            }
            
            var maxSystolic = 0.0, minSystolic = 500.0, systolicCounts = 0
            for entry in systolicEntries {
                if (entry.x >= bpChartView.lowestVisibleX && entry.x <= bpChartView.highestVisibleX) {
                    if (entry.end > maxSystolic) { maxSystolic = entry.end }
                    if (entry.start < minSystolic ) {
                        minSystolic = entry.start
                    }
                    if (entry.start > 0) {
                        systolicCounts += 1
                    }
                }
            }
            var maxDiastolic = 0.0, minDiastolic = 500.0, diastolicCounts = 0
            for entry in diastolicEntries {
                if (entry.x >= bpChartView.lowestVisibleX && entry.x <= bpChartView.highestVisibleX) {
                    if (entry.end > maxDiastolic) { maxDiastolic = entry.end }
                    if (entry.start < minDiastolic ) {
                        minDiastolic = entry.start
                    }
                    if (entry.start > 0) {
                        diastolicCounts += 1
                    }
                }
            }

            let strType = "\("SYSTOLIC".localized()) / \("DIASTOLIC".localized())"

            let formatter = DateIntervalFormatter()
            let startDate = GetDateFromChartEntryX(value: bpChartView.lowestVisibleX, type: selectedDataType)
            var endDate = GetDateFromChartEntryX(value: bpChartView.highestVisibleX, type: selectedDataType)

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
            yFormatter.numberStyle = .decimal
            yFormatter.groupingSeparator = ","
            let valueAttributes = [NSAttributedString.Key.font: UIFont(name: "Avenir-Black", size: 24)!, NSAttributedString.Key.foregroundColor: UIColor.black]
            let unitAttributes = [NSAttributedString.Key.font: UIFont(name: "Avenir-Black", size: 12)!, NSAttributedString.Key.foregroundColor: UIColor(red: 0.4, green: 0.4, blue: 0.4, alpha: 1.0)]
            
            let sleepAmountString = NSMutableAttributedString()
            
            if systolicCounts > 0 || diastolicCounts > 0 {
                let strSystolic = minSystolic == maxSystolic ? "\(Int(maxSystolic))" : "\(Int(minSystolic))-\(Int(maxSystolic))"
                let strDiastolic = minDiastolic == maxDiastolic ? "\(Int(maxDiastolic))" : "\(Int(minDiastolic))-\(Int(maxDiastolic))"
                sleepAmountString.append(NSMutableAttributedString(string: "\(strSystolic) / \(strDiastolic)", attributes: valueAttributes))
                sleepAmountString.append(NSMutableAttributedString(string: " mmHg" , attributes: unitAttributes))
            } else {
                sleepAmountString.append(NSMutableAttributedString(string: "NO DATA".localized() , attributes: valueAttributes))
            }

            lblAmount.attributedText = sleepAmountString

            let strDate = formatter.string(from: startDate, to: endDate)
            lblDate.text = strDate
        }
        else {
            lblMeasurement.text = ""
            let attributes = [NSAttributedString.Key.font: UIFont(name: "Avenir-Black", size: 24)!, NSAttributedString.Key.foregroundColor: UIColor.black]
            let stepAmountString = NSMutableAttributedString(string: "NO DATA".localized() , attributes: attributes)
            lblAmount.attributedText = stepAmountString
            lblDate.text = ""
        }
    }
    
    private func minutesToString(_ minutes: Double) -> NSMutableAttributedString {
        let hours = Int(floor(minutes / 60.0))
        let mins = Int(round(minutes)) % 60
        let hasHours = hours > 0
        
        let attrValue = [NSAttributedString.Key.font: UIFont(name: "Avenir-Black", size: 24)!, NSAttributedString.Key.foregroundColor: UIColor.black]
        let strHours = NSMutableAttributedString(string: String(hours), attributes: attrValue)
        let strMins = NSMutableAttributedString(string: String(mins), attributes: attrValue)
        
        let attriUnit = [NSAttributedString.Key.font: UIFont(name: "Avenir-Black", size: 12)!, NSAttributedString.Key.foregroundColor: UIColor(red: 0.4, green: 0.4, blue: 0.4, alpha: 1.0)]
        let strHourUnit = NSMutableAttributedString(string: " hr ", attributes: attriUnit)
        let strMinuteUnit = NSMutableAttributedString(string: " min ", attributes: attriUnit)
        
        let result = NSMutableAttributedString()
        
        if hasHours {
            result.append(strHours)
            result.append(strHourUnit)
        }
        result.append(strMins)
        result.append(strMinuteUnit)
        
        return result
    }
    
}


extension BloodPressureVC: CustomLabelMarkerViewDelegate {
    
    func getLabel(entry: ChartDataEntry, highlight: Highlight) -> String {
        let date = GetDateFromChartEntryX(value: entry.x, type: selectedDataType)
        let df = DateFormatter()
        var strDate = ""
        var strBP = ""

        var systolicEntries: [RangeBarChartDataEntry]
        var diastolicEntries: [RangeBarChartDataEntry]
        switch selectedDataType {
        case .Day:
            df.dateFormat = "MMM dd, h {1} a {2}"
            systolicEntries = daySystolicEntries
            diastolicEntries = dayDiastolicEntries
            break
        case .Week:
            df.dateFormat = "MMM dd, yyyy"
            systolicEntries = weekSystolicEntries
            diastolicEntries = weekDiastolicEntries
            break
        case .Month:
            df.dateFormat = "MMM dd, yyyy"
            systolicEntries = monthSystolicEntries
            diastolicEntries = monthDiastolicEntries
            break
        default:
            df.dateFormat = "MMM, yyyy"
            systolicEntries = yearSystolicEntries
            diastolicEntries = yearDiastolicEntries
            break
        }
        var strSystolic: String?
        for sysEntry in systolicEntries {
            if sysEntry.x == entry.x {
                strSystolic = sysEntry.start == sysEntry.end ? "\(Int(sysEntry.end))" : "\(Int(sysEntry.start))-\(Int(sysEntry.end))"
                break
            }
        }
        var strDiastolic: String?
        for diaEntry in diastolicEntries {
            if diaEntry.x == entry.x {
                strDiastolic = diaEntry.start == diaEntry.end ? "\(Int(diaEntry.end))" : "\(Int(diaEntry.start))-\(Int(diaEntry.end))"
                break
            }
        }
        strBP = "\(strSystolic ?? "NO DATA") / \(strDiastolic ?? "NO DATA") mmHg\n"
        strDate = df.string(from: date)
        
        if (selectedDataType == .Day) {
            let hour = Calendar.current.component(.hour, from: date)
            if (hour == 23) {
                strDate = strDate.replacingOccurrences(of: "{1}", with: "")
                strDate = strDate.replacingOccurrences(of: "{2}", with: "- 12 AM")
            }
            else if (hour == 11) {
                strDate = strDate.replacingOccurrences(of: "{1}", with: "")
                strDate = strDate.replacingOccurrences(of: "{2}", with: "- 12 PM")
            }
            else {
                strDate = strDate.replacingOccurrences(of: "{1}", with: "- \(hour % 12 + 1)")
                strDate = strDate.replacingOccurrences(of: "{2}", with: "")
            }
        }
        else if (selectedDataType == .Year) {
            strDate = "\(months[Int(entry.x) % 12]), \(Int(floor(entry.x / 12)))"
        }
        
        return strBP + strDate
    }
    
}
