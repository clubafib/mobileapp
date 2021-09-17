//
//  BloodAlcoholContentVC.swift
//  ClubAfib
//
//  Created by Rener on 8/5/20.
//  Copyright © 2020 ETU. All rights reserved.
//

import UIKit

class BloodAlcoholContentVC: UIViewController {
        
        
    @IBOutlet weak var typeSC: UISegmentedControl!
    @IBOutlet weak var heartRateChartView: RangeBarChartView!
    @IBOutlet weak var alcoholContentChartView: RangeBarChartView!
    @IBOutlet weak var lblMeasurement: UILabel!
    @IBOutlet weak var lblAmount: UILabel!
    @IBOutlet weak var lblDate: UILabel!
    
    var allChartViews: [ChartViewBase] = []
    
    let dayInSeconds: Double = 24 * 3600
    var XAxisValueFormatter: DayAxisValueFormatter? = nil
    var heartRateMarker: HeartRateMarkerView? = nil
    var alcoholContentMarker: AlcoholContentMarkerView? = nil
    
    var dayStartDate = Date()
    var dayEndDate = Date()
    var weekStartDate = Date()
    var weekEndDate = Date()
    var monthStartDate = Date()
    var monthEndDate = Date()
    var yearStartDate = Date()
    var yearEndDate = Date()
    
    var dayHeartRateEntries = [RangeBarChartDataEntry]()
    var dayAlcoholContentEntries = [RangeBarChartDataEntry]()
    
    var weekHeartRateEntries = [RangeBarChartDataEntry]()
    var weekAlcoholContentEntries = [RangeBarChartDataEntry]()
    
    var monthHeartRateEntries = [RangeBarChartDataEntry]()
    var monthAlcoholContentEntries = [RangeBarChartDataEntry]()
    
    var yearHeartRateEntries = [RangeBarChartDataEntry]()
    var yearAlcoholContentEntries = [RangeBarChartDataEntry]()
    
