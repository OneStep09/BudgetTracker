//
//  SelectDateCell.swift
//  BudgetTracker
//
//  Created by Самат Танкеев on 09.07.2025.
//

import UIKit

class SelectDateCell: UITableViewCell {
    static let identifier = "SelectDateCell"
   
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16)
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var datePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = .date
        picker.preferredDatePickerStyle = .compact
        picker.locale = Locale(identifier: "ru-RU")
        picker.tintColor = UIColor.accent
        picker.backgroundColor = UIColor.accent.withAlphaComponent(0.2)
        picker.translatesAutoresizingMaskIntoConstraints = false
        picker.layer.cornerRadius = 8
        picker.clipsToBounds = true
        picker.addTarget(self, action: #selector(dateChanged(_:)), for: .valueChanged)
        return picker
    }()
    
    private var dateChangeCallback: ((Date) -> Void)?
    private var currentDate: Date = Date()
    
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
        contentView.addSubview(datePicker)
        
        NSLayoutConstraint.activate([
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            
            datePicker.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            datePicker.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            datePicker.heightAnchor.constraint(equalToConstant: 32),
        ])
    }
    
    @objc private func dateChanged(_ sender: UIDatePicker) {
        currentDate = sender.date
        dateChangeCallback?(currentDate)
    }
    
    func configure(title: String, date: Date, onDateChange: @escaping (Date) -> Void) {
        titleLabel.text = title
        currentDate = date
        datePicker.date = date
        dateChangeCallback = onDateChange
    }
}
