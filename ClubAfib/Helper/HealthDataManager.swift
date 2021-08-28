//
//  HealthDataManager.swift
//  ClubAfib
//
//  Created by Rener on 8/19/20.
//  Copyright © 2020 ETU. All rights reserved.
//

import UIKit
import RealmSwift
import Alamofire

class HealthDataManager {
    
    static var `default` : HealthDataManager = {
        var instance = HealthDataManager()
        return instance
    }()

    var heartRateData: [HeartRate]
    var energyBurnedData: Set<EnergyBurn>
    var exerciseData: Set<Exercise>
    var standData: Set<Stand>
    var weightData: Set<Weight>
    var stepsData = Set<Steps>()
    var sleepData = Set<Sleep>()
    var alcoholUseData: Set<AlcoholUse>
    var bloodPressureData: Set<BloodPressure>
    var ecgData: [Ecg]
    var mutex = DispatchGroup()
    init() {
        self.heartRateData = HeartRate.get()
        self.energyBurnedData = Set(EnergyBurn.getEnergyBurned()).filter({ $0.status < 2 })
        self.exerciseData = Set(Exercise.getExercises()).filter({ $0.status < 2 })
        self.standData = Set(Stand.getStands()).filter({ $0.status < 2 })
        self.weightData = Set(Weight.getWeights()).filter({ $0.status < 2 })
        self.stepsData = Set(Steps.getSteps()).filter({ $0.status < 2 })
        self.sleepData = Set(Sleep.getSleeps()).filter({ $0.status < 2 })
        self.alcoholUseData = Set(AlcoholUse.getAlcoholUses()).filter({ $0.status < 2 })
        self.bloodPressureData = Set(BloodPressure.getBloodPressures()).filter({ $0.status < 2 })
        self.ecgData = Ecg.get()
    }
    
