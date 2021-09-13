//
//  SleepVC.swift
//  ClubAfib
//
//  Created by Rener on 7/29/20.
//  Copyright © 2020 ETU. All rights reserved.
//

import UIKit
import HealthKit
import SwiftyJSON

class SleepVC: UIViewController {
    
    @IBOutlet weak var typeSC: UISegmentedControl!
    @IBOutlet weak var vwChartECG: BarChartView!
    @IBOutlet weak var sleepChartView: BarChartView!
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
        
    var weekInBedEntries = [BarChartDataEntry]()
    var weekAsleepEntries = [BarChartDataEntry]()
        
    var monthInBedEntries = [BarChartDataEntry]()
    var monthAsleepEntries = [BarChartDataEntry]()
        
    var yearInBedEntries = [BarChartDataEntry]()
    var yearAsleepEntries = [BarChartDataEntry]()
    
    var ecgAFEntries = [BarChartDataEntry]()
    var ecgAF = [Ecg]()
    
    var selectedDataType: ChartDataViewType = .Week    
    
    var dataLoads = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        
        typeSC.selectedSegmentIndex = self.selectedDataType.rawValue - 1
        typeSC.addTarget(self, action: #selector(self.chartDataViewTypeChanged), for:.valueChanged)
        typeSC.addTarget(self, action: #selector(self.chartDataViewTypeChanged), for:.touchUpInside)
        
        allChartViews = [vwChartECG, sleepChartView]
        
        initChartView()
        initDates()
        
        let viewAllDataTap = UITapGestureRecognizer(target: self, action: #selector(onViewAllDataTapped))
        self.viewAllData.isUserInteractionEnabled = true
        self.viewAllData.addGestureRecognizer(viewAllDataTap)
        
        self.showLoadingProgress(view: self.navigationController?.view)
        self.dataLoads = 2
        getECGData()
        getSleepAnalysis()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.healthDataChanged), name: NSNotification.Name(USER_NOTIFICATION_HEALTHDATA_CHANGED), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)                
//        HealthDataManager.default.getSleepFromDevice()
    }
    
    @objc private func healthDataChanged(notification: NSNotification){
        DispatchQueue.main.async {
            self.showLoadingProgress(view: self.navigationController?.view)
            self.dataLoads = 2
            self.getECGData()
            self.getSleepAnalysis()
        }
    }
    
    private func initChartView() {
        let chartViews: [BarLineChartViewBase] = [vwChartECG, sleepChartView]
        
        vwChartECG.drawBarShadowEnabled = false
        vwChartECG.drawValueAboveBarEnabled = false
        sleepChartView.drawBarShadowEnabled = false
        sleepChartView.drawValueAboveBarEnabled = false
        
        
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
            rightAxis.minWidth = 30.0
            rightAxis.maxWidth = 30.0
            rightAxis.spaceTop = 0.1
            rightAxis.spaceBottom = 0
            rightAxis.axisMinimum = 0
        }
        
        sleepChartView.xAxis.drawLabelsEnabled = true
        sleepChartView.rightAxis.valueFormatter = PeriodTimeAxisValueFormatter(chart: sleepChartView)
        let transformer = sleepChartView.getTransformer(forAxis: .right)
        let viewPortHandler = sleepChartView.rightYAxisRenderer.viewPortHandler
        sleepChartView.rightYAxisRenderer = TimelineYAxisRender(viewPortHandler: viewPortHandler, yAxis: sleepChartView.rightAxis, transformer: transformer)

        let ecgMarker = EcgMarker(color: UIColor(white: 230/250, alpha: 1), font: .systemFont(ofSize: 12), textColor: .black, insets: UIEdgeInsets(top: 8, left: 8, bottom: 20, right: 8))
        ecgMarker.chartView = vwChartECG
        ecgMarker.minimumSize = CGSize(width: 80, height: 40)
        vwChartECG.marker = ecgMarker

        let sleepMarker = SimpleDataMarkerView(color: UIColor(white: 230/250, alpha: 1), font: .systemFont(ofSize: 12), textColor: .black, insets: UIEdgeInsets(top: 8, left: 8, bottom: 20, right: 8))
        sleepMarker.healthType = .Sleep
        sleepMarker.chartView = sleepChartView
        sleepMarker.minimumSize = CGSize(width: 80, height: 40)
        sleepChartView.marker = sleepMarker
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
    
