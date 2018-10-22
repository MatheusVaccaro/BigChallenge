//
//  TagsCollectionViewController.swift
//  BigChallenge
//
//  Created by Bruno Fulber Wide on 11/07/18.
//  Copyright © 2018 Matheus Vaccaro. All rights reserved.
//

import UIKit
import Crashlytics
import ReefKit

class TagCollectionViewController: UIViewController {
    
    class var tagViewControllerID: String {
        return "TagCollectionViewController"
    }
    
    @IBOutlet weak var tagsCollectionView: UICollectionView!
    
    var viewModel: TagCollectionViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.translatesAutoresizingMaskIntoConstraints = false
        
        tagsCollectionView.allowsMultipleSelection = true
        if let layout = tagsCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.estimatedItemSize = CGSize(width: 150, height: 40)
        }
        
        tagsCollectionView.dataSource = self
        tagsCollectionView.delegate = self
        
        tagsCollectionView.isAccessibilityElement = true
    }
    
    func presentActionSheet(for tag: Tag) {
        guard !viewModel.presentingActionSheet else { return }
        viewModel.presentingActionSheet = true
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        let actionsheet = UIAlertController(title: tag.title!,
                                            message: nil,
                                            preferredStyle: .actionSheet)
        
        let updateAction = UIAlertAction(title: viewModel.updateActionTitle, style: .default) { _ in
            self.viewModel.update(tag: tag)
            self.viewModel.presentingActionSheet = false
        }
        
        let deleteAction = UIAlertAction(title: viewModel.deleteActionTitle, style: .destructive) { _ in
            self.viewModel.delete(tag: tag)
            self.viewModel.presentingActionSheet = false
        }
        
        let cancelAction = UIAlertAction(title: viewModel.cancelActionTitle, style: .cancel) { _ in
            print("Cancelled")
            self.viewModel.presentingActionSheet = false
        }
        
        actionsheet.addAction(updateAction)
        actionsheet.addAction(deleteAction)
        actionsheet.addAction(cancelAction)
        
        
        present(actionsheet, animated: true, completion: nil)
    }
    
    private func select(_ bool: Bool, at index: IndexPath, animated: Bool = false) {
        if bool {
            tagsCollectionView.selectItem(at: index,
                                          animated: animated,
                                          scrollPosition: UICollectionView.ScrollPosition.bottom)
        } else {
            tagsCollectionView.deselectItem(at: index, animated: animated)
        }
    }
    
    func loadSelection(for cell: UICollectionViewCell, tag: Tag, at indexPath: IndexPath) {
        if self.viewModel.selectedTags.contains(tag) {
            cell.isSelected = true
            self.select(true, at: indexPath)
        } else {
            cell.isSelected = false
            self.select(false, at: indexPath)
        }
    }
    
    fileprivate func configureCell(indexPath: IndexPath, cell: TagCollectionViewCell) {
        guard let tag = viewModel.tag(for: indexPath) else {
            cell.configure()
            cell.layoutIfNeeded()
            return
        }
        
        let tagViewModel = self.viewModel.tagCollectionCellViewModel(for: tag)
        
        tagViewModel.delegate = self
        cell.configure(with: tagViewModel)
        
        self.loadSelection(for: cell, tag: tag, at: indexPath)

        cell.layoutIfNeeded()
    }
    
    fileprivate func presentBigCollection() {
        let bigTagVC = BigTagCollectionViewController.instantiate()
        
        bigTagVC.viewModel = self.viewModel
        bigTagVC.modalPresentationStyle = .overCurrentContext
        bigTagVC.modalTransitionStyle = .crossDissolve
        
        resignFirstResponder()
        present(bigTagVC, animated: true)
    }
}

extension TagCollectionViewController: StoryboardInstantiable {
    static var viewControllerID: String {
        return self.tagViewControllerID
    }
    
    static var storyboardIdentifier: String {
        return "TagCollection"
    }
}

extension TagCollectionViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let item =
            tagsCollectionView.cellForItem(at: indexPath) as? TagCollectionViewCell else { return }
        
        guard item.kind == .tag, let tag = item.viewModel?.tag else {
            viewModel.delegate?.didclickAddTag(); return
        }
        
        if !viewModel.shouldAskForAuthentication(with: tag) {
            UISelectionFeedbackGenerator().selectionChanged()
        }
        
        viewModel.select(tag)
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        guard let item =
            tagsCollectionView.cellForItem(at: indexPath) as? TagCollectionViewCell,
            let tag = item.viewModel?.tag else { return }
        
        UISelectionFeedbackGenerator().selectionChanged()
        viewModel.select(tag)
    }
}

extension TagCollectionViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.filteredTags.count + 1 // tags + add button
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView
            .dequeueReusableCell(withReuseIdentifier: TagCollectionViewCell.identifier,
                                 for: indexPath) as! TagCollectionViewCell
        
        configureCell(indexPath: indexPath, cell: cell)
        
        return cell
    }
}

extension TagCollectionViewController: TagCollectionViewCellDelegate {
    func didLongPress(_ tagCollectionViewCellViewModel: TagCollectionViewCellViewModel) {
        self.presentActionSheet(for: tagCollectionViewCellViewModel.tag)
        Answers.logCustomEvent(withName: "longpressed tag")
    }
}

extension TagCollectionViewController: TagCollectionViewModelUIDelegate {
    func shouldDelete(at indexPath: [IndexPath]) {
        tagsCollectionView.deleteItems(at: indexPath)
    }
    
    func shouldUpdate(at indexPath: [IndexPath]) {
        tagsCollectionView.reloadItems(at: indexPath)
    }
    
    func shouldUpdate() {
        tagsCollectionView.reloadData()
    }
}
