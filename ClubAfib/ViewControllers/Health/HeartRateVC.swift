//
//  HeartRateVC.swift
//  ClubAfib
//
//  Created by Rener on 7/25/20.
//  Copyright © 2020 ETU. All rights reserved.
//

import UIKit
import HealthKit

class HeartRateVC: UIViewController {
    
    @IBOutlet weak var imgLogo: UIImageView!
    @IBOutlet weak var imgMenu: UIImageView!
    @IBOutlet weak var typeSC: UISegmentedControl!
        
    @IBOutlet weak var lblMeasurement: UILabel!
    @IBOutlet weak var lblAmount: UILabel!
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var scvwContent: UIScrollView!
    @IBOutlet weak var tblData: UITableView!
    
    @IBOutlet weak var vwChartsHeader: UIView!
    
    var heartRateChartView: RangeBarChartView!
    var ecgCharts = [BarChartView]()
    let dayInSeconds: Double = 24 * 3600
    
    var dayStartDate = Date.Max()
    var dayEndDate = Date()
    var weekStartDate = Date()
    var weekEndDate = Date()
    var monthStartDate = Date()
    var monthEndDate = Date()
    var yearStartDate = Date()
    var yearEndDate = Date()

    var dayEntries = [RangeBarChartDataEntry]()
    var weekEntries = [RangeBarChartDataEntry]()
    var monthEntries = [RangeBarChartDataEntry]()
    var yearEntries = [RangeBarChartDataEntry]()
    var ecgSREntries = [BarChartDataEntry]()
    var ecgAFEntries = [BarChartDataEntry]()
    var ecgICCSEntries = [BarChartDataEntry]()
    
    var timer: Timer!
    
    var selectedDataType: ChartDataViewType = .Week    
    var ecgSR = [Ecg]()
    var ecgAF = [Ecg]()
    var ecgICCS = [Ecg]()
    var chartHeight:CGFloat = 100
    var m_vwData = [UIView]()
    
    var dataLoads = 0
    var previousHeartRatesQueryStartDate:Date?
    var previousHeartRatesQueryEndDate:Date?
    var previousECGQueryStartDate:Date?
    var previousECGQueryEndDate:Date?

    override func viewDidLoad() {
        super.viewDidLoad()
                
        self.initTopbar()
        
        typeSC.selectedSegmentIndex = self.selectedDataType.rawValue
        typeSC.addTarget(self, action: #selector(self.chartDataViewTypeChanged), for:.valueChanged)
        typeSC.addTarget(self, action: #selector(self.chartDataViewTypeChanged), for:.touchUpInside)
        
        tblData.dragInteractionEnabled = true
        tblData.dragDelegate = self
        tblData.dropDelegate = self
        
        chartHeight = (scvwContent.frame.size.height - vwChartsHeader.frame.size.height - 20) / 2 - 20
        heartRateChartView = RangeBarChartView(frame: CGRect(x: 10, y: 15, width:self.view.frame.size.width - 20, height: chartHeight - 15 ))
        heartRateChartView.tag = 0
        var lblLegend = UILabel(frame: CGRect(x: 17, y: 15, width: 50, height: 10))
        lblLegend.text = "Heart Rate"
        lblLegend.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        lblLegend.textColor = UIColor.red
        lblLegend.sizeToFit()
        heartRateChartView.addSubview(lblLegend)
        m_vwData.append(heartRateChartView)
        for i in 0..<3 {
            lblLegend = UILabel(frame: lblLegend.frame)
            lblLegend.font = UIFont.systemFont(ofSize: 12, weight: .medium)
            switch i {
            case 0:
                lblLegend.text = "Sinus Rhythm"
                lblLegend.textColor = UIColor.systemGreen
                break
            case 1:
                lblLegend.text = "Atrial Fibrillation"
                lblLegend.textColor = UIColor.red
                break
            default:
                lblLegend.text = "Inconclusive"
                lblLegend.textColor = UIColor.orange
                break
            }
            let barChart = BarChartView(frame: heartRateChartView.frame)
            barChart.tag = 1 + i
            lblLegend.sizeToFit()
            barChart.addSubview(lblLegend)
            ecgCharts.append(barChart)
            m_vwData.append(ecgCharts[i])
        }
        tblData.frame.size = CGSize(width: scvwContent.frame.size.width, height: (chartHeight + 20) * 4)
        scvwContent.contentSize = CGSize(width: 0, height: tblData.frame.size.height + tblData.frame.origin.y)
        tblData.reloadData()
        
        fetchData()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.healthDataChanged), name: NSNotification.Name(USER_NOTIFICATION_HEALTHDATA_CHANGED), object: nil)
    }
    
