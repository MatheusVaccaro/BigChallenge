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
    
    let readmitted: [String]
    private var randomReadmitted: [Int]!
    
    let deleted: [String]
    private var randomDeleted: [Int]!
    
    private init() {
        self.completed = [Strings.Task.Cell.Swipe.Text.completed]
        self.readmitted = [Strings.Task.Cell.Swipe.Text.readmitted]
        self.deleted = [Strings.Task.Cell.Swipe.Text.deleted]
        
        self.randomCompleted = generateRandomArray(size: completed.count)
        self.randomReadmitted = generateRandomArray(size: readmitted.count)
        self.randomDeleted = generateRandomArray(size: deleted.count)
    }
    
    private func generateRandomArray(size: Int) -> [Int] {
        var array: [Int] = []
        for _ in 0..<size {
            var elementAdded = false
            repeat {
                let random = Int(arc4random_uniform(UInt32(size)))
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
            guard let index = randomCompleted.first else {
                randomCompleted = generateRandomArray(size: completed.count)
                return nextText(forTask: .completed)
            }
            return completed[index]
        case .readmitted:
            guard let index = randomReadmitted.first else {
                randomReadmitted = generateRandomArray(size: readmitted.count)
                return nextText(forTask: .readmitted)
            }
            return readmitted[index]
        case .deleted:
            guard let index = randomDeleted.first else {
                randomDeleted = generateRandomArray(size: deleted.count)
                return nextText(forTask: .deleted)
            }
            return deleted[index]
        }
    }
    
    enum TextType {
        case completed
        case readmitted
        case deleted
    }
}
