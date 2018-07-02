//
//  Persistence.swift
//  BigChallenge
//
//  Created by Matheus Vaccaro on 25/05/18.
//  Copyright © 2018 Matheus Vaccaro. All rights reserved.
//

import Foundation

public protocol PersistenceProtocol {
    func create<T: Storable>(_ model: T.Type) -> T
    func fetch<T: Storable>(_ model: T.Type, predicate: NSPredicate?, completion: (([T]) -> ()))
    func save()
    func delete(_ object: Storable)
}
