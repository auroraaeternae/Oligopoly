//
//  Player+CoreDataProperties.swift
//  oligopoly
//
//  Created by yseoyu on 16/05/2018.
//  Copyright © 2018 LePremierChat. All rights reserved.
//
//

import Foundation
import CoreData


extension Player {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Player> {
        return NSFetchRequest<Player>(entityName: "Player")
    }

    @NSManaged public var balance: Int16
    @NSManaged public var isSafe: Bool
    @NSManaged public var name: String?
    @NSManaged public var numberOfRiskGames: Int16
    @NSManaged public var numberOfSafeGames: Int16

}
