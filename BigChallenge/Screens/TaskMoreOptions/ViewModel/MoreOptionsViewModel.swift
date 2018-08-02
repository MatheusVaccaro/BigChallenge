//
//  MoreOptionsViewModel.swift
//  BigChallenge
//
//  Created by Matheus Vaccaro on 01/08/18.
//  Copyright © 2018 Matheus Vaccaro. All rights reserved.
//

import Foundation

class MoreOptionsViewModel: MoreOptionsViewModelProtocol {
    
    private var numberOfRowsInSection0: Int
    private var numberOfRowsInSection1: Int
    private(set) var isShowingLocationCell: Bool
    private(set) var isShowingTimeCell: Bool
    
    init() {
        self.numberOfRowsInSection0 = 0
        self.numberOfRowsInSection1 = 0
        self.isShowingLocationCell = false
        self.isShowingTimeCell = false
    }
    
    func numberOfRows(in section: Int) -> Int {
        if section == 0 {
            return numberOfRowsInSection0
        } else if section == 1 {
            return numberOfRowsInSection1
        } else {
            return 0
        }
    }
    
    func numberOfSections() -> Int {
        return 2
    }
    
    func showLocationCell() {
        if !isShowingLocationCell {
            isShowingLocationCell.toggle()
            numberOfRowsInSection0 += 1
        }
    }
    
    func collapseLocationCell() {
        if isShowingLocationCell {
            isShowingLocationCell.toggle()
            numberOfRowsInSection0 -= 1
        }
    }
    
    func showTimeCell() {
        if !isShowingTimeCell {
            isShowingTimeCell.toggle()
            numberOfRowsInSection1 += 1
        }
    }
    
    func collapseTimeCell() {
        if isShowingTimeCell {
            isShowingTimeCell.toggle()
            numberOfRowsInSection1 -= 1
        }
    }
    
    func locationViewModel() -> MoreOptionsTableViewCellViewModelProtocol {
        return LocationTableViewCellViewModel()
    }
    
    func timeViewModel() -> MoreOptionsTableViewCellViewModelProtocol {
        return TimeTableViewCellViewModel()
    }
    
}
