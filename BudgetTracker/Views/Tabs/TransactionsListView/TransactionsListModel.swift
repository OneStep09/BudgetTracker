//
//  TransactionsListModel.swift
//  BudgetTracker
//
//  Created by Самат Танкеев on 17.07.2025.
//

import SwiftUI

@Observable
final class TransactionsListModel {
    var sortOption: TransactionSortOption = .date
    var transactions: [Transaction] = []
    var sum: Decimal = 0
    var showTransactionOperation: Bool = false
    var selectedTransaction: Transaction? = nil
    var isLoading: Bool = false
    var errorMessage: String?
    var accountId: Int?
    
    let direction: Direction
    private let transactionsService: TransactionsService
    private let bankAccountService: BankAccountsService
    
    var selectedSortLabel: String {
        switch sortOption {
        case .date: return "дате"
        case .sum: return "сумме"
        }
    }
    
    var navigationTitle: String {
        direction == .outcome ? "Расходы сегодня" : "Доходы сегодня"
    }
    
    var operationTitle: String {
        direction == .outcome ? "Мои расходы" : "Мои доходы"
    }
    
    // MARK: - Initialization
    
    init(direction: Direction, transactionsService: TransactionsService = TransactionsServiceImpl(), bankAccountsService: BankAccountsService = BankAccountsServiceImpl()) {
        self.direction = direction
        self.transactionsService = transactionsService
        self.bankAccountService = bankAccountsService
    }
    
    
    func onViewAppear() {
        loadAccount()
    }
    
    // MARK: - Public Methods
    func loadTransactions() {
        
        guard let accountId else { return }
        let calendar = Calendar.current
        let now = Date()
        let startOfDay = calendar.startOfDay(for: now)
        let endOfDay = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: now) ?? Date()
        
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                let fetchedTransactions = try await transactionsService.fetchTransactions(
                    accountId: accountId,
                    startDate: startOfDay,
                    endDate: endOfDay
                )
                
                let filteredTransactions = fetchedTransactions.filter { $0.category.direction == direction }
                let calculatedSum = filteredTransactions.reduce(Decimal(0)) { $0 + $1.amount }
                
                await MainActor.run {
                    self.transactions = filteredTransactions
                    self.sum = calculatedSum
                    self.isLoading = false
                    sortTransactions()
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = error.localizedDescription
                    self.isLoading = false
                }
            }
        }
    }
    
    func loadAccount() {
        self.isLoading = true
        Task {
            do {
                let account = try await bankAccountService.fetchAccount()
                self.accountId = account.id
                loadTransactions()
                
            } catch let error  {
                self.errorMessage = error.localizedDescription
                self.isLoading = false
            }
        }
    }
    
    func sortTransactions() {
        switch sortOption {
        case .date:
            transactions = transactions.sorted(by: { $0.trasactionDate < $1.trasactionDate })
        case .sum:
            transactions = transactions.sorted(by: { $0.amount < $1.amount })
        }
    }
    
    func updateSortOption(_ option: TransactionSortOption) {
        sortOption = option
        sortTransactions()
    }
    
    func selectTransaction(_ transaction: Transaction) {
        selectedTransaction = transaction
        showTransactionOperation = true
    }
    
    func showAddTransaction() {
        selectedTransaction = nil
        showTransactionOperation = true
    }
    
    func hideTransactionOperation() {
        showTransactionOperation = false
        selectedTransaction = nil
        loadTransactions()
    }
}
