//
//  TaskTableViewCell.swift
//  BigChallenge
//
//  Created by Matheus Vaccaro on 25/05/18.
//  Copyright © 2018 Matheus Vaccaro. All rights reserved.
//

import UIKit
import ReefKit

public protocol TaskCellDelegate: class {
    func shouldUpdateSize(of cell: TaskTableViewCell)
    func edit(_ cell: TaskTableViewCell)
    func delete(_ cell: TaskTableViewCell)
}

public enum CellType {
    case card
    case none
}

public class TaskTableViewCell: UITableViewCell {
    
    // MARK: - Properties
    public static let identifier = "taskCell"
    public weak var delegate: TaskCellDelegate?
    
    private var viewModel: TaskCellViewModel?
    private var previousRect = CGRect.zero
    private lazy var gradientLayer: CAGradientLayer = {
        let layer = CAGradientLayer()
        
        layer.frame = checkButton.imageView!.frame
        layer.startPoint = CGPoint(x: 0, y: 1)
        layer.endPoint = CGPoint(x: 1, y: 0)
        layer.zPosition = -1
        
        return layer
    }()
    
    // MARK: - IBOutlets
    @IBOutlet weak var taskTitleTextView: UITextView!
    @IBOutlet weak var checkButton: UIButton!
    @IBOutlet weak var tagsLabel: UILabel!
    
    // MARK: - TableViewCell Lifecycle
    override public func awakeFromNib() {
        super.awakeFromNib()
        
        checkButton.isSelected = false
        checkButton.layer.addSublayer(gradientLayer)
        checkButton.mask = checkButton.imageView
        
        taskTitleTextView.textContainerInset =
            UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        taskTitleTextView.textContainer.lineFragmentPadding = 0
        
        //TODO: Reef Font extension
        selectionStyle = .none
        taskTitleTextView.font = UIFont.font(sized: 19, weight: .medium, with: .body)
        tagsLabel.font = UIFont.font(sized: 14, weight: .regular, with: .footnote)
        configureAccessibility()
    }
    
    // MARK: - Functions
    public func configure(with viewModel: TaskCellViewModel) {
        self.viewModel = viewModel
        
        gradientLayer.colors = viewModel.checkButtonGradient
        taskTitleTextView.text = viewModel.title
        tagsLabel.text = viewModel.tagsDescription
        checkButton.isSelected = viewModel.taskIsCompleted
    }
    
    public func layout(with position: CellType) {
        switch position {
        case .card:
            layer.shadowColor = UIColor.black.cgColor
            backgroundColor = UIColor.white
        case .none:
            backgroundColor = UIColor.clear
            layer.shadowColor = UIColor.clear.cgColor
        }
    }
    
    // MARK: - IBActions
    
    @IBAction func didPressCheckButton(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        UISelectionFeedbackGenerator().selectionChanged()
        viewModel?.changedCheckButton(to: checkButton.isSelected)
    }
    
    public override func layoutSubviews() {
        gradientLayer.frame = checkButton.bounds
    }
    
    fileprivate func configureAccessibility() {
        checkButton.accessibilityIgnoresInvertColors = true
    }
}

extension TaskTableViewCell { // MARK: - Accessibility
    
    public override var accessibilityLabel: String? {
        get {
            return viewModel!.title
        }
        set { }
    }
    
    public override var accessibilityValue: String? {
        get {
            
            var ans = ""
            
            if let tagsDescription = viewModel!.tagsDescription {
                ans.append(tagsDescription)
            }
            
            if let dateDescription = viewModel!.dateString(with: "dd mmmm yyyy") {
                ans.append(", \(dateDescription)")
            }
            
            if let locationDescription = viewModel!.locationDescription {
                ans.append(", \(locationDescription)")
            }
            
            return ans
        }
        set { }
    }
    
    public override var accessibilityHint: String? {
        get {
            return viewModel!.voiceOverHint
        }
        set { }
    }
    
    public override var accessibilityCustomActions: [UIAccessibilityCustomAction]? {
        get {
            let editAction = UIAccessibilityCustomAction(name: viewModel!.editActionTitle,
                                                         target: self,
                                                         selector: #selector(performEditAction))
            let deleteAction = UIAccessibilityCustomAction(name: viewModel!.deleteActionTitle,
                                                           target: self,
                                                           selector: #selector(performDeleteAction))
            
            return [editAction, deleteAction]
        }
        set { }
    }
    
    public override var accessibilityTraits: UIAccessibilityTraits {
        get {
            return UIAccessibilityTraits.allowsDirectInteraction
        }
        set { }
    }
    
    public override func accessibilityActivate() -> Bool {
        didPressCheckButton(checkButton)
        return true
    }
    
    @objc private func performEditAction() {
        delegate?.edit(self)
    }
    
    @objc private func performDeleteAction() {
        delegate?.delete(self)
    }
}
