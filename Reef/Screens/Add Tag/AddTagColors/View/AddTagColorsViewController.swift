//
//  AddTagColorsViewController.swift
//  Reef
//
//  Created by Gabriel Paul on 24/09/18.
//  Copyright © 2018 Matheus Vaccaro. All rights reserved.
//

import UIKit

protocol AddTagColorsDelegate: class {
    func addTagColorsDidSelectColor()
}

class AddTagColorsViewController: UIViewController {

    @IBOutlet weak var tagColorsCollectionView: UICollectionView!
    // MARK: - Properties
    var viewModel: AddTagColorsViewModel!
    
    weak var delegate: AddTagColorsDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureColorsCollectionView()
        tagColorsCollectionView.selectItem(at: IndexPath(row: Int(viewModel.colorIndex), section: 0), animated: false, scrollPosition: .bottom)
    }
    
    private func configureColorsCollectionView() {
        tagColorsCollectionView.dataSource = self
        tagColorsCollectionView.delegate = self
    }
}

extension AddTagColorsViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let row = indexPath.row
        viewModel?.colorIndex = Int64(row)
        delegate?.addTagColorsDidSelectColor()
    }
}

extension AddTagColorsViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.numberOfColors()
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ColorCollectionViewCell.identifier,
                                                            for: indexPath) as? ColorCollectionViewCell else {
                                                                return UICollectionViewCell()
        }
        
        cell.configure(with: indexPath.row)
        return cell
    }
}

extension AddTagColorsViewController: StoryboardInstantiable {
    static var viewControllerID: String {
        return "addTagColors"
    }
    
    static var storyboardIdentifier: String {
        return "AddTagColors"
    }
}
