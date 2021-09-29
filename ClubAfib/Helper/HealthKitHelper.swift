//
//  HealthKitHelper.swift
//  Helper
//
//  Created by Rener on 7/22/20.
//  Copyright © 2020 ExtremeMobile. All rights reserved.
//

import HealthKit


class HealthKitHelper {
    
    static let `default` = HealthKitHelper()
    
    private let healthStore = HKHealthStore()
    var m_bProcessingECG = false
    var m_bProcessingHR = false
    
    public enum HealthkitSetupError: Error {
      case notAvailableOnDevice
      case dataTypeNotAvailable
      case dateCalculationerror
    }
    
    func authorizeHealthKit(completion: @escaping (Bool, Error?) -> Swift.Void) {
        guard HKHealthStore.isHealthDataAvailable() else {
            completion(false, HealthkitSetupError.notAvailableOnDevice)
            return
        }
        
        guard let dateOfBirth = HKObjectType.characteristicType(forIdentifier: .dateOfBirth),
            let height = HKObjectType.quantityType(forIdentifier: .height),
            let bodyMass = HKObjectType.quantityType(forIdentifier: .bodyMass),
            let enerbyBurned = HKObjectType.quantityType(forIdentifier: .activeEnergyBurned),
            let exerciseTime = HKObjectType.quantityType(forIdentifier: .appleExerciseTime),
            let standHour = HKObjectType.categoryType(forIdentifier: .appleStandHour),
            let stepCount = HKQuantityType.quantityType(forIdentifier: .stepCount),
            let sleepAnalysis = HKObjectType.categoryType(forIdentifier: HKCategoryTypeIdentifier.sleepAnalysis),
            let bloodPressureSystolic = HKObjectType.quantityType(forIdentifier: .bloodPressureSystolic),
            let bloodPressureDiastolic = HKObjectType.quantityType(forIdentifier: .bloodPressureDiastolic),
            let heartRate = HKQuantityType.quantityType(forIdentifier: .heartRate),
            let restingHeartRate = HKQuantityType.quantityType(forIdentifier: .restingHeartRate),
            let walkingHeartRateAverage = HKQuantityType.quantityType(forIdentifier: .walkingHeartRateAverage) else {
            completion(false, HealthkitSetupError.dataTypeNotAvailable)
            return
        }

        let activitySummaryType = HKActivitySummaryType.activitySummaryType()
        
        let healthKitTypesToWrite: Set<HKSampleType> = [bodyMass, sleepAnalysis, bloodPressureSystolic, bloodPressureDiastolic]

        let healthKitTypesToRead: Set<HKObjectType> = [dateOfBirth, height, bodyMass, stepCount, enerbyBurned, exerciseTime, standHour, activitySummaryType, sleepAnalysis, bloodPressureSystolic, bloodPressureDiastolic, heartRate, restingHeartRate, walkingHeartRateAverage, HKObjectType.electrocardiogramType()]
        
        healthStore.requestAuthorization(toShare: healthKitTypesToWrite, read: healthKitTypesToRead) { (success, error) in
            completion(success, error)
        }
    }
    
    func getActivitySummary(completion: @escaping ([(Date, Double)]?, [(Date, Double)]?, [(Date, Double)]?, Error?) -> Swift.Void) {
        let calendar = Calendar.current
        
        let now = Date()
        var interval = DateComponents()
        interval.hour = 1
        
        // Set the anchor date to start of today
        let anchorDate = calendar.startOfDay(for: now)
        
        var dateComponents = calendar.dateComponents([.day, .month, .year, .weekday], from: anchorDate)
        
        // Set the start date to first day of the year
        dateComponents.month = 1
        dateComponents.day = 1
        
        guard let startDate = calendar.date(from: dateComponents) else {
            return completion(nil, nil, nil, HealthkitSetupError.dateCalculationerror)
        }
        
        // Set the end date to first day of the next year
        dateComponents.year! += 1
        guard let endDate = calendar.date(from: dateComponents) else {
            return completion(nil, nil, nil, HealthkitSetupError.dateCalculationerror)
        }
        
        guard
            let quantityTypeEnergyBurned = HKObjectType.quantityType(forIdentifier: .activeEnergyBurned),
            let quantityTypeExerciseTime = HKObjectType.quantityType(forIdentifier: .appleExerciseTime),
            let categoryTypeStandHour = HKObjectType.categoryType(forIdentifier: .appleStandHour) else {
            return completion(nil, nil, nil, HealthkitSetupError.dataTypeNotAvailable)
        }
        
        var moveData = [(Date, Double)]()
        var exerciseData = [(Date, Double)]()
        var standData = [(Date, Double)]()
        
        // Create the predicate
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)
        
