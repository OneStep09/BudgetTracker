//
//  Untitled.swift
//  BudgetTracker
//
//  Created by Самат Танкеев on 19.06.2025.
//

import SwiftUI




struct TransactionsListView: View {
    // Parameters 
    var direction: Direction
    var service: TransactionsService
    
    
    @State private var sortOption: TransactionSortOption = .date
    @State private var transactions: [Transaction] = []
    @State private var sum: Decimal = 100_000
    
    var selectedSortLabel: String {
        switch sortOption {
        case .date: return "дате"
        case .sum: return "сумме"
        }
    }
    
    init(direction: Direction, service: TransactionsService = TransactionsService()) {
        self.direction = direction
        self.service = service
    }
    
    var body: some View {
        NavigationStack() {
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    VStack(spacing: 12) {
                        TransactionsSortingView(sortOption: $sortOption, sortTransactions: sortTransactions)
                        
                        Divider()

                        // Всего
                        TransactionsSumView(sum: sum)
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .padding()
                   
                    
                    Text("Операции")
                        .padding(.horizontal, 28)
                        .foregroundStyle(Color.secondary)
                    
                    // Транзакции
                    LazyVStack(spacing: 0) {
                        ForEach(transactions) { transaction in
                            TransactionItemView(transaction: transaction)
                            
                            Divider()
                                .padding(.leading, 48)
                        }
                    }
                    .background(Color(.systemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .padding(.horizontal)
                }
            }
            .background(Color(.systemGray6))
            .navigationTitle(direction == .outcome ? "Расходы сегодня" : "Доходы сегодня")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink(destination: TransactionsHistoryView(direction: direction)) {
                        Image(systemName: "clock")
                    }
                }
            }
        }
        .onAppear() {
            getTransations()
        }
        .tint(Color(.secondary))
    }
    
    
    func getTransations() {
        let calendar = Calendar.current
        let now = Date()
        let startOfDay = calendar.startOfDay(for: now)
        let endOfDay = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: now) ?? Date()
        
        Task {
            do {
                let transactions = try await  service.fetchTransactions(direction: direction, startDate: startOfDay , endDate: endOfDay)
                var sum: Decimal = 0
                for transaction in transactions {
                    sum += transaction.amount
                }
                
                await MainActor.run {
                    self.transactions = transactions
                    self.sum = sum
                }
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    func sortTransactions() {
        switch sortOption {
        case .date:
            transactions = transactions.sorted(by: {$0.trasactionDate < $1.trasactionDate})
        case .sum:
            transactions = transactions.sorted(by: {$0.amount < $1.amount})
        }
    }
}

#Preview {
    TransactionsListView(direction: .outcome)
}




