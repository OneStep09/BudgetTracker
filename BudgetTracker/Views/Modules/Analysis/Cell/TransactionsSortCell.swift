//
//  TransactionsSortCell.swift
//  BudgetTracker
//
//  Created by Самат Танкеев on 10.07.2025.
//

import UIKit

class TransactionsSortCell: UITableViewCell {
    static let identifier = "TransactionsSortCell"
    
    private var onSortOptionChanged: ((TransactionSortOption) -> Void)?
    private var currentSortOption: TransactionSortOption = .date
    
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Сортировать по"
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var sortButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(.systemBlue, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        button.contentHorizontalAlignment = .right
        
        let dateAction = UIAction(title: "по дате", state: .on) { [weak self] _ in
            self?.updateSortOption(.date)
        }

        
        let sumAction = UIAction(title: "по сумме", state: .off) { [weak self] _ in
            self?.updateSortOption(.sum)
        }
        
        let menu = UIMenu(title: "", children: [dateAction, sumAction])
        button.menu = menu
        button.showsMenuAsPrimaryAction = true
        button.setTitleColor(.secondary, for: .normal)
        return button
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
        
        contentView.addSubview(titleLabel)
        contentView.addSubview(sortButton)
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            sortButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            sortButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            sortButton.leadingAnchor.constraint(greaterThanOrEqualTo: titleLabel.trailingAnchor, constant: 8)
        ])
    }
    
    func configure(sortOption: TransactionSortOption, onSortOptionChanged: @escaping (TransactionSortOption) -> Void) {
        self.currentSortOption = sortOption
        self.onSortOptionChanged = onSortOptionChanged
        
        updateButtonTitle()
        updateMenuStates()
    }
    
    private func updateSortOption(_ option: TransactionSortOption) {
        currentSortOption = option
        updateButtonTitle()
        updateMenuStates()
        onSortOptionChanged?(option)
    }
    
    private func updateButtonTitle() {
        sortButton.setTitle(currentSortOption.label, for: .normal)
    }
    
    private func updateMenuStates() {
        let dateAction = UIAction(title: "по дате", state: currentSortOption == .date ? .on : .off) { [weak self] _ in
            self?.updateSortOption(.date)
        }
        
        let sumAction = UIAction(title: "по сумме", state: currentSortOption == .sum ? .on : .off) { [weak self] _ in
            self?.updateSortOption(.sum)
        }
        
        let menu = UIMenu(title: "", children: [dateAction, sumAction])
        sortButton.menu = menu
    }
}
