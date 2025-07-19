//
//  AccountModel.swift
//  BudgetTracker
//
//  Created by Самат Танкеев on 18.07.2025.
//

import SwiftUI

@Observable
final class AccountModel {
    var state: AccountViewState = .initial
    var mode: AccountViewMode = .view
    var editedBalance: String = ""
    var editedCurrency: Currency = .rub
    var errorMessage: String?
    
    private let bankAccountsService: BankAccountsService
    
    var currentAccount: BankAccount? {
        if case .success(let account) = state {
            return account
        }
        return nil
    }
    
    var isLoading: Bool {
        if case .loading = state {
            return true
        }
        return false
    }
    
    var canSave: Bool {
        !editedBalance.isEmpty && Decimal(string: formatBalanceForDecimal(editedBalance)) != nil
    }
    
    // MARK: - Initialization
    
    init(bankAccountsService: BankAccountsService = BankAccountsServiceImpl()) {
        self.bankAccountsService = bankAccountsService
    }
    
    // MARK: - Public Methods
    
    func onViewAppear() {
        Task {
            await fetchAccount()
        }
    }
    
    func refreshAccount() async {
        await fetchAccount()
    }
    
    func startEditing() {
        guard let account = currentAccount else { return }
        
        editedBalance = formatDecimalForDisplay(account.balance)
        editedCurrency = account.currency
        mode = .edit
    }
    
    func cancelEditing() {
        mode = .view
        editedBalance = ""
    }
    
    func saveChanges() {
        guard let account = currentAccount,
              canSave else { return }
        
        let formattedBalance = formatBalanceForDecimal(editedBalance)
        
        guard let newBalance = Decimal(string: formattedBalance) else {
            errorMessage = "Некорректная сумма"
            return
        }
        
        let updatedAccount = BankAccount(
            id: account.id,
            userId: account.userId,
            name: account.name,
            balance: newBalance,
            currency: editedCurrency,
            createdAt: account.createdAt,
            updatedAt: Date()
        )
        
        Task {
            await updateAccount(updatedAccount)
        }
    }
    
    // MARK: - Private Methods
    
    private func fetchAccount() async {
        await MainActor.run {
            self.state = .loading
        }
        
        do {
            let account = try await bankAccountsService.fetchAccount()
            await MainActor.run {
                self.state = .success(account)
            }
        } catch {
            await MainActor.run {
                self.state = .error(error.localizedDescription)
                self.errorMessage = error.localizedDescription
            }
        }
    }
    
    private func updateAccount(_ account: BankAccount) async {
        do {
            try await bankAccountsService.updateAccount(account: account)
            await MainActor.run {
                self.state = .success(account)
                self.mode = .view
                self.editedBalance = ""
            }
        } catch {
            await MainActor.run {
                self.errorMessage = error.localizedDescription
            }
        }
    }
    
    private func formatDecimalForDisplay(_ decimal: Decimal) -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.maximumFractionDigits = 2
        numberFormatter.groupingSeparator = " "
        numberFormatter.decimalSeparator = "."
        
        return numberFormatter.string(from: decimal as NSDecimalNumber) ?? "0"
    }
    
    private func formatBalanceForDecimal(_ input: String) -> String {
        return input
            .replacingOccurrences(of: " ", with: "")
            .replacingOccurrences(of: ",", with: ".")
    }
}

enum AccountViewState {
    case initial
    case success(BankAccount)
    case error(String)
    case loading
}

enum AccountViewMode {
    case view
    case edit
}
