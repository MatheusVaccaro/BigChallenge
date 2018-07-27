//
//  bigTagCollectionView.swift
//  BigChallenge
//
//  Created by Bruno Fulber Wide on 18/07/18.
//  Copyright © 2018 Matheus Vaccaro. All rights reserved.
//

import Foundation
import UIKit
import RxCocoa
import RxSwift

class BigTagCollectionViewController: TagCollectionViewController {
    
    override class var tagViewControllerID: String {
        return "BigTagCollectionViewController"
    }
    
    @IBOutlet weak var collectionViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var tagsLabel: UILabel!
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tagsLabel.text = Strings.Tag.CollectionScreen.title
    }
    
    override func bindCollectionView() {
        viewModel.tagsObservable
            .map { return [Item(tag: nil)] + $0.map { Item(tag: $0) } }
            .bind(to: tagsCollectionView.rx
                .items(cellIdentifier: TagCollectionViewCell.identifier,
                       cellType: TagCollectionViewCell.self)) { (row, item, cell) in
                
                        guard let tag = item.tag else {
                            cell.configure()
                            return
                        }
                        
                        let viewModel = self.viewModel.tagCollectionCellViewModel(for: tag)
                        let index = IndexPath(row: row, section: 0)
                        cell.configure(with: viewModel)
                        self.loadSelection(for: cell, tag: tag, at: index)
                
                        if row == self.viewModel.tags.count-1 {
                            self.collectionViewHeightConstraint.constant =
                                self.tagsCollectionView.collectionViewLayout.collectionViewContentSize.height
                        }
                
            }.disposed(by: disposeBag)
        
        tagsCollectionView.rx.modelSelected(Item.self).subscribe { event in
            guard let tag = event.element?.tag else { return }
            self.viewModel.selectedTagEvent.onNext(tag)
        }.disposed(by: disposeBag)
        
        tagsCollectionView.rx.modelDeselected(Item.self).subscribe { event in
            guard let tag = event.element?.tag else { return }
            self.viewModel.selectedTagEvent.onNext(tag)
        }.disposed(by: disposeBag)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        dismiss(animated: true)
    }
}