        let group = DispatchGroup()
        
        // Create the EnerbyBurned query
        var query = HKStatisticsCollectionQuery(quantityType: quantityTypeEnergyBurned, quantitySamplePredicate: predicate, options: .cumulativeSum, anchorDate: anchorDate, intervalComponents: interval)
        
        // Set the results handler
        query.initialResultsHandler = {
            query, results, error in
            
            guard let statsCollection = results else {
                return group.leave()
            }
            
            // Plot the weekly step counts over the past 3 months
            statsCollection.enumerateStatistics(from: startDate, to: endDate) { statistics, stop in
                if let quantity = statistics.sumQuantity() {
                    let date = statistics.startDate
                    let value = quantity.doubleValue(for: HKUnit.kilocalorie())
                    
                    moveData.append((date, value))
                }
            }

            group.leave()
        }
        
        group.enter()
        healthStore.execute(query)
        
        // Create the ExerciseTime query
        query = HKStatisticsCollectionQuery(quantityType: quantityTypeExerciseTime, quantitySamplePredicate: predicate, options: .cumulativeSum, anchorDate: anchorDate, intervalComponents: interval)
        
        // Set the results handler
        query.initialResultsHandler = {
            query, results, error in
            
            guard let statsCollection = results else {
                return group.leave()
            }
            
            // Plot the weekly step counts over the past 3 months
            statsCollection.enumerateStatistics(from: startDate, to: endDate) { statistics, stop in
                if let quantity = statistics.sumQuantity() {
                    let date = statistics.startDate
                    let value = quantity.doubleValue(for: HKUnit.minute())
                    
                    exerciseData.append((date, value))
                }
            }

            group.leave()
        }
        