    public func fetchData() {
        // fetch all data from API
        var lastAt = "1970-01-01 00:00:00"
        if let lastItem = self.heartRateData.last {
            lastAt = lastItem.dateTxt
        }
        self.mutex.enter()
        ApiManager.sharedInstance.getHeartRateData(lastAt) { (heartRates, errorMsg) in
            if let heartRates = heartRates {
                HeartRate.append(heartRates)
            }
            else {
                print("error on getting heart rate data: \(errorMsg ?? "")")
            }
            self.mutex.leave()
        }
        self.mutex.enter()
        ApiManager.sharedInstance.getEnergyBurnedData() { (energyBurned, errorMsg) in
            if let energyBurned = energyBurned {
                EnergyBurn.setEnergyBurned(energyBurned)
            }
            else {
                print("error on getting energy burned data: \(errorMsg ?? "")")
            }
            self.mutex.leave()
        }
        self.mutex.enter()
        ApiManager.sharedInstance.getExerciseData() { (exercises, errorMsg) in
            if let exercises = exercises {
                Exercise.setExercises(exercises)
            }
            else {
                print("error on getting exercise data: \(errorMsg ?? "")")
            }
            self.mutex.leave()
        }
        self.mutex.enter()
        ApiManager.sharedInstance.getStandData() { (stands, errorMsg) in
            if let stands = stands {
                Stand.setStands(stands)
            }
            else {
                print("error on getting stand data: \(errorMsg ?? "")")
            }
            self.mutex.leave()
        }
        self.mutex.enter()
        ApiManager.sharedInstance.getWeightData() { (weights, errorMsg) in
            if let weights = weights {
                Weight.setWeights(weights)
            }
            else {
                print("error on getting weight data: \(errorMsg ?? "")")
            }
            self.mutex.leave()
        }
        self.mutex.enter()
        ApiManager.sharedInstance.getStepsData() { (steps, errorMsg) in
            if let steps = steps {
                Steps.setSteps(steps)
            }
            else {
                print("error on getting steps data: \(errorMsg ?? "")")
            }
            self.mutex.leave()
        }
        
        lastAt = "1970-01-01 00:00:00"
        if let lastItem = self.ecgData.last {
            lastAt = lastItem.dateTxt
        }
        self.mutex.enter()
        ApiManager.sharedInstance.getECGData(lastAt) { (ecg, errorMsg) in
            if let ecg = ecg {
                Ecg.append(ecg)
            }
            else {
                print("error on getting steps data: \(errorMsg ?? "")")
            }
            self.mutex.leave()
        }
                
        self.mutex.enter()
        ApiManager.sharedInstance.getSleepData() { (sleeps, errorMsg) in
            if let sleeps = sleeps {
                Sleep.setSleeps(sleeps)
            }
            else {
                print("error on getting sleep data: \(errorMsg ?? "")")
            }
            self.mutex.leave()
        }
        self.mutex.enter()
        ApiManager.sharedInstance.getAlcoholUseData() { (alcoholUses, errorMsg) in
            if let alcoholUses = alcoholUses {
                AlcoholUse.setAlcoholUses(alcoholUses)
            }
            else {
                print("error on getting alcohol used data: \(errorMsg ?? "")")
            }
            self.mutex.leave()
        }
        self.mutex.enter()
        ApiManager.sharedInstance.getBloodPressureData() { (bloodPressures, errorMsg) in
            if let bloodPressures = bloodPressures {
                BloodPressure.setBloodPressures(bloodPressures)
            }
            else {
                print("error on getting blood pressure data: \(errorMsg ?? "")")
            }
            self.mutex.leave()
        }
        self.mutex.notify(queue: .main) {
            self.heartRateData = HeartRate.get()
            self.energyBurnedData = Set(EnergyBurn.getEnergyBurned()).filter({ $0.status < 2 })
            self.exerciseData = Set(Exercise.getExercises()).filter({ $0.status < 2 })
            self.standData = Set(Stand.getStands()).filter({ $0.status < 2 })
            self.weightData = Set(Weight.getWeights()).filter({ $0.status < 2 })
            self.stepsData = Set(Steps.getSteps()).filter({ $0.status < 2 })
            self.sleepData = Set(Sleep.getSleeps()).filter({ $0.status < 2 })
            self.alcoholUseData = Set(AlcoholUse.getAlcoholUses()).filter({ $0.status < 2 })
            self.bloodPressureData = Set(BloodPressure.getBloodPressures()).filter({ $0.status < 2 })
            self.ecgData = Ecg.get()
            NotificationCenter.default.post(name: Notification.Name(USER_NOTIFICATION_FECTED_DATA), object: nil)
            self.getDeviceData()
        }
    }
    
    func getHeartRatesFromDevice() {
        HealthKitHelper.default.getHeartRates() {(satistics, error) in
            
            if (error != nil) {
                print(error!)
            }
            guard let dataset = satistics else {
                print("can't get heart rate data")
                return
            }
            self.syncHeartRateData(dataset)
        }
    }
    
    func getActivitySummaryFromDevice() {
        
        HealthKitHelper.default.getActivitySummary() {(energyBurnedData, exerciseData, standData, error) in
            
            if (error != nil) {
                print(error!)
            }
            
            guard
                let energyBurnedData = energyBurnedData,
                let exerciseData = exerciseData,
                let standData = standData else {
                print("can't get activity summary data")
                return
            }
            
            self.syncEnergyBurnedData(energyBurnedData)
            self.syncExerciseData(exerciseData)
            self.syncStandData(standData)
        }
    }
    
    func getWeightsFromDevice() {
        
        HealthKitHelper.default.getBodyWeightData() {(satistics, error) in
            
            if (error != nil) {
                print(error!)
            }
            
            guard let dataset = satistics else {
                print("can't get weight data")
                return
            }
            
            self.syncWeightData(dataset)
        }
    }
    
