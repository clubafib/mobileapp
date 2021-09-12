//
//  ApiManager.swift
//  Helper
//
//  Created by Rener on 7/24/20.
//  Copyright © 2020 ExtremeMobile. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire

enum HttpResponseCode : Int{
    case ok = 200
    case badrequest = 400
    case unauthorized = 401
}


class ApiManager: NSObject {
    
    static var sharedInstance : ApiManager = {
        var instance = ApiManager()
        return instance
    }()
    
    let baseURL = "https://clubafib.com/api/"
    
    // MARK - Member
    let apiUserLogin            = "auth/login"
    let apiSocialLoginFB        = "auth/facebook"
    let apiSocialLoginGoogle    = "auth/google"
    let apiSocialLoginApple    = "auth/apple"
    let apiUserRegister         = "auth/signup"
    let apiUserRequestResetPassword   = "auth/request_reset_password"
    let apiUserVerify           = "auth/activate"
    let apiUserResetPassword    = "auth/reset_password"
    
    let apiUploadImage          = "media/upload"
    
    let apiUpdateProfile        = "profile"
    
    let apiGetArticles          = "data/article"
    let apiGetGoods             = "data/good"
    
    let apiGetPosts             = "post"
    let apiAddEditPost          = "post"
    let apiDeletePost           = "post/delete"
    let apiAddComment           = "comment"
    let apiReaction             = "reaction"
    
//    let apiGetHeartRateData         = "health/heart_rate"
//    let apiSetHeartRateData         = "health/heart_rate"
//    let apiGetEnergyData            = "health/energy"
//    let apiSetEnergyData            = "health/energy"
//    let apiGetExerciseData          = "health/exercise"
//    let apiSetExerciseData          = "health/exercise"
//    let apiGetStandData             = "health/stand"
//    let apiSetStandData             = "health/stand"
//    let apiGetWeightData            = "health/weight"
//    let apiSetWeightData            = "health/weight"
//    let apiAddWeightData            = "health/weight/add"
//    let apiDeleteWeightData         = "health/weight/delete"
//    let apiGetStepsData             = "health/steps"
//    let apiSetStepsData             = "health/steps"
//    let apiGetSleepData             = "health/sleep"
//    let apiSetSleepData             = "health/sleep"
//    let apiAddSleepData             = "health/sleep/add"
//    let apiDeleteSleepData          = "health/sleep/delete"
//    let apiGetAlcoholUseData        = "health/alcohol"
//    let apiSetAlcoholUseData        = "health/alcohol"
//    let apiAddAlcoholUseData        = "health/alcohol/add"
//    let apiDeleteAlcoholUseData     = "health/alcohol/delete"
//    let apiGetBloodPressureData     = "health/blood_pressure"
//    let apiSetBloodPressureData     = "health/blood_pressure"
//    let ecgDataUri     = "health/ekg"
//    let ekgDataUri     = "health/ekg"
//    let fileDataUri     = "health/upload"
    
//    let apiAddBloodPressureData     = "health/blood_pressure/add"
//    let apiDeleteBloodPressureData  = "health/blood_pressure/delete"
    
    let apiGetDoctorList        = "doctor"
    let apiGetChatRoom          = "chat"
    let apiCloseChatRoom        = "chat/close"
    let apiGiveFeedBack         = "feedback/"
    
    let apiGetActivePayment             = "subscription/payment"
    let apiGetStripeEphemeralKeys       = "subscription/ephemeral_keys"
    let apiGetStripePaymentIntent       = "subscription/payment_intent"
    let apiOneTimePay                   = "subscription/onetime-pay"
    let apiStripeSubscibe               = "subscription/subscribe"
    let apiStripeCancelSubsciption      = "subscription/cancel_subscription"
    let apiLogo = "data/logo"
    // MARK - Response Blocks
    typealias DefaultResponse       = (JSON?, Error?, Int) -> Void
    typealias UpdateResponse        = (Bool, String) -> Void
    typealias DefaultArrayResponse  = ([JSON]?, Error?) ->Void
    typealias JSONDefaultResponse   = (Bool, Error?) -> Void
    typealias JSONResponse          = (JSON?, String?, Bool) -> Void
    
    let defaultHeaders : HTTPHeaders = [
        "X-API-KEY":"1b41924f23b544e8dc9dd2cbe2328ba0"
    ]
    
    // Get header
    class func getHeader() -> HTTPHeaders {
        var header : HTTPHeaders = [:]
        header["Content-Type"] = "application/json"
        header["Accept"] = "application/json"
        
        return header
    }
    
    // Get Token Header
    func getHeaderWithToken() -> HTTPHeaders{
        let token: String = UserInfo.sharedInstance.accessToken
        let headers: HTTPHeaders = ["Authorization": "Bearer " + token]
        
        return headers
    }
   
    // MARK - REQUEST METHOD
    // Send request with URL Encoding
    func request(method:HTTPMethod, endPoint:String, params:[String:Any]?, headers :HTTPHeaders? = nil, encoding: ParameterEncoding = URLEncoding.default, complete: @escaping DefaultResponse) -> Void {
        
        let url = "\(baseURL)\(endPoint)"
        
        Alamofire.request(url, method: method, parameters: params, encoding: encoding, headers: defaultHeaders).responseJSON { (response:DataResponse<Any>) in
            print("**** Response from server : url = \(url) **** \n")
            
            let statusCode = response.response?.statusCode ?? HttpResponseCode.unauthorized.rawValue
            print("Http request respone code = \(statusCode)")
            
            switch response.result{
            case .success(let data):
                let result = JSON(data)
                complete(result, nil, statusCode)
                break
            case .failure(let error):
                complete(nil, error, statusCode)
                break
            }
        }
    }
    
    // Send request with JSON Encoding
    func requestWithJson(method:HTTPMethod, endPoint:String, params:[String:Any]?, header: HTTPHeaders? = nil, encoding: ParameterEncoding = JSONEncoding.default, complete: @escaping DefaultResponse) -> Void {
        
        let url = "\(baseURL)\(endPoint)"
        
        Alamofire.request(url, method: method, parameters: params, encoding: encoding, headers: defaultHeaders).responseJSON { (response : DataResponse<Any>) in
            print("**** Response from server **** \(response)")
            let statusCode = response.response?.statusCode ?? HttpResponseCode.unauthorized.rawValue
            print("Http request respone code = \(statusCode)")
            
            switch response.result{
            case .success(let data):
                let result = JSON(data)
                complete(result, nil, statusCode)
                break
            case .failure(let error):
                complete(nil, error, statusCode)
                break
            }
        }
    }
    
    // MARK - Request Funtions with token
    func requestWithToken(method:HTTPMethod, endPoint:String, params:[String:Any]?, headers :HTTPHeaders? = nil, encoding: ParameterEncoding = URLEncoding.default, complete: @escaping DefaultResponse) -> Void {
        
        let url = "\(baseURL)\(endPoint)"
        let customHeader = self.getHeaderWithToken()
        
        Alamofire.request(url, method: method, parameters: params, encoding: encoding, headers: customHeader).responseJSON { (response: DataResponse<Any>) in
            print("**** Response from server : url = \(url) **** \n")
            
            let statusCode = response.response?.statusCode ?? HttpResponseCode.unauthorized.rawValue
            print("Http request respone code = \(statusCode)")
            
            switch response.result{
            case .success(let data):
                let result = JSON(data)
                complete(result, nil, statusCode)
                break
            case .failure(let error):
                complete(nil, error, statusCode)
                break
            }
        }
    }
    