        group.enter()
        healthStore.execute(query)
        
        
        // Get the recent data first
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: true)
        
        // Create the query
        let standQuery = HKSampleQuery(sampleType: categoryTypeStandHour, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: [sortDescriptor]) { (query, tmpResult, error) -> Void in
        
            guard let result = tmpResult else {
                return group.leave()
            }
            
            if error != nil {
                return group.leave()
            }
                
            for item in result {
                if let sample = item as? HKCategorySample {
                    standData.append((sample.startDate, sample.value == 0 ? 1 : 0))
                }
            }
            
            group.leave()
        }
        
        group.enter()
        healthStore.execute(standQuery)

        // notify the main thread when all task are completed
        group.notify(queue: .main) {
            print("All Tasks are done")
            completion(moveData, exerciseData, standData, nil)
        }
    }
    
    func getBodyWeightData(completion: @escaping ([(Date, Double)]?, Error?) -> Swift.Void) {
        let calendar = Calendar.current
        
        let now = Date()
        var interval = DateComponents()
        interval.hour = 1
        
        // Set the anchor date to start of today
        let anchorDate = calendar.startOfDay(for: now)
        
        var dateComponents = calendar.dateComponents([.day, .month, .year, .weekday], from: anchorDate)
        
        // Set the start date to first day of the year
        dateComponents.month = 1
        dateComponents.day = 1
        
        guard let startDate = calendar.date(from: dateComponents) else {
            return completion(nil, HealthkitSetupError.dateCalculationerror)
        }
        
        // Set the end date to first day of the next year
        dateComponents.year! += 1
        guard let endDate = calendar.date(from: dateComponents) else {
            return completion(nil, HealthkitSetupError.dateCalculationerror)
        }
        
        guard let quantityType = HKObjectType.quantityType(forIdentifier: .bodyMass) else {
            return completion(nil, HealthkitSetupError.dataTypeNotAvailable)
        }
        
        // Create the predicate
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)
        
        // Create the query
        let query = HKStatisticsCollectionQuery(quantityType: quantityType, quantitySamplePredicate: predicate, options: .discreteAverage, anchorDate: anchorDate, intervalComponents: interval)
        
        // Set the results handler
        query.initialResultsHandler = {
            query, results, error in
            
            guard let statsCollection = results else {
                return completion(nil, error)
            }

            var satisticsData = [(Date, Double)]()
            
            // Plot the weekly step counts over the past 3 months
            statsCollection.enumerateStatistics(from: startDate, to: endDate) { statistics, stop in
                
                if let quantity = statistics.averageQuantity() {
                    let date = statistics.startDate
                    let value = quantity.doubleValue(for: HKUnit.pound())
                    
                    satisticsData.append((date, value))
                }
            }

            completion(satisticsData, error)
        }
        healthStore.execute(query)
    }
    
    func saveBodyWeight(weight: Double, forDate : Date, completion: @escaping (Bool, Error?) -> Swift.Void) {
        let quantityType = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.bodyMass)!
        
        let authorizationStatus = healthStore.authorizationStatus(for: quantityType)

        switch authorizationStatus {
        case .sharingAuthorized:
            break
        case .sharingDenied:
            print("sharing denied")
            return completion(false, HealthkitSetupError.dataTypeNotAvailable)
        default:
            print("not determined")
            return completion(false, HealthkitSetupError.dataTypeNotAvailable)
        }

        let sample = HKQuantitySample (type: quantityType, quantity: HKQuantity.init(unit: HKUnit.pound(), doubleValue: weight), start: forDate, end: forDate)
        
        healthStore.save(sample) { success, error in
            completion(success, error)
        }
    }
    
    func getDayStepCounts(completion: @escaping ([(Date, Double)]?, Error?) -> Swift.Void) {
        let calendar = Calendar.current
        
        let now = Date()
        var interval = DateComponents()
        interval.hour = 1
        
        // Set the anchor date to start of today
        let anchorDate = calendar.startOfDay(for: now)
        
        guard let startDate = calendar.date(byAdding: .day, value: 1, to: anchorDate) else {
            return completion(nil, HealthkitSetupError.dateCalculationerror)
        }
        
        guard let endDate = calendar.date(byAdding: .day, value: -6, to: anchorDate) else {
            return completion(nil, HealthkitSetupError.dateCalculationerror)
        }
        
        guard let quantityType = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.stepCount) else {
            return completion(nil, HealthkitSetupError.dataTypeNotAvailable)
        }
        
        // Create the predicate
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)
        
        // Create the query
        let query = HKStatisticsCollectionQuery(quantityType: quantityType, quantitySamplePredicate: predicate, options: .cumulativeSum, anchorDate: anchorDate, intervalComponents: interval)
        
        // Set the results handler
        query.initialResultsHandler = {
            query, results, error in
            
            guard let statsCollection = results else {
                return completion(nil, error)
            }

            var satisticsData = [(Date, Double)]()
            
            // Plot the weekly step counts over the past 3 months
            statsCollection.enumerateStatistics(from: anchorDate, to: now) { statistics, stop in
                
                if let quantity = statistics.sumQuantity() {
                    let date = statistics.startDate
                    let value = quantity.doubleValue(for: HKUnit.count())
                    
                    satisticsData.append((date, value))
                } else {
                    satisticsData.append((statistics.startDate, 0))
                }
            }
            
            completion(satisticsData, nil)
        }
        
        healthStore.execute(query)
    }
    
    func getMonthStepCounts(completion: @escaping ([(Date, Double)]?, Error?) -> Swift.Void) {
        let calendar = Calendar.current
        
        let now = Date()
        var interval = DateComponents()
        interval.day = 1
        
        guard let endDate = calendar.date(byAdding: .day, value: 3, to: now) else {
            return completion(nil, HealthkitSetupError.dateCalculationerror)
        }
        
        // Set the anchor date to one month ago
        var anchorComponents = calendar.dateComponents([.day, .month, .year, .weekday], from: endDate)
        
        anchorComponents.month! -= 3
        anchorComponents.hour = 0
        
        guard let startDate = calendar.date(from: anchorComponents) else {
            return completion(nil, HealthkitSetupError.dateCalculationerror)
        }
        
        guard let quantityType = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.stepCount) else {
            return completion(nil, HealthkitSetupError.dataTypeNotAvailable)
        }
        
        // Create the predicate
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)
        
        // Create the query
        let query = HKStatisticsCollectionQuery(quantityType: quantityType, quantitySamplePredicate: predicate, options: .cumulativeSum, anchorDate: startDate, intervalComponents: interval)
        
        // Set the results handler
        query.initialResultsHandler = {
            query, results, error in
            
            guard let statsCollection = results else {
                return completion(nil, error)
            }

            var satisticsData = [(Date, Double)]()
            
            // Plot the weekly step counts over the past 3 months
            statsCollection.enumerateStatistics(from: startDate, to: endDate) { statistics, stop in
                
                if let quantity = statistics.sumQuantity() {
                    let date = statistics.startDate
                    let value = quantity.doubleValue(for: HKUnit.count())
                    
                    satisticsData.append((date, value))
                } else {
                    satisticsData.append((statistics.startDate, 0))
                }
            }
            
            completion(satisticsData, nil)
        }
        
        healthStore.execute(query)
    }
    
    func getStepCounts(completion: @escaping ([(Date, Double)]?, Error?) -> Swift.Void) {
        let calendar = Calendar.current
        
        let now = Date()
        var interval = DateComponents()
        interval.minute = 10
        
        // Set the anchor date to start of today
        let anchorDate = calendar.startOfDay(for: now)
        
        var dateComponents = calendar.dateComponents([.day, .month, .year, .weekday], from: anchorDate)
        
        // Set the start date to first day of the year
        dateComponents.month = 1
        dateComponents.day = 1
        
        guard let startDate = calendar.date(from: dateComponents) else {
            return completion(nil, HealthkitSetupError.dateCalculationerror)
        }
        
        // Set the end date to first day of the next year
        dateComponents.year! += 1
        guard let endDate = calendar.date(from: dateComponents) else {
            return completion(nil, HealthkitSetupError.dateCalculationerror)
        }
        
        guard let quantityType = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.stepCount) else {
            return completion(nil, HealthkitSetupError.dataTypeNotAvailable)
        }
        
        // Create the predicate
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)
        
        // Create the query
        let query = HKStatisticsCollectionQuery(quantityType: quantityType, quantitySamplePredicate: predicate, options: .cumulativeSum, anchorDate: anchorDate, intervalComponents: interval)
        
        // Set the results handler
        query.initialResultsHandler = {
            query, results, error in
            
            guard let statsCollection = results else {
                return completion(nil, error)
            }

            var satisticsData = [(Date, Double)]()
            
            // Plot the weekly step counts over the past 3 months
            statsCollection.enumerateStatistics(from: startDate, to: endDate) { statistics, stop in
                
                if let quantity = statistics.sumQuantity() {
                    let date = statistics.startDate
                    let value = quantity.doubleValue(for: HKUnit.count())
                    
                    satisticsData.append((date, value))
                }
            }
            
            completion(satisticsData, nil)
        }
        
        healthStore.execute(query)
    }
    
    func getSleepAnalysis(completion: @escaping ([(String, Date, Date, Int)]?, Error?) -> Swift.Void) {
        let calendar = Calendar.current
        
        let now = Date()
        var interval = DateComponents()
        interval.hour = 1
        
        // Set the anchor date to start of today
        let anchorDate = calendar.startOfDay(for: now)
        
        var dateComponents = calendar.dateComponents([.day, .month, .year, .weekday], from: anchorDate)
        
        // Set the start date to first day of the year
        dateComponents.month = 1
        dateComponents.day = 1
        
        guard let startDate = calendar.date(from: dateComponents) else {
            return completion(nil, HealthkitSetupError.dateCalculationerror)
        }
        
        // Set the end date to first day of the next year
        dateComponents.year! += 1
        guard let endDate = calendar.date(from: dateComponents) else {
            return completion(nil, HealthkitSetupError.dateCalculationerror)
        }
        
        guard let categoryType = HKObjectType.categoryType(forIdentifier: HKCategoryTypeIdentifier.sleepAnalysis) else {
            return completion(nil, HealthkitSetupError.dataTypeNotAvailable)
        }
        
        // Create the predicate
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)
        
        // Get the recent data first
        
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: true)
        
        // Create the query
        let query = HKSampleQuery(sampleType: categoryType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: [sortDescriptor]) { (query, tmpResult, error) -> Void in
        
            guard let result = tmpResult else {
                return completion(nil, error)
            }
            
            if error != nil {
                return completion(nil, error)
            }

            var sleepData = [(String, Date, Date, Int)]()
            
            for item in result {
                if let sample = item as? HKCategorySample {
                    sleepData.append((sample.uuid.uuidString, sample.startDate, sample.endDate, sample.value))
                }
            }
            
            completion(sleepData, nil)
        }
        
        
        healthStore.execute(query)
    }
    
    func saveSleepData(startDate: Date, endDate : Date, isAsleep: Bool, completion: @escaping ((String, Date, Date, Int)?, Error?) -> Swift.Void) {
        let quantityType = HKObjectType.categoryType(forIdentifier: HKCategoryTypeIdentifier.sleepAnalysis)!
        
        let authorizationStatus = healthStore.authorizationStatus(for: quantityType)

        switch authorizationStatus {
        case .sharingAuthorized:
            break
        case .sharingDenied:
            print("sharing denied")
            return completion(nil, HealthkitSetupError.dataTypeNotAvailable)
        default:
            print("not determined")
            return completion(nil, HealthkitSetupError.dataTypeNotAvailable)
        }
        
        let sample = HKCategorySample(type: quantityType, value: isAsleep ? HKCategoryValueSleepAnalysis.asleep.rawValue : HKCategoryValueSleepAnalysis.inBed.rawValue, start: startDate, end: endDate)
        
        healthStore.save(sample) { success, error in
            completion((sample.uuid.uuidString, startDate, endDate, sample.value), error)
        }
    }
    
    func deleteSleep(_ uuid: String, completion: @escaping (Bool, Error?) -> Swift.Void) {
        guard let quantityType = HKObjectType.categoryType(forIdentifier: HKCategoryTypeIdentifier.sleepAnalysis) else {
            return completion(false, HealthkitSetupError.dataTypeNotAvailable)
        }
        
        let authorizationStatus = healthStore.authorizationStatus(for: quantityType)

        switch authorizationStatus {
        case .sharingAuthorized:
            break
        case .sharingDenied:
            print("sharing denied")
            return completion(false, HealthkitSetupError.dataTypeNotAvailable)
        default:
            print("not determined")
            return completion(false, HealthkitSetupError.dataTypeNotAvailable)
        }
        
        // Create the predicate
        let predicate = HKQuery.predicateForObject(with: UUID(uuidString: uuid)!)
        
        // Create the query
        let sysQuery = HKSampleQuery(sampleType: quantityType, predicate: predicate, limit: 1, sortDescriptors: nil) { (query, tmpResult, error) -> Void in
        
            guard let sample = tmpResult?.first else {
                return completion(false, error)
            }
            
            if error != nil {
                return completion(false, error)
            }
            
            self.healthStore.delete(sample, withCompletion: { (success, error) in
                completion(success, error)
            })
        }
        
        healthStore.execute(sysQuery)
    }
    
    func getBloodAlcoholContent(completion: @escaping ([(Date, Double)]?, Error?) -> Swift.Void) {
        let calendar = Calendar.current
        
        let now = Date()
        var interval = DateComponents()
        interval.hour = 1
        
        // Set the anchor date to start of today
        let anchorDate = calendar.startOfDay(for: now)
        
        var dateComponents = calendar.dateComponents([.day, .month, .year, .weekday], from: anchorDate)
        
        // Set the start date to first day of the year
        dateComponents.month = 1
        dateComponents.day = 1
        
        guard let startDate = calendar.date(from: dateComponents) else {
            return completion(nil, HealthkitSetupError.dateCalculationerror)
        }
        
        // Set the end date to first day of the next year
        dateComponents.year! += 1
        guard let endDate = calendar.date(from: dateComponents) else {
            return completion(nil, HealthkitSetupError.dateCalculationerror)
        }
        
        guard let quantityType = HKObjectType.quantityType(forIdentifier: .bloodAlcoholContent) else {
            return completion(nil, HealthkitSetupError.dataTypeNotAvailable)
        }
        
        // Create the predicate
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)
        
        // Create the query
        let query = HKStatisticsCollectionQuery(quantityType: quantityType, quantitySamplePredicate: predicate, options: .discreteAverage, anchorDate: anchorDate, intervalComponents: interval)
        
        // Set the results handler
        query.initialResultsHandler = {
            query, results, error in
            
            guard let statsCollection = results else {
                return completion(nil, error)
            }

            var satisticsData = [(Date, Double)]()
            
            // Plot the weekly step counts over the past 3 months
            statsCollection.enumerateStatistics(from: startDate, to: endDate) { statistics, stop in
                
                if let quantity = statistics.averageQuantity() {
                    let date = statistics.startDate
                    let value = quantity.doubleValue(for: HKUnit.percent()) * 100
                    
                    satisticsData.append((date, value))
                }
            }

            completion(satisticsData, error)
        }
        healthStore.execute(query)
    }
    
    func saveBloodAlcoholContent(alcohol: Double, forDate : Date, completion: @escaping (Bool, Error?) -> Swift.Void) {
        let quantityType = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.bloodAlcoholContent)!
        
        let authorizationStatus = healthStore.authorizationStatus(for: quantityType)

        switch authorizationStatus {
        case .sharingAuthorized:
            break
        case .sharingDenied:
            print("sharing denied")
            return completion(false, HealthkitSetupError.dataTypeNotAvailable)
        default:
            print("not determined")
            return completion(false, HealthkitSetupError.dataTypeNotAvailable)
        }

        let sample = HKQuantitySample (type: quantityType, quantity: HKQuantity.init(unit: HKUnit.percent(), doubleValue: alcohol / 100), start: forDate, end: forDate)
        
        healthStore.save(sample) { success, error in
            completion(success, error)
        }
    }
    
    func getBloodPressure(completion: @escaping ([(Date, String, Double, String, Double)]?, Error?) -> Swift.Void) {
        let calendar = Calendar.current
        
        let now = Date()
        var interval = DateComponents()
        interval.hour = 1
        
        // Set the anchor date to start of today
        let anchorDate = calendar.startOfDay(for: now)
        
        var dateComponents = calendar.dateComponents([.day, .month, .year, .weekday], from: anchorDate)
        
        // Set the start date to first day of the year
        dateComponents.month = 1
        dateComponents.day = 1
        
        guard let startDate = calendar.date(from: dateComponents) else {
            return completion(nil, HealthkitSetupError.dateCalculationerror)
        }
        
        // Set the end date to first day of the next year
        dateComponents.year! += 1
        guard let endDate = calendar.date(from: dateComponents) else {
            return completion(nil, HealthkitSetupError.dateCalculationerror)
        }
        
        guard let correlationType = HKQuantityType.correlationType(forIdentifier: HKCorrelationTypeIdentifier.bloodPressure),
            let systolicType = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.bloodPressureSystolic),
            let diastolicType = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.bloodPressureDiastolic) else {
            return completion(nil, HealthkitSetupError.dataTypeNotAvailable)
        }
        
        // Create the predicate
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)
        
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: true)
        
        // Create the query
        let query = HKSampleQuery(sampleType: correlationType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: [sortDescriptor]) { (query, tmpResult, error) -> Void in
        
            guard let result = tmpResult else {
                return completion(nil, error)
            }
            
            if error != nil {
                return completion(nil, error)
            }

            var booldPressureData = [(Date, String, Double, String, Double)]()
            
            for item in result {
                if let sample = item as? HKCorrelation {

                    if let systolic = sample.objects(for: systolicType).first as? HKQuantitySample,
                        let diastolic = sample.objects(for: diastolicType).first as? HKQuantitySample {

                        booldPressureData.append((sample.startDate, systolic.uuid.uuidString, systolic.quantity.doubleValue(for: HKUnit.millimeterOfMercury()), diastolic.uuid.uuidString, diastolic.quantity.doubleValue(for: HKUnit.millimeterOfMercury())))
                    }
                }
            }
            
            completion(booldPressureData, nil)
        }
        
        healthStore.execute(query)
    }
    
    func saveBloodPressure(systolic: Double, diastolic: Double, forDate : Date, completion: @escaping ((Date, String, Double, String, Double)?, Error?) -> Swift.Void) {
        guard let bpCorrelationType = HKQuantityType.correlationType(forIdentifier: HKCorrelationTypeIdentifier.bloodPressure),
            let systolicType = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.bloodPressureSystolic),
            let diastolicType = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.bloodPressureDiastolic) else {
            return completion(nil, HealthkitSetupError.dataTypeNotAvailable)
        }
        
        let systolicAuthorizationStatus = healthStore.authorizationStatus(for: systolicType)

        switch systolicAuthorizationStatus {
        case .sharingAuthorized:
            break
        case .sharingDenied:
            print("sharing denied")
            return completion(nil, HealthkitSetupError.dataTypeNotAvailable)
        default:
            print("not determined")
            return completion(nil, HealthkitSetupError.dataTypeNotAvailable)
        }
        
        let diastolicAuthorizationStatus = healthStore.authorizationStatus(for: diastolicType)

        switch diastolicAuthorizationStatus {
        case .sharingAuthorized:
            break
        case .sharingDenied:
            print("sharing denied")
            return completion(nil, HealthkitSetupError.dataTypeNotAvailable)
        default:
            print("not determined")
            return completion(nil, HealthkitSetupError.dataTypeNotAvailable)
        }
        
        
        let unit = HKUnit.millimeterOfMercury()
        
        let systolicSample = HKQuantitySample(type: systolicType, quantity: HKQuantity.init(unit: unit, doubleValue: systolic), start: forDate, end: forDate)
        let diastolicSample = HKQuantitySample(type: diastolicType, quantity: HKQuantity.init(unit: unit, doubleValue: diastolic), start: forDate, end: forDate)
        let bloodPressureSample = HKCorrelation(type: bpCorrelationType, start: forDate, end: forDate, objects: Set<HKSample>(arrayLiteral: systolicSample, diastolicSample))
        
        healthStore.save(bloodPressureSample) { success, error in
            completion((forDate, systolicSample.uuid.uuidString, systolic, diastolicSample.uuid.uuidString, diastolic), error)
        }
    }
    
    func deleteBloodPressure(sysUUID: String, diaUUID: String, completion: @escaping (Bool, Error?) -> Swift.Void) {
        guard let systolicType = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.bloodPressureSystolic),
            let diastolicType = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.bloodPressureDiastolic) else {
            return completion(false, HealthkitSetupError.dataTypeNotAvailable)
        }
        
        let systolicAuthorizationStatus = healthStore.authorizationStatus(for: systolicType)

        switch systolicAuthorizationStatus {
        case .sharingAuthorized:
            break
        case .sharingDenied:
            print("sharing denied")
            return completion(false, HealthkitSetupError.dataTypeNotAvailable)
        default:
            print("not determined")
            return completion(false, HealthkitSetupError.dataTypeNotAvailable)
        }
        
        let diastolicAuthorizationStatus = healthStore.authorizationStatus(for: diastolicType)

        switch diastolicAuthorizationStatus {
        case .sharingAuthorized:
            break
        case .sharingDenied:
            print("sharing denied")
            return completion(false, HealthkitSetupError.dataTypeNotAvailable)
        default:
            print("not determined")
            return completion(false, HealthkitSetupError.dataTypeNotAvailable)
        }
        
        
        let group = DispatchGroup()
        var onDeletingError: Error? = nil
        
        // Create the predicate
        let sysPredicate = HKQuery.predicateForObject(with: UUID(uuidString: sysUUID)!)
        var systolicDeleted = false
        
        // Create the query
        let sysQuery = HKSampleQuery(sampleType: systolicType, predicate: sysPredicate, limit: 1, sortDescriptors: nil) { (query, tmpResult, error) -> Void in
            group.leave()
        
            guard let sample = tmpResult?.first else {
                return
            }
            
            if error != nil {
                onDeletingError = error
                return
            }
            
            self.healthStore.delete(sample, withCompletion: { (success, error) in
                systolicDeleted = success
            })
        }
        
        group.enter()
        healthStore.execute(sysQuery)
        
        // Create the predicate
        let diaPredicate = HKQuery.predicateForObject(with: UUID(uuidString: diaUUID)!)
        var diastolicDeleted = false
        
        // Create the query
        let diaQuery = HKSampleQuery(sampleType: diastolicType, predicate: diaPredicate, limit: 1, sortDescriptors: nil) { (query, tmpResult, error) -> Void in
            group.leave()
        
            guard let sample = tmpResult?.first else {
                return
            }
            
            if error != nil {
                onDeletingError = error
                return
            }
            
            self.healthStore.delete(sample, withCompletion: { (success, error) in
                diastolicDeleted = success
            })
        }
        
        group.enter()
        healthStore.execute(diaQuery)

        // notify the main thread when all task are completed
        group.notify(queue: .main) {
            completion(systolicDeleted && diastolicDeleted, onDeletingError)
        }
    }

    func getHeartRates(completion: @escaping ([HeartRate]?, Error?) -> Swift.Void) {
        if m_bProcessingHR {
            completion(nil, nil)
            return
        }
        self.m_bProcessingHR = true
        
        guard let quantityType = HKObjectType.quantityType(forIdentifier: .heartRate) else {
            return completion(nil, HealthkitSetupError.dataTypeNotAvailable)
        }
        
        // Create the query
                        
        let query = HKSampleQuery(sampleType: quantityType, predicate: nil, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { (query, samples, error) in
            if let error = error {
                completion(nil, error)
                return
            }
            let heartRateUnit:HKUnit = HKUnit(from: "count/min")
            var satisticsData = [HeartRate]()
            let df = DateFormatter()
            df.dateFormat = "yyyy-MM-dd HH"
            var prevDate = ""
            var min:HeartRate?
            var max:HeartRate?
            
            for sample in samples! {
                let item = (sample as! HKQuantitySample)
                let hr = HeartRate()
                hr.date = item.endDate
                hr.heart_rate = item.quantity.doubleValue(for: heartRateUnit)
//                satisticsData.append(hr)
                if df.string(from: item.endDate) != prevDate {
                    if min != nil {
                        if min?.heart_rate == max?.heart_rate {
                            satisticsData.append(min!)
                        } else {
                            satisticsData.append(min!)
                            satisticsData.append(max!)
                        }
                    }
                    prevDate = df.string(from: item.endDate)
                    min = HeartRate()
                    min!.heart_rate = 10000
                    max = HeartRate()
                    max!.heart_rate = 0
                }
                if hr.heart_rate < min!.heart_rate {
                    min = hr
                }
                if hr.heart_rate > max!.heart_rate {
                    max = hr
                }
            }
            
            if min != nil {
                if min?.heart_rate == max?.heart_rate {
                    satisticsData.append(min!)
                } else {
                    satisticsData.append(min!)
                    satisticsData.append(max!)
                }
            }
            self.m_bProcessingHR = false
            completion(satisticsData, nil)
        }
                
        healthStore.execute(query)
    }

    @available(iOS 14.0, *)
    func getECG(completion: @escaping ([Ecg]?, Error?) -> Swift.Void) {
        let ecgType = HKObjectType.electrocardiogramType()
        let ecgQuery = HKSampleQuery(sampleType: ecgType,
                                     predicate: nil,
                                     limit: HKObjectQueryNoLimit,
                                     sortDescriptors: nil) { (query, samples, error) in
            
            if let error = error {
                completion(nil, error)
                return
            }
            
            guard let ecgSamples = samples as? [HKElectrocardiogram] else {                
                print("*** Unable to convert \(String(describing: samples)) to [HKElectrocardiogram] ***")
                return
            }
            var ecgs = [Ecg]()
            for sample in ecgSamples {
                // exclude low and high inconclusive data per Dr. Maria
                if sample.classification != .inconclusiveLowHeartRate &&
                    sample.classification != .inconclusiveHighHeartRate {
                    let ecg = Ecg()
                    if let val = sample.averageHeartRate {
                        ecg.avgHeartRate = val.doubleValue(for: HKUnit(from: "count/min"))
                    }
                    ecg.date = sample.endDate
                    ecg.type = sample.classification.rawValue
                    ecgs.append(ecg)
                }
            }
            completion(ecgs, nil)
        }
        self.healthStore.execute(ecgQuery)
    }
    
    @available(iOS 14.0, *)
    func getECGDetail(startDate:Date, endDate:Date, completion: @escaping ([Ecg]?, Error?) -> Swift.Void) {
        let ecgType = HKObjectType.electrocardiogramType()
        let predicateByStartEndDate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: [])
        let ecgQuery = HKSampleQuery(sampleType: ecgType,
                                     predicate: predicateByStartEndDate,
                                     limit: HKObjectQueryNoLimit,
                                     sortDescriptors: nil) { [self] (query, samples, error) in
            
            if let error = error {
                completion(nil, error)
                return
            }
            
            guard let ecgSamples = samples as? [HKElectrocardiogram] else {
                print("*** Unable to convert \(String(describing: samples)) to [HKElectrocardiogram] ***")
                return
            }
            var ecgs = [Ecg]()
            let group = DispatchGroup()
            for sample in ecgSamples {
                let ecg = Ecg()
                if let val = sample.averageHeartRate {
                    ecg.avgHeartRate = val.doubleValue(for: HKUnit(from: "count/min"))
                }
                ecg.date = sample.endDate
                ecg.type = sample.classification.rawValue
                ecgs.append(ecg)
                
                group.enter()
                let query = HKElectrocardiogramQuery(sample) { (query, result) in
                    switch result {
                    case .error(let error):
                        print("error: ", error)
                        break
                    case .measurement(let value):
                        let ecgitem = EcgItem()
                        if let val = value.quantity(for: .appleWatchSimilarToLeadI) {
                            ecgitem.value = val.doubleValue(for: HKUnit(from: "mcV"))
                        }
                        
                        ecgitem.time = value.timeSinceSampleStart
                        ecg.voltages.append(ecgitem)
                    case .done:
                        group.leave()
                        break
                    default:
                        break
                    }
                }
                healthStore.execute(query)
            }
            group.notify(queue: .main) {
                completion(ecgs, nil)
            }
        }
        self.healthStore.execute(ecgQuery)
    }
}
