//
//  TransactionsHistoryView.swift
//  BudgetTracker
//
//  Created by Самат Танкеев on 20.06.2025.
//

import SwiftUI

struct TransactionsHistoryView: View {
    
    // Parameters
    var direction: Direction
    
    var service: TransactionsService
    
    // State variables
    @State private var transactions: [Transaction] = []
    @State private var startDate = Calendar.current.date(byAdding: .month, value: -1, to: Date()) ?? Date()
    @State private var endDate = Date()
    @State private var sum: Decimal = 0
    @State private var sortOption: TransactionSortOption = .date
    
    
    init(direction: Direction, service: TransactionsService = TransactionsService()) {
        self.direction = direction
        self.service = service
    
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                HStack {
                    Text("Сортировать по")
                    Picker("Сортировка", selection: $sortOption) {
                        ForEach(TransactionSortOption.allCases) { option in
                            Text(option.rawValue).tag(option)
                        }
                    }
                    .pickerStyle(.menu) // makes it a dropdown menu
                    .onChange(of: sortOption) {
                        sortTransactions()
                    }
                }
                .padding(.horizontal)
                .padding(.top)
                
                VStack(alignment: .leading, spacing: 12) {
                    VStack(spacing: 8) {
                        DatePicker("Начало", selection: $startDate, displayedComponents: .date)
                        
                        Divider()
                        
                        DatePicker("Конец", selection: $endDate, displayedComponents: .date)
                        
                        Divider()
                        
                        HStack {
                            Text("Сумма")
                            
                            Spacer()
                            
                            Text("\(sum) ₽")
                        }
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
                            HistoryTransactionItemView(transaction: transaction)
                            
                            Divider()
                                .padding(.leading, 48)
                        }
                    }
                    .background(Color(.systemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .padding(.horizontal)
                }
            }
        }
        .background(Color(.systemGray6))
        
        .onAppear() {
            getTransations()
        }
        .onChange(of: startDate) {
            // Если новая дата начала позже конца, обновляем дату начала
            if startDate > endDate {
                startDate = endDate
            }
            getTransations()
        }
        .onChange(of: endDate) {
            // Если новая дата конца раньше начала, обновляем дату конца
            if startDate > endDate {
                endDate = startDate
            }
            getTransations()
        }
        
        .navigationTitle("Моя история")
    }
    
    
    func getTransations() {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: startDate)
        let endOfDay = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: endDate) ?? Date()
        
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
    TransactionsHistoryView(direction: .outcome)
}
