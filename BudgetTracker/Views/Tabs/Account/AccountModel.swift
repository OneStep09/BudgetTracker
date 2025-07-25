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
    var dailyBalances: [DailyBalance] = []
    var errorMessage: String?
    
    private let bankAccountsService: BankAccountsService
    private let transactionsService: TransactionsService
    
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
    
    init(bankAccountsService: BankAccountsService = BankAccountsServiceImpl(),
         transactionsService: TransactionsService = TransactionsServiceImpl()) {
        self.bankAccountsService = bankAccountsService
        self.transactionsService = transactionsService
    }
    
    // MARK: - Public Methods
    
    func onViewAppear() {
        Task {
            await fetchAccount()
            await fetchTransactions()
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
    
    
    private func fetchTransactions() async {
        guard let account = currentAccount else { return }
        
        let calendar = Calendar.current
        let endDate = Date()
        let startDate = calendar.date(byAdding: .month, value: -1, to: endDate) ?? endDate
        
        do {
            let transactions = try await transactionsService.fetchTransactions(
                accountId: account.id,
                startDate: startDate,
                endDate: endDate
            )
            
            let balances = calculateDailyBalances(
                transactions: transactions,
                startDate: startDate,
                endDate: endDate,
                currentBalance: account.balance
            )
            
            await MainActor.run {
                self.dailyBalances = balances.map{ DailyBalance(date: DateStringConverter.getDate(from: $0.key,
                                                format: .yearMonthDate) ?? Date(),
                                                balance: $0.value)}.sorted{$0.date < $1.date}
            }
        } catch {
            await MainActor.run {
                self.errorMessage = "Не удалось загрузить транзакции: \(error.localizedDescription)"
            }
        }
    }
    
    private func calculateDailyBalances(transactions: [Transaction], startDate: Date, endDate: Date, currentBalance: Decimal) -> [String: Decimal] {
        var balanceByDay: [String: Decimal] = [:]
        var transactionsByDay: [String: Decimal] = [:]
        // Групировка операции по дням
        for transaction in transactions {
            let dateString = DateStringConverter.getString(from: transaction.trasactionDate, formatType: .yearMonthDate)
            
            if transactionsByDay[dateString] == nil {
                transactionsByDay[dateString] = 0
            }
            
            if transaction.category.direction == .outcome {
                transactionsByDay[dateString]! -= transaction.amount
            } else {
                transactionsByDay[dateString]! += transaction.amount
            }
        }
        
        
        var currentDate = endDate
        var runningBalance = currentBalance
       
        while currentDate > startDate {
            let currentDateStr = DateStringConverter.dateFormatter.string(from: currentDate)
            balanceByDay[currentDateStr] = runningBalance
            runningBalance -= transactionsByDay[currentDateStr] ?? 0
            currentDate = Calendar.current.date(byAdding: .day, value: -1, to: currentDate)!
        }
        
        return balanceByDay
    }
    
    
    
    private func updateAccount(_ account: BankAccount) async {
        do {
            let upatedAccount = try await bankAccountsService.updateAccount(account: account)
            await MainActor.run {
                self.state = .success(upatedAccount)
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

struct DailyBalance: Identifiable {
    let id = UUID()
    let date: Date
    let balance: Decimal
    
    var balanceDouble: Double {
        NSDecimalNumber(decimal: balance).doubleValue
    }
    
    var isPositive: Bool {
        balance >= 0
    }
}
