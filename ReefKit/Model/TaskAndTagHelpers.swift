//
//  TaskAndTagExtraVariables.swift
//  Reef
//
//  Created by Bruno Fulber Wide on 20/08/18.
//  Copyright © 2018 Matheus Vaccaro. All rights reserved.
//

import Foundation
import CoreLocation
import UIKit

public extension Tag {
    public var allTasks: [Task] {
        return tasks!.allObjects as! [Task] //swiftlint:disable:this force_cast
    }
    
    public var color: UIColor {
        return UIColor(cgColor: UIColor.tagColors[Int(colorIndex)].first!)
    }
    
    public var colors: [CGColor] {
        return UIColor.tagColors[Int(colorIndex)]
    }
    
    public var location: CLCircularRegion? {
        if let data = locationData {
            return NSKeyedUnarchiver.unarchiveObject(with: data) as? CLCircularRegion
        } else {
            return nil
        }
    }
}

extension Tag: Comparable {
    public static func < (lhs: Tag, rhs: Tag) -> Bool {
        return lhs.title! < rhs.title!
    }
}

public extension Task {
    public var allTags: [Tag] {
        guard tags != nil else { return [] }
        return tags!.allObjects as! [Tag] //swiftlint:disable:this force_cast
    }
    
    public var location: CLCircularRegion? {
        if let data = locationData {
            return NSKeyedUnarchiver.unarchiveObject(with: data) as? CLCircularRegion
        } else {
            return nil
        }
    }
    
    public var locations: [CLCircularRegion] {
        var ans: [CLCircularRegion] = []
        
        if let data =
            self.locationData { ans.append(NSKeyedUnarchiver.unarchiveObject(with: data) as! CLCircularRegion) }
        
        let tagsData = self
            .allTags
            .map { $0.locationData }
        
        for data in tagsData where data != nil {
            ans.append(NSKeyedUnarchiver.unarchiveObject(with: data!) as! CLCircularRegion)
        }
        
        return ans
    }
    
    public var dates: [Date] {
        var dates: [Date] = []
        
        if let dueDate = dueDate { dates.append(dueDate) }
        dates.append(contentsOf: allTags
            .map { $0.dueDate }
            .filter { $0 != nil } as! [Date]) //swiftlint:disable:this force_cast
        
        return dates
    }
    
    public var isPrivate: Bool {
        return allTags.contains { $0.requiresAuthentication }
    }
    
    public func isInside(_ location: CLLocationCoordinate2D) -> Bool {
        for taskLocation in locations where taskLocation.contains( location ) { return true }
        return false
    }
    
    public func isBefore(_ task: Task) -> Bool {
        guard !dates.isEmpty, !task.dates.isEmpty else { return false }
        return dates.min()! < task.dates.min()!
    }
}