    var selectedDataType: ChartDataViewType = .Week
    var hasData = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        typeSC.selectedSegmentIndex = self.selectedDataType.rawValue
        typeSC.addTarget(self, action: #selector(self.chartDataViewTypeChanged), for:.valueChanged)
        typeSC.addTarget(self, action: #selector(self.chartDataViewTypeChanged), for:.touchUpInside)
        
        allChartViews = [heartRateChartView, alcoholContentChartView]
        
        initChartView()
        initDates()
        
        getHeartRates()
        getBloodAlcoholContent()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.healthDataChanged), name: NSNotification.Name(USER_NOTIFICATION_HEALTHDATA_CHANGED), object: nil)
    }
    
    @objc private func healthDataChanged(notification: NSNotification){
        DispatchQueue.main.async {
            self.getHeartRates()
            self.getBloodAlcoholContent()
        }
    }
    
    private func initChartView() {
        let chartViews: [BarLineChartViewBase] = [heartRateChartView, alcoholContentChartView]
        
        heartRateChartView.drawBarShadowEnabled = false
        heartRateChartView.drawValueAboveBarEnabled = false
        alcoholContentChartView.drawBarShadowEnabled = false
        alcoholContentChartView.drawValueAboveBarEnabled = false
        
        
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
        
        alcoholContentChartView.xAxis.drawLabelsEnabled = true

        heartRateMarker = HeartRateMarkerView(color: UIColor(white: 230/250, alpha: 1), font: .systemFont(ofSize: 12), textColor: .black, insets: UIEdgeInsets(top: 8, left: 8, bottom: 20, right: 8))
        heartRateMarker?.chartView = heartRateChartView
        heartRateMarker?.minimumSize = CGSize(width: 80, height: 40)
        heartRateChartView.marker = heartRateMarker

        alcoholContentMarker = AlcoholContentMarkerView(color: UIColor(white: 230/250, alpha: 1), font: .systemFont(ofSize: 12), textColor: .black, insets: UIEdgeInsets(top: 8, left: 8, bottom: 20, right: 8))
        alcoholContentMarker?.chartView = alcoholContentChartView
        alcoholContentMarker?.minimumSize = CGSize(width: 80, height: 40)
        alcoholContentChartView.marker = alcoholContentMarker
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
    
    private func getHeartRates() {
//        let heartRateData = HealthDataManager.default.heartRateData.sorted(by: { $0.date.compare($1.date) == .orderedAscending })
//        self.processDataset(heartRateData, healthType: .HeartRate)
        self.resetChartView()
    }
    
    private func getBloodAlcoholContent() {
//        let alcoholUseData = HealthDataManager.default.alcoholUseData.sorted(by: { $0.date.compare($1.date) == .orderedAscending })
//        self.processDataset(alcoholUseData, healthType: .BloodAlcoholContent)
        self.resetChartView()
    }
    
    private func processDataset(_ dataset: [SingleValueHealthData], healthType: HealthCategoryType) {
        if (dataset.count > 0) {
            let calendar = Calendar.current
            let now = Date()
            
            dayStartDate = now
            for data in dataset {
                if (data.value > 0) {
                    dayStartDate = data.date
                    break
                }
            }
            if (dayStartDate >= now) {
                hasData = false
                return print("No data")
            }
            
            hasData = true
            
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
            case .BloodAlcoholContent:
                dayAlcoholContentEntries.removeAll()
                weekAlcoholContentEntries.removeAll()
                monthAlcoholContentEntries.removeAll()
                yearAlcoholContentEntries.removeAll()
                break
            default:
                dayHeartRateEntries.removeAll()
                weekHeartRateEntries.removeAll()
                monthHeartRateEntries.removeAll()
                yearHeartRateEntries.removeAll()
                break
            }
            
            for data in dataset {
                if (data.date >= dayStartDate && data.date < dayEndDate) {
                    let entry = RangeBarChartDataEntry(x: 0.5 + GetXValueFromDate(date: data.date, type: .Day), start: data.value, end: data.value)
                    switch healthType {
                    case .BloodAlcoholContent:
                        dayAlcoholContentEntries.append(entry)
                        break
                    default:
                        dayHeartRateEntries.append(entry)
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
                    
                    let entry = RangeBarChartDataEntry(x: 0.5 + GetXValueFromDate(date: startOfDay, type: .Week), start: dailyMin, end: dailyMax)
                    
                    if (dailyCount > 0 && data.date >= weekStartDate && data.date < weekEndDate) {
                        switch healthType {
                        case .BloodAlcoholContent:
                            weekAlcoholContentEntries.append(entry)
                            break
                        default:
                            weekHeartRateEntries.append(entry)
                            break
                        }
                    }
                    if (dailyCount > 0 && data.date >= monthStartDate && data.date < monthEndDate) {
                        switch healthType {
                        case .BloodAlcoholContent:
                            monthAlcoholContentEntries.append(entry)
                            break
                        default:
                            monthHeartRateEntries.append(entry)
                            break
                        }
                    }

                    if (month != dateComponents.month) {
                        let xValue = 0.5 + GetXValueFromDate(date: startOfMonth, type: .Year)
                        let entry = RangeBarChartDataEntry(x: xValue, start: monthlyMin, end: monthlyMax)
                        
                        if (monthlyCount > 0 && data.date >= yearStartDate && data.date < yearEndDate) {
                            switch healthType {
                            case .BloodAlcoholContent:
                                yearAlcoholContentEntries.append(entry)
                                break
                            default:
                                yearHeartRateEntries.append(entry)
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

                let entry = RangeBarChartDataEntry(x: 0.5 + GetXValueFromDate(date: startOfDay, type: .Week), start: dailyMin, end: dailyMax)
                
                switch healthType {
                case .BloodAlcoholContent:
                    weekAlcoholContentEntries.append(entry)
                    monthAlcoholContentEntries.append(entry)
                    break
                default:
                    weekHeartRateEntries.append(entry)
                    monthHeartRateEntries.append(entry)
                    break
                }
            }

            if (monthlyCount > 0) {
                let xValue = 0.5 + GetXValueFromDate(date: startOfMonth, type: .Year)
                let entry = RangeBarChartDataEntry(x: xValue, start: monthlyMin, end: monthlyMax)
                
                switch healthType {
                case .BloodAlcoholContent:
                    yearAlcoholContentEntries.append(entry)
                    break
                default:
                    yearHeartRateEntries.append(entry)
                    break
                }
            }
        }
    }
    
    private func resetChartView() {
        if (hasData) {
            XAxisValueFormatter?.currentXAxisType = selectedDataType
            heartRateMarker?.currentXAxisType = selectedDataType
            alcoholContentMarker?.currentXAxisType = selectedDataType
            
            var minX = 0.0, maxX = 0.0
            var heartRateEntries: [RangeBarChartDataEntry]
            var alcoholContentEntries: [RangeBarChartDataEntry]
            switch selectedDataType {
            case .Day:
                heartRateEntries = dayHeartRateEntries
                alcoholContentEntries = dayAlcoholContentEntries
                
                minX = GetXValueFromDate(date: dayStartDate, type: .Day)
                maxX = GetXValueFromDate(date: dayEndDate, type: .Day)
                break
            case .Week:
                heartRateEntries = weekHeartRateEntries
                alcoholContentEntries = weekAlcoholContentEntries
                
                minX = GetXValueFromDate(date: weekStartDate, type: .Week)
                maxX = GetXValueFromDate(date: weekEndDate, type: .Week)
                break
            case .Month:
                heartRateEntries = monthHeartRateEntries
                alcoholContentEntries = monthAlcoholContentEntries
                
                minX = GetXValueFromDate(date: monthStartDate, type: .Month)
                maxX = GetXValueFromDate(date: monthEndDate, type: .Month)
                break
            default:
                heartRateEntries = yearHeartRateEntries
                alcoholContentEntries = yearAlcoholContentEntries
                
                minX = GetXValueFromDate(date: yearStartDate, type: .Year)
                maxX = GetXValueFromDate(date: yearEndDate, type: .Year)
                break
            }
            
            heartRateChartView.xAxis.axisMinimum = minX
            heartRateChartView.xAxis.axisMaximum = maxX
            alcoholContentChartView.xAxis.axisMinimum = minX
            alcoholContentChartView.xAxis.axisMaximum = maxX
            
            if
                let hrSet = heartRateChartView.rangeBarData?.dataSets.first as? RangeBarChartDataSet,
                let alcoholContentSet = alcoholContentChartView.rangeBarData?.dataSets.first as? RangeBarChartDataSet {
                
                hrSet.replaceEntries(heartRateEntries)
                alcoholContentSet.replaceEntries(alcoholContentEntries)
                
                heartRateChartView.data?.notifyDataChanged()
                heartRateChartView.notifyDataSetChanged()
                alcoholContentChartView.data?.notifyDataChanged()
                alcoholContentChartView.notifyDataSetChanged()
            } else {
                let hrSet = RangeBarChartDataSet(entries: heartRateEntries, label: "")
                hrSet.colors = [UIColor.systemPink]
                hrSet.drawValuesEnabled = false
                let hrData = RangeBarChartData(dataSet: hrSet)
                hrData.setValueFont(UIFont(name: "HelveticaNeue-Light", size: 10)!)
                heartRateChartView.data = hrData
                
                let alcoholContentSet = RangeBarChartDataSet(entries: alcoholContentEntries, label: "")
                alcoholContentSet.colors = [.systemGray]
                alcoholContentSet.drawValuesEnabled = false
                let alcoholContentData = RangeBarChartData(dataSet: alcoholContentSet)
                alcoholContentData.setValueFont(UIFont(name: "HelveticaNeue-Light", size: 10)!)
                alcoholContentChartView.data = alcoholContentData
            }

            switch selectedDataType {
            case .Day:
                heartRateChartView.setVisibleXRange(minXRange: 24, maxXRange: 24)
                heartRateChartView.xAxis.axisMaxLabels = 5
                heartRateChartView.rangeBarData?.barWidth = 0.5
                alcoholContentChartView.setVisibleXRange(minXRange: 24, maxXRange: 24)
                alcoholContentChartView.xAxis.axisMaxLabels = 5
                alcoholContentChartView.rangeBarData?.barWidth = 0.5
                break
            case .Week:
                heartRateChartView.setVisibleXRange(minXRange: 7, maxXRange: 7)
                heartRateChartView.xAxis.axisMaxLabels = 7
                heartRateChartView.xAxis.axisMinLabels = 7
                heartRateChartView.rangeBarData?.barWidth = 0.2
                alcoholContentChartView.setVisibleXRange(minXRange: 7, maxXRange: 7)
                alcoholContentChartView.xAxis.axisMaxLabels = 7
                alcoholContentChartView.xAxis.axisMinLabels = 7
                alcoholContentChartView.rangeBarData?.barWidth = 0.2
                break
            case .Month:
                heartRateChartView.setVisibleXRange(minXRange: 30, maxXRange: 30)
                heartRateChartView.xAxis.axisMaxLabels = 5
                heartRateChartView.rangeBarData?.barWidth = 0.7
                alcoholContentChartView.setVisibleXRange(minXRange: 30, maxXRange: 30)
                alcoholContentChartView.xAxis.axisMaxLabels = 5
                alcoholContentChartView.rangeBarData?.barWidth = 0.7
                break
            default:
                heartRateChartView.setVisibleXRange(minXRange: 12, maxXRange: 12)
                heartRateChartView.xAxis.axisMaxLabels = 12
                heartRateChartView.xAxis.axisMinLabels = 12
                heartRateChartView.rangeBarData?.barWidth = 0.32
                alcoholContentChartView.setVisibleXRange(minXRange: 12, maxXRange: 12)
                alcoholContentChartView.xAxis.axisMaxLabels = 12
                alcoholContentChartView.xAxis.axisMinLabels = 12
                alcoholContentChartView.rangeBarData?.barWidth = 0.32
                break
            }
            
            heartRateChartView.moveViewToX(maxX)
            alcoholContentChartView.moveViewToX(maxX)
        }

        updateChartYScale()
        updateMeasurements()
    }
    
    @objc func chartDataViewTypeChanged(segment: UISegmentedControl) {
        selectedDataType = ChartDataViewType(rawValue: segment.selectedSegmentIndex) ?? .Day
        
        resetChartView()
    }
    
    @IBAction func onBackPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }

    @IBAction func onShareButtonPressed(_ sender: Any) {
        shareScreenshot()
    }
    
    @IBAction func onAddButtonPressed(_ sender: Any) {
        let addVC = HOME_STORYBOARD.instantiateViewController(withIdentifier: "BloodAlcoholContentAddVC") as! BloodAlcoholContentAddVC
        self.navigationController?.pushViewController(addVC, animated: true)
    }
    
}

extension BloodAlcoholContentVC: ChartViewDelegate {
    
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
        if (hasData) {
//            var heartRateEntries: [RangeBarChartDataEntry]
            var alcoholContentEntries: [RangeBarChartDataEntry]
            switch selectedDataType {
            case .Day:
//                heartRateEntries = dayHeartRateEntries
                alcoholContentEntries = dayAlcoholContentEntries
                break
            case .Week:
//                heartRateEntries = weekHeartRateEntries
                alcoholContentEntries = weekAlcoholContentEntries
                break
            case .Month:
//                heartRateEntries = monthHeartRateEntries
                alcoholContentEntries = monthAlcoholContentEntries
                break
            default:
//                heartRateEntries = yearHeartRateEntries
                alcoholContentEntries = yearAlcoholContentEntries
                break
            }
            
            var minAlcoholContent = 100.0, maxAlcoholContent = 0.0, counts = 0
            for entry in alcoholContentEntries {
                if (entry.x >= alcoholContentChartView.lowestVisibleX && entry.x <= alcoholContentChartView.highestVisibleX) {
                    if (entry.end > maxAlcoholContent) { maxAlcoholContent = entry.end }
                    if (entry.start < minAlcoholContent) { minAlcoholContent = entry.start }
                    if (entry.end > 0 ) { counts += 1 }
                }
            }
            
            let strType = minAlcoholContent == maxAlcoholContent ? "" : "RANGE".localized()
            
            let formatter = DateIntervalFormatter()
            let startDate = GetDateFromChartEntryX(value: alcoholContentChartView.lowestVisibleX, type: selectedDataType)
            var endDate = GetDateFromChartEntryX(value: alcoholContentChartView.highestVisibleX, type: selectedDataType)
            
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

            let valueFormatter = NumberFormatter()
            valueFormatter.maximumFractionDigits = 2
            let attributes1 = [NSAttributedString.Key.font: UIFont(name: "Avenir-Black", size: 24)!, NSAttributedString.Key.foregroundColor: UIColor.black]
            let attributesString1 = NSMutableAttributedString(string: minAlcoholContent == maxAlcoholContent ? valueFormatter.string(from: NSNumber(value: maxAlcoholContent))! : "\(valueFormatter.string(from: NSNumber(value: minAlcoholContent))!)-\(valueFormatter.string(from: NSNumber(value: maxAlcoholContent))!)", attributes: attributes1)
            let attributes2 = [NSAttributedString.Key.font: UIFont(name: "Avenir-Black", size: 12)!, NSAttributedString.Key.foregroundColor: UIColor(red: 0.4, green: 0.4, blue: 0.4, alpha: 1.0)]
            let attributesString2 = NSMutableAttributedString(string: " times" , attributes: attributes2)
            let alcoholContentRangeString = NSMutableAttributedString()
            if counts > 0 {
                alcoholContentRangeString.append(attributesString1)
                alcoholContentRangeString.append(attributesString2)
            } else {
                alcoholContentRangeString.append(NSMutableAttributedString(string: "NO DATA".localized() , attributes: attributes1))
            }
            
            lblAmount.attributedText = alcoholContentRangeString
            
            
            let strDate = formatter.string(from: startDate, to: endDate)
            lblDate.text = strDate
        }
        else {
            lblMeasurement.text = ""
            let attributes = [NSAttributedString.Key.font: UIFont(name: "Avenir-Black", size: 24)!, NSAttributedString.Key.foregroundColor: UIColor.black]
            let alcoholContentAmountString = NSMutableAttributedString(string: "NO DATA".localized() , attributes: attributes)
            lblAmount.attributedText = alcoholContentAmountString
            lblDate.text = ""
        }
    }

}
