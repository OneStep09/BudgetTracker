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
    @Published var categoryAnalysis: [CategoryAnalysis] = []
    
    @Published var sortOption: TransactionSortOption = .date
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    var account: BankAccount?
    
    var direction: Direction
    
    private let transactionsService: TransactionsService
    private let accountsService: BankAccountsService
    private var cancellables = Set<AnyCancellable>()
    
    
    struct TransactionAnalysis {
        let percentage: Double
        let transaction: Transaction
    }

    struct CategoryAnalysis {
        let category: Category
        let totalAmount: Decimal
        let percentage: Double
        let transactionCount: Int
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
            self.account = account
            fetchTransactions()
        }
    }
    
    func fetchTransactions() {
        guard let account else { return }
        isLoading = true
        errorMessage = nil
        let calendar = Calendar.current
        
        let startOfDay = calendar.startOfDay(for: startDate)
        let endOfDay = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: endDate) ?? Date()
        
        Task {
            do {
                let transactions = try await transactionsService.fetchTransactions(
                    accountId: account.id, startDate: startOfDay,
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
        let filteredTransactions = transactions.filter{$0.category.direction == direction}
        let total = filteredTransactions.reduce(Decimal(0)) { $0 + $1.amount }
        
        var analysis: [TransactionAnalysis] = []
        analysis = filteredTransactions.map { transaction in
            let percentage = total > 0 ? Double(truncating: (transaction.amount / total * 100) as NSNumber) : 0
            return TransactionAnalysis(
                percentage: percentage,
                transaction: transaction
            )
        }
        
        // Group transactions by category
        let groupedByCategory = Dictionary(grouping: filteredTransactions) { $0.category }
        let categoryAnalysis = groupedByCategory.map { (category, categoryTransactions) in
            let categoryTotal = categoryTransactions.reduce(Decimal(0)) { $0 + $1.amount }
            let percentage = total > 0 ? Double(truncating: (categoryTotal / total * 100) as NSNumber) : 0
            return CategoryAnalysis(
                category: category,
                totalAmount: categoryTotal,
                percentage: percentage,
                transactionCount: categoryTransactions.count
            )
        }.sorted { $0.totalAmount > $1.totalAmount }
        
        self.totalAmount = total
        self.transactions = analysis
        self.categoryAnalysis = categoryAnalysis
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


