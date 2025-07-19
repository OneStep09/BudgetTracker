//
//  Untitled.swift
//  BudgetTracker
//
//  Created by Самат Танкеев on 19.06.2025.
//

import SwiftUI

struct TransactionsListView: View {
    @State private var model: TransactionsListModel
    
    init(model: TransactionsListModel) {
        self.model = model
    }
    
    
    
    var body: some View {
        ZStack {
            if model.isLoading {
                ProgressView()
            } else {
                ScrollView {
                    VStack(alignment: .leading, spacing: 12) {
                        header
                        transactionsList
                    }
                }
            }
            plusButton
        }
        .background(Color(.systemGray6))
        .navigationTitle(model.navigationTitle)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                NavigationLink(destination: TransactionsHistoryView(model:
                                                                        TransactionsHistoryModel(direction: model.direction))) {
                    Image(systemName: "clock")
                }
            }
        }
        .onAppear() {
            model.onViewAppear()
        }
        .fullScreenCover(isPresented: $model.showTransactionOperation) {
            TransactionOperationView(
                model: TransactionOperationModel(
                    direction: model.direction,
                    existingTransaction: model.selectedTransaction,
                    transactionsService: TransactionsServiceImpl()
                )
            )
            .onDisappear {
                model.hideTransactionOperation()
            }
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
    
    private var header: some View {
        VStack(spacing: 12) {
            TransactionsSortingView(
                sortOption: $model.sortOption,
                sortTransactions: {
                    model.updateSortOption(model.sortOption)
                }
            )
            Divider()
            TransactionsSumView(sum: model.sum)
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .padding()
    }
    
    private var transactionsList: some View {
        Section(model.operationTitle) {
            LazyVStack(spacing: 0) {
                ForEach(model.transactions) { transaction in
                    TransactionItemView(transaction: transaction)
                        .onTapGesture {
                            model.selectTransaction(transaction)
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
                    model.showAddTransaction()
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
}

#Preview {
    TransactionsListView(model: TransactionsListModel(direction: .outcome))
}