    // Send request with Files
    func requestWithFiles(method:HTTPMethod, endPoint:String, params:[String:Any]?, URLs : [URL], name:String, header: HTTPHeaders? = nil, complete:@escaping DefaultResponse) -> Void {

        let url = "\(baseURL)\(endPoint)"
        Alamofire.upload(multipartFormData: { (multiFormData) in
            for index in 0..<URLs.count {
                let file_extension = "jpeg"
                let mimeType = "image/jpeg"

                multiFormData.append(URLs[index], withName: name, fileName: "\(UUID.init().uuidString).\(file_extension)", mimeType: mimeType)
            }

            if params != nil
            {
                for (key, value) in params! {
                    multiFormData.append("\(value)".data(using: String.Encoding.utf8)!, withName: key)
                }
            }
        }, usingThreshold: 10240, to: url, method: .post, headers: self.getHeaderWithToken()) { (ret) in
            switch ret {
            case .success(let request, _, _):
                request.responseJSON { (response) in
                    print("**** Response from server : url = \(url) **** \n")

                    let statusCode = response.response?.statusCode ?? HttpResponseCode.unauthorized.rawValue
                    print("Http request respone code = \(statusCode)")

                    switch response.result{
                    case .success(let data):
                        let result = JSON(data)
                        complete(result, nil, statusCode)
                        break
                    case .failure(let error):
                        complete(nil, error, statusCode)
                        break
                    }
                }
                break
            case .failure(let error):
                complete(nil, error, 0)
                break
            }
        }                
    }
    
    func uploadImage(urls : [URL], name : String, complete:@escaping(String?, String?) -> Void) {
        requestWithFiles(method: .post, endPoint: apiUploadImage, params: nil, URLs: urls, name: name) { (response, error, responseCode) in
            if let json = response {
                let error = json["errors"].array
                
                if error == nil{
                    if let url = json["data"]["url"].string {
                        return complete(url, nil)
                    }
                    complete(nil, "No url received")
                } else {
                    let firstError = error![0]
                    complete(nil, firstError["message"].stringValue)
                }
            }
            else{
                complete(nil, error?.localizedDescription)
            }
        }
    }

    // MARK :- Facebook & Google Login
    func loginWithSocial(params:[String:Any], isFacebook : Bool = true, complete:@escaping(Bool, String?) -> Void){
        let endPointURL = isFacebook ? apiSocialLoginFB : apiSocialLoginGoogle
        
        request(method: .post, endPoint: endPointURL, params: params) { (response, error, responseCode) in
            if let json = response {
                let error = json["errors"].array
                
                if error == nil{
                    let data = json["data"]
                    
                    UserInfo.sharedInstance.isLoggedIn = true
                    UserInfo.sharedInstance.userData = User(data["user"])
                    UserInfo.sharedInstance.accessToken = data["token"].stringValue
                    UserInfo.sharedInstance.refreshToken = data["refresh_token"].stringValue
                    complete(true, nil)
                    
                    self.getGetActivePayments(complete: nil)
                } else {
                    let firstError = error![0]
                    complete(false, firstError["message"].stringValue)
                }
            }
            else{
                complete(false, error?.localizedDescription)
            }
        }
    }

    func loginWithApple(params:[String:String], complete:@escaping(Bool, String?) -> Void){        
        request(method: .post, endPoint: apiSocialLoginApple, params: params) { (response, error, responseCode) in
            if let json = response {
                let error = json["errors"].array
                
                if error == nil{
                    let data = json["data"]
                    UserInfo.sharedInstance.isLoggedIn = true
                    UserInfo.sharedInstance.userData = User(data["user"])
                    UserInfo.sharedInstance.accessToken = data["token"].stringValue
                    UserInfo.sharedInstance.refreshToken = data["refresh_token"].stringValue
                    complete(true, nil)
                    
                    self.getGetActivePayments(complete: nil)
                } else {
                    let firstError = error![0]
                    complete(false, firstError["message"].stringValue)
                }
            }
            else{
                complete(false, error?.localizedDescription)
            }
        }
    }
    
    // Mark - Login
    func login(params : [String : Any], complete:@escaping(Bool, String?) -> Void) {
        
        request(method: .post, endPoint: apiUserLogin, params: params) { (response, error, responseCode) in
            if let json = response {
                let error = json["errors"].array
                
                if error == nil{
                    let data = json["data"]
                    UserInfo.sharedInstance.isLoggedIn = true
                    UserInfo.sharedInstance.userData = User(data["user"])
                    UserInfo.sharedInstance.accessToken = data["token"].stringValue
                    UserInfo.sharedInstance.refreshToken = data["refresh_token"].stringValue
                    complete(true, nil)
                    
                    self.getGetActivePayments(complete: nil)
                } else {
                    let firstError = error![0]
                    complete(false, firstError["message"].stringValue)
                }
            }
            else{
                complete(false, error?.localizedDescription)
            }
        }
    }

    // Mark - Register
    func register(params : [String : Any], complete:@escaping(Bool, String?) -> Void) {
        
        request(method: .post, endPoint: apiUserRegister, params: params) { (response, error, responseCode) in
            if let json = response {
                
                let error = json["errors"].array
                
                if error == nil{
                    let data = json["data"]
                    UserInfo.sharedInstance.userData = User(data["user"])
                    complete(true, nil)
                } else {
                    let firstError = error![0]
                    complete(false, firstError["message"].stringValue)
                }
            }
            else{
                complete(false, error?.localizedDescription)
            }
        }
    }


    // Mark - Update Token
    func updateToken(complete:@escaping(Bool, String?) -> Void) {
        let params = [
            "refresh_token": UserInfo.sharedInstance.refreshToken
        ]
        request(method: .post, endPoint: apiUserLogin, params: params) { (response, error, responseCode) in
            if let json = response {
                let error = json["errors"].array
                
                if error == nil{
                    let data = json["data"]
                    UserInfo.sharedInstance.isLoggedIn = true
                    UserInfo.sharedInstance.userData = User(data["user"])
                    UserInfo.sharedInstance.accessToken = data["token"].stringValue
                    UserInfo.sharedInstance.refreshToken = data["refresh_token"].stringValue
                    complete(true, nil)
                    
                    self.getGetActivePayments(complete: nil)
                } else {
                    let firstError = error![0]
                    complete(false, firstError["message"].stringValue)
                }
            }
            else{
                complete(false, error?.localizedDescription)
            }
        }
    }

    // Mark - Forgot Password / Request Reset Password
    func requestResetPassword(params : [String : Any], complete:@escaping(Bool, String?) -> Void) {
        complete(true, nil)
        
        request(method: .post, endPoint: apiUserRequestResetPassword, params: params) { (response, error, responseCode) in
            if let json = response {
                let error = json["errors"].array
                
                if error == nil{
                    complete(true, nil)
                } else {
                    let firstError = error![0]
                    complete(false, firstError["message"].stringValue)
                }
            }
            else{
                complete(false, error?.localizedDescription)
            }
        }
    }

