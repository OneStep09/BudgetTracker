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
    @State private var showTransactionOperation: Bool = false
    @State private var selectedTransaction: Transaction? = nil
    
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
        ZStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    header
                    transactionsList
                }
            }
            plusButton
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
        .onAppear() {
            getTransations()
        }
    
        .fullScreenCover(isPresented: $showTransactionOperation) {
            TransactionOperationView(
                model: TransactionOperationModel(
                    direction: direction,
                    existingTransaction: selectedTransaction,
                    transactionsService: service
                )
            )
            .onDisappear {
                getTransations()
            }
        }
    }
    
    
    private var header: some View {
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
    }
    
    private var transactionsList: some View {
        Section("Операции") {
            // Транзакции
            LazyVStack(spacing: 0) {
                ForEach(transactions) { transaction in
                    TransactionItemView(transaction: transaction)
                        .onTapGesture {
                            selectedTransaction = transaction
                            showTransactionOperation = true
                        }
    
                    
                    Divider()
                        .padding(.leading, 48)
                }
            }
            .background(Color(.systemBackground))
            .foregroundStyle(Color.primary)
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
            .padding(.horizontal)
            .foregroundStyle(Color.secondary)
    }
    
    
    private var plusButton: some View {
        VStack {
            Spacer()
            HStack {
                
                
                Spacer()
                
                Button {
                    showTransactionOperation = true
                } label: {
                    Image(systemName: "plus")
                        .resizable()
                        .frame(width: 16, height: 16, alignment: .trailing)
                        .tint(Color.white)
                        .padding(20)
                        .background(Color.accent)
                        .clipShape(Circle())
                        .padding(.trailing, 16)
                        .padding(.bottom, 28)
                }
            }
        }
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




