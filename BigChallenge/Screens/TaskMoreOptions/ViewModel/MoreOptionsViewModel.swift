//
//  MoreOptionsViewModel.swift
//  BigChallenge
//
//  Created by Matheus Vaccaro on 01/08/18.
//  Copyright © 2018 Matheus Vaccaro. All rights reserved.
//

import Foundation

class MoreOptionsViewModel: MoreOptionsViewModelProtocol {
    
    private var numberOfRows: Int
    private(set) var isShowingLocationCell: Bool
    private(set) var isShowingTimeCell: Bool
    
    init() {
        self.numberOfRows = 2
        self.isShowingLocationCell = false
        self.isShowingTimeCell = false
    }
    
    func numberOfRows(in section: Int) -> Int {
        return numberOfRows
    }
    
    func numberOfSections() -> Int {
        return 1
    }
    
    func showLocationCell() {
        if !isShowingLocationCell {
            isShowingLocationCell.toggle()
            numberOfRows += 1
        }
    }
    
    func collapseLocationCell() {
        if isShowingLocationCell {
            isShowingLocationCell.toggle()
            numberOfRows -= 1
        }
    }
    
    func showTimeCell() {
        if !isShowingTimeCell {
            isShowingTimeCell.toggle()
            numberOfRows += 1
        }
    }
    
    func collapseTimeCell() {
        if isShowingTimeCell {
            isShowingTimeCell.toggle()
            numberOfRows -= 1
        }
    }
    
    func locationViewModel() -> MoreOptionsTableViewCellViewModelProtocol {
        return LocationTableViewCellViewModel()
    }
    
    func timeViewModel() -> MoreOptionsTableViewCellViewModelProtocol {
        return TimeTableViewCellViewModel()
    }
    
}