    // Mark - Verify
    func verify(params : [String : Any], complete:@escaping(Bool, String?) -> Void) {
        request(method: .post, endPoint: apiUserVerify, params: params) { (response, error, responseCode) in
            if let json = response {
                let error = json["errors"].array
                
                if error == nil{
                    let data = json["data"]
                    UserInfo.sharedInstance.isLoggedIn = true
                    UserInfo.sharedInstance.userData = User(data["user"])
                    UserInfo.sharedInstance.accessToken = data["token"].stringValue
                    UserInfo.sharedInstance.refreshToken = data["refresh_token"].stringValue
                    complete(true, nil)
                    
                    self.getGetActivePayments(complete: nil)
                } else {
                    let firstError = error![0]
                    complete(false, firstError["message"].stringValue)
                }
            }
            else{
                complete(false, error?.localizedDescription)
            }
        }
    }

    // Mark - Reset Password
    func resetPassword(params : [String : Any], complete:@escaping(Bool, String?) -> Void) {
        request(method: .post, endPoint: apiUserResetPassword, params: params) { (response, error, responseCode) in
            if let json = response {
                let error = json["errors"].array
                
                if error == nil{
                    complete(true, nil)
                } else {
                    let firstError = error![0]
                    complete(false, firstError["message"].stringValue)
                }
            }
            else{
                complete(false, error?.localizedDescription)
            }
        }
    }
    
    // Update Profile
    func updateProfile(params: [String: Any]?, complete: @escaping (Bool, String?) -> Void) -> Void {
        requestWithToken(method: .post, endPoint: apiUpdateProfile, params: params) { (response, error, resoponseCode) in
            if let json = response {
                let errors = json["errors"].array
                
                if errors == nil{
                    complete(true, nil)
                } else {
                    var message = "Occur error on Server"
                    if errors!.count > 0 {
                        message = errors![0]["message"].string ?? message
                    }
                    complete(false, message)
                }
            }
            else{
                complete(false, error?.localizedDescription)
            }
        }
    }
    
    // Get Articles
    func getArticles(params: [String: Any]?, complete: @escaping ([Article]?, String?) -> Void) -> Void {
        requestWithToken(method: .get, endPoint: apiGetArticles, params: params) { (response, error, resoponseCode) in
            if let json = response {
                let errors = json["errors"].array
                
                if errors == nil{
                    if let data = json["data"].array {
                        let articles = data.map({return Article($0)})
                        complete(articles, nil)
                    }
                    else {
                        complete([], nil)
                    }
                } else {
                    var message = "Occur error on Server"
                    if errors!.count > 0 {
                        message = errors![0]["message"].string ?? message
                    }
                    complete(nil, message)
                }
            }
            else{
                complete(nil, error?.localizedDescription)
            }
        }
    }
    
    // Get Articles
    func getGoods(params: [String: Any]?, complete: @escaping ([Goods]?, String?) -> Void) -> Void {
        requestWithToken(method: .get, endPoint: apiGetGoods, params: params) { (response, error, resoponseCode) in
            if let json = response {
                let errors = json["errors"].array
                
                if errors == nil{
                    if let data = json["data"].array {
                        let goods = data.map({return Goods($0)})
                        complete(goods, nil)
                    }
                    else {
                        complete([], nil)
                    }
                } else {
                    var message = "Occur error on Server"
                    if errors!.count > 0 {
                        message = errors![0]["message"].string ?? message
                    }
                    complete(nil, message)
                }
            }
            else{
                complete(nil, error?.localizedDescription)
            }
        }
    }
    
    // Get Posts
    func getPosts(params: [String: Any]?, complete: @escaping ([Post]?, String?) -> Void) -> Void {
        requestWithToken(method: .get, endPoint: apiGetPosts, params: params) { (response, error, resoponseCode) in
            if let json = response {
                let errors = json["errors"].array
                
                if errors == nil{
                    if let data = json["data"].array {
                        let posts = data.map({return Post($0)})
                        complete(posts, nil)
                    }
                    else {
                        complete([], nil)
                    }
                } else {
                    var message = "Occur error on Server"
                    if errors!.count > 0 {
                        message = errors![0]["message"].string ?? message
                    }
                    complete(nil, message)
                }
            }
            else{
                complete(nil, error?.localizedDescription)
            }
        }
    }
    
    // add Post
    func addPost(_ id: Int, params: [String: Any]?, complete: @escaping (Post?, String?) -> Void) -> Void {
        requestWithToken(method: .post, endPoint: "\(apiAddEditPost)/\(id)", params: params) { (response, error, resoponseCode) in
            if let json = response {
                let errors = json["errors"].array
                
                if errors == nil{
                    if json["data"]["post"].dictionaryObject != nil {
                        complete(Post(json["data"]["post"]), nil)
                    }
                    else {
                        complete(nil, nil)
                    }
                } else {
                    var message = "Occur error on Server"
                    if errors!.count > 0 {
                        message = errors![0]["message"].string ?? message
                    }
                    complete(nil, message)
                }
            }
            else{
                complete(nil, error?.localizedDescription)
            }
        }
    }
    
    // edit Post
    func editPost(_ id: Int,  params: [String: Any]?, complete: @escaping (Post?, String?) -> Void) -> Void {
        requestWithToken(method: .post, endPoint: "\(apiAddEditPost)/\(id)", params: params) { (response, error, resoponseCode) in
            if let json = response {
                let errors = json["errors"].array
                
                if errors == nil{
                    if json["data"]["post"].dictionaryObject != nil {
                        complete(Post(json["data"]["post"]), nil)
                    }
                    else {
                        complete(nil, nil)
                    }
                } else {
                    var message = "Occur error on Server"
                    if errors!.count > 0 {
                        message = errors![0]["message"].string ?? message
                    }
                    complete(nil, message)
                }
            }
            else{
                complete(nil, error?.localizedDescription)
            }
        }
    }
    
    // delete Post
    func deletePost(_ id: Int, complete: @escaping (Bool, String?) -> Void) -> Void {
        requestWithToken(method: .post, endPoint: "\(apiDeletePost)/\(id)", params: nil) { (response, error, resoponseCode) in
            if let json = response {
                let errors = json["errors"].array
                
                if errors == nil{
                    complete(true, nil)
                } else {
                    var message = "Occur error on Server"
                    if errors!.count > 0 {
                        message = errors![0]["message"].string ?? message
                    }
                    complete(false, message)
                }
            }
            else{
                complete(false, error?.localizedDescription)
            }
        }
    }
    
    // Add comment
    func addComment(_ id: Int, params: [String: Any]?, complete: @escaping (PostComment?, String?) -> Void) -> Void {
        requestWithToken(method: .post, endPoint: "\(apiAddComment)/\(id)", params: params) { (response, error, resoponseCode) in
            if let json = response {
                let errors = json["errors"].array
                
                if errors == nil{
                    if json["data"]["comment"].dictionaryObject != nil {
                        complete(PostComment(json["data"]["comment"]), nil)
                    }
                    else {
                        complete(nil, nil)
                    }
                } else {
                    var message = "Occur error on Server"
                    if errors!.count > 0 {
                        message = errors![0]["message"].string ?? message
                    }
                    complete(nil, message)
                }
            }
            else{
                complete(nil, error?.localizedDescription)
            }
        }
    }
    
