//
//  ActivitySummaryVC.swift
//  ClubAfib
//
//  Created by Rener on 7/22/20.
//  Copyright © 2020 ETU. All rights reserved.
//

import UIKit
import HealthKit
import SwiftyJSON

class ActivitySummaryVC: UIViewController {
    
    @IBOutlet weak var typeSC: UISegmentedControl!
    @IBOutlet weak var vwChartECG: BarChartView!
    @IBOutlet weak var moveChartView: BarChartView!
    @IBOutlet weak var exerciseChartView: BarChartView!
    @IBOutlet weak var standChartView: BarChartView!
    
    @IBOutlet weak var lblMoveAmount: UILabel!
    @IBOutlet weak var lblExerciseAmount: UILabel!
    @IBOutlet weak var lblStandAmount: UILabel!
    @IBOutlet weak var lblDate: UILabel!
    
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
        
    var dayMoveEntries = [BarChartDataEntry]()
    var dayExerciseEntries = [BarChartDataEntry]()
    var dayStandEntries = [BarChartDataEntry]()
        
    var weekMoveEntries = [BarChartDataEntry]()
    var weekExerciseEntries = [BarChartDataEntry]()
    var weekStandEntries = [BarChartDataEntry]()
        
    var monthMoveEntries = [BarChartDataEntry]()
    var monthExerciseEntries = [BarChartDataEntry]()
    var monthStandEntries = [BarChartDataEntry]()
        
    var yearMoveEntries = [BarChartDataEntry]()
    var yearExerciseEntries = [BarChartDataEntry]()
    var yearStandEntries = [BarChartDataEntry]()
    
    var ecgAFEntries = [BarChartDataEntry]()
//    var ecgData = [Ecg]()
    var ecgAF = [Ecg]()
    
