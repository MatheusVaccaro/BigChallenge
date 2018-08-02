//
//  MoreOptionsViewModelProtocol.swift
//  BigChallenge
//
//  Created by Matheus Vaccaro on 01/08/18.
//  Copyright © 2018 Matheus Vaccaro. All rights reserved.
//

import Foundation

protocol MoreOptionsViewModelProtocol {

    var isShowingLocationCell: Bool { get }
    var isShowingTimeCell: Bool { get }
    
    func numberOfRows(in section: Int) -> Int
    func numberOfSections() -> Int
    
    func showLocationCell()
    func collapseLocationCell()
    func showTimeCell()
    func collapseTimeCell()
    
    func locationViewModel() -> MoreOptionsTableViewCellViewModelProtocol
    func timeViewModel() -> MoreOptionsTableViewCellViewModelProtocol
    
}
