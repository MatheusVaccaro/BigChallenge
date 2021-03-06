//
//  TaskTableViewCell.swift
//  BigChallenge
//
//  Created by Matheus Vaccaro on 25/05/18.
//  Copyright © 2018 Matheus Vaccaro. All rights reserved.
//

import UIKit
import ReefKit

public protocol TodayTaskCellDelegate: class {
    func shouldUpdateSize(of cell: TodayTaskTableViewCell)
}

public enum CellType {
    case card
    case none
}

public class TodayTaskTableViewCell: UITableViewCell {
    
    // MARK: - Properties
    public static let identifier = "todayTaskCell"
    public weak var delegate: TodayTaskCellDelegate?
    
    private var viewModel: TodayTaskCellViewModel?
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
    public func configure(with viewModel: TodayTaskCellViewModel) {
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
