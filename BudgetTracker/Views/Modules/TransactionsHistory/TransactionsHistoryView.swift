//
//  TransactionsHistoryView.swift
//  BudgetTracker
//
//  Created by Самат Танкеев on 20.06.2025.
//

import SwiftUI

struct TransactionsHistoryView: View {
    @State private var model: TransactionsHistoryModel
    
    init(model: TransactionsHistoryModel) {
        self.model = model
    }
    
    var body: some View {
        ZStack {
            if model.isLoading {
                ProgressView()
            } else {
                ScrollView {
                    VStack(alignment: .leading) {
                        VStack(alignment: .leading, spacing: 12) {
                            headerSection
                            transactionsSection
                        }
                    }
                }
                .background(Color(.systemGray6))
            }
        }
        .navigationTitle("Моя история")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                NavigationLink(destination: 
                    AnalysisViewControllerWrapper(direction: model.direction)
                        .navigationTitle("Анализ")
                        .ignoresSafeArea(.all)
                ) {
                    Image(systemName: "doc")
                }
            }
        }
        .onAppear {
            model.onViewAppear()
        }
        .alert("Ошибка", isPresented: .constant(model.errorMessage != nil)) {
            Button("OK") {
                model.errorMessage = nil
            }
        } message: {
            if let errorMessage = model.errorMessage {
                Text(errorMessage)
            }
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: 8) {
            CustomPickerView(label: "Начало", selectedDate: Binding(
                get: { model.startDate },
                set: { model.updateStartDate($0) }
            ))
            
            Divider()
            
            CustomPickerView(label: "Конец", selectedDate: Binding(
                get: { model.endDate },
                set: { model.updateEndDate($0) }
            ))
            
            Divider()
            
            TransactionsSortingView(
                sortOption: $model.sortOption,
                sortTransactions: {
                    model.updateSortOption(model.sortOption)
                }
            )
            
            Divider()
            
            HStack {
                Text("Сумма")
                
                Spacer()
                
                Text("\(model.sum) \(model.account?.currency.symbol ?? "")")
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .padding()
    }
    
    private var transactionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Операции")
                .padding(.horizontal, 28)
                .foregroundStyle(Color.secondary)
            
            LazyVStack(spacing: 0) {
                ForEach(model.transactions) { transaction in
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

#Preview {
    let model = TransactionsHistoryModel(direction: .outcome)
    TransactionsHistoryView(model: model)
}
