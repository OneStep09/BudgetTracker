//
//  AnalysisViewModel.swift
//  BudgetTracker
//
//  Created by Самат Танкеев on 09.07.2025.
//

import UIKit
import Combine

// MARK: - View Model
@MainActor
class AnalysisViewModel: ObservableObject {
    @Published var startDate = Calendar.current.date(byAdding: .month, value: -1, to: Date()) ?? Date()
    @Published var endDate = Date()
    @Published var totalAmount: Decimal = 0
    @Published var transactions: [TransactionAnalysis] = []
    
    @Published var sortOption: TransactionSortOption = .date
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private var accountId: Int?
    
    var direction: Direction
    
    private let transactionsService: TransactionsService
    private let accountsService: BankAccountsService
    private var cancellables = Set<AnyCancellable>()
    
    
    struct TransactionAnalysis {
        let percentage: Double
        let transaction: Transaction
    }
    
    init(direction: Direction,
         transactionsService: TransactionsService = TransactionsServiceImpl(),
         accountsService: BankAccountsService = BankAccountsServiceImpl()) {
        self.direction = direction
        self.transactionsService = transactionsService
        self.accountsService = accountsService
        fetchAccount()
    }
    
    
    func fetchAccount() {
        Task {
            let account = try await accountsService.fetchAccount()
            self.accountId = account.id
            fetchTransactions()
        }
    }
    
    func fetchTransactions() {
        guard let accountId else { return }
        isLoading = true
        errorMessage = nil
        let calendar = Calendar.current
        
        let startOfDay = calendar.startOfDay(for: startDate)
        let endOfDay = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: endDate) ?? Date()
        
        Task {
            do {
                let transactions = try await transactionsService.fetchTransactions(
                    accountId: accountId, startDate: startOfDay,
                    endDate: endOfDay
                )
                
                
                
                await MainActor.run {
                    self.processTransactions(transactions)
                    self.isLoading = false
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = error.localizedDescription
                    self.isLoading = false
                }
            }
        }
    }
    
    private func processTransactions(_ transactions: [Transaction]) {
        let total = transactions.reduce(Decimal(0)) { $0 + $1.amount }
        var analysis: [TransactionAnalysis] = []
        let filteredTransactions = transactions.filter{$0.category.direction == direction}
        analysis = filteredTransactions.map { transaction in
            let percentage = total > 0 ? Double(truncating: (transaction.amount / total * 100) as NSNumber) : 0
            return TransactionAnalysis(
                percentage: percentage,
                transaction: transaction
            )
        }
        
        self.totalAmount = total
        self.transactions = analysis
        sortAnalysis()
    }
    
    
    func updateStartDate(date: Date) {
        startDate = date
        
        if startDate > endDate {
            endDate = date
        }
        
        fetchTransactions()
    }
    
    func updateEndDate(date: Date) {
        endDate = date
        
        if startDate > endDate {
            startDate = date
        }
        
        fetchTransactions()
    }
    
    func updateSortOption(_ option: TransactionSortOption) {
        sortOption = option
        sortAnalysis()
    }
    
    private func sortAnalysis() {
        switch sortOption {
        case .date:
            transactions = transactions.sorted{$0.transaction.trasactionDate < $1.transaction.trasactionDate}
        case .sum:
            transactions = transactions.sorted { $0.transaction.amount < $1.transaction.amount }
        }
    }
}


