//
//  TaskAndTagExtraVariables.swift
//  Reef
//
//  Created by Bruno Fulber Wide on 20/08/18.
//  Copyright © 2018 Matheus Vaccaro. All rights reserved.
//

import Foundation
import CoreLocation

extension Tag {
    var allTasks: [Task] {
        return tasks!.allObjects as! [Task] //swiftlint:disable:this force_cast
    }
}

extension Task {
    var allTags: [Tag] {
        return tags!.allObjects as! [Tag] //swiftlint:disable:this force_cast
    }
    
    var regions: [CLCircularRegion] {
        var ans: [CLCircularRegion] = []
        
        if let data =
            self.regionData { ans.append(NSKeyedUnarchiver.unarchiveObject(with: data) as! CLCircularRegion) }
        
        let tagsData = self
            .allTags
            .map { $0.regionData }
        
        for data in tagsData where data != nil {
            ans.append(NSKeyedUnarchiver.unarchiveObject(with: data!) as! CLCircularRegion)
        }
        
        return ans
    }
    
    var dates: [Date] {
        var dates: [Date] = []
        
        if let dueDate = dueDate { dates.append(dueDate) }
        dates.append(contentsOf: allTags
            .map { $0.dueDate }
            .filter { $0 != nil } as! [Date]) //swiftlint:disable:this force_cast
        
        return dates
    }
    
    func isInside(_ location: CLLocationCoordinate2D) -> Bool {
        for region in regions where region.contains( location ) { return true }
        return false
    }
    
    func isBefore(_ task: Task) -> Bool {
        guard !dates.isEmpty, !task.dates.isEmpty else { return false }
        return dates.min()! < task.dates.min()!
    }
}