    var selectedDataType: ChartDataViewType = .Week    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        typeSC.selectedSegmentIndex = self.selectedDataType.rawValue
        typeSC.addTarget(self, action: #selector(self.chartDataViewTypeChanged), for:.valueChanged)
        typeSC.addTarget(self, action: #selector(self.chartDataViewTypeChanged), for:.touchUpInside)
        
        allChartViews = [vwChartECG, moveChartView, exerciseChartView, standChartView]
        
        initChartView()
        initDates()
        
        showLoadingProgress(view: self.navigationController?.view)
        getECGData()
        getActivitySummary()
                            
        NotificationCenter.default.addObserver(self, selector: #selector(self.healthDataChanged), name: NSNotification.Name(USER_NOTIFICATION_HEALTHDATA_CHANGED), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
//        HealthDataManager.default.getECGDataFromDevice()
//        HealthDataManager.default.getActivitySummaryFromDevice()
    }
    
    @objc private func healthDataChanged(notification: NSNotification){
        DispatchQueue.main.async {
            self.showLoadingProgress(view: self.navigationController?.view)
            self.getECGData()
            self.getActivitySummary()
        }
    }
    
    private func initChartView() {
        let chartViews: [BarLineChartViewBase] = [vwChartECG, moveChartView, exerciseChartView, standChartView]
        
        vwChartECG.drawBarShadowEnabled = false
        vwChartECG.drawValueAboveBarEnabled = false
        moveChartView.drawBarShadowEnabled = false
        moveChartView.drawValueAboveBarEnabled = false
        exerciseChartView.drawBarShadowEnabled = false
        exerciseChartView.drawValueAboveBarEnabled = false
        standChartView.drawBarShadowEnabled = false
        standChartView.drawValueAboveBarEnabled = false
        
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
            xAxis.labelFont = .systemFont(ofSize: 10)
            xAxis.drawLabelsEnabled = false
            xAxis.centerAxisLabelsEnabled = true
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
        
        standChartView.xAxis.drawLabelsEnabled = true

        let ecgMarker = EcgMarker(color: UIColor(white: 230/250, alpha: 1), font: .systemFont(ofSize: 12), textColor: .black, insets: UIEdgeInsets(top: 8, left: 8, bottom: 20, right: 8))
        ecgMarker.chartView = vwChartECG
        ecgMarker.minimumSize = CGSize(width: 80, height: 40)
        vwChartECG.marker = ecgMarker

        let moveMarker = SimpleDataMarkerView(color: UIColor(white: 230/250, alpha: 1), font: .systemFont(ofSize: 12), textColor: .black, insets: UIEdgeInsets(top: 8, left: 8, bottom: 20, right: 8))
        moveMarker.healthType = .ActivityMove
        moveMarker.chartView = moveChartView
        moveMarker.minimumSize = CGSize(width: 80, height: 40)
        moveChartView.marker = moveMarker

        let exerciseMarker = SimpleDataMarkerView(color: UIColor(white: 230/250, alpha: 1), font: .systemFont(ofSize: 12), textColor: .black, insets: UIEdgeInsets(top: 8, left: 8, bottom: 20, right: 8))
        exerciseMarker.healthType = .ActivityExercise
        exerciseMarker.chartView = exerciseChartView
        exerciseMarker.minimumSize = CGSize(width: 80, height: 40)
        exerciseChartView.marker = exerciseMarker

        let standMarker = SimpleDataMarkerView(color: UIColor(white: 230/250, alpha: 1), font: .systemFont(ofSize: 12), textColor: .black, insets: UIEdgeInsets(top: 8, left: 8, bottom: 20, right: 8))
        standMarker.healthType = .ActivityStand
        standMarker.chartView = standChartView
        standMarker.minimumSize = CGSize(width: 80, height: 40)
        standChartView.marker = standMarker
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
    
    private func getActivitySummary() {
        DispatchQueue.global(qos: .background).async {
            HealthKitHelper.default.getActivitySummary() {(energyBurnedData, exerciseData, standData, error) in
                
                if (error != nil) {
                    print(error!)
                }
                
                guard
                    let energyBurnedData:[(Date, Double)] = energyBurnedData,
                    let exerciseData:[(Date, Double)] = exerciseData,
                    let standData:[(Date, Double)] = standData else {
                    print("can't get activity summary data")
                    self.dismissLoadingProgress(view: self.navigationController?.view)
                    return
                }
                
                var energyBurnedData1 = [EnergyBurn]()
                for data in energyBurnedData {
                    energyBurnedData1.append(
                        EnergyBurn(JSON([
                            "date": data.0.toString,
                            "energy": data.1
                        ])))
                }
                var exerciseData1 = [Exercise]()
                for data in exerciseData {
                    exerciseData1.append(
                        Exercise(JSON([
                            "date": data.0.toString,
                            "exercise": data.1
                        ])))
                }
                var standData1 = [Stand]()
                for data in standData {
                    standData1.append(
                        Stand(JSON([
                            "date": data.0.toString,
                            "stand": data.1
                        ])))
                }
                
                self.processDataset(energyBurnedData1, healthType: .ActivityMove)
                self.processDataset(exerciseData1, healthType: .ActivityExercise)
                self.processDataset(standData1, healthType: .ActivityStand)
                DispatchQueue.main.async {
                    self.resetChartView()
                    self.dismissLoadingProgress(view: self.navigationController?.view)
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
    
    private func processDataset(_ dataset: [(SingleValueHealthData)], healthType: HealthCategoryType) {
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
            
            var day = 0, dailyCount = 0, dailySum: Double = 0, dailyMin = 5000.0, dailyMax = 0.0
            var month = 1, monthlyCount = 0, monthlySum: Double = 0, monthlyMin = 5000.0, monthlyMax = 0.0
            var startOfDay = dayStartDate
            var startOfMonth = monthStartDate
            
            switch healthType {
            case .ActivityMove:
                dayMoveEntries.removeAll()
                weekMoveEntries.removeAll()
                monthMoveEntries.removeAll()
                yearMoveEntries.removeAll()
                break
            case .ActivityExercise:
                dayExerciseEntries.removeAll()
                weekExerciseEntries.removeAll()
                monthExerciseEntries.removeAll()
                yearExerciseEntries.removeAll()
                break
            case .ActivityStand:
                dayStandEntries.removeAll()
                weekStandEntries.removeAll()
                monthStandEntries.removeAll()
                yearStandEntries.removeAll()
                break
            default:
                break
            }
            
            for data in dataset {
                if (data.date >= dayStartDate && data.date < dayEndDate) {

                    let entry = BarChartDataEntry(x: 0.5 + GetXValueFromDate(date: data.date, type: .Day), y: data.value)
                    switch healthType {
                    case .ActivityMove:
                        dayMoveEntries.append(entry)
                        break
                    case .ActivityExercise:
                        dayExerciseEntries.append(entry)
                        break
                    case .ActivityStand:
                        dayStandEntries.append(entry)
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
                    if (dailyCount > 0) {
                        monthlyCount += 1
                    }
                    
                    let entry = BarChartDataEntry(x: 0.5 + GetXValueFromDate(date: startOfDay, type: .Week), y: round(dailySum))
                    
                    if (dailyCount > 0 && data.date >= weekStartDate && data.date < weekEndDate) {
                        switch healthType {
                        case .ActivityMove:
                            weekMoveEntries.append(entry)
                            break
                        case .ActivityExercise:
                            weekExerciseEntries.append(entry)
                            break
                        case .ActivityStand:
                            weekStandEntries.append(entry)
                            break
                        default:
                            break
                        }
                    }
                    if (dailyCount > 0 && data.date >= monthStartDate && data.date < monthEndDate) {
                        switch healthType {
                        case .ActivityMove:
                            monthMoveEntries.append(entry)
                            break
                        case .ActivityExercise:
                            monthExerciseEntries.append(entry)
                            break
                        case .ActivityStand:
                            monthStandEntries.append(entry)
                            break
                        default:
                            break
                        }
                    }

                    if (month != dateComponents.month) {
                        let xValue = 0.5 + GetXValueFromDate(date: startOfMonth, type: .Year)
                        let entry = BarChartDataEntry(x: xValue, y: monthlySum / Double(monthlyCount))
                        
                        if (monthlyCount > 0 && data.date >= yearStartDate && data.date < yearEndDate) {
                            switch healthType {
                            case .ActivityMove:
                                yearMoveEntries.append(entry)
                                break
                            case .ActivityExercise:
                                yearExerciseEntries.append(entry)
                                break
                            case .ActivityStand:
                                yearStandEntries.append(entry)
                                break
                            default:
                                break
                            }
                        }
                        
                        let components = calendar.dateComponents([.year, .month], from: data.date)
                        startOfMonth = calendar.date(from: components)!
                        month = dateComponents.month!
                        monthlyCount = 0
                        monthlySum = 0
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
                
                let entry = BarChartDataEntry(x: 0.5 + GetXValueFromDate(date: startOfDay, type: .Week), y: round(dailySum))

                switch healthType {
                case .ActivityMove:
                    weekMoveEntries.append(entry)
                    monthMoveEntries.append(entry)
                    break
                case .ActivityExercise:
                    weekExerciseEntries.append(entry)
                    monthExerciseEntries.append(entry)
                    break
                case .ActivityStand:
                    weekStandEntries.append(entry)
                    monthStandEntries.append(entry)
                    break
                default:
                    break
                }
            }

            if (monthlyCount > 0) {
                let xValue = 0.5 + GetXValueFromDate(date: startOfMonth, type: .Year)
                let entry = BarChartDataEntry(x: xValue, y: monthlySum / Double(monthlyCount))

                switch healthType {
                case .ActivityMove:
                    yearMoveEntries.append(entry)
                    break
                case .ActivityExercise:
                    yearExerciseEntries.append(entry)
                    break
                case .ActivityStand:
                    yearStandEntries.append(entry)
                    break
                default:
                    break
                }
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
                    self.resetChartView()
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
        (moveChartView.marker as! SimpleDataMarkerView).currentXAxisType = selectedDataType
        (exerciseChartView.marker as! SimpleDataMarkerView).currentXAxisType = selectedDataType
        (standChartView.marker as! SimpleDataMarkerView).currentXAxisType = selectedDataType
        
        var minX = 0.0, maxX = 0.0
        var moveEntries: [BarChartDataEntry]
        var exerciseEntries: [BarChartDataEntry]
        var standEntries: [BarChartDataEntry]
        switch selectedDataType {
        case .Day:
            moveEntries = dayMoveEntries
            exerciseEntries = dayExerciseEntries
            standEntries = dayStandEntries
            
            minX = GetXValueFromDate(date: dayStartDate, type: .Day)
            maxX = GetXValueFromDate(date: dayEndDate, type: .Day)
            break
        case .Week:
            moveEntries = weekMoveEntries
            exerciseEntries = weekExerciseEntries
            standEntries = weekStandEntries
            
            minX = GetXValueFromDate(date: weekStartDate, type: .Week)
            maxX = GetXValueFromDate(date: weekEndDate, type: .Week)
            break
        case .Month:
            moveEntries = monthMoveEntries
            exerciseEntries = monthExerciseEntries
            standEntries = monthStandEntries
            
            minX = GetXValueFromDate(date: monthStartDate, type: .Month)
            maxX = GetXValueFromDate(date: monthEndDate, type: .Month)
            break
        default:
            moveEntries = yearMoveEntries
            exerciseEntries = yearExerciseEntries
            standEntries = yearStandEntries
            
            minX = GetXValueFromDate(date: yearStartDate, type: .Year)
            maxX = GetXValueFromDate(date: yearEndDate, type: .Year)
            break
        }
        
        vwChartECG.xAxis.axisMinimum = minX
        vwChartECG.xAxis.axisMaximum = maxX
        moveChartView.xAxis.axisMinimum = minX
        moveChartView.xAxis.axisMaximum = maxX
        exerciseChartView.xAxis.axisMinimum = minX
        exerciseChartView.xAxis.axisMaximum = maxX
        standChartView.xAxis.axisMinimum = minX
        standChartView.xAxis.axisMaximum = maxX
        
        if
            let moveSet = moveChartView.barData?.dataSets.first as? BarChartDataSet,
            let exerciseSet = exerciseChartView.barData?.dataSets.first as? BarChartDataSet,
            let standSet = standChartView.barData?.dataSets.first as? BarChartDataSet {
                            
            moveSet.replaceEntries(moveEntries)
            exerciseSet.replaceEntries(exerciseEntries)
            standSet.replaceEntries(standEntries)
                            
            moveChartView.data?.notifyDataChanged()
            moveChartView.notifyDataSetChanged()
            exerciseChartView.data?.notifyDataChanged()
            exerciseChartView.notifyDataSetChanged()
            standChartView.data?.notifyDataChanged()
            standChartView.notifyDataSetChanged()
        } else {
            let moveSet = BarChartDataSet(entries: moveEntries, label: "")
            moveSet.colors = [UIColor.systemRed]
            moveSet.drawValuesEnabled = false
            let moveData = BarChartData(dataSet: moveSet)
            moveData.setValueFont(UIFont(name: "HelveticaNeue-Light", size: 10)!)
            if moveSet.count > 0 {
                moveChartView.data = moveData
            }
            
            let exerciseSet = BarChartDataSet(entries: exerciseEntries, label: "")
            exerciseSet.colors = [UIColor.systemGreen]
            exerciseSet.drawValuesEnabled = false
            let exerciseData = BarChartData(dataSet: exerciseSet)
            exerciseData.setValueFont(UIFont(name: "HelveticaNeue-Light", size: 10)!)
            if exerciseSet.count > 0 {
                exerciseChartView.data = exerciseData
            }
            
            let standSet = BarChartDataSet(entries: standEntries, label: "")
            standSet.colors = [UIColor.systemBlue]
            standSet.drawValuesEnabled = false
            let standData = BarChartData(dataSet: standSet)
            standData.setValueFont(UIFont(name: "HelveticaNeue-Light", size: 10)!)
            if standSet.count > 0 {
                standChartView.data = standData
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
            vwChartECG.barData?.barWidth = 0.64
            moveChartView.setVisibleXRange(minXRange: 24, maxXRange: 24)
            moveChartView.xAxis.axisMaxLabels = 5
            moveChartView.barData?.barWidth = 0.64
            exerciseChartView.setVisibleXRange(minXRange: 24, maxXRange: 24)
            exerciseChartView.xAxis.axisMaxLabels = 5
            exerciseChartView.barData?.barWidth = 0.64
            standChartView.setVisibleXRange(minXRange: 24, maxXRange: 24)
            standChartView.xAxis.axisMaxLabels = 5
            standChartView.barData?.barWidth = 0.64
            break
        case .Week:
            vwChartECG.setVisibleXRange(minXRange: 7, maxXRange: 7)
            vwChartECG.xAxis.axisMaxLabels = 7
            vwChartECG.xAxis.axisMinLabels = 7
            vwChartECG.barData?.barWidth = 0.2
            moveChartView.setVisibleXRange(minXRange: 7, maxXRange: 7)
            moveChartView.xAxis.axisMaxLabels = 7
            moveChartView.xAxis.axisMinLabels = 7
            moveChartView.barData?.barWidth = 0.7
            exerciseChartView.setVisibleXRange(minXRange: 7, maxXRange: 7)
            exerciseChartView.xAxis.axisMaxLabels = 7
            exerciseChartView.xAxis.axisMinLabels = 7
            exerciseChartView.barData?.barWidth = 0.7
            standChartView.setVisibleXRange(minXRange: 7, maxXRange: 7)
            standChartView.xAxis.axisMaxLabels = 7
            standChartView.xAxis.axisMinLabels = 7
            standChartView.barData?.barWidth = 0.7
            break
        case .Month:
            vwChartECG.setVisibleXRange(minXRange: 30, maxXRange: 30)
            vwChartECG.xAxis.axisMaxLabels = 5
            vwChartECG.barData?.barWidth = 0.7
            moveChartView.setVisibleXRange(minXRange: 30, maxXRange: 30)
            moveChartView.xAxis.axisMaxLabels = 5
            moveChartView.barData?.barWidth = 0.7
            exerciseChartView.setVisibleXRange(minXRange: 30, maxXRange: 30)
            exerciseChartView.xAxis.axisMaxLabels = 5
            exerciseChartView.barData?.barWidth = 0.7
            standChartView.setVisibleXRange(minXRange: 30, maxXRange: 30)
            standChartView.xAxis.axisMaxLabels = 5
            standChartView.barData?.barWidth = 0.7
            break
        default:
            vwChartECG.setVisibleXRange(minXRange: 12, maxXRange: 12)
            vwChartECG.xAxis.axisMaxLabels = 12
            vwChartECG.xAxis.axisMinLabels = 12
            vwChartECG.barData?.barWidth = 0.32
            moveChartView.setVisibleXRange(minXRange: 12, maxXRange: 12)
            moveChartView.xAxis.axisMaxLabels = 12
            moveChartView.xAxis.axisMinLabels = 12
            moveChartView.barData?.barWidth = 0.8
            exerciseChartView.setVisibleXRange(minXRange: 12, maxXRange: 12)
            exerciseChartView.xAxis.axisMaxLabels = 12
            exerciseChartView.xAxis.axisMinLabels = 12
            exerciseChartView.barData?.barWidth = 0.8
            standChartView.setVisibleXRange(minXRange: 12, maxXRange: 12)
            standChartView.xAxis.axisMaxLabels = 12
            standChartView.xAxis.axisMinLabels = 12
            standChartView.barData?.barWidth = 0.8
            break
        }
        
        vwChartECG.moveViewToX(maxX)
        moveChartView.moveViewToX(maxX)
        exerciseChartView.moveViewToX(maxX)
        standChartView.moveViewToX(maxX)

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
}

extension ActivitySummaryVC: ChartViewDelegate {
    
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
            var moveEntries: [BarChartDataEntry]
            var exerciseEntries: [BarChartDataEntry]
            var standEntries: [BarChartDataEntry]
            switch selectedDataType {
            case .Day:
//                heartRateEntries = dayHeartRateEntries
                moveEntries = dayMoveEntries
                exerciseEntries = dayExerciseEntries
                standEntries = dayStandEntries
                break
            case .Week:
//                heartRateEntries = weekHeartRateEntries
                moveEntries = weekMoveEntries
                exerciseEntries = weekExerciseEntries
                standEntries = weekStandEntries
                break
            case .Month:
//                heartRateEntries = monthHeartRateEntries
                moveEntries = monthMoveEntries
                exerciseEntries = monthExerciseEntries
                standEntries = monthStandEntries
                break
            default:
//                heartRateEntries = yearHeartRateEntries
                moveEntries = yearMoveEntries
                exerciseEntries = yearExerciseEntries
                standEntries = yearStandEntries
                break
            }

            var maxMove = 0.0, sumMove = 0.0, moveCounts = 0
            var maxExercise = 0.0, sumExercise = 0.0, exerciseCounts = 0
            var maxStand = 0.0, sumStand = 0.0, standCounts = 0
            for entry in moveEntries {
                if (entry.x >= moveChartView.lowestVisibleX && entry.x <= moveChartView.highestVisibleX) {
                    if (entry.y > maxMove) { maxMove = entry.y }
                    if (entry.y > 0 ) {
                        sumMove += entry.y
                        moveCounts += 1
                    }
                }
            }
            for entry in exerciseEntries {
                if (entry.x >= exerciseChartView.lowestVisibleX && entry.x <= exerciseChartView.highestVisibleX) {
                    if (entry.y > maxExercise) { maxExercise = entry.y }
                    if (entry.y > 0 ) {
                        sumExercise += entry.y
                        exerciseCounts += 1
                    }
                }
            }
            for entry in standEntries {
                if (entry.x >= standChartView.lowestVisibleX && entry.x <= standChartView.highestVisibleX) {
                    if (entry.y > maxStand) { maxStand = entry.y }
                    if (entry.y > 0 ) {
                        sumStand += entry.y
                        standCounts += 1
                    }
                }
            }

            var move = 0.0, exercise = 0.0, stand = 0.0

            let formatter = DateIntervalFormatter()
            let startDate = GetDateFromChartEntryX(value: moveChartView.lowestVisibleX, type: selectedDataType)
            var endDate = GetDateFromChartEntryX(value: moveChartView.highestVisibleX, type: selectedDataType)

            switch selectedDataType {
            case .Day:
                move = round(sumMove)
                exercise = round(sumExercise)
                stand = round(sumStand)
                formatter.dateTemplate = "MMM d, h a"
                break
            case .Week:
                move = moveCounts > 0 ? round(sumMove / Double(moveCounts)) : 0
                exercise = exerciseCounts > 0 ? round(sumExercise / Double(exerciseCounts)) : 0
                stand = standCounts > 0 ? round(sumStand / Double(standCounts)) : 0
                formatter.dateTemplate = "MMM d, yyyy"
                break
            case .Month:
                move = moveCounts > 0 ? round(sumMove / Double(moveCounts)) : 0
                exercise = exerciseCounts > 0 ? round(sumExercise / Double(exerciseCounts)) : 0
                stand = standCounts > 0 ? round(sumStand / Double(standCounts)) : 0
                formatter.dateTemplate = "MMM d, yyyy"
                break
            default:
                move = moveCounts > 0 ? round(sumMove / Double(moveCounts)) : 0
                exercise = exerciseCounts > 0 ? round(sumExercise / Double(exerciseCounts)) : 0
                stand = standCounts > 0 ? round(sumStand / Double(standCounts)) : 0
                formatter.dateTemplate = "yyyy"

                endDate = Calendar.current.date(byAdding: .day, value: -1, to: endDate)! // sometimes it's the first day of new year
                break
            }

            let yFormatter = NumberFormatter()
            yFormatter.numberStyle = .decimal
            yFormatter.groupingSeparator = ","
            let attributes1 = [NSAttributedString.Key.font: UIFont(name: "Avenir-Black", size: 24)!, NSAttributedString.Key.foregroundColor: UIColor.black]
            let attributesMoveString1 = NSMutableAttributedString(string: yFormatter.string(from: NSNumber(floatLiteral: move))!, attributes: attributes1)
            let attributes2 = [NSAttributedString.Key.font: UIFont(name: "Avenir-Black", size: 12)!, NSAttributedString.Key.foregroundColor: UIColor(red: 0.4, green: 0.4, blue: 0.4, alpha: 1.0)]
            let attributesMoveString2 = NSMutableAttributedString(string: " kcal", attributes: attributes2)
            let moveAmountString = NSMutableAttributedString()
            moveAmountString.append(attributesMoveString1)
            moveAmountString.append(attributesMoveString2)
            lblMoveAmount.attributedText = moveAmountString
            
            let attributesExerciseString1 = NSMutableAttributedString(string: yFormatter.string(from: NSNumber(floatLiteral: exercise))!, attributes: attributes1)
            let attributesExerciseString2 = NSMutableAttributedString(string: " min", attributes: attributes2)
            let exerciseAmountString = NSMutableAttributedString()
            exerciseAmountString.append(attributesExerciseString1)
            exerciseAmountString.append(attributesExerciseString2)
            lblExerciseAmount.attributedText = exerciseAmountString
            
            let attributesStandString1 = NSMutableAttributedString(string: yFormatter.string(from: NSNumber(floatLiteral: stand))!, attributes: attributes1)
            let attributesStandString2 = NSMutableAttributedString(string: " hr", attributes: attributes2)
            let standAmountString = NSMutableAttributedString()
            standAmountString.append(attributesStandString1)
            standAmountString.append(attributesStandString2)
            lblStandAmount.attributedText = standAmountString

            let strDate = formatter.string(from: startDate, to: endDate)
            lblDate.text = strDate
        }
        else {
            let attributes = [NSAttributedString.Key.font: UIFont(name: "Avenir-Black", size: 18)!, NSAttributedString.Key.foregroundColor: UIColor.black]
            let amountString = NSMutableAttributedString(string: "NO DATA".localized() , attributes: attributes)
            lblMoveAmount.attributedText = amountString
            
            lblDate.text = ""
        }
    }
    
}

