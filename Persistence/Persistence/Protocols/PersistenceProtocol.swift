//
//  Persistence.swift
//  BigChallenge
//
//  Created by Matheus Vaccaro on 25/05/18.
//  Copyright © 2018 Matheus Vaccaro. All rights reserved.
//

import Foundation

public protocol PersistenceProtocol {
    func create<T: Storable>(_ model: T.Type) throws -> T
    func fetch<T: Storable>(_ model: T.Type, predicate: NSPredicate?, completion: (([T]) -> Void)) throws
    func save() throws
    func delete(_ object: Storable) throws
}

public protocol PersistenceDelegate: class {
    func persistence(_ persistence: PersistenceProtocol, didInsertObjects objects: [Storable])
    func persistence(_ persistence: PersistenceProtocol, didUpdateObjects objects: [Storable])
    func persistence(_ persistence: PersistenceProtocol, didDeleteObjects objects: [Storable])
    func willSaveContext(in persistence: PersistenceProtocol)
    func didSaveContext(in persistence: PersistenceProtocol)
}

extension PersistenceDelegate {
    public func willSaveContext(in persistence: PersistenceProtocol) { }
    public func didSaveContext(in persistence: PersistenceProtocol) { }
}
