//
//  TransactionsHistoryView.swift
//  BudgetTracker
//
//  Created by Самат Танкеев on 20.06.2025.
//

import SwiftUI

struct TransactionsHistoryView: View {
    var direction: Direction
    
    var service = TransactionsService()
    
    // State variables
    @State private var transactions: [Transaction] = []
    @State private var startDate = Calendar.current.date(byAdding: .month, value: -1, to: Date()) ?? Date()
    @State private var endDate = Date()
    @State private var sum: Decimal = 0
    
    var body: some View {
        ScrollView {
            VStack {
//                // Background color
//                Color(.systemGray6)
//                    .ignoresSafeArea()
                
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
            getTransations()
        }
        .onChange(of: endDate) {
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
    
    
}


#Preview {
    TransactionsHistoryView(direction: .outcome)
}
