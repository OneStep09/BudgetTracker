//
//  AnalysisViewModel.swift
//  BudgetTracker
//
//  Created by Самат Танкеев on 09.07.2025.
//

import UIKit
import Combine

// MARK: - View Model
class AnalysisViewModel: ObservableObject {
    @Published var startDate = Calendar.current.date(byAdding: .month, value: -1, to: Date()) ?? Date()
    @Published var endDate = Date()
    @Published var totalAmount: Decimal = 0
    @Published var transactions: [TransactionAnalysis] = []

    @Published var sortOption: TransactionSortOption = .date
    @Published var isLoading = false
    @Published var error: Error?
    
    var direction: Direction
    
    private let transactionsService = TransactionsService()
    private var cancellables = Set<AnyCancellable>()
    
    
    struct TransactionAnalysis {
        let percentage: Double
        let transaction: Transaction
    }

    init(direction: Direction) {
        self.direction = direction
        fetchTransactions()
    }
    
    func fetchTransactions() {
        isLoading = true
        error = nil
        let calendar = Calendar.current
        
        let startOfDay = calendar.startOfDay(for: startDate)
        let endOfDay = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: endDate) ?? Date()
        
        Task {
            do {
                let transactions = try await transactionsService.fetchTransactions(
                    direction: direction,
                    startDate: startOfDay,
                    endDate: endOfDay
                )
                
                await MainActor.run {
                    self.processTransactions(transactions)
                    self.isLoading = false
                }
            } catch {
                await MainActor.run {
                    self.error = error
                    self.isLoading = false
                }
            }
        }
    }
    
    private func processTransactions(_ transactions: [Transaction]) {
        let total = transactions.reduce(Decimal(0)) { $0 + $1.amount }
        var analysis: [TransactionAnalysis] = []
        
        analysis = transactions.map { transaction in
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


