//
//  ApiManager.swift
//  Share
//
//  Created by Rener on 9/3/20.
//  Copyright © 2020 ETU. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire

enum HttpResponseCode : Int{
    case ok = 200
    case badrequest = 400
    case unauthorized = 401
}

class ApiManager {
    
    static var sharedInstance : ApiManager = {
        var instance = ApiManager()
        return instance
    }()
    
    let baseURL = "https://clubafib.com/api/"
    
    let apiUploadImage          = "media/upload"
    let apiAddPost              = "post"
    
    
    typealias DefaultResponse       = (JSON?, Error?, Int) -> Void
    
    // Get Token Header
    func getHeaderWithToken(_ token: String) -> HTTPHeaders{
        let headers: HTTPHeaders = ["Authorization": "Bearer " + token]
        
        return headers
    }

    // MARK - Request Funtions with token
    func requestWithToken(method:HTTPMethod, endPoint:String, params:[String:Any]?, token :String, encoding: ParameterEncoding = URLEncoding.default, complete: @escaping DefaultResponse) -> Void {

        let url = "\(baseURL)\(endPoint)"
        let headers = self.getHeaderWithToken(token)
//        Alamofire.requ
        Alamofire.request(url, method: method, parameters: params, encoding: encoding, headers: headers).responseJSON { (response: DataResponse<Any>) in
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
    func requestWithFiles(method:HTTPMethod, endPoint:String, params:[String:Any]?, URLs : [URL], name:String, token: String, complete:@escaping DefaultResponse) -> Void {

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
        }, usingThreshold: 10240, to: url, method: .post, headers: self.getHeaderWithToken(token)) { (ret) in
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
//        Alamofire.upload(
//            multipartFormData: { multiFormData in
//                for index in 0..<URLs.count {
//                    let file_extension = "jpeg"
//                    let mimeType = "image/jpeg"
//
//                    multiFormData.append(URLs[index], withName: name, fileName: "\(UUID.init().uuidString).\(file_extension)", mimeType: mimeType)
//                }
//
//                if params != nil
//                {
//                    for (key, value) in params! {
//                        multiFormData.append("\(value)".data(using: String.Encoding.utf8)!, withName: key)
//                    }
//                }
//            }, to: url, method: .post , headers: self.getHeaderWithToken(token)).responseJSON { (response: DataResponse<Any>) in
//                print("**** Response from server : url = \(url) **** \n")
//                
//                let statusCode = response.response?.statusCode ?? HttpResponseCode.unauthorized.rawValue
//                print("Http request respone code = \(statusCode)")
//                
//                switch response.result{
//                case .success(let data):
//                    let result = JSON(data)
//                    complete(result, nil, statusCode)
//                    break
//                case .failure(let error):
//                    complete(nil, error, statusCode)
//                    break
//                }
//            }
    }
    
    func uploadImage(urls : [URL], name : String, token: String, complete:@escaping(String?, String?) -> Void) {
        requestWithFiles(method: .post, endPoint: apiUploadImage, params: nil, URLs: urls, name: name, token: token) { (response, error, responseCode) in
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
    
    // add Posts
    func addPost(_ id: Int, params: [String: Any]?, token: String, complete: @escaping (Bool, String?) -> Void) -> Void {
        requestWithToken(method: .post, endPoint: "\(apiAddPost)/\(id)", params: params, token: token) { (response, error, resoponseCode) in
            if let json = response {
                let errors = json["errors"].array
                
                if errors == nil{
                    if json["data"]["post"].dictionaryObject != nil {
                        complete(true, nil)
                    }
                    else {
                        complete(false, nil)
                    }
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

}