    // Reaction to articles, goods and posts
    func reaction(params: [String: Any]?, complete: @escaping ([Like]?, [Like]?, String?) -> Void) -> Void {
        requestWithToken(method: .post, endPoint: apiReaction, params: params) { (response, error, resoponseCode) in
            if let json = response {
                let errors = json["errors"].array
                
                if errors == nil{
                    var likes = [Like]()
                    var dislikes = [Like]()
                    if let jsonLikes = json["data"]["likes"].array {
                        likes = jsonLikes.map({return Like($0)})
                    }
                    if let jsonDislikes = json["data"]["dislikes"].array {
                        dislikes = jsonDislikes.map({return Like($0)})
                    }
                    complete(likes, dislikes, nil)
                } else {
                    var message = "Occur error on Server"
                    if errors!.count > 0 {
                        message = errors![0]["message"].string ?? message
                    }
                    complete(nil, nil, message)
                }
            }
            else{
                complete(nil, nil, error?.localizedDescription)
            }
        }
    }
    
    /*
    // Get Heart Rate data
    func getHeartRateData(_ lastAt:String, complete: @escaping ([HeartRate]?, String?) -> Void) -> Void {
        let param = lastAt.replacingOccurrences(of: " ", with: "%20")
        requestWithToken(method: .get, endPoint: apiGetHeartRateData + "?lastAt=" + param, params: nil) { (response, error, resoponseCode) in
            if let json = response {
                let errors = json["errors"].array
                
                if errors == nil{
                    if let data = json["data"].array {
                        let heartRates = data.map({return HeartRate($0)})
                        complete(heartRates, nil)
                    }
                    else {
                        complete([], nil)
                    }
                } else {
                    var message = "Occur error on Server"
                    if errors!.count > 0 {
                        message = errors![0]["message"].string ?? message
                    }
                    complete(nil, message)
                }
            }
            else{
                complete(nil, error?.localizedDescription)
            }
        }
    }
    
    // Set Heart Rate data
    func setHeartRateData(_ dataset: [HeartRate], complete: @escaping ([HeartRate]?, String?) -> Void) -> Void {
        var data: [[String: Any]] = [[String: Any]]()
        for heartRate in dataset {
            data.append([
                "date": heartRate.dateTxt,
                "heart_rate": heartRate.value
            ])
        }
        let params: [String: Any] = [
            "data": data
        ]
        requestWithToken(method: .post, endPoint: apiSetHeartRateData, params: params, headers: nil, encoding: JSONEncoding.default) { (response, error, resoponseCode) in
            if let json = response {
                let errors = json["errors"].array
                
                if errors == nil{
                    if let data = json["data"].array {
                        let heartRates = data.map({return HeartRate($0)})
                        complete(heartRates, nil)
                    }
                    else {
                        complete([], nil)
                    }
                } else {
                    var message = "Occur error on Server"
                    if errors!.count > 0 {
                        message = errors![0]["message"].string ?? message
                    }
                    complete(nil, message)
                }
            }
            else{
                complete(nil, error?.localizedDescription)
            }
        }
    }
    
    // Get Energy Burned data
    func getEnergyBurnedData(complete: @escaping ([EnergyBurn]?, String?) -> Void) -> Void {
        requestWithToken(method: .get, endPoint: apiGetEnergyData, params: nil) { (response, error, resoponseCode) in
            if let json = response {
                let errors = json["errors"].array
                
                if errors == nil{
                    if let data = json["data"].array {
                        let energyBurned = data.map({return EnergyBurn($0)})
                        complete(energyBurned, nil)
                    }
                    else {
                        complete([], nil)
                    }
                } else {
                    var message = "Occur error on Server"
                    if errors!.count > 0 {
                        message = errors![0]["message"].string ?? message
                    }
                    complete(nil, message)
                }
            }
            else{
                complete(nil, error?.localizedDescription)
            }
        }
    }
    
    // Set Energy Burned data
    func setEnergyBurnedData(_ dataset: [(Date, Double)], complete: @escaping ([EnergyBurn]?, String?) -> Void) -> Void {
        var data: [[String: Any]] = [[String: Any]]()
        for energy in dataset {
            data.append([
                "date": energy.0.toString,
                "energy": energy.1
            ])
        }
        let params: [String: Any] = [
            "data": data
        ]
        requestWithToken(method: .post, endPoint: apiSetEnergyData, params: params, headers: nil, encoding: JSONEncoding.default) { (response, error, resoponseCode) in
            if let json = response {
                let errors = json["errors"].array
                
                if errors == nil{
                    if let data = json["data"].array {
                        let energyBurned = data.map({return EnergyBurn($0)})
                        complete(energyBurned, nil)
                    }
                    else {
                        complete([], nil)
                    }
                } else {
                    var message = "Occur error on Server"
                    if errors!.count > 0 {
                        message = errors![0]["message"].string ?? message
                    }
                    complete(nil, message)
                }
            }
            else{
                complete(nil, error?.localizedDescription)
            }
        }
    }
    
    // Get Exercise data
    func getExerciseData(complete: @escaping ([Exercise]?, String?) -> Void) -> Void {
        requestWithToken(method: .get, endPoint: apiGetExerciseData, params: nil) { (response, error, resoponseCode) in
            if let json = response {
                let errors = json["errors"].array
                
                if errors == nil{
                    if let data = json["data"].array {
                        let exercises = data.map({return Exercise($0)})
                        complete(exercises, nil)
                    }
                    else {
                        complete([], nil)
                    }
                } else {
                    var message = "Occur error on Server"
                    if errors!.count > 0 {
                        message = errors![0]["message"].string ?? message
                    }
                    complete(nil, message)
                }
            }
            else{
                complete(nil, error?.localizedDescription)
            }
        }
    }
    
    // Set Exercise data
    func setExerciseData(_ dataset: [(Date, Double)], complete: @escaping ([Exercise]?, String?) -> Void) -> Void {
        var data: [[String: Any]] = [[String: Any]]()
        for exercise in dataset {
            data.append([
                "date": exercise.0.toString,
                "exercise": exercise.1
            ])
        }
        let params: [String: Any] = [
            "data": data
        ]
        requestWithToken(method: .post, endPoint: apiSetExerciseData, params: params, headers: nil, encoding: JSONEncoding.default) { (response, error, resoponseCode) in
            if let json = response {
                let errors = json["errors"].array
                
                if errors == nil{
                    if let data = json["data"].array {
                        let exercises = data.map({return Exercise($0)})
                        complete(exercises, nil)
                    }
                    else {
                        complete([], nil)
                    }
                } else {
                    var message = "Occur error on Server"
                    if errors!.count > 0 {
                        message = errors![0]["message"].string ?? message
                    }
                    complete(nil, message)
                }
            }
            else{
                complete(nil, error?.localizedDescription)
            }
        }
    }
    
    // Get Stand data
    func getStandData(complete: @escaping ([Stand]?, String?) -> Void) -> Void {
        requestWithToken(method: .get, endPoint: apiGetStandData, params: nil) { (response, error, resoponseCode) in
            if let json = response {
                let errors = json["errors"].array
                
                if errors == nil{
                    if let data = json["data"].array {
                        let stands = data.map({return Stand($0)})
                        complete(stands, nil)
                    }
                    else {
                        complete([], nil)
                    }
                } else {
                    var message = "Occur error on Server"
                    if errors!.count > 0 {
                        message = errors![0]["message"].string ?? message
                    }
                    complete(nil, message)
                }
            }
            else{
                complete(nil, error?.localizedDescription)
            }
        }
    }
    
    // Set Stand data
    func setStandData(_ dataset: [(Date, Double)], complete: @escaping ([Stand]?, String?) -> Void) -> Void {
        var data: [[String: Any]] = [[String: Any]]()
        for stand in dataset {
            data.append([
                "date": stand.0.toString,
                "stand": stand.1
            ])
        }
        let params: [String: Any] = [
            "data": data
        ]
        requestWithToken(method: .post, endPoint: apiSetStandData, params: params, headers: nil, encoding: JSONEncoding.default) { (response, error, resoponseCode) in
            if let json = response {
                let errors = json["errors"].array
                
                if errors == nil{
                    if let data = json["data"].array {
                        let stands = data.map({return Stand($0)})
                        complete(stands, nil)
                    }
                    else {
                        complete([], nil)
                    }
                } else {
                    var message = "Occur error on Server"
                    if errors!.count > 0 {
                        message = errors![0]["message"].string ?? message
                    }
                    complete(nil, message)
                }
            }
            else{
                complete(nil, error?.localizedDescription)
            }
        }
    }
    
    // Get Weight Data
    func getWeightData(complete: @escaping ([Weight]?, String?) -> Void) -> Void {
        requestWithToken(method: .get, endPoint: apiGetWeightData, params: nil) { (response, error, resoponseCode) in
            if let json = response {
                let errors = json["errors"].array
                
                if errors == nil{
                    if let data = json["data"].array {
                        let weights = data.map({return Weight($0)})
                        complete(weights, nil)
                    }
                    else {
                        complete([], nil)
                    }
                } else {
                    var message = "Occur error on Server"
                    if errors!.count > 0 {
                        message = errors![0]["message"].string ?? message
                    }
                    complete(nil, message)
                }
            }
            else{
                complete(nil, error?.localizedDescription)
            }
        }
    }
    
    // Set Weight Data
    func setWeightData(_ dataset: [(Date, Double)], complete: @escaping ([Weight]?, String?) -> Void) -> Void {
        var data: [[String: Any]] = [[String: Any]]()
        for weight in dataset {
            data.append([
                "date": weight.0.toString,
                "weight": weight.1
            ])
        }
        let params: [String: Any] = [
            "data": data
        ]
        requestWithToken(method: .post, endPoint: apiSetWeightData, params: params, headers: nil, encoding: JSONEncoding.default) { (response, error, resoponseCode) in
            if let json = response {
                let errors = json["errors"].array
                
                if errors == nil{
                    if let data = json["data"].array {
                        let weights = data.map({return Weight($0)})
                        complete(weights, nil)
                    }
                    else {
                        complete([], nil)
                    }
                } else {
                    var message = "Occur error on Server"
                    if errors!.count > 0 {
                        message = errors![0]["message"].string ?? message
                    }
                    complete(nil, message)
                }
            }
            else{
                complete(nil, error?.localizedDescription)
            }
        }
    }
    
    // Add Weight Data
    func addWeightData(_ weight: (Date, Double), complete: @escaping (Weight?, String?) -> Void) -> Void {
        let params: [String: Any] = [
            "data": [
                "date": weight.0.toString,
                "weight": weight.1
            ]
        ]
        requestWithToken(method: .post, endPoint: apiAddWeightData, params: params, headers: nil, encoding: JSONEncoding.default) { (response, error, resoponseCode) in
            if let json = response {
                let errors = json["errors"].array
                
                if errors == nil{
                    if json["data"].dictionary != nil {
                        let weight = Weight(json["data"])
                        complete(weight, nil)
                    }
                    else {
                        complete(nil, nil)
                    }
                } else {
                    var message = "Occur error on Server"
                    if errors!.count > 0 {
                        message = errors![0]["message"].string ?? message
                    }
                    complete(nil, message)
                }
            }
            else{
                complete(nil, error?.localizedDescription)
            }
        }
    }
    
    // Delete Weight Data
    func deleteWeightData(_ weight: Weight, complete: @escaping (Bool, String?) -> Void) -> Void {
        let params: [String: Any] = [
            "id": weight.id
        ]
        requestWithToken(method: .post, endPoint: apiDeleteWeightData, params: params, headers: nil, encoding: JSONEncoding.default) { (response, error, resoponseCode) in
            if let json = response {
                let errors = json["errors"].array
                
                if errors == nil{
                    complete(true, nil)
                } else {
                    var message = "Occur error on Server"
                    if errors!.count > 0 {
                        message = errors![0]["message"].string ?? message
                    }
                    complete(false, message)
                }
            }
            else{
                complete(false, error?.localizedDescription)
            }
        }
    }
    
    // Get Steps data
    func getStepsData(complete: @escaping ([Steps]?, String?) -> Void) -> Void {
        requestWithToken(method: .get, endPoint: apiGetStepsData, params: nil) { (response, error, resoponseCode) in
            if let json = response {
                let errors = json["errors"].array
                
                if errors == nil{
                    if let data = json["data"].array {
                        let steps = data.map({return Steps($0)})
                        complete(steps, nil)
                    }
                    else {
                        complete([], nil)
                    }
                } else {
                    var message = "Occur error on Server"
                    if errors!.count > 0 {
                        message = errors![0]["message"].string ?? message
                    }
                    complete(nil, message)
                }
            }
            else{
                complete(nil, error?.localizedDescription)
            }
        }
    }
    
    // Set Steps data
    func setStepsData(_ dataset: [(Date, Double)], complete: @escaping ([Steps]?, String?) -> Void) -> Void {
        var data: [[String: Any]] = [[String: Any]]()
        for steps in dataset {
            data.append([
                "date": steps.0.toString,
                "steps": steps.1
            ])
        }
        let params: [String: Any] = [
            "data": data
        ]
        requestWithToken(method: .post, endPoint: apiSetStepsData, params: params, headers: nil, encoding: JSONEncoding.default) { (response, error, resoponseCode) in
            if let json = response {
                let errors = json["errors"].array
                
                if errors == nil{
                    if let data = json["data"].array {
                        let steps = data.map({return Steps($0)})
                        complete(steps, nil)
                    }
                    else {
                        complete([], nil)
                    }
                } else {
                    var message = "Occur error on Server"
                    if errors!.count > 0 {
                        message = errors![0]["message"].string ?? message
                    }
                    complete(nil, message)
                }
            }
            else{
                complete(nil, error?.localizedDescription)
            }
        }
    }
    
    // Get Sleep Data
    func getSleepData(complete: @escaping ([Sleep]?, String?) -> Void) -> Void {
        requestWithToken(method: .get, endPoint: apiGetSleepData, params: nil) { (response, error, resoponseCode) in
            if let json = response {
                let errors = json["errors"].array
                
                if errors == nil{
                    if let data = json["data"].array {
                        let sleeps = data.map({return Sleep($0)})
                        complete(sleeps, nil)
                    }
                    else {
                        complete([], nil)
                    }
                } else {
                    var message = "Occur error on Server"
                    if errors!.count > 0 {
                        message = errors![0]["message"].string ?? message
                    }
                    complete(nil, message)
                }
            }
            else{
                complete(nil, error?.localizedDescription)
            }
        }
    }
    
    // Set Sleep Data
    func setSleepData(_ dataset: [(String, Date, Date, Int)], complete: @escaping ([Sleep]?, String?) -> Void) -> Void {
        var data: [[String: Any]] = [[String: Any]]()
        for sleep in dataset {
            data.append([
                "uuid": sleep.0,
                "start": sleep.1.toString,
                "end": sleep.2.toString,
                "type": sleep.3
            ])
        }
        let params: [String: Any] = [
            "data": data
        ]
        requestWithToken(method: .post, endPoint: apiSetSleepData, params: params, headers: nil, encoding: JSONEncoding.default) { (response, error, resoponseCode) in
            if let json = response {
                let errors = json["errors"].array
                
                if errors == nil{
                    if let data = json["data"].array {
                        let sleeps = data.map({return Sleep($0)})
                        complete(sleeps, nil)
                    }
                    else {
                        complete([], nil)
                    }
                } else {
                    var message = "Occur error on Server"
                    if errors!.count > 0 {
                        message = errors![0]["message"].string ?? message
                    }
                    complete(nil, message)
                }
            }
            else{
                complete(nil, error?.localizedDescription)
            }
        }
    }
    
    // Add Sleep Data
    func addSleepData(_ sleep: (String, Date, Date, Int), complete: @escaping (Sleep?, String?) -> Void) -> Void {
        let params: [String: Any] = [
            "data": [
                "uuid": sleep.0,
                "start": sleep.1.toString,
                "end": sleep.2.toString,
                "type": sleep.3
            ]
        ]
        requestWithToken(method: .post, endPoint: apiAddSleepData, params: params, headers: nil, encoding: JSONEncoding.default) { (response, error, resoponseCode) in
            if let json = response {
                let errors = json["errors"].array
                
                if errors == nil{
                    if json["data"].dictionary != nil {
                        let sleep = Sleep(json["data"])
                        complete(sleep, nil)
                    }
                    else {
                        complete(nil, nil)
                    }
                } else {
                    var message = "Occur error on Server"
                    if errors!.count > 0 {
                        message = errors![0]["message"].string ?? message
                    }
                    complete(nil, message)
                }
            }
            else{
                complete(nil, error?.localizedDescription)
            }
        }
    }
    
    // Delete Sleep Data
    func deleteSleepData(_ sleep: Sleep, complete: @escaping (Bool, String?) -> Void) -> Void {
        let params: [String: Any] = [
            "id": sleep.id
        ]
        requestWithToken(method: .post, endPoint: apiDeleteSleepData, params: params, headers: nil, encoding: JSONEncoding.default) { (response, error, resoponseCode) in
            if let json = response {
                let errors = json["errors"].array
                
                if errors == nil{
                    complete(true, nil)
                } else {
                    var message = "Occur error on Server"
                    if errors!.count > 0 {
                        message = errors![0]["message"].string ?? message
                    }
                    complete(false, message)
                }
            }
            else{
                complete(false, error?.localizedDescription)
            }
        }
    }
    
    // Get AlcoholUse Data
    func getAlcoholUseData(complete: @escaping ([AlcoholUse]?, String?) -> Void) -> Void {
        requestWithToken(method: .get, endPoint: apiGetAlcoholUseData, params: nil) { (response, error, resoponseCode) in
            if let json = response {
                let errors = json["errors"].array
                
                if errors == nil{
                    if let data = json["data"].array {
                        let alcoholUses = data.map({return AlcoholUse($0)})
                        complete(alcoholUses, nil)
                    }
                    else {
                        complete([], nil)
                    }
                } else {
                    var message = "Occur error on Server"
                    if errors!.count > 0 {
                        message = errors![0]["message"].string ?? message
                    }
                    complete(nil, message)
                }
            }
            else{
                complete(nil, error?.localizedDescription)
            }
        }
    }
    
    // Set AlcoholUse Data
    func setAlcoholUseData(_ dataset: [(Date, Double)], complete: @escaping ([AlcoholUse]?, String?) -> Void) -> Void {
        var data: [[String: Any]] = [[String: Any]]()
        for alcoholUse in dataset {
            data.append([
                "date": alcoholUse.0.toString,
                "alcohol": alcoholUse.1
            ])
        }
        let params: [String: Any] = [
            "data": data
        ]
        requestWithToken(method: .post, endPoint: apiSetAlcoholUseData, params: params, headers: nil, encoding: JSONEncoding.default) { (response, error, resoponseCode) in
            if let json = response {
                let errors = json["errors"].array
                
                if errors == nil{
                    if let data = json["data"].array {
                        let alcoholUses = data.map({return AlcoholUse($0)})
                        complete(alcoholUses, nil)
                    }
                    else {
                        complete([], nil)
                    }
                } else {
                    var message = "Occur error on Server"
                    if errors!.count > 0 {
                        message = errors![0]["message"].string ?? message
                    }
                    complete(nil, message)
                }
            }
            else{
                complete(nil, error?.localizedDescription)
            }
        }
    }
    
    // Add AlcoholUse Data
    func addAlcoholUseData(_ alcoholUse: (Date, Double), complete: @escaping (AlcoholUse?, String?) -> Void) -> Void {
        let params: [String: Any] = [
            "data": [
                "date": alcoholUse.0.toString,
                "alcohol": alcoholUse.1
            ]
        ]
        requestWithToken(method: .post, endPoint: apiAddAlcoholUseData, params: params, headers: nil, encoding: JSONEncoding.default) { (response, error, resoponseCode) in
            if let json = response {
                let errors = json["errors"].array
                
                if errors == nil{
                    if json["data"].dictionary != nil {
                        let alcoholUse = AlcoholUse(json["data"])
                        complete(alcoholUse, nil)
                    }
                    else {
                        complete(nil, nil)
                    }
                } else {
                    var message = "Occur error on Server"
                    if errors!.count > 0 {
                        message = errors![0]["message"].string ?? message
                    }
                    complete(nil, message)
                }
            }
            else{
                complete(nil, error?.localizedDescription)
            }
        }
    }
    
    // Delete AlcoholUse Data
    func deleteAlcoholUseData(_ alcoholUse: AlcoholUse, complete: @escaping (Bool, String?) -> Void) -> Void {
        let params: [String: Any] = [
            "id": alcoholUse.id
        ]
        requestWithToken(method: .post, endPoint: apiDeleteAlcoholUseData, params: params, headers: nil, encoding: JSONEncoding.default) { (response, error, resoponseCode) in
            if let json = response {
                let errors = json["errors"].array
                
                if errors == nil{
                    complete(true, nil)
                } else {
                    var message = "Occur error on Server"
                    if errors!.count > 0 {
                        message = errors![0]["message"].string ?? message
                    }
                    complete(false, message)
                }
            }
            else{
                complete(false, error?.localizedDescription)
            }
        }
    }
    
    // Get Blood Pressure Data
    func getBloodPressureData(complete: @escaping ([BloodPressure]?, String?) -> Void) -> Void {
        requestWithToken(method: .get, endPoint: apiGetBloodPressureData, params: nil) { (response, error, resoponseCode) in
            if let json = response {
                let errors = json["errors"].array
                
                if errors == nil{
                    if let data = json["data"].array {
                        let bloodPressures = data.map({return BloodPressure($0)})
                        complete(bloodPressures, nil)
                    }
                    else {
                        complete([], nil)
                    }
                } else {
                    var message = "Occur error on Server"
                    if errors!.count > 0 {
                        message = errors![0]["message"].string ?? message
                    }
                    complete(nil, message)
                }
            }
            else{
                complete(nil, error?.localizedDescription)
            }
        }
    }
    
    // Set Blood Pressure Data
    func setBloodPressureData(_ dataset: [(Date, String, Double, String, Double)], complete: @escaping ([BloodPressure]?, String?) -> Void) -> Void {
        var data: [[String: Any]] = [[String: Any]]()
        for bloodPressure in dataset {
            data.append([
                "date": bloodPressure.0.toString,
                "sys_uuid": bloodPressure.1,
                "systolic": bloodPressure.2,
                "dia_uuid": bloodPressure.3,
                "diastolic": bloodPressure.4
            ])
        }
        let params: [String: Any] = [
            "data": data
        ]
        requestWithToken(method: .post, endPoint: apiSetBloodPressureData, params: params, headers: nil, encoding: JSONEncoding.default) { (response, error, resoponseCode) in
            if let json = response {
                let errors = json["errors"].array
                
                if errors == nil{
                    if let data = json["data"].array {
                        let bloodPressures = data.map({return BloodPressure($0)})
                        complete(bloodPressures, nil)
                    }
                    else {
                        complete([], nil)
                    }
                } else {
                    var message = "Occur error on Server"
                    if errors!.count > 0 {
                        message = errors![0]["message"].string ?? message
                    }
                    complete(nil, message)
                }
            }
            else{
                complete(nil, error?.localizedDescription)
            }
        }
    }
    
    // Add Blood Pressure Data
    func addBloodPressureData(_ bloodPressure: (Date, String, Double, String, Double), complete: @escaping (BloodPressure?, String?) -> Void) -> Void {
        let params: [String: Any] = [
            "data": [
                "date": bloodPressure.0.toString,
                "sys_uuid": bloodPressure.1,
                "systolic": bloodPressure.2,
                "dia_uuid": bloodPressure.3,
                "diastolic": bloodPressure.4
            ]
        ]
        requestWithToken(method: .post, endPoint: apiAddBloodPressureData, params: params, headers: nil, encoding: JSONEncoding.default) { (response, error, resoponseCode) in
            if let json = response {
                let errors = json["errors"].array
                
                if errors == nil{
                    if json["data"].dictionary != nil {
                        let bloodPressures = BloodPressure(json["data"])
                        complete(bloodPressures, nil)
                    }
                    else {
                        complete(nil, nil)
                    }
                } else {
                    var message = "Occur error on Server"
                    if errors!.count > 0 {
                        message = errors![0]["message"].string ?? message
                    }
                    complete(nil, message)
                }
            }
            else{
                complete(nil, error?.localizedDescription)
            }
        }
    }
    
    // Delete Blood Pressure Data
    func deleteBloodPressureData(_ bloodPressure: BloodPressure, complete: @escaping (Bool, String?) -> Void) -> Void {
        let params: [String: Any] = [
            "id": bloodPressure.id
        ]
        requestWithToken(method: .post, endPoint: apiDeleteBloodPressureData, params: params, headers: nil, encoding: JSONEncoding.default) { (response, error, resoponseCode) in
            if let json = response {
                let errors = json["errors"].array
                
                if errors == nil{
                    complete(true, nil)
                } else {
                    var message = "Occur error on Server"
                    if errors!.count > 0 {
                        message = errors![0]["message"].string ?? message
                    }
                    complete(false, message)
                }
            }
            else{
                complete(false, error?.localizedDescription)
            }
        }
    }
    
    func getECGData(_ lastAt:String, complete: @escaping ([Ecg]?, String?) -> Void) -> Void {
        let param = lastAt.replacingOccurrences(of: " ", with: "%20")
        requestWithToken(method: .get, endPoint: ecgDataUri + "?lastAt=" + param, params: nil) { (response, error, resoponseCode) in
            if let json = response {
                let errors = json["errors"].array
                
                if errors == nil{
                    if let data = json["data"].array {
                        var ecgs = [Ecg]()
                        for item in data {
                            let ecg = Ecg(item)
                            ecg.setVoltages()
                            ecgs.append(ecg)
                        }
                        
                        complete(ecgs, nil)
                    }
                    else {
                        complete([], nil)
                    }
                } else {
                    var message = "Occur error on Server"
                    if errors!.count > 0 {
                        message = errors![0]["message"].string ?? message
                    }
                    complete(nil, message)
                }
            }
            else{
                complete(nil, error?.localizedDescription)
            }
        }
    }
    
    func setECGData(_ dataset: [Ecg], complete: @escaping ([Ecg]?, String?) -> Void) -> Void {
        let dic = getECGDic(dataset)
        let params: [String: Any] = [
            "data": dic as Any
        ]
        
        requestWithToken(method: .post, endPoint: ecgDataUri, params: params, headers: nil, encoding: JSONEncoding.default) { (response, error, resoponseCode) in
            if let json = response {
                let errors = json["errors"].array
                
                if errors == nil{
                    complete([], nil)                    
                } else {
                    var message = "Occur error on Server"
                    if errors!.count > 0 {
                        message = errors![0]["message"].string ?? message
                    }
                    complete(nil, message)
                }
            }
            else{
                complete(nil, error?.localizedDescription)
            }
        }
    }
    
    func uploadEcgFile(_ data:Data, complete:@escaping (String?) -> Void) -> Void {
        let url = baseURL + fileDataUri
        Alamofire.upload(multipartFormData: { (multipartFormData) in
            multipartFormData.append(data, withName: "file", fileName: "ekg.txt", mimeType: "application/octet-stream")
        }, usingThreshold: 10240000, to: url, method: .post, headers: self.getHeaderWithToken()) { (ret) in
            switch ret {
            case .success(let request, _, _):
                request.responseJSON { (response) in
                    print("**** Response from server : url = \(url) **** \n")

                    let statusCode = response.response?.statusCode ?? HttpResponseCode.unauthorized.rawValue
                    print("Http request respone code = \(statusCode)")
                    if let data = response.data {
                        complete(String(decoding: data, as: UTF8.self))
                    } else {
                        complete(nil)
                    }
                    print(String(decoding: response.data!, as: UTF8.self))
                    
                }
                break
            case .failure(let error):
                complete(nil)
                break
            }
        }
    }
    */
    
