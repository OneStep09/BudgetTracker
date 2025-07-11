//
//  ChartCell.swift
//  BudgetTracker
//
//  Created by Самат Танкеев on 09.07.2025.
//

import UIKit

class ChartCell: UITableViewCell {
    static let identifier = "ChartCell"
    
    private let placeholderLabel: UILabel = {
        let label = UILabel()
        label.text = "График будет здесь"
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        selectionStyle = .none
        
        contentView.addSubview(placeholderLabel)
        
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: contentView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            contentView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            contentView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            placeholderLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            placeholderLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
}
