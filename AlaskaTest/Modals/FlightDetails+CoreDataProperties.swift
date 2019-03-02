//
//  FlightDetails+CoreDataProperties.swift
//  AlaskaTest
//
//  Created by Sai Sailesh Kumar Suri on 10/01/19.
//  Copyright © 2019 Kiran. All rights reserved.
//
//

import Foundation
import CoreData


extension FlightDetails {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<FlightDetails> {
        return NSFetchRequest<FlightDetails>(entityName: "FlightDetails")
    }

    @NSManaged public var flightId: String?
    @NSManaged public var tailId: String?
    @NSManaged public var estArrivalTime: Date?
    @NSManaged public var schArrivalTime: String?
    @NSManaged public var origin: String?
    @NSManaged public var airport: String?
    @NSManaged public var retrievedTime: String?

}