    // Get Doctor List
    func getDoctorList(complete: @escaping ([Doctor]?, String?, Bool) -> Void) -> Void {
        requestWithToken(method: .get, endPoint: apiGetDoctorList, params: nil) { (response, error, resoponseCode) in
            if let json = response {
                let errors = json["errors"].array
                
                if errors == nil, let data = json["data"].array {
                    let doctors = data.map({return Doctor($0)})
                    complete(doctors, nil, true)
                } else {
                    var errorMessge = ""
                    if errors!.count > 0 {
                        errorMessge = errors![0]["message"].stringValue
                    }
                    complete(nil, errorMessge, false)
                }
            }
            else{
                complete(nil, error?.localizedDescription, false)
            }
        }
    }
    
    // Get Chat Room or Create New Room
    func getOrCreateChatRoom(params: [String: Int], complete: @escaping JSONResponse) -> Void {
        requestWithToken(method: .post, endPoint: apiGetChatRoom, params: params) { (response, error, resoponseCode) in
            if let json = response {
                let errors = json["errors"].array
                
                if let errors = errors, errors.count > 0 {
                    var message = "Occur error on Server"
                    message = errors[0]["message"].string ?? message
                    print("Error on give feedback: \(message)")
                    complete(errors[0], nil, true)
                }
                else if json["data"]["room_id"].string != nil {
                    complete(json["data"], nil, true)
                }
                else {
                    complete(nil, nil, true)
                }
            }
            else{
                complete(nil, error?.localizedDescription, false)
            }
        }
    }
    
