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

class BigTagCollectionViewController: UIViewController {
    
    public var tagsObservable: BehaviorSubject<[Tag]> {
        return viewModel!.tagsObservable
    }
    
    var viewModel: TagCollectionViewModel!
    
    @IBOutlet weak var tagsCollectionView: UICollectionView!
    @IBOutlet weak var collectionViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var tagsLabel: UILabel!
    
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() { // OVERRIDE
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        bindCollectionView()
        tagsCollectionView.allowsMultipleSelection = true
        if let layout = tagsCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.estimatedItemSize = CGSize(width: 150, height: 40)
        }
        
        tagsLabel.text = Strings.Tag.CollectionScreen.title
    }
    
    private func select(_ bool: Bool, at index: IndexPath, animated: Bool = false) {
        if bool {
            tagsCollectionView.selectItem(at: index,
                                          animated: animated,
                                          scrollPosition: UICollectionViewScrollPosition.right)
        } else {
            tagsCollectionView.deselectItem(at: index,
                                            animated: animated)
        }
    }
    
    private func loadSelection(for cell: UICollectionViewCell, tag: Tag, at indexPath: IndexPath) {
        if self.viewModel.selectedTags.contains(tag) {
            cell.isSelected = true
            self.select(true, at: indexPath)
        } else {
            cell.isSelected = false
            self.select(false, at: indexPath)
        }
    }
    
    func bindCollectionView() { //OVERRIDE
        viewModel.tagsObservable
        .bind(to: tagsCollectionView.rx
        .items(cellIdentifier: TagCollectionViewCell.identifier,
               cellType: TagCollectionViewCell.self)) { (row, tag, cell) in
                        
                print("updating collection with tag \(tag.title!)")
                let viewModel = self.viewModel.tagCollectionCellViewModel(for: tag)
                let index = IndexPath(row: row, section: 0)
                
                cell.configure(with: viewModel)
                self.loadSelection(for: cell, tag: tag, at: index)
                if row == self.viewModel.tags.count-1 {
                    self.collectionViewHeightConstraint.constant =
                        self.tagsCollectionView.collectionViewLayout.collectionViewContentSize.height
                }
                
            }.disposed(by: disposeBag)
        
        tagsCollectionView.rx.modelSelected(Tag.self).subscribe { event in // selected x item in collection
            self.viewModel.selectedTagEvent.on(event) // send to viewModel
        }.disposed(by: disposeBag)
        
        tagsCollectionView.rx.modelDeselected(Tag.self).subscribe { event in
            self.viewModel.selectedTagEvent.on(event)
        }.disposed(by: disposeBag)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        dismiss(animated: true)
    }
}

extension BigTagCollectionViewController: StoryboardInstantiable {
    static var viewControllerID: String {
        return "BigTagCollectionViewController"
    }
    
    static var storyboardIdentifier: String {
        return "TagCollection"
    }
}
