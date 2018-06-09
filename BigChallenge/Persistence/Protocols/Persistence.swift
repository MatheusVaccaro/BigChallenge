//
//  Persistence.swift
//  BigChallenge
//
//  Created by Matheus Vaccaro on 25/05/18.
//  Copyright © 2018 Matheus Vaccaro. All rights reserved.
//

import Foundation

protocol Persistence {
    func fetchAll<T: Storable>(_ model: T.Type) -> [T]
    func save(object: Storable)
    func remove(object: Storable)
    func remove(at index: Int)
    func update(object: Storable)
}