    func getStepsFromDevice() {
        
        HealthKitHelper.default.getStepCounts() {(satistics, error) in
            
            if (error != nil) {
                print(error!)
            }
            
            guard let dataset = satistics else {
                print("can't get steps data")
                return
            }
            
            self.syncStepsData(dataset)
        }
    }
    
    func getSleepFromDevice() {
        
        HealthKitHelper.default.getSleepAnalysis() {(satistics, error) in
            
            if (error != nil) {
                print(error!)
            }
            
            guard let dataset = satistics else {
                print("can't get sleep data")
                return
            }
            
            self.syncSleepData(dataset)
        }
    }
    
    func getBloodPressureFromDevice() {
        
        HealthKitHelper.default.getBloodPressure() {(satistics, error) in
            
            if (error != nil) {
                print(error!)
            }
            
            guard let dataset = satistics else {
                print("can't get steps data")
                return
            }

            self.syncBloodPressureData(dataset)
        }
    }
    
    func getECGDataFromDevice() {        
        HealthKitHelper.default.getECG { (data, error) in
            
            if (error != nil) {
                print(error!)
            }
            
            guard let dataset = data else {
                print("can't get ECG data")
                return
            }
            self.syncEcgData(dataset)
        }
    }
    
    var _syncingHR = false
    func syncHeartRateData(_ deviceDataset: [HeartRate]) {
        if _syncingHR == true {
            return
        }
        self._syncingHR = true
        var newLocalData = [HeartRate]()
        let localData = self.heartRateData
        DispatchQueue.global(qos: .background).async {
            for heartRate in deviceDataset {
                if let last = localData.last {
                    if last.date < heartRate.date {
                        newLocalData.append(heartRate)
                    }
                } else {
                    newLocalData.append(heartRate)
                }
            }
            
            if (newLocalData.count > 0) {
                self.mutex.enter()
                ApiManager.sharedInstance.setHeartRateData(newLocalData) { (heartRates, errorMsg) in
                    if errorMsg == nil {
                        DispatchQueue.global(qos: .background).async {
                            HeartRate.append(newLocalData)
                            self.updatedHealthData()
                        }
                    }
                    else {
                        print("error on saving heart rate data: \(errorMsg ?? "")")
                        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { (timer) in
                            timer.invalidate()
                            self.syncHeartRateData(deviceDataset)
                        }
                    }
                    self._syncingHR = false
                    self.mutex.leave()
                }
            }
        }
    }
    
    func syncEnergyBurnedData(_ deviceDataset: [(Date, Double)]) {
        DispatchQueue.global(qos: .background).async {
            do{
                let realm = try Realm()
                
                var newLocalData = [(Date, Double)]()
                let localData = EnergyBurn.getEnergyBurnedAsync(realm)
                for energy in deviceDataset {
                    if !localData.contains(where: { $0.date == energy.0 }) {
                        newLocalData.append(energy)
                    }
                }
                
                if (newLocalData.count > 0) {
                    self.mutex.enter()
                    ApiManager.sharedInstance.setEnergyBurnedData(newLocalData) { (energyBurnedData, errorMsg) in
                        
                        if let energyBurnedData = energyBurnedData {
                            EnergyBurn.setEnergyBurned(energyBurnedData)
                            self.updatedHealthData()
                        }
                        else {
                            print("error on saving energy burned data: \(errorMsg ?? "")")
                        }
                        self.mutex.leave()
                    }
                }
            }
            catch{
                print("error on creating Realm inside syncEnergyBurnedData")
            }
        }
    }
    
    func syncExerciseData(_ deviceDataset: [(Date, Double)]) {
        DispatchQueue.global(qos: .background).async {
            do{
                let realm = try Realm()
                
                var newLocalData = [(Date, Double)]()
                let localData = Exercise.getExercisesAsync(realm)
                for exercise in deviceDataset {
                    if !localData.contains(where: { $0.date == exercise.0 }) {
                        newLocalData.append(exercise)
                    }
                }
                
                if (newLocalData.count > 0) {
                    self.mutex.enter()
                    ApiManager.sharedInstance.setExerciseData(newLocalData) { (exerciseData, errorMsg) in
                        
                        if let exerciseData = exerciseData {
                            Exercise.setExercises(exerciseData)
                            self.updatedHealthData()
                        }
                        else {
                            print("error on saving exercise data: \(errorMsg ?? "")")
                        }
                        self.mutex.leave()
                    }
                }
            }
            catch{
                print("error on creating Realm inside syncExerciseData")
            }
        }
    }
    
