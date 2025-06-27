//
//  AccountView.swift
//  BudgetTracker
//
//  Created by Самат Танкеев on 19.06.2025.
//

import SwiftUI

struct AccountView: View {
    
    let service: BankAccountsService
    @State var state: AccountViewState = .initial
    @State var mode: AccountViewMode = .view
    
    init(service: BankAccountsService = BankAccountsService()) {
        self.service = service
    }
    

    @State private var editedBalance: String = ""
    @State private var editedCurrency: Currency = .usd
    
    var body: some View {
        
        NavigationStack {
            VStack(spacing: 16) {
                
                switch state {
                case .initial:
                    EmptyView()
                case .sucess(let account):
                    switch mode {
                    case .view:
                        AccountInfoView(balance: account.balance, currency: account.currency)
                    case .edit:
                        EditAccountView(
                            balanceText: $editedBalance,
                            selectedCurrency: $editedCurrency
                        )
                    }
                    
                case .error(let message):
                    Text("Произошла ошибка")
                    
                    Text(message)
                case .loading:
                    Text("Загрузка...")
                }
                
            }
            .navigationTitle("Мой счет")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    if case .sucess(let account) = state {
                        if mode == .view {
                            Button("Редактировать") {
                                editedBalance = account.balance.formatted()
                                editedCurrency = account.currency
                                mode = .edit
                            }
                        } else {
                            Button("Сохранить") {
                                saveChanges(account: account)
                            }
                        }
                    }
                }
            }
            .background(Color(.systemGray6))
            .tint(Color(.secondary))
            
        }
        
        .task {
            await fetchAccount()
        }
        
       
        
            
    }
    
    private func saveChanges(account: BankAccount) {
        if let newBalance = Decimal(string: editedBalance) {
            let updatedAccount = BankAccount(
                id: account.id,
                userId: account.userId,
                name: account.name,
                balance: newBalance,
                currency: editedCurrency,
                createdAt: account.createdAt,
                updatedAt: account.updatedAt)
            
            
            updateAccount(with: newBalance)
          
            self.state = .sucess(updatedAccount)
        }
        
      
        self.mode = .view
    }
    
    func fetchAccount() async {
        do {
            let account = try await service.fetchAccount()
            await MainActor.run {
                self.state = .sucess(account)
            }
        } catch {
            state = .error(error.localizedDescription)
        }
    }
    
    func updateAccount(with balance: Decimal) {
        Task {
            do {
             try await  service.updateAccount(with: balance)
            } catch {
                print(error.localizedDescription)
            }
        }
        
    }
}

enum AccountViewState {
    case initial
    case sucess(BankAccount)
    case error(String)
    case loading
}

enum AccountViewMode {
    case view
    case edit
}

#Preview {
    AccountView()
}
