//
//  NetworkManager.swift
//  AlaskaTest
//
//  Created by Kiran on 09/01/19.
//  Copyright © 2019 Kiran. All rights reserved.
//

import UIKit

class NetworkManager: NSObject {

    typealias CompletionHandler = (_ success:Bool, _ responseArray : [[String : Any]]?) -> Void

    
    // Service call with "GET" function, using URL Session
     static func fetchFlightDetailsResponse(_ urlString:String, completionHandler : @escaping CompletionHandler) {
        
        let url = URL(string: urlString)
        
        let request = NSMutableURLRequest(url: url!)
        
        // setting request headers
        request.addValue("0a570f0bf03d46089b7829d7304831e4", forHTTPHeaderField: "Ocp-Apim-Subscription-Key")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.httpMethod = "GET"
        
        // request timeout intervel is set to 60
        request.timeoutInterval = 60
        let session = URLSession.shared
        
        // response being received.
        let dataTask = session.dataTask(with: request as URLRequest) { (data, response, error) -> Void in
            var responseArray : [[String : Any]]? = nil
            if  let dataResponse = data {
                let responseObj = try! JSONSerialization.jsonObject(with: dataResponse, options:
                    .mutableContainers)
                if responseObj is [Any]{
                    responseArray = responseObj as? [[String : Any]]
                    print("Response: %@", responseArray)
                    completionHandler(true,responseArray)
                }else{
                    completionHandler(false,responseArray)
                    print("Error: \(String(describing: error))")
              }
        }else{
            print("Error: \(String(describing: error))")
            completionHandler(false,responseArray)
        }
        
    }
        dataTask.resume()

    }
}