    func syncStandData(_ deviceDataset: [(Date, Double)]) {
        DispatchQueue.global(qos: .background).async {
            do{
                let realm = try Realm()
                
                var newLocalData = [(Date, Double)]()
                let localData = Stand.getStandsAsync(realm)
                for stand in deviceDataset {
                    if !localData.contains(where: { $0.date == stand.0 }) {
                        newLocalData.append(stand)
                    }
                }
                
                if (newLocalData.count > 0) {
                    self.mutex.enter()
                    ApiManager.sharedInstance.setStandData(newLocalData) { (standData, errorMsg) in
                        
                        if let standData = standData {
                            Stand.setStands(standData)
                            self.updatedHealthData()
                        }
                        else {
                            print("error on saving stand data: \(errorMsg ?? "")")
                        }
                        self.mutex.leave()
                    }
                }
            }
            catch{
                print("error on creating Realm inside syncStandData")
            }
        }
    }
    
    func syncWeightData(_ deviceDataset: [(Date, Double)]) {
        DispatchQueue.global(qos: .background).async {
            do{
                let realm = try Realm()
                
                var newLocalData = [(Date, Double)]()
                let localData = Weight.getWeightsAsync(realm)
                for weight in deviceDataset {
                    if !localData.contains(where: { $0.date == weight.0 }) {
                        newLocalData.append(weight)
                    }
                }
                
                if (newLocalData.count > 0) {
                    self.mutex.enter()
                    ApiManager.sharedInstance.setWeightData(newLocalData) { (weights, errorMsg) in
                        
                        if let weights = weights {
                            Weight.setWeights(weights)
                            self.updatedHealthData()
                        }
                        else {
                            print("error on saving weight data: \(errorMsg ?? "")")
                        }
                        self.mutex.leave()
                    }
                }
            }
            catch{
                print("error on creating Realm inside syncWeightData")
            }
        }
    }
    
    func syncStepsData(_ deviceDataset: [(Date, Double)]) {
        DispatchQueue.global(qos: .background).async {
            do{
                let realm = try Realm()
                
                var newLocalData = [(Date, Double)]()
                let localData = Steps.getStepsAsync(realm)
                for steps in deviceDataset {
                    if !localData.contains(where: { $0.date == steps.0 }) {
                        newLocalData.append(steps)
                    }
                }
                
                if (newLocalData.count > 0) {
                    self.mutex.enter()
                    ApiManager.sharedInstance.setStepsData(newLocalData) { (steps, errorMsg) in
                        
                        if let steps = steps {
                            Steps.setSteps(steps)
                            self.updatedHealthData()
                        }
                        else {
                            print("error on saving steps data: \(errorMsg ?? "")")
                        }
                        self.mutex.leave()
                    }
                }
            }
            catch{
                print("error on creating Realm inside syncStepsData")
            }
        }
    }
    
