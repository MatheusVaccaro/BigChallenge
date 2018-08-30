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
        layer.mask = checkButton.imageView!.layer
        
        return layer
    }()
    
    // MARK: - IBOutlets
    @IBOutlet weak var taskTitleTextView: UITextView!
    @IBOutlet weak var checkButton: UIButton!
    @IBOutlet weak var tagsLabel: UILabel!
    
    // MARK: - TableViewCell Lifecycle
    override public func awakeFromNib() {
        super.awakeFromNib()
        taskTitleTextView.delegate = self
        checkButton.isSelected = false
        checkButton.layer.addSublayer(gradientLayer)
        
        layer.shadowOpacity = 1
        layer.shadowOffset = CGSize(width: 0, height: 0)
        
        taskTitleTextView.textContainerInset =
            UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        taskTitleTextView.textContainer.lineFragmentPadding = 0
        
        //TODO: Reef Font extension
        selectionStyle = .none
        taskTitleTextView.font = UIFont.font(sized: 19, weight: .medium, with: .body)
        tagsLabel.font = UIFont.font(sized: 14, weight: .regular, with: .footnote)
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
}

extension TaskTableViewCell: UITextViewDelegate {
    public func textViewDidEndEditing(_ textView: UITextView) {
        guard let text = textView.text else { return }
        viewModel?.changeTextTitle(to: text)
    }
    
    public func textViewDidChange(_ textView: UITextView) {
        let lastCharPos = textView.endOfDocument

        let currentRect = textView.caretRect(for: lastCharPos)
        if currentRect.origin.y < previousRect.origin.y {
            delegate?.shouldUpdateSize(of: self)
        }
        previousRect = currentRect
    }
}
