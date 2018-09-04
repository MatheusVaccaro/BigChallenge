//
//  CreateTagViewController.swift
//  BigChallenge
//
//  Created by Bruno Fulber Wide on 09/08/18.
//  Copyright © 2018 Matheus Vaccaro. All rights reserved.
//

import UIKit

class CreateTagViewController: UIViewController, CreationFramePresentable {
    
    // MARK: - Properties
    
    var viewModel: NewTagViewModel!
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var colorsCollectionView: UICollectionView!
    @IBOutlet weak var tagTitleTextView: UITextView!
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureColorsCollectionView()
        configureWithViewModel()
        configureTagTitleTextView()
    }
    
    // MARK: - IBAction
    
    func didTapMoreOptionsButton(_ sender: UIButton) {
        print("Tapped more options button from tag creation screen")
    }
    
    // MARK: - Functions
    
    private func configureTagTitleTextView() {
        tagTitleTextView.delegate = self
        tagTitleTextView.font = UIFont.font(sized: 38.0, weight: .bold, with: .title1, fontName: .barlow)
        tagTitleTextView.placeholderColor = UIColor.lightGray.withAlphaComponent(0.5)
        tagTitleTextView.becomeFirstResponder()
        tagTitleTextView.placeholder = Strings.Tag.CreationScreen.tagTitlePlaceholder
    }
    
    private func configureColorsCollectionView() {
        colorsCollectionView.dataSource = self
        colorsCollectionView.delegate = self
    }

    private func configureWithViewModel() {
        if let title = viewModel.tagTitle {
            tagTitleTextView.text = title
        }
        
        if let colorIndex = viewModel.colorIndex {
            let indexPath = IndexPath(row: colorIndex, section: 0)
            colorsCollectionView.selectItem(at: indexPath, animated: false, scrollPosition: .left)
        }
    }
    
}

// MARK: - UITextViewDelegate

extension CreateTagViewController: UITextViewDelegate {
    func textViewDidChangeSelection(_ textView: UITextView) {
        if textView === tagTitleTextView {
            viewModel?.tagTitle = textView.text
        }
    }
}

// MARK: - StoryboardInstantiable

extension CreateTagViewController: StoryboardInstantiable {
    
    static var storyboardIdentifier: String {
        return "NewTag"
    }
    
    static var viewControllerID: String {
        return "NewTagViewController"
    }
}

// MARK: - UICollectionViewDataSource

extension CreateTagViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.numberOfColors()
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: ColorCollectionViewCell.identifier, for: indexPath) as? ColorCollectionViewCell else {
                return UICollectionViewCell()
        }
        cell.configure(with: indexPath.row)
        return cell
    }
}

extension CreateTagViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let row = indexPath.row
        viewModel?.colorIndex = row
    }
    
}
