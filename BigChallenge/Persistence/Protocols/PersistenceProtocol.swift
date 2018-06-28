//
//  Persistence.swift
//  BigChallenge
//
//  Created by Matheus Vaccaro on 25/05/18.
//  Copyright © 2018 Matheus Vaccaro. All rights reserved.
//

import Foundation

public protocol PersistenceProtocol {
    func fetchAll<T: Storable>(_ model: T.Type) -> [T]
    func save(object: Storable)
    func remove(object: Storable)
<<<<<<< Updated upstream:BigChallenge/Persistence/Protocols/Persistence.swift
    func remove(at index: Int)
    func update(object: Storable)
=======
//    func update(object: Storable)
>>>>>>> Stashed changes:BigChallenge/Persistence/Protocols/PersistenceProtocol.swift
}
