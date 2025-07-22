//
//  ChartCell.swift
//  BudgetTracker
//
//  Created by Самат Танкеев on 09.07.2025.
//

import UIKit
import PieChart

class ChartCell: UITableViewCell {
    static let identifier = "ChartCell"
    
    private let pieChartView: PieChartView = {
        let chartView = PieChartView()
        chartView.translatesAutoresizingMaskIntoConstraints = false
        return chartView
    }()
    
    private let placeholderLabel: UILabel = {
        let label = UILabel()
        label.text = "Нет данных для отображения"
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.isHidden = true
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
        backgroundColor = .clear
        selectionStyle = .none
        
        contentView.addSubview(pieChartView)
        contentView.addSubview(placeholderLabel)
        
        NSLayoutConstraint.activate([
            pieChartView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            pieChartView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            pieChartView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            pieChartView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),
            pieChartView.heightAnchor.constraint(equalToConstant: 190),
            
            placeholderLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            placeholderLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
    
    func configure(with categoryAnalysis: [AnalysisViewModel.CategoryAnalysis]) {
        if categoryAnalysis.isEmpty {
            pieChartView.isHidden = true
            placeholderLabel.isHidden = false
        } else {
            pieChartView.isHidden = false
            placeholderLabel.isHidden = true
            
            let entities = categoryAnalysis.map { analysis in
                Entity(value: analysis.totalAmount, label: analysis.category.name)
            }
     
            pieChartView.configure(with: entities)
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        pieChartView.isHidden = false
        placeholderLabel.isHidden = true
    }
}
