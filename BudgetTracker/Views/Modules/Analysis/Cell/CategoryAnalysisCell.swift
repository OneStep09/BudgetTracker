//
//  CategoryAnalysisCell.swift
//  BudgetTracker
//
//  Created by Самат Танкеев on 09.07.2025.
//

import UIKit

class CategoryAnalysisCell: UITableViewCell {
    static let identifier = "CategoryAnalysisCell"

    private let iconLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 24)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let percentageLabel: UILabel = {
        let label = UILabel()
        label.textColor = .label
        label.textAlignment = .right
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let amountLabel: UILabel = {
        let label = UILabel()
        label.textColor = .label
        label.textAlignment = .right
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let chevronImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "chevron.right")
        imageView.tintColor = .secondaryLabel
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        contentView.addSubview(iconLabel)
        contentView.addSubview(titleLabel)
        contentView.addSubview(subtitleLabel)
        contentView.addSubview(percentageLabel)
        contentView.addSubview(amountLabel)
        contentView.addSubview(chevronImageView)
        
        NSLayoutConstraint.activate([
            
            iconLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            iconLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            iconLabel.widthAnchor.constraint(equalToConstant: 24),
            iconLabel.heightAnchor.constraint(equalToConstant: 24),
            
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            titleLabel.leadingAnchor.constraint(equalTo: iconLabel.trailingAnchor, constant: 12),
            
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 2),
            subtitleLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            subtitleLabel.trailingAnchor.constraint(lessThanOrEqualTo: amountLabel.leadingAnchor, constant: -8),
            
            chevronImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            chevronImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            chevronImageView.widthAnchor.constraint(equalToConstant: 16),
            chevronImageView.heightAnchor.constraint(equalToConstant: 16),
            
            percentageLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            percentageLabel.trailingAnchor.constraint(equalTo: chevronImageView.leadingAnchor, constant: -16),
            percentageLabel.leadingAnchor.constraint(greaterThanOrEqualTo: titleLabel.trailingAnchor, constant: 16),
            
            amountLabel.topAnchor.constraint(equalTo: percentageLabel.bottomAnchor, constant: 2),
            amountLabel.trailingAnchor.constraint(equalTo: percentageLabel.trailingAnchor)
        ])
    }
    
    func configure(analysis: AnalysisViewModel.TransactionAnalysis) {
        iconLabel.text = "\(analysis.transaction.category.emoji)"
        titleLabel.text = analysis.transaction.category.name
        subtitleLabel.text = analysis.transaction.comment
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = " "
        
        let formattedAmount = formatter.string(from: analysis.transaction.amount as NSNumber) ?? "0"
        amountLabel.text = "\(formattedAmount) ₽"
        percentageLabel.text = "\(Int(analysis.percentage))%"
    }
}