    // Close Chat Room
    func closeChatRoom(params: [String: String], complete: @escaping JSONResponse) -> Void {
        
        requestWithToken(method: .post, endPoint: apiCloseChatRoom, params: params) { (response, error, resoponseCode) in
            if let json = response {
                let error = json["errors"].array
                
                if error == nil{
                    complete(nil, nil, true)
                } else {
                    let firstError = error![0]
                    complete(firstError, nil, true)
                }
            }
            else{
                complete(nil, error?.localizedDescription, false)
            }
        }
    }
    
    // FeedBack to doctor
    func giveFeedBack(params: [String: Any], doctorId: Int, complete: @escaping JSONResponse) -> Void {
        requestWithToken(method: .post, endPoint: apiGiveFeedBack + String(doctorId), params: params) { (response, error, resoponseCode) in
            if let json = response {
                let errors = json["errors"].array
                
                if let errors = errors, errors.count > 0 {
                    var message = "Occur error on Server"
                    message = errors[0]["message"].string ?? message
                    print("Error on give feedback: \(message)")
                }
                complete(nil, nil, true)
            }
            else{
                complete(nil, error?.localizedDescription, false)
            }
        }
    }
    
    // Get Active payments
    func getGetActivePayments(complete: ((Payment?, Error?) -> Void)?) -> Void {
        requestWithToken(method: .get, endPoint: apiGetActivePayment, params: nil) { (response, error, resoponseCode) in
            if let json = response {
                let errors = json["errors"].array
                
                if errors == nil{
                    var payment: Payment? = nil
                    if json["data"].dictionaryObject != nil {
                        payment = Payment(json["data"])
                    }
                    UserInfo.sharedInstance.userPayment = payment
                    complete?(payment, nil)
                } else {
                    complete?(nil, error)
                }
            }
            else{
                complete?(nil, error)
            }
        }
    }
    
