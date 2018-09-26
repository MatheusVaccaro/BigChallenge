//
//  DetailsViewModelProtocol.swift
//  Reef
//
//  Created by Bruno Fulber Wide on 26/09/18.
//  Copyright © 2018 Matheus Vaccaro. All rights reserved.
//

import Foundation

protocol AddDetailsProtocol {
    var numberOfSections: Int { get }
    var numberOfRows: Int { get }
    func viewModelForCell(at row: Int) -> IconCellPresentable
    func shouldPresentView(at row: Int)
}
