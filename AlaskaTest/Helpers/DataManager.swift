//
//  DataManager.swift
//  AlaskaTest
//
//  Created by Kiran on 10/01/19.
//  Copyright © 2019 Kiran. All rights reserved.
//

import UIKit
import CoreData

class DataManager: NSObject {
    
    func insertFlightDetails(_ flightDetailsArray:NSArray,_ searchedAirport:String){
        let appdelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appdelegate.persistentContainer.viewContext
        let retrievedTime = Utilities.getCurrentTime()
        
        for dictionary in flightDetailsArray {
            let flightdetailsDict : NSDictionary = dictionary as! NSDictionary
            let strFlightId : String = flightdetailsDict.value(forKey: "FltId") as! String
            
            if checkForFlightDetails(flightId: strFlightId){
                
                let entity = NSEntityDescription.entity(forEntityName: "FlightDetails", in: context)
                let flightDetails = NSManagedObject(entity: entity!, insertInto: context) as! FlightDetails
                
                flightDetails.setValue(flightdetailsDict.value(forKey: Constants.flightId), forKey: "flightId")
                
                let estimatedDate : Date = Utilities.getDateFromString(flightdetailsDict.value(forKey: Constants.estimatedArrivalTime) as! String)
                flightDetails.setValue(estimatedDate, forKey: "estArrivalTime")
                flightDetails.setValue(flightdetailsDict.value(forKey: Constants.scheduledArrivalTime), forKey: "schArrivalTime")
                flightDetails.setValue(flightdetailsDict.value(forKey: Constants.origin), forKey: "origin")
                flightDetails.setValue(flightdetailsDict.value(forKey: Constants.tailId), forKey: "tailId")
                flightDetails.setValue(retrievedTime, forKey: "retrievedTime")
                flightDetails.setValue(searchedAirport, forKey: "airport")

                appdelegate.saveContext()
            }
        }
    }

    func checkForFlightDetails(flightId : String) -> Bool {
        let appdelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appdelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>.init(entityName: "FlightDetails")
        request.predicate = NSPredicate.init(format: "flightId == %@",flightId)
        request.returnsObjectsAsFaults = false
        
        do {
            let results = try context.fetch(request)
            
            if results.count > 0 {
                return false
            }
        } catch  {
            print("Error fetching data")
        }
        
        return true
    }
    
    func fetchFlightDetails() ->  [FlightDetails]{
            let appdelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appdelegate.persistentContainer.viewContext
            let sort:NSSortDescriptor = NSSortDescriptor(key:"estArrivalTime", ascending: true)
            let request = NSFetchRequest<NSFetchRequestResult>.init(entityName: "FlightDetails")
            request.sortDescriptors = [sort]
            request.returnsObjectsAsFaults = false
            
            do {
                let results = try context.fetch(request)
                
                if results.count > 0 {
                    return results as! [FlightDetails]
                }
             
            } catch  {
                print("Error fetching data")
            }
        return []
    }
    
    //The app should not display data that is more than 10 minutes old.
    
    func remove10MinOldData()  {
      
        let appdelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appdelegate.persistentContainer.viewContext

        let flightDetails : [FlightDetails] = self.fetchFlightDetails()
        let strCurrentTime = Utilities.getCurrentTime()

        for fDetail in flightDetails {
            
            let flightDetail : FlightDetails = fDetail
            let dataRetrievedTime = Utilities.getDateFromString(flightDetail.retrievedTime ?? "")
            let currentDateTime = Utilities.getDateFromString(strCurrentTime)
            
            let meanInterval = currentDateTime.timeIntervalSince(dataRetrievedTime)
            let validity = Int(meanInterval)/60
            if validity > 10 {
                context.delete(flightDetail)
                appdelegate.saveContext()
            }
        }
    }
    

}
