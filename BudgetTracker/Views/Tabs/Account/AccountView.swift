//
//  AccountView.swift
//  BudgetTracker
//
//  Created by Самат Танкеев on 19.06.2025.
//

import SwiftUI

struct AccountView: View {
    @State private var model: AccountModel
    
//    init(service: BankAccountsService = BankAccountsServiceImpl()) {
//        self._model = State(initialValue: AccountModel(bankAccountsService: service))
//    }
    
    init(model: AccountModel) {
        self.model = model
    }
    
    var body: some View {
        VStack(spacing: 16) {
            switch model.state {
            case .initial:
                EmptyView()
            case .loading:
                ProgressView()
                    .frame(width: 100, height: 100)
            case .success(let account):
                accountContent(account: account)
            case .error(let message):
                errorView(message: message)
            }
        }
        .refreshable {
            await model.refreshAccount()
        }
        .navigationTitle("Мой счет")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                toolbarButton
            }
        }
        .background(Color(.systemGray6))
        .tint(Color(.secondary))
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
    
    @ViewBuilder
    private func accountContent(account: BankAccount) -> some View {
        switch model.mode {
        case .view:
            AccountInfoView(balance: account.balance, currency: account.currency)
            
            if !model.dailyBalances.isEmpty {
                BalanceChartView(dailyBalances: model.dailyBalances,
                                 currency: model.currentAccount?.currency.symbol ?? "")
            }
            
            Spacer()
            
            
        case .edit:
            EditAccountView(
                balanceText: $model.editedBalance,
                selectedCurrency: $model.editedCurrency
            )
        }
    }
    
    private func errorView(message: String) -> some View {
        VStack(spacing: 8) {
            Text("Произошла ошибка")
                .font(.headline)
            Text(message)
                .foregroundColor(.secondary)
        }
    }
    
    @ViewBuilder
    private var toolbarButton: some View {
        if case .success(_) = model.state {
            switch model.mode {
            case .view:
                Button("Редактировать") {
                    model.startEditing()
                }
            case .edit:
                HStack {
                    Button("Отмена") {
                        model.cancelEditing()
                    }
                    
                    Button("Сохранить") {
                        model.saveChanges()
                    }
                    .disabled(!model.canSave)
                }
            }
        }
    }
}

#Preview {
    AccountView(model: AccountModel())
}
