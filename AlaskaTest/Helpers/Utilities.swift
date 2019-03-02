//
//  Utilities.swift
//  AlaskaTest
//
//  Created by Kiran on 10/01/19.
//  Copyright © 2019 Kiran. All rights reserved.
//

import UIKit

class Utilities: NSObject {

   class func getCurrentTime() -> String {
        let dateFormatter : DateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        let date = Date()
        let dateString = dateFormatter.string(from: date)
        return dateString
    }
    
    class func getDateFromString(_ inputString : String) -> Date{
        var date : Date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        if inputString.count < 2 {
            return date
        }else{
            date = dateFormatter.date(from: inputString)!
            return date
        }
    }
    
    
    class func getStringFromDate(_ inputDate : Date) -> String{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        let dateString = dateFormatter.string(from: inputDate)
        return dateString
    }

    
  
}