    private func getSleepAnalysis() {
        DispatchQueue.global(qos: .background).async {
            HealthKitHelper.default.getSleepAnalysis() {(satistics, error) in
                
                if (error != nil) {
                    print(error!)
                }
                
                guard let dataset = satistics else {
                    print("can't get sleep data")
                    self.dismissLoadingProgress(view: self.navigationController?.view)
                    return
                }
                
                var sleepData = [Sleep]()
                for data in dataset {
                    sleepData.append(
                        Sleep(JSON([
                            "uuid": data.0,
                            "start": data.1.toString,
                            "end": data.2.toString,
                            "type": data.3
                        ])))
                }
                let inBed = sleepData.filter({ $0.type == 0 })
                let asleep = sleepData.filter({ $0.type == 1 })
                self.processSleepDataset(inBed, inBed: true)
                self.processSleepDataset(asleep, inBed: false)
                DispatchQueue.main.async {
                    self.dataLoads = self.dataLoads - 1
                    if (self.dataLoads == 0) {
                        self.dismissLoadingProgress(view: self.navigationController?.view)
                        self.resetChartView()
                    }
                }
            }
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
    
    private func processSleepDataset(_ dataset: [Sleep], inBed: Bool) {
        if (dataset.count > 0) {
            let calendar = Calendar.current
                                      
            if let data = dataset.first {
                if data.start < dayStartDate {
                    dayStartDate = data.start                    
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
            
            var day = 0, dailyCount = 0, dailySum: Double = 0
            var month = 1, monthlyCount = 0, monthlySum = 0.0
            var startOfDay = dayStartDate
            var startOfMonth = monthStartDate
            
            weekAsleepEntries.removeAll()
            monthAsleepEntries.removeAll()
            yearAsleepEntries.removeAll()
            
            let deltaX = inBed ? 0.3 : 0.7

            for data in dataset {
                // need to calc from every day 6 PM
                dateComponents = calendar.dateComponents([.year, .month, .day, .weekday], from: calendar.date(byAdding: .hour, value: 6, to: data.start)!)

                if (day != dateComponents.day) {
                    if (dailyCount > 0) {
                        monthlyCount += 1
                    }

                    let entry = BarChartDataEntry(x: deltaX + GetXValueFromDate(date: startOfDay, type: .Week), y: dailySum)

                    if (dailyCount > 0 && data.start >= weekStartDate && data.start < weekEndDate) {
                        inBed ? weekInBedEntries.append(entry) : weekAsleepEntries.append(entry)
                    }
                    if (dailyCount > 0 && data.start >= monthStartDate && data.start < monthEndDate) {
                        inBed ? monthInBedEntries.append(entry) : monthAsleepEntries.append(entry)
                    }

                    if (month != dateComponents.month) {
                        let xValue = deltaX + GetXValueFromDate(date: startOfMonth, type: .Year)
                        let entry = BarChartDataEntry(x: xValue, y: monthlySum / Double(monthlyCount))

                        if (monthlyCount > 0 && data.start >= yearStartDate && data.start < yearEndDate) {
                            inBed ? yearInBedEntries.append(entry) : yearAsleepEntries.append(entry)
                        }

                        let components = calendar.dateComponents([.year, .month], from: data.start)
                        startOfMonth = calendar.date(from: components)!
                        month = dateComponents.month!
                        monthlyCount = 0
                        monthlySum = 0.0
                    }

                    startOfDay = calendar.date(from: dateComponents)!
                    day = dateComponents.day!
                    dailyCount = 0
                    dailySum = 0
                }
                
                let asleepMins = calendar.dateComponents([.minute], from: data.start, to: data.end).minute!
                dailySum += Double(asleepMins)
                dailyCount += 1
            }

            if (dailyCount > 0) {
                if (dailyCount > 0) {
                    monthlyCount += 1
                }

                let entry = BarChartDataEntry(x: deltaX + GetXValueFromDate(date: startOfDay, type: .Week), y: dailySum)

                inBed ? weekInBedEntries.append(entry) : weekAsleepEntries.append(entry)
                inBed ? monthInBedEntries.append(entry) : monthAsleepEntries.append(entry)
            }

            if (monthlyCount > 0) {
                let xValue = deltaX + GetXValueFromDate(date: startOfMonth, type: .Year)
                let entry = BarChartDataEntry(x: xValue, y: monthlySum / Double(monthlyCount))

                inBed ? yearInBedEntries.append(entry) : yearAsleepEntries.append(entry)
            }
        }
    }
    
    private func getECGData(){
        DispatchQueue.global(qos: .background).async {
            HealthKitHelper.default.getECG { (ecgData, error) in
                
                if (error != nil) {
                    print(error!)
                }
                
                guard let ecgData = ecgData else {
                    print("can't get ECG data")
                    return
                }
                self.processECGDataset(ecgData: ecgData)
                DispatchQueue.main.async {
                    self.dataLoads = self.dataLoads - 1
                    if (self.dataLoads == 0) {
                        self.dismissLoadingProgress(view: self.navigationController?.view)
                        self.resetChartView()
                    }
                }
            }
        }
    }
    
    private func processECGDataset(ecgData: [Ecg]) {
        ecgAFEntries.removeAll()
        ecgAF.removeAll()
        for item in ecgData {
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
        (sleepChartView.marker as! SimpleDataMarkerView).currentXAxisType = selectedDataType
        
        var minX = 0.0, maxX = 0.0
        var inBedEntries: [BarChartDataEntry]
        var asleepEntries: [BarChartDataEntry]
        switch selectedDataType {
        case .Week:
            inBedEntries = weekInBedEntries
            asleepEntries = weekAsleepEntries
            
            minX = GetXValueFromDate(date: weekStartDate, type: .Week)
            maxX = GetXValueFromDate(date: weekEndDate, type: .Week)
            break
        case .Month:
            inBedEntries = monthInBedEntries
            asleepEntries = monthAsleepEntries
            
            minX = GetXValueFromDate(date: monthStartDate, type: .Month)
            maxX = GetXValueFromDate(date: monthEndDate, type: .Month)
            break
        default:
            inBedEntries = yearInBedEntries
            asleepEntries = yearAsleepEntries
            
            minX = GetXValueFromDate(date: yearStartDate, type: .Year)
            maxX = GetXValueFromDate(date: yearEndDate, type: .Year)
            break
        }
        
        vwChartECG.xAxis.axisMinimum = minX
        vwChartECG.xAxis.axisMaximum = maxX
        sleepChartView.xAxis.axisMinimum = minX
        sleepChartView.xAxis.axisMaximum = maxX

        if
            let sleepSets = sleepChartView.barData?.dataSets as? [BarChartDataSet] {
            if sleepSets.count > 1 {
                sleepSets[0].replaceEntries(inBedEntries)
                sleepSets[1].replaceEntries(asleepEntries)
            }
            
            sleepChartView.data?.notifyDataChanged()
            sleepChartView.notifyDataSetChanged()
        } else {
            let inBedSet = BarChartDataSet(entries: inBedEntries, label: "")
            inBedSet.colors = [.systemGray]
            inBedSet.drawValuesEnabled = false
            let asleepSet = BarChartDataSet(entries: asleepEntries, label: "")
            asleepSet.colors = [.systemYellow]
            asleepSet.drawValuesEnabled = false
            let sleepData = BarChartData(dataSets: [inBedSet, asleepSet])
            sleepData.setValueFont(UIFont(name: "HelveticaNeue-Light", size: 10)!)
            if inBedSet.count > 0 || asleepSet.count > 0 {
                sleepChartView.data = sleepData
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
        case .Week:
            vwChartECG.setVisibleXRange(minXRange: 7, maxXRange: 7)
            vwChartECG.xAxis.axisMaxLabels = 7
            vwChartECG.xAxis.axisMinLabels = 7
            vwChartECG.barData?.barWidth = 0.2
            sleepChartView.setVisibleXRange(minXRange: 7, maxXRange: 7)
            sleepChartView.xAxis.axisMaxLabels = 7
            sleepChartView.xAxis.axisMinLabels = 7
            sleepChartView.barData?.barWidth = 0.2
            break
        case .Month:
            vwChartECG.setVisibleXRange(minXRange: 30, maxXRange: 30)
            vwChartECG.xAxis.axisMaxLabels = 5
            vwChartECG.barData?.barWidth = 0.32
            sleepChartView.setVisibleXRange(minXRange: 30, maxXRange: 30)
            sleepChartView.xAxis.axisMaxLabels = 5
            sleepChartView.barData?.barWidth = 0.32
            break
        default:
            vwChartECG.setVisibleXRange(minXRange: 12, maxXRange: 12)
            vwChartECG.xAxis.axisMaxLabels = 12
            vwChartECG.xAxis.axisMinLabels = 12
            vwChartECG.barData?.barWidth = 0.32
            sleepChartView.setVisibleXRange(minXRange: 12, maxXRange: 12)
            sleepChartView.xAxis.axisMaxLabels = 12
            sleepChartView.xAxis.axisMinLabels = 12
            sleepChartView.barData?.barWidth = 0.32
            break
        }
        
        vwChartECG.moveViewToX(maxX)
        sleepChartView.moveViewToX(maxX)

        updateChartYScale()
        updateMeasurements()
    }
    
    @objc func chartDataViewTypeChanged(segment: UISegmentedControl) {
        self.selectedDataType = ChartDataViewType(rawValue: segment.selectedSegmentIndex) ?? .Day
        HealthKitHelper.default.getECG { (ecgData, error) in
            
            if (error != nil) {
                print(error!)
            }
            
            guard let ecgData = ecgData else {
                print("can't get ECG data")
                return
            }
            self.processECGDataset(ecgData: ecgData)
            DispatchQueue.main.async {
                self.resetChartView()
            }
        }
    }
    
    @IBAction func onBackPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }

    @IBAction func onShareButtonPressed(_ sender: Any) {
        shareScreenshot()
    }
    
    @IBAction func onAddButtonPressed(_ sender: Any) {
        let addVC = HOME_STORYBOARD.instantiateViewController(withIdentifier: "SleepAddVC") as! SleepAddVC
        self.navigationController?.pushViewController(addVC, animated: true)
    }
    
    @objc func onViewAllDataTapped() {
//        let sleepData = HealthDataManager.default.sleepData.sorted(by: { $0.start.compare($1.start) == .orderedDescending })
//        if sleepData.count == 0 {
//            showSimpleAlert(title: "Warning", message: "No data has been added by the user.  You can add data using the + found on top right corner of the page.", complete: nil)
//            return
//        }
//        if dayStartDate != Date.Max() {
//            let dataListVC = HOME_STORYBOARD.instantiateViewController(withIdentifier: "SleepDataListVC") as! SleepDataListVC
//            dataListVC.data = sleepData
//            self.navigationController?.pushViewController(dataListVC, animated: true)
//        }
    }
    
}

extension SleepVC: ChartViewDelegate {
    
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
            var inBedEntries: [BarChartDataEntry]
            var asleepEntries: [BarChartDataEntry]
            switch selectedDataType {
            case .Week:
                inBedEntries = weekInBedEntries
                asleepEntries = weekAsleepEntries
                break
            case .Month:
                inBedEntries = monthInBedEntries
                asleepEntries = monthAsleepEntries
                break
            default:
                inBedEntries = yearInBedEntries
                asleepEntries = yearAsleepEntries
                break
            }
            
            var maxInBed = 0.0, sumInBed = 0.0, inBedCounts = 0
            for entry in inBedEntries {
                if (entry.x >= sleepChartView.lowestVisibleX && entry.x <= sleepChartView.highestVisibleX) {
                    if (entry.y > maxInBed) { maxInBed = entry.y }
                    if (entry.y > 0 ) {
                        sumInBed += entry.y
                        inBedCounts += 1
                    }
                }
            }
            var maxAsleep = 0.0, sumAsleep = 0.0, asleepCounts = 0
            for entry in asleepEntries {
                if (entry.x >= sleepChartView.lowestVisibleX && entry.x <= sleepChartView.highestVisibleX) {
                    if (entry.y > maxAsleep) { maxAsleep = entry.y }
                    if (entry.y > 0 ) {
                        sumAsleep += entry.y
                        asleepCounts += 1
                    }
                }
            }

            let strType = "\("IN BED AVERAGE".localized()) / \("ASLEEP AVERAGE".localized())"
            let inBed = inBedCounts > 0 ? sumInBed / Double(inBedCounts) : 0.0
            let asleep = asleepCounts > 0 ? sumAsleep / Double(asleepCounts) : 0.0

            let formatter = DateIntervalFormatter()
            let startDate = GetDateFromChartEntryX(value: sleepChartView.lowestVisibleX, type: selectedDataType)
            var endDate = GetDateFromChartEntryX(value: sleepChartView.highestVisibleX, type: selectedDataType)

            switch selectedDataType {
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
            let attributes = [NSAttributedString.Key.font: UIFont(name: "Avenir-Black", size: 24)!, NSAttributedString.Key.foregroundColor: UIColor.black]
            
            let sleepAmountString = NSMutableAttributedString()
            
            if inBedCounts > 0 || asleepCounts > 0 {
                sleepAmountString.append(minutesToString(inBed))
                sleepAmountString.append(NSMutableAttributedString(string: " / ", attributes: attributes))
                sleepAmountString.append(minutesToString(asleep))
            } else {
                sleepAmountString.append(NSMutableAttributedString(string: "NO DATA".localized() , attributes: attributes))
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