    // Get Stripe Ephemeral Keys
    func getStripeEphemeralKeys(params: [String: Any], complete: @escaping ([String: Any]?, Error?) -> Void) -> Void {
        requestWithToken(method: .post, endPoint: apiGetStripeEphemeralKeys, params: params) { (response, error, resoponseCode) in
            if let json = response {
                let errors = json["errors"].array
                
                if errors == nil{
                    complete(json["data"].dictionaryObject, nil)
                } else {
                    complete(nil, error)
                }
            }
            else{
                complete(nil, error)
            }
        }
    }
    
    // Get Stripe Payment Intent
    func getStripePaymentIntent(params: [String: Any], complete: @escaping (String?, Error?) -> Void) -> Void {
        requestWithToken(method: .post, endPoint: apiGetStripePaymentIntent, params: params) { (response, error, resoponseCode) in
            if let json = response {
                let errors = json["errors"].array
                
                if errors == nil{
                    complete(json["data"].string, nil)
                } else {
                    complete(nil, error)
                }
            }
            else{
                complete(nil, error)
            }
        }
    }
    
    // One Time pay
    func oneTimePay(params: [String: Any], complete: ((Payment?, Error?) -> Void)?) -> Void {
        requestWithToken(method: .post, endPoint: apiOneTimePay, params: params) { (response, error, resoponseCode) in
            if let json = response {
                let errors = json["errors"].array
                
                if errors == nil{
                    var payment: Payment? = nil
                    if json["data"]["payment"].dictionaryObject != nil {
                        payment = Payment(json["data"]["payment"])
                    }
                    UserInfo.sharedInstance.userPayment = payment
                    complete?(payment, nil)
                } else {
                    complete?(nil, error)
                }
            }
            else{
                complete?(nil, error)
            }
        }
    }
    