    func syncEcgData(_ deviceDataset: [Ecg]) {
        DispatchQueue.global(qos: .background).async {
            var newLocalData = [Ecg]()
            let localData = self.ecgData
            for newItem in deviceDataset {
                if let last = localData.last {
                    if last.date < newItem.date {
                        newLocalData.append(newItem)
                    }
                } else {
                    newLocalData.append(newItem)
                }
            }
            
            if (newLocalData.count > 0) {
                var cnt = 0
                var uploadBatch = [[Ecg]]()
                uploadBatch.append([Ecg]())
                while(newLocalData.count != 0) {
                    uploadBatch[uploadBatch.count - 1].append(newLocalData[0])
                    newLocalData.remove(at: 0)
                    cnt += 1
                    if cnt == 10 {
                        uploadBatch.append([Ecg]())
                        cnt = 0
                    }
                }
                for batch in uploadBatch {
                    let lock = DispatchGroup()
                    for i in 0..<batch.count {
                        lock.enter()
                        let data = batch[i].getVoltageData()
                        ApiManager.sharedInstance.uploadEcgFile(data) { (url) in
                            if let val = url {
                                batch[i].file_url = val
//                                batch[i].setVoltages()
                            }
                            lock.leave()
                        }
                    }
                    lock.notify(queue: .global()) {
                        ApiManager.sharedInstance.setECGData(batch) { (data, errorMsg) in
                            if errorMsg == nil {
                                DispatchQueue.global(qos: .background).async {                               
                                    Ecg.append(batch)
                                    self.updatedHealthData()
                                }
                            }
                            else {
                                print("error on saving ecg data: \(errorMsg ?? "")")
                            }
                        }
                    }
                }
            }
        }
    }
    
    func syncSleepData(_ deviceDataset: [(String, Date, Date, Int)]) {
        DispatchQueue.global(qos: .background).async {
            do{
                let realm = try Realm()
                
                var newLocalData = [(String, Date, Date, Int)]()
                let localData = Sleep.getSleepsAsync(realm)
                for sleep in deviceDataset {
                    if !localData.contains(where: { !sleep.0.isEmpty && $0.UUID == sleep.0 }) {
                        newLocalData.append(sleep)
                    }
                }
                
                if (newLocalData.count > 0) {
                    self.mutex.enter()
                    ApiManager.sharedInstance.setSleepData(newLocalData) { (sleeps, errorMsg) in
                        
                        if let sleeps = sleeps {
                            Sleep.setSleeps(sleeps)
                            self.updatedHealthData()
                        }
                        else {
                            print("error on saving sleep data: \(errorMsg ?? "")")
                        }
                        self.mutex.leave()
                    }
                }
            }
            catch{
                print("error on creating Realm inside syncSleepData")
            }
        }
    }
    
    func syncBloodPressureData(_ deviceDataset: [(Date, String, Double, String, Double)]) {
        DispatchQueue.global(qos: .background).async {
            do{
                let realm = try Realm()
                
                var newLocalData = [(Date, String, Double, String, Double)]()
                let localData = BloodPressure.getBloodPressuresAsync(realm)
                for bloodPressure in deviceDataset {
                    if !localData.contains(where: { $0.sysUUID == bloodPressure.1 && $0.diaUUID == bloodPressure.3 }) {
                        newLocalData.append(bloodPressure)
                    }
                }
                
                if (newLocalData.count > 0) {
                    self.mutex.enter()
                    ApiManager.sharedInstance.setBloodPressureData(newLocalData) { (bloodPressures, errorMsg) in
                        if let bloodPressures = bloodPressures {
                            BloodPressure.setBloodPressures(bloodPressures)
                            self.updatedHealthData()
                        }
                        else {
                            print("error on saving blood pressure data: \(errorMsg ?? "")")
                        }
                        self.mutex.leave()
                    }
                }
            }
            catch{
                print("error on creating Realm inside syncBloodPressureData")
            }
        }
    }
    
    private func getDeviceData() {
        self.getHeartRatesFromDevice()
        self.getECGDataFromDevice()
        self.getActivitySummaryFromDevice()
        self.getWeightsFromDevice()
        self.getStepsFromDevice()
        self.getSleepFromDevice()
        self.getBloodPressureFromDevice()
    }
    
