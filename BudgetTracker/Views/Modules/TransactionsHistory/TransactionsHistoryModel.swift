//
//  TransactionsHistoryModel.swift
//  BudgetTracker
//
//  Created by Самат Танкеев on 18.07.2025.
//


//
//  TransactionsHistoryModel.swift
//  BudgetTracker
//
//  Created by Самат Танкеев on 18.07.2025.
//

import SwiftUI

@Observable
final class TransactionsHistoryModel {
    var transactions: [Transaction] = []
    var startDate = Calendar.current.date(byAdding: .month, value: -1, to: Date()) ?? Date()
    var endDate = Date()
    var sum: Decimal = 0
    var sortOption: TransactionSortOption = .date
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
    
    var filteredTransactions: [Transaction] {
        transactions.filter { $0.category.direction == direction }
    }
    
    // MARK: - Initialization
    
    init(direction: Direction, 
         transactionsService: TransactionsService = TransactionsServiceImpl(),
         bankAccountsService: BankAccountsService = BankAccountsServiceImpl()) {
        self.direction = direction
        self.transactionsService = transactionsService
        self.bankAccountService = bankAccountsService
    }
    
    // MARK: - Public Methods
    
    func onViewAppear() {
        loadAccount()
    }
    
    func updateStartDate(_ newDate: Date) {
        startDate = newDate
        // Если новая дата начала позже конца, обновляем дату конца
        if startDate > endDate {
            endDate = startDate
        }
        loadTransactions()
    }
    
    func updateEndDate(_ newDate: Date) {
        endDate = newDate
        // Если новая дата конца раньше начала, обновляем дату начала
        if startDate > endDate {
            startDate = endDate
        }
        loadTransactions()
    }
    
    func updateSortOption(_ option: TransactionSortOption) {
        sortOption = option
        sortTransactions()
    }
    
    // MARK: - Private Methods
    
    private func loadAccount() {
        isLoading = true
        Task {
            do {
                let account = try await bankAccountService.fetchAccount()
                await MainActor.run {
                    self.accountId = account.id
                }
                loadTransactions()
            } catch {
                await MainActor.run {
                    self.errorMessage = error.localizedDescription
                    self.isLoading = false
                }
            }
        }
    }
    
    private func loadTransactions() {
        guard let accountId else { return }
        
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: startDate)
        let endOfDay = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: endDate) ?? Date()
        
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                let fetchedTransactions = try await transactionsService.fetchTransactions(
                    accountId: accountId,
                    startDate: startOfDay,
                    endDate: endOfDay
                )
                
                let filtered = fetchedTransactions.filter { $0.category.direction == direction }
                let calculatedSum = filtered.reduce(Decimal(0)) { $0 + $1.amount }
                
                await MainActor.run {
                    self.transactions = filtered
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
    
    private func sortTransactions() {
        switch sortOption {
        case .date:
            transactions = transactions.sorted(by: { $0.trasactionDate < $1.trasactionDate })
        case .sum:
            transactions = transactions.sorted(by: { $0.amount < $1.amount })
        }
    }
}