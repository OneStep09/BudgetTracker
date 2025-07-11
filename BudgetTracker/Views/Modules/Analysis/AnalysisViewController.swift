//
//  AnalysisViewController.swift
//  BudgetTracker
//
//  Created by Самат Танкеев on 09.07.2025.
//

import UIKit
import SwiftUI
import Combine

class AnalysisViewController: UIViewController {
    private let viewModel: AnalysisViewModel
    private var cancellables = Set<AnyCancellable>()
    
    init(direction: Direction) {
        self.viewModel = AnalysisViewModel(direction: direction)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private lazy var tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .insetGrouped)
        table.translatesAutoresizingMaskIntoConstraints = false
        table.delegate = self
        table.dataSource = self
        table.backgroundColor = UIColor.systemGroupedBackground
        
        table.register(SelectDateCell.self, forCellReuseIdentifier: SelectDateCell.identifier)
        table.register(TransactionsSortCell.self, forCellReuseIdentifier: TransactionsSortCell.identifier)
        table.register(TotalAmountCell.self, forCellReuseIdentifier: TotalAmountCell.identifier)
        table.register(ChartCell.self, forCellReuseIdentifier: ChartCell.identifier)
        table.register(CategoryAnalysisCell.self, forCellReuseIdentifier: CategoryAnalysisCell.identifier)
        
        return table
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindViewModel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.backgroundColor = .systemGroupedBackground
    }
    
    private func setupUI() {
    
        view.backgroundColor = UIColor.systemGroupedBackground
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 4),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func bindViewModel() {
        viewModel.$transactions
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.tableView.reloadData()
            }
            .store(in: &cancellables)
        
        viewModel.$totalAmount
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.tableView.reloadData()
            }
            .store(in: &cancellables)
        
        viewModel.$sortOption
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.tableView.reloadData()
            }
            .store(in: &cancellables)
        
        viewModel.$error
            .compactMap { $0 }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] error in
                self?.showError(error)
            }
            .store(in: &cancellables)
    }
    
    private func showError(_ error: Error) {
        let alert = UIAlertController(title: "Ошибка", message: error.localizedDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - Table View Data Source & Delegate
extension AnalysisViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return AnalysisSection.allCases.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let analysisSection = AnalysisSection(rawValue: section) else { return 0 }
        
        switch analysisSection {
        case .controls:
            return ControlsRow.allCases.count
        case .chart:
            return 1
        case .transactions:
            return viewModel.transactions.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let section = AnalysisSection(rawValue: indexPath.section) else {
            return UITableViewCell()
        }
        
        switch section {
        case .controls:
            return configureControlsCell(at: indexPath, in: tableView)
        case .chart:
            return configureChartCell(at: indexPath, in: tableView)
        case .transactions:
            return configureTransactionCell(at: indexPath, in: tableView)
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard let analysisSection = AnalysisSection(rawValue: section) else { return nil }
        return analysisSection.title
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let section = AnalysisSection(rawValue: indexPath.section) else { return 44 }
        return section.rowHeight
    }
}

// MARK: - Cell Configuration
private extension AnalysisViewController {
    func configureControlsCell(at indexPath: IndexPath, in tableView: UITableView) -> UITableViewCell {
        guard let controlsRow = ControlsRow(rawValue: indexPath.row) else {
            return UITableViewCell()
        }
        
        switch controlsRow {
        case .startDate:
            let cell = tableView.dequeueReusableCell(withIdentifier: SelectDateCell.identifier, for: indexPath) as! SelectDateCell
            cell.configure(title: "Период: начало", date: viewModel.startDate) { [weak self] newDate in
                self?.viewModel.updateStartDate(date: newDate)
            }
            return cell
            
        case .endDate:
            let cell = tableView.dequeueReusableCell(withIdentifier: SelectDateCell.identifier, for: indexPath) as! SelectDateCell
            cell.configure(title: "Период: конец", date: viewModel.endDate) { [weak self] newDate in
                self?.viewModel.updateEndDate(date: newDate)
            }
            return cell
            
        case .sortOption:
            let cell = tableView.dequeueReusableCell(withIdentifier: TransactionsSortCell.identifier, for: indexPath) as! TransactionsSortCell
            cell.configure(sortOption: viewModel.sortOption) { [weak self] newSortOption in
                self?.viewModel.updateSortOption(newSortOption)
            }
            return cell
            
        case .totalAmount:
            let cell = tableView.dequeueReusableCell(withIdentifier: TotalAmountCell.identifier, for: indexPath) as! TotalAmountCell
            cell.configure(amount: viewModel.totalAmount)
            return cell
        }
    }
    
    func configureChartCell(at indexPath: IndexPath, in tableView: UITableView) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ChartCell.identifier, for: indexPath) as! ChartCell
        return cell
    }
    
    func configureTransactionCell(at indexPath: IndexPath, in tableView: UITableView) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CategoryAnalysisCell.identifier, for: indexPath) as! CategoryAnalysisCell
        let transaction = viewModel.transactions[indexPath.row]
        cell.configure(analysis: transaction)
        cell.separatorInset = .init(top: 0, left: 56, bottom: 0, right: 0)
        return cell
    }
}

struct AnalysisViewControllerWrapper: UIViewControllerRepresentable {
    let direction: Direction
    
    init(direction: Direction) {
        self.direction = direction
    }
    
    func makeUIViewController(context: Context) -> AnalysisViewController {
        let controller = AnalysisViewController(direction: direction)
        return controller
    }
    
    func updateUIViewController(_ uiViewController: AnalysisViewController, context: Context) {}
}

// MARK: - Enums
enum AnalysisSection: Int, CaseIterable {
    case controls = 0
    case chart = 1
    case transactions = 2
    
    var title: String? {
        switch self {
        case .controls, .chart:
            return nil
        case .transactions:
            return "ОПЕРАЦИИ"
        }
    }
    
    var rowHeight: CGFloat {
        switch self {
        case .controls:
            return 50
        case .chart:
            return 200
        case .transactions:
            return 60
        }
    }
}

enum ControlsRow: Int, CaseIterable {
    case startDate = 0
    case endDate = 1
    case sortOption = 2
    case totalAmount = 3
}