    private func updatedHealthData() {
        DispatchQueue.main.async {
            self.energyBurnedData = Set(EnergyBurn.getEnergyBurned()).filter({ $0.status < 2 })
            self.exerciseData = Set(Exercise.getExercises()).filter({ $0.status < 2 })
            self.standData = Set(Stand.getStands()).filter({ $0.status < 2 })
            self.weightData = Set(Weight.getWeights()).filter({ $0.status < 2 })
            self.stepsData = Set(Steps.getSteps()).filter({ $0.status < 2 })
            self.sleepData = Set(Sleep.getSleeps()).filter({ $0.status < 2 })
            self.alcoholUseData = Set(AlcoholUse.getAlcoholUses()).filter({ $0.status < 2 })
            self.bloodPressureData = Set(BloodPressure.getBloodPressures()).filter({ $0.status < 2 })
            DispatchQueue.global(qos: .background).async {
                self.heartRateData = HeartRate.get()
                self.ecgData = Ecg.get()
                DispatchQueue.main.async {
                    NotificationCenter.default.post(name: Notification.Name(USER_NOTIFICATION_HEALTHDATA_CHANGED), object: nil)
                }
            }
        }
    }
    
    func addWeightData(_ weight: Weight) {
        Weight.setWeight(weight)
        self.weightData = Set(Weight.getWeights()).filter({ $0.status < 2 })
        NotificationCenter.default.post(name: Notification.Name(USER_NOTIFICATION_HEALTHDATA_CHANGED), object: nil)
    }
    
    func deleteWeightData(_ weight: Weight) {
        Weight.setWeight(weight)
        self.weightData = Set(Weight.getWeights()).filter({ $0.status < 2 })
        NotificationCenter.default.post(name: Notification.Name(USER_NOTIFICATION_HEALTHDATA_CHANGED), object: nil)
    }
    
    func addSleepData(_ sleep: Sleep) {
        Sleep.setSleep(sleep)
        self.sleepData = Set(Sleep.getSleeps()).filter({ $0.status < 2 })
        NotificationCenter.default.post(name: Notification.Name(USER_NOTIFICATION_HEALTHDATA_CHANGED), object: nil)
    }
    
    func deleteSleepData(_ sleep: Sleep) {
        Sleep.setSleep(sleep)
        self.sleepData = Set(Sleep.getSleeps()).filter({ $0.status < 2 })
        NotificationCenter.default.post(name: Notification.Name(USER_NOTIFICATION_HEALTHDATA_CHANGED), object: nil)
    }
    
    func addAlcoholUseData(_ alcoholUse: AlcoholUse) {
        AlcoholUse.setAlcoholUse(alcoholUse)
        self.alcoholUseData = Set(AlcoholUse.getAlcoholUses()).filter({ $0.status < 2 })
        NotificationCenter.default.post(name: Notification.Name(USER_NOTIFICATION_HEALTHDATA_CHANGED), object: nil)
    }
    
    func deleteAlcoholUseData(_ alcoholUse: AlcoholUse) {
        AlcoholUse.setAlcoholUse(alcoholUse)
        self.alcoholUseData =  Set(AlcoholUse.getAlcoholUses()).filter({ $0.status < 2 })
        NotificationCenter.default.post(name: Notification.Name(USER_NOTIFICATION_HEALTHDATA_CHANGED), object: nil)
    }
    
    func addBloodPressureData(_ bloodPressure: BloodPressure) {
        BloodPressure.setBloodPressure(bloodPressure)
        self.bloodPressureData = Set(BloodPressure.getBloodPressures()).filter({ $0.status < 2 })
        NotificationCenter.default.post(name: Notification.Name(USER_NOTIFICATION_HEALTHDATA_CHANGED), object: nil)
    }
    
    func deleteBloodPressureData(_ bloodPressure: BloodPressure) {
        BloodPressure.setBloodPressure(bloodPressure)
        self.bloodPressureData = Set(BloodPressure.getBloodPressures()).filter({ $0.status < 2 })
        NotificationCenter.default.post(name: Notification.Name(USER_NOTIFICATION_HEALTHDATA_CHANGED), object: nil)
    }
}