    private func fetchData() {
        self.showLoadingProgress(view: self.navigationController?.view)
        self.dataLoads = 2
        
        initChartView()
        initEcgCharts()
        initDates()
        getHeartRates()
        getECGData()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.healthDataChanged), name: NSNotification.Name(USER_NOTIFICATION_HEALTHDATA_CHANGED), object: nil)
    }
    
    private func initChartView() {
        heartRateChartView.chartDescription?.enabled = false

        heartRateChartView.dragEnabled = true
        heartRateChartView.setScaleEnabled(false)
        heartRateChartView.pinchZoomEnabled = false

        heartRateChartView.delegate = self

        heartRateChartView.drawBordersEnabled = true
        heartRateChartView.drawBarShadowEnabled = false
        heartRateChartView.drawValueAboveBarEnabled = false
        heartRateChartView.chartDescription?.enabled = true
        heartRateChartView.legend.enabled = false

        let xAxis = heartRateChartView.xAxis
        xAxis.labelPosition = .bottom
        xAxis.centerAxisLabelsEnabled = true
        xAxis.labelFont = .systemFont(ofSize: 10)
        xAxis.granularity = 1
        xAxis.labelCount = 5
        let XAxisValueFormatter = DayAxisValueFormatter(chart: heartRateChartView)
        XAxisValueFormatter.currentXAxisType = .Month
        xAxis.valueFormatter = XAxisValueFormatter
        
        let leftAxis = heartRateChartView.leftAxis
        leftAxis.enabled = false
        leftAxis.spaceTop = 0.1
        leftAxis.spaceBottom = 0
        leftAxis.axisMinimum = 0

        let rightAxis = heartRateChartView.rightAxis
        rightAxis.enabled = true
        rightAxis.labelFont = .systemFont(ofSize: 10)
        rightAxis.labelCount = 3
        rightAxis.spaceTop = 0.1
        rightAxis.spaceBottom = 0
        rightAxis.axisMinimum = 0
        rightAxis.minWidth = 25
        rightAxis.maxWidth = 25
        
        let marker = HeartRateMarkerView(color: UIColor(white: 230/250, alpha: 1), font: .systemFont(ofSize: 12), textColor: .black, insets: UIEdgeInsets(top: 8, left: 8, bottom: 20, right: 8))
        marker.chartView = heartRateChartView
        marker.minimumSize = CGSize(width: 60, height: 40)
        heartRateChartView.marker = marker
    }
    
    func initEcgCharts(){
        for chartView in ecgCharts {
            chartView.drawBarShadowEnabled = false
            chartView.drawValueAboveBarEnabled = false
            chartView.isECG = true
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
            let XAxisValueFormatter = DayAxisValueFormatter(chart: chartView)
            XAxisValueFormatter.currentXAxisType = .Month
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
            rightAxis.spaceTop = 0.1
            rightAxis.spaceBottom = 0
            rightAxis.axisMinimum = 0
            rightAxis.minWidth = 25
            rightAxis.maxWidth = 25
            
            chartView.xAxis.drawLabelsEnabled = true
            
            let ecgMarker = EcgMarker(color: UIColor(white: 230/250, alpha: 1), font: .systemFont(ofSize: 12), textColor: .black, insets: UIEdgeInsets(top: 8, left: 8, bottom: 20, right: 8))
            ecgMarker.chartView = chartView
            ecgMarker.minimumSize = CGSize(width: 80, height: 40)
            chartView.marker = ecgMarker
        }
    }
    
    private func processECGDataset(ecgData: [Ecg]) {
        ecgSREntries.removeAll()
        ecgAFEntries.removeAll()
        ecgICCSEntries.removeAll()
        ecgSR.removeAll()
        ecgAF.removeAll()
        ecgICCS.removeAll()
        
        for item in ecgData {
            switch HKElectrocardiogram.Classification(rawValue: item.type) {
            case .sinusRhythm:
                ecgSR.append(item)
                break
            case .atrialFibrillation:
                ecgAF.append(item)
                break
            case .inconclusiveHighHeartRate:
                break
            case .inconclusiveLowHeartRate:
                break
            case .inconclusiveOther:
                ecgICCS.append(item)
                break
            case .inconclusivePoorReading:
                ecgICCS.append(item)
                break
            default:
                break
            }
        }
        
        self.initEcgEntries(ecgSR, type:0)
        self.initEcgEntries(ecgAF, type:1)
        self.initEcgEntries(ecgICCS, type:2)
    }
    
    func initEcgEntries(_ ecgs:[Ecg], type:Int) {
        var entry:BarChartDataEntry! = nil
        let offset:Double = 0.5
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
                self.appendEcgEntries(entry, type: type)
                entry = BarChartDataEntry(x: offset + GetXValueFromDate(date: item.date, type: self.selectedDataType), y: 1)
                prevDate = newDate
            }
        }
        
        if entry != nil {
            if entry.y != 0 {
                self.appendEcgEntries(entry, type: type)
            }
        }
    }
    
    func appendEcgEntries(_ entry: BarChartDataEntry, type:Int){
        switch type {
        case 0:
            ecgSREntries.append(entry)
            break
        case 1:
            ecgAFEntries.append(entry)
            break
        default:
            ecgICCSEntries.append(entry)
            break
        }
    }
    
    private func initTopbar() {
        self.setProfileMenu()
        
        let menuTap = UITapGestureRecognizer(target: self, action: #selector(self.onMenuClicked(sender:)))
        self.imgMenu.isUserInteractionEnabled = true
        self.imgMenu.addGestureRecognizer(menuTap)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.setProfileMenu), name: NSNotification.Name(USER_NOTIFICATION_PROFILE_CHANGED), object: nil)
    }
    
    @objc private func setProfileMenu() {
        let user = UserInfo.sharedInstance.userData
        if let photo = user?.photo {
            imgMenu.sd_setImage(with: URL(string: photo), placeholderImage: UIImage(named: "default_avatar"))
        }
        else {
            imgMenu.image = UIImage(named: "default_avatar")
        }
    }
    
    @objc func onMenuClicked(sender: UIButton!) {
        NotificationCenter.default.post(name: Notification.Name(USER_NOTIFICATION_OPEN_MENU), object: nil)
    }
    
    @objc private func healthDataChanged(notification: NSNotification){
        DispatchQueue.main.async {
            self.fetchData()
        }
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
    
    private func calculateHealthKitStartDate() -> (startDate:Date, endDate:Date) {
        let calendar = Calendar.current
        var startDate = Date()
        var endDate = calendar.date(byAdding: .day, value: 1, to: Date()) ?? Date()
        endDate = calendar.startOfDay(for: endDate)
        switch self.selectedDataType {
        case ChartDataViewType.Day:
            startDate = calendar.date(byAdding: .day, value: -30, to: endDate)!
        case ChartDataViewType.Week:
            startDate = calendar.date(byAdding: .weekOfYear, value: -11, to: endDate)!
            let dateComponents = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: startDate)
            if let weekStartDate = calendar.date(from: dateComponents) {
                startDate = weekStartDate
            }
        case ChartDataViewType.Month:
            startDate = calendar.date(byAdding: .month, value: -11, to: endDate)!
            let dateComponents = calendar.dateComponents([.year, .month], from: startDate)
            if let monthStartDate = calendar.date(from: dateComponents) {
                startDate = monthStartDate
            }
        case ChartDataViewType.Year:
            startDate = calendar.date(byAdding: .year, value: -99, to: endDate)!
            let dateComponents = calendar.dateComponents([.year], from: startDate)
            if let yearStartDate = calendar.date(from: dateComponents) {
                startDate = yearStartDate
            }
        }
        
        return (startDate, endDate)
    }
    
    private func getHeartRates() {
        let result = self.calculateHealthKitStartDate()
        let startDate = result.startDate
        let endDate = result.endDate
        if (previousHeartRatesQueryStartDate != nil && previousHeartRatesQueryEndDate != nil) &&
            startDate >= previousHeartRatesQueryStartDate! &&
            endDate <= previousHeartRatesQueryEndDate! {
            self.resetChartView()
        } else {
            DispatchQueue.global(qos: .background).async {
                HealthKitHelper.default.getHeartRates(startDate: startDate, endDate: endDate) {(heartRates, error) in
                    if (error != nil) {
                        print(error!)
                    }
                    guard let heartRates = heartRates else {
                        print("can't get heart rate data")
                        DispatchQueue.main.async {
                            self.dismissLoadingProgress(view: self.navigationController?.view)
                        }
                        return
                    }
                    self.previousHeartRatesQueryStartDate = startDate
                    self.previousHeartRatesQueryEndDate = endDate
                    self.processDataset(heartRates: heartRates)
                    self.resetChartView()
                }
            }
        }
    }
    
    private func getECGData(){
        let result = self.calculateHealthKitStartDate()
        let startDate = result.startDate
        let endDate = result.endDate
        if (previousECGQueryStartDate != nil && previousECGQueryEndDate != nil) &&
            startDate >= previousECGQueryStartDate! &&
            endDate <= previousECGQueryEndDate! {
            self.resetChartView()
        } else {
            DispatchQueue.global(qos: .background).async {
                HealthKitHelper.default.getECG(startDate: startDate, endDate: endDate) { (ecgData, error) in
                    
                    if (error != nil) {
                        print(error!)
                    }
                    
                    guard let ecgData = ecgData else {
                        print("can't get ECG data")
                        self.dismissLoadingProgress(view: self.navigationController?.view)
                        return
                    }
                    self.previousECGQueryStartDate = startDate
                    self.previousECGQueryEndDate = endDate
                    self.processECGDataset(ecgData: ecgData)
                    self.resetChartView()
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
    
    private func processDataset(heartRates:[HeartRate]) {
        let dataset = heartRates
        if (dataset.count > 0) {
            let calendar = Calendar.current
            for data in dataset {
                if (data.value > 0) {
                    if data.date < dayStartDate {
                        dayStartDate = data.date
                    }
                }
            }
            resetStartDate()
            // get the week start date from start date
            var dateComponents = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: dayStartDate)
            
            var day = 0, dailyCount = 0, dailyMin = 500.0, dailyMax = 0.0, hourMin = 10000.0, hourMax = 0.0
            var month = 1, monthlyCount = 0, monthlyMin = 500.0, monthlyMax = 0.0
            var startOfDay = dayStartDate
            var startOfMonth = monthStartDate
            
            dayEntries.removeAll()
            weekEntries.removeAll()
            monthEntries.removeAll()
            yearEntries.removeAll()
            let df = DateFormatter()
            var prevHour = ""
            let offset:Double = 0.5
            for data in dataset {
                if (data.date >= dayStartDate && data.date < dayEndDate) {
                    df.dateFormat = "yyyy-MM-dd HH"
                    if df.string(from: data.date) != prevHour {
                        if hourMax != 0 {
                            let entry = RangeBarChartDataEntry(x: offset + GetXValueFromDate(date: data.date, type: .Day), start: hourMin, end: hourMax)
                            dayEntries.append(entry)
                        }
                        
                        hourMin = 10000.0
                        hourMax = 0.0
                        prevHour = df.string(from: data.date)
                    }
                    if hourMin > data.value {
                        hourMin = data.value
                    }
                    if hourMax < data.value {
                        hourMax = data.value
                    }
                }
            }
            
            if hourMax != 0 {
                let entry = RangeBarChartDataEntry(x: offset + GetXValueFromDate(date: df.date(from: prevHour)!, type: .Day), start: hourMin, end: hourMax)
                dayEntries.append(entry)
            }
            
            for data in dataset {
                dateComponents = calendar.dateComponents([.year, .month, .day, .weekday], from: data.date)
                if (day != dateComponents.day) {
                    if (dailyMin < monthlyMin) { monthlyMin = dailyMin }
                    if (dailyMax > monthlyMax) { monthlyMax = dailyMax }
                    if (dailyCount > 0) {
                        monthlyCount += 1
                    }
                    
                    let entry = RangeBarChartDataEntry(x: offset + GetXValueFromDate(date: startOfDay, type: .Week), start: dailyMin, end: dailyMax)
                    
                    if (dailyCount > 0 && data.date >= weekStartDate && data.date < weekEndDate) {
                        weekEntries.append(entry)
                    }
                    if (dailyCount > 0 && data.date >= monthStartDate && data.date < monthEndDate) {
                        monthEntries.append(entry)
                    }

                    if (month != dateComponents.month) {
                        let xValue = 0.5 + GetXValueFromDate(date: startOfMonth, type: .Year)
                        let entry = RangeBarChartDataEntry(x: xValue, start: monthlyMin, end: monthlyMax)
                        
                        if (monthlyCount > 0 && data.date >= yearStartDate && data.date < yearEndDate) {
                            yearEntries.append(entry)
                        }
                        
                        let components = calendar.dateComponents([.year, .month], from: data.date)
                        startOfMonth = calendar.date(from: components)!
                        month = dateComponents.month!
                        monthlyCount = 0
                        monthlyMin = 500.0
                        monthlyMax = 0.0
                    }
                    
                    startOfDay = calendar.date(from: dateComponents)!
                    day = dateComponents.day!
                    dailyCount = 0
                    dailyMin = 500.0
                    dailyMax = 0.0
                }
                
                if (data.value < dailyMin) { dailyMin = data.value }
                if (data.value > dailyMax) { dailyMax = data.value }
                if (data.value > 0) { dailyCount += 1 }
            }
            
            if (dailyCount > 0) {
                if (dailyMin < monthlyMin) { monthlyMin = dailyMin }
                if (dailyMax > monthlyMax) { monthlyMax = dailyMax }
                if (dailyCount > 0) {
                    monthlyCount += 1
                }
                
                let entry = RangeBarChartDataEntry(x: offset + GetXValueFromDate(date: startOfDay, type: .Week), start: dailyMin, end: dailyMax)

                weekEntries.append(entry)
                monthEntries.append(entry)
            }

            if (monthlyCount > 0) {
                let xValue = offset + GetXValueFromDate(date: startOfMonth, type: .Year)
                let entry = RangeBarChartDataEntry(x: xValue, start: monthlyMin, end: monthlyMax)
                
                yearEntries.append(entry)
            }
        }
    }
    
    private func resetChartView() {
        self.dataLoads = self.dataLoads - 1
        if (self.dataLoads > 0) {
            return
        }
        DispatchQueue.main.async { [self] in
            self.dismissLoadingProgress(view: self.navigationController?.view)
            (heartRateChartView.xAxis.valueFormatter as! DayAxisValueFormatter).currentXAxisType = selectedDataType
            (heartRateChartView.marker as! HeartRateMarkerView).currentXAxisType = selectedDataType
            
            var minX = 0.0, maxX = 0.0
            var entries: [RangeBarChartDataEntry]
            switch selectedDataType {
            case .Day:
                entries = dayEntries
                minX = GetXValueFromDate(date: dayStartDate, type: selectedDataType)
                maxX = GetXValueFromDate(date: dayEndDate, type: selectedDataType)
                break
            case .Week:
                entries = weekEntries
                minX = GetXValueFromDate(date: weekStartDate, type: .Week)
                maxX = GetXValueFromDate(date: weekEndDate, type: .Week)
                break
            case .Month:
                entries = monthEntries
                minX = GetXValueFromDate(date: monthStartDate, type: .Month)
                maxX = GetXValueFromDate(date: monthEndDate, type: .Month)
                break
            default:
                entries = yearEntries
                minX = GetXValueFromDate(date: yearStartDate, type: .Year)
                maxX = GetXValueFromDate(date: yearEndDate, type: .Year)
                break
            }
            if entries.count == 0 {
                return
            }
            for chart in ecgCharts {
                chart.xAxis.axisMinimum = minX
                chart.xAxis.axisMaximum = maxX
            }
            heartRateChartView.xAxis.axisMinimum = minX
            heartRateChartView.xAxis.axisMaximum = maxX
            
            if let hrSet = heartRateChartView.rangeBarData?.dataSets.first as? RangeBarChartDataSet {
                hrSet.replaceEntries(entries)
                heartRateChartView.data?.notifyDataChanged()
            } else {
                let hrSet = RangeBarChartDataSet(entries: entries, label: "")
                hrSet.colors = [UIColor.systemPink]
                hrSet.drawValuesEnabled = false
                let hrData = RangeBarChartData(dataSet: hrSet)
                hrData.setValueFont(UIFont(name: "HelveticaNeue-Light", size: 10)!)
                if entries.count > 0 {
                    heartRateChartView.data = hrData
                }
            }
            heartRateChartView.notifyDataSetChanged()
            
            for chart in ecgCharts {
                if chart.barData != nil {
                    if let dataSet = chart.barData!.dataSets.first as? BarChartDataSet {
                        switch chart.tag {
                        case 1:
                            dataSet.replaceEntries(ecgSREntries)
                            break
                        case 2:
                            dataSet.replaceEntries(ecgAFEntries)
                            break
                        case 3:
                            dataSet.replaceEntries(ecgICCSEntries)
                            break
                        default:
                            break
                        }
                        chart.data!.notifyDataChanged()
                    }
                } else {
                    var dataSet = BarChartDataSet(entries: ecgSREntries, label: "")
                    switch chart.tag {
                    case 1:
                        dataSet.colors = [UIColor.systemGreen]
                        break
                    case 2:
                        dataSet = BarChartDataSet(entries: ecgAFEntries, label: "")
                        dataSet.colors = [UIColor.red]
                        break
                    case 3:
                        dataSet = BarChartDataSet(entries: ecgICCSEntries, label: "")
                        dataSet.colors = [UIColor.orange]
                        break
                    default:
                        break
                    }
                    dataSet.drawValuesEnabled = false
                    let data = BarChartData(dataSet: dataSet)
                    data.setValueFont(UIFont(name: "HelveticaNeue-Light", size: 10)!)
                    if dataSet.count > 0 {
                        chart.data = data
                    }
                }
                if let chartData = chart.data{
                    chartData.notifyDataChanged()
                }
                chart.notifyDataSetChanged()
                (chart.marker as! EcgMarker).currentXAxisType = selectedDataType
            }
            
            switch selectedDataType {
            case .Day:
                heartRateChartView.setVisibleXRange(minXRange: 24, maxXRange: 24) //24
                heartRateChartView.rangeBarData?.barWidth = 0.7
                break
            case .Week:
                heartRateChartView.setVisibleXRange(minXRange: 7, maxXRange: 7)
                heartRateChartView.rangeBarData?.barWidth = 0.2
                break
            case .Month:
                heartRateChartView.setVisibleXRange(minXRange: 30, maxXRange: 30) // 30
                heartRateChartView.rangeBarData?.barWidth = 0.7
                break
            default:
                heartRateChartView.setVisibleXRange(minXRange: 12, maxXRange: 12)
                heartRateChartView.rangeBarData?.barWidth = 0.5
                break
            }
            
            heartRateChartView.moveViewToX(maxX)
            
            for chart in ecgCharts {
                (chart.xAxis.valueFormatter as! DayAxisValueFormatter).currentXAxisType = selectedDataType
                chart.setVisibleXRange(minXRange: heartRateChartView.visibleXRange, maxXRange: heartRateChartView.visibleXRange)
                chart.xAxis.axisMaxLabels = heartRateChartView.xAxis.axisMaxLabels
                chart.xAxis.axisMinLabels = heartRateChartView.xAxis.axisMinLabels
                chart.barData?.barWidth = heartRateChartView.rangeBarData!.barWidth
                chart.moveViewToX(maxX)
            }
            updateMeasurements()
        }
    }
    
    @objc func chartDataViewTypeChanged(segment: UISegmentedControl) {
        self.selectedDataType = ChartDataViewType(rawValue: segment.selectedSegmentIndex) ?? .Day
        self.fetchData()
    }

    @IBAction func onShareButtonPressed(_ sender: Any) {
        shareScreenshot()
    }    
}

extension HeartRateVC: ChartViewDelegate {

    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight){        
        if chartView == heartRateChartView {
            for tempChart in ecgCharts {
                if tempChart != chartView {
                    tempChart.highlightValue(highlight)
                }
            }
        } else {
            for tempChart in ecgCharts {
                if tempChart != chartView {
                    tempChart.highlightValue(highlight)
                }
            }
            heartRateChartView.highlightValue(highlight)
        }
    }
    
    func chartValueNothingSelected(_ chartView: ChartViewBase) {
        if chartView == heartRateChartView {
            return
        }
        if let lastEntry = chartView.lastActivated {
            if let entry = chartView.data?.entryForHighlight(lastEntry) {
                let date = GetDateFromChartEntryX(value: entry.x, type: self.selectedDataType)
                let vc = HOME_STORYBOARD.instantiateViewController(withIdentifier: "ECGChartsVC") as! ECGChartsVC
                switch chartView.tag {
                case 1:
                    vc.ecgData = ecgSR
                    break
                case 2:
                    vc.ecgData = ecgAF
                    break
                default:
                    vc.ecgData = ecgICCS
                    break
                }
                vc.m_date = date
                vc.selectedDataType = self.selectedDataType
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
    func chartTranslated(_ chartView: ChartViewBase, dX: CGFloat, dY: CGFloat) {
        let mainMatrix = chartView.viewPortHandler.touchMatrix
        
        for tempChart in ecgCharts {
            if tempChart != chartView {
                tempChart.viewPortHandler.refresh(newMatrix: mainMatrix, chart: tempChart, invalidate: true)
            }
        }
        if heartRateChartView != chartView {
            heartRateChartView.viewPortHandler.refresh(newMatrix: mainMatrix, chart: heartRateChartView, invalidate: true)
        }
    }
    
    func chartViewDidEndPanning(_ chartView: ChartViewBase) {
        updateMeasurements()
    }
    
    private func updateMeasurements() {
        var entries: [RangeBarChartDataEntry]
        switch selectedDataType {
        case .Day:
            entries = dayEntries
            break
        case .Week:
            entries = weekEntries
            break
        case .Month:
            entries = monthEntries
            break
        default:
            entries = yearEntries
            break
        }
        if entries.count > 0 {
            var minBPM = 500.0, maxBPM = 0.0, counts = 0
            for entry in entries {
                if (entry.x >= heartRateChartView.lowestVisibleX && entry.x <= heartRateChartView.highestVisibleX) {
                    if (entry.end > maxBPM) { maxBPM = entry.end }
                    if (entry.start < minBPM) { minBPM = entry.start }
                    if (entry.end > 0 ) { counts += 1 }
                }
            }
            
//            heartRateChartView.rightAxis.axisMinimum = 0
//            heartRateChartView.rightAxis.axisMaximum = maxBPM * 1.1
//            heartRateChartView.leftAxis.axisMinimum = 0
//            heartRateChartView.leftAxis.axisMaximum = maxBPM * 1.1
            
            let strType = minBPM == maxBPM ? "" : "RANGE".localized()
            
            let formatter = DateIntervalFormatter()
            let startDate = GetDateFromChartEntryX(value: heartRateChartView.lowestVisibleX, type: selectedDataType)
            var endDate = GetDateFromChartEntryX(value: heartRateChartView.highestVisibleX, type: selectedDataType)
            
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
            
            let strRange = minBPM == maxBPM ? "\(Int(maxBPM))" : "\(Int(minBPM))-\(Int(maxBPM))"

            let yFormatter = NumberFormatter()
            yFormatter.numberStyle = .decimal
            yFormatter.groupingSeparator = ","
            let attributes1 = [NSAttributedString.Key.font: UIFont(name: "Avenir-Black", size: 24)!, NSAttributedString.Key.foregroundColor: UIColor.black]
            let attributesString1 = NSMutableAttributedString(string: strRange, attributes: attributes1)
            let attributes2 = [NSAttributedString.Key.font: UIFont(name: "Avenir-Black", size: 12)!, NSAttributedString.Key.foregroundColor: UIColor(red: 0.4, green: 0.4, blue: 0.4, alpha: 1.0)]
            let attributesString2 = NSMutableAttributedString(string: " BPM" , attributes: attributes2)
            let heartRateRangeString = NSMutableAttributedString()
            if counts > 0 {
                heartRateRangeString.append(attributesString1)
                heartRateRangeString.append(attributesString2)
            } else {
                heartRateRangeString.append(NSMutableAttributedString(string: "NO DATA".localized() , attributes: attributes1))
            }
            
            lblAmount.attributedText = heartRateRangeString
            
            
            let strDate = formatter.string(from: startDate, to: endDate)
            lblDate.text = strDate
            
            if let latestEntry = dayEntries.last {
                let date = GetDateFromChartEntryX(value: latestEntry.x, type: selectedDataType)
                let dateFormatter = DateFormatter()
                if Calendar.current.isDateInToday(date) {
                    dateFormatter.dateFormat = "h:mm a"
                }
                else {
                    dateFormatter.dateFormat = "dd MMM, h:mm a"
                }
            }
        }
        else {
            lblMeasurement.text = ""
            let attributes = [NSAttributedString.Key.font: UIFont(name: "Avenir-Black", size: 24)!, NSAttributedString.Key.foregroundColor: UIColor.black]
            let stepAmountString = NSMutableAttributedString(string: "NO DATA".localized() , attributes: attributes)
            lblAmount.attributedText = stepAmountString
            lblDate.text = ""
        }
        tblData.reloadData()
    }
}

extension HeartRateVC: UITableViewDelegate, UITableViewDataSource, UITableViewDragDelegate, UITableViewDropDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return m_vwData.count
    }
            
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CellChart
        cell.setChart(m_vwData[indexPath.row], date: lblDate.text!)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return chartHeight + 20
    }
    
    func tableView(_ tableView: UITableView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        return [
            UIDragItem(itemProvider: NSItemProvider())
        ]
    }
    
    func tableView(_ tableView: UITableView, canHandle session: UIDropSession) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UITableViewDropProposal {
        if tableView.hasActiveDrag {
            if session.items.count > 1 {
                return UITableViewDropProposal(operation: .cancel)
            } else {
                return UITableViewDropProposal(operation: .move, intent: .insertAtDestinationIndexPath)
            }
        } else {
            return UITableViewDropProposal(operation: .copy, intent: .insertAtDestinationIndexPath)
        }
    }
    
    func tableView(_ tableView: UITableView, performDropWith coordinator: UITableViewDropCoordinator) {
        let destinationIndexPath: IndexPath
        if let indexPath = coordinator.destinationIndexPath {
            destinationIndexPath = indexPath
        } else {
            let section = tableView.numberOfSections - 1
            let row = tableView.numberOfRows(inSection: section)
            destinationIndexPath = IndexPath(row: row, section: section)
        }
        let source = m_vwData[coordinator.items[0].sourceIndexPath!.row]
        let dest = m_vwData[destinationIndexPath.row]
        m_vwData[destinationIndexPath.row] = source
        m_vwData[coordinator.items[0].sourceIndexPath!.row] = dest
        tblData.moveRow(at: coordinator.items[0].sourceIndexPath!, to: destinationIndexPath)
    }
}

class CellChart: UITableViewCell {
    @IBOutlet var lblDate: UILabel!
    
    public func setChart(_ vw:UIView, date:String) {
        for item in self.subviews {
            item.removeFromSuperview()
        }
        self.addSubview(lblDate)        
        lblDate.text = date
        self.addSubview(vw)
    }
}