    // subscribe
    func subscribe(params: [String: Any], complete: ((Payment?, Error?) -> Void)?) -> Void {
        requestWithToken(method: .post, endPoint: apiStripeSubscibe, params: params) { (response, error, resoponseCode) in
            if let json = response {
                let errors = json["errors"].array
                
                if errors == nil{
                    var payment: Payment? = nil
                    if json["data"]["payment"].dictionaryObject != nil {
                        payment = Payment(json["data"]["payment"])
                    }
                    UserInfo.sharedInstance.userPayment = payment
                    complete?(payment, nil)
                } else {
                    complete?(nil, error)
                }
            }
            else{
                complete?(nil, error)
            }
        }
    }
    
    // cancel subscribe
    func cancelSubscription(params: [String: Any], complete: ((Bool, Error?) -> Void)?) -> Void {
        requestWithToken(method: .post, endPoint: apiStripeCancelSubsciption, params: params) { (response, error, resoponseCode) in
            if let json = response {
                let errors = json["errors"].array
                
                if errors == nil{
                    if json["data"].dictionaryObject != nil {
                        UserInfo.sharedInstance.userPayment = nil
                        complete?(true, nil)
                    }
                    complete?(false, error)
                } else {
                    complete?(false, error)
                }
            }
            else{
                complete?(false, error)
            }
        }
    }
    
    func getLogo(complete: @escaping (String?) -> Void) -> Void {
        requestWithToken(method: .get, endPoint: apiLogo, params: nil) { (response, error, resoponseCode) in
            if let json = response {
                let errors = json["errors"].array
                
                if errors == nil{
                    if let data = json["data"].dictionary {
                        if let logo = data["logo"]{
                            complete(logo.string)
                        }
                    }
                    else {
                        complete(nil)
                    }
                } else {
                    var message = "Occur error on Server"
                    if errors!.count > 0 {
                        message = errors![0]["message"].string ?? message
                    }
                    complete(nil)
                }
            }
            else{
                complete(nil)
            }
        }
    }
}
