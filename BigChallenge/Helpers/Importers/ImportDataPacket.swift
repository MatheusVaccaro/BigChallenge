//
//  ImportInfoType.swift
//  BigChallenge
//
//  Created by Max Zorzetti on 24/07/18.
//  Copyright © 2018 Matheus Vaccaro. All rights reserved.
//

import Foundation

/**
 Abstraction of data coming from external import sources.
*/
public enum ImportDataPacket {
    //swiftlint:disable identifier_name
    case remindersDataPacket(id: String, externalId: String?) // 1
    
    // Assigns an identifier to each import source. Required for CoreData.
    var type: Int16 {
        switch self {
        case .remindersDataPacket: return 1 	// Reminders
        }
    }
    
    static func from(_ remindersData: RemindersImportData) -> ImportDataPacket {
        return .remindersDataPacket(id: remindersData.calendarItemIdentifier!,
                                    externalId: remindersData.calendarItemExternalIdentifier)
    }
}
