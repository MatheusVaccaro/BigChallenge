//
//  RandomSwipeTextGenerator.swift
//  Reef
//
//  Created by Matheus Vaccaro on 07/11/18.
//  Copyright © 2018 Matheus Vaccaro. All rights reserved.
//

import Foundation

class RandomSwipeTextGenerator {
    
    static let shared = RandomSwipeTextGenerator()
    
    let completed: [String]
    private var randomCompleted: [Int]!
    private var lastCompletedIndex: Int = 0
    
    let readmitted: [String]
    private var randomReadmitted: [Int]!
    private var lastReadmittedIndex: Int = 0
    
    let deleted: [String]
    private var randomDeleted: [Int]!
    private var lastDeletedIndex: Int = 0
    
    private init() {
        self.completed = [Strings.Task.Cell.Swipe.Text.completed1,
                          Strings.Task.Cell.Swipe.Text.completed2,
                          Strings.Task.Cell.Swipe.Text.completed3,
                          Strings.Task.Cell.Swipe.Text.completed4,
                          Strings.Task.Cell.Swipe.Text.completed5]
        self.readmitted = [Strings.Task.Cell.Swipe.Text.readmitted1,
                           Strings.Task.Cell.Swipe.Text.readmitted2,
                           Strings.Task.Cell.Swipe.Text.readmitted3,
                           Strings.Task.Cell.Swipe.Text.readmitted4]
        self.deleted = [Strings.Task.Cell.Swipe.Text.deleted1]
        
        self.randomCompleted = generateRandomArray(size: completed.count, notStartingWith: lastCompletedIndex)
        self.randomReadmitted = generateRandomArray(size: readmitted.count, notStartingWith: lastReadmittedIndex)
        self.randomDeleted = generateRandomArray(size: deleted.count, notStartingWith: lastDeletedIndex)
    }
    
    private func generateRandomArray(size: Int, notStartingWith value: Int) -> [Int] {
        var array: [Int] = []
        for index in 0..<size {
            var elementAdded = false
            repeat {
                let random = Int(arc4random_uniform(UInt32(size)))
                if size != 1 && index == 0 && random == value {
                    continue
                }
                if !array.contains(random) {
                    array.append(random)
                    elementAdded = true
                }
            } while !elementAdded
        }
        return array
    }
    
    func nextText(forTask taskType: RandomSwipeTextGenerator.TextType) -> String {
        switch taskType {
        case .completed:
            if randomCompleted.isEmpty {
                randomCompleted = generateRandomArray(size: completed.count, notStartingWith: lastCompletedIndex)
                return nextText(forTask: .completed)
            } else {
                let index = randomCompleted.removeFirst()
                lastCompletedIndex = index
                return completed[index]
            }
        case .readmitted:
            if randomReadmitted.isEmpty {
                randomReadmitted = generateRandomArray(size: readmitted.count, notStartingWith: lastReadmittedIndex)
                return nextText(forTask: .readmitted)
            } else {
                let index = randomReadmitted.removeFirst()
                lastReadmittedIndex = index
                return readmitted[index]
            }
        case .deleted:
            if randomDeleted.isEmpty {
                randomDeleted = generateRandomArray(size: deleted.count, notStartingWith: lastDeletedIndex)
                return nextText(forTask: .deleted)
            } else {
                let index = randomDeleted.removeFirst()
                lastDeletedIndex = index
                return deleted[index]
            }
        }
    }
    
    enum TextType {
        case completed
        case readmitted
        case deleted
    }
}
