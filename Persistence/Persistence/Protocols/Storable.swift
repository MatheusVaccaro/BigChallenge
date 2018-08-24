//
//  Storable.swift
//  BigChallenge
//
//  Created by Matheus Vaccaro on 25/05/18.
//  Copyright © 2018 Matheus Vaccaro. All rights reserved.
//

import Foundation
import CoreData

public protocol Storable {
    var uuid: UUID { get }
}

extension NSManagedObject: Storable {
    public var uuid: UUID {
        //swiftlint:disable:next force_cast
        return value(forKey: "id") as! UUID
    }
}
