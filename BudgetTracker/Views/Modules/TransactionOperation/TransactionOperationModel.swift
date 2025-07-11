//
//  TransactionOperationModel.swift
//  BudgetTracker
//
//  Created by Самат Танкеев on 11.07.2025.
//

import SwiftUI

@Observable
final class TransactionOperationModel {
    var categories: [Category] = []
    var selectedCategoryId: Int?
    var amountText: String = ""
    var selectedDate: Date = Date()
    var comment: String = ""
    var showDeleteAlert: Bool = false
    
    var existingTransaction: Transaction?
    var direction: Direction
    var type: TransactionOperation = .create
    
    private let categoriesService: CategoriesService
    private let transactionsService: TransactionsService
    private let bankAccountsService: BankAccountsService
    
    var selectedCategory: Category? {
        guard let selectedCategoryId = selectedCategoryId else { return nil }
        return categories.first { $0.id == selectedCategoryId }
    }
    
    var amount: Decimal {
        Decimal(string: amountText.replacingOccurrences(of: ",", with: ".")) ?? 0
    }
    
    var canCreateTransaction: Bool {
        selectedCategory != nil &&
        amount > 0 &&
        !amountText.isEmpty
    }
    
    // MARK: - Initialization
    
    init(direction: Direction,
        existingTransaction: Transaction? = nil,
         cateogiresService: CategoriesService = CategoriesService(),
         transactionsService: TransactionsService = TransactionsService(),
         bankAccountService: BankAccountsService = BankAccountsService()
    ) {
        self.direction = direction
        self.existingTransaction = existingTransaction
        self.categoriesService = cateogiresService
        self.transactionsService = transactionsService
        self.bankAccountsService = bankAccountService
        if let transaction = existingTransaction {
            type = .edit
            setupForEditing(transaction: transaction)
        }
    }
    
    private func setupForEditing(transaction: Transaction) {
        selectedCategoryId = transaction.category.id
        amountText = String(describing: transaction.amount)
        selectedDate = transaction.trasactionDate
        comment = transaction.comment ?? ""
    }
    
    // MARK: - Data Loading
    
    func loadCategories() async {
        do {
            categories = try await categoriesService.fetchAllCategoires()
        } catch {
            print("Ошибка загрузки категорий: \(error)")
        }
    }
    
    // MARK: - Transaction Operations
    
    func createTransaction() async {
        guard let selectedCategory = selectedCategory,
              canCreateTransaction else {
            print("Невозможно создать транзакцию: недостаточно данных")
            return
        }
        
        do {
            let bankAccount = try await bankAccountsService.fetchAccount()
            
            let newTransaction = Transaction(
                id: Int.random(in: 1000...9999),
                account: bankAccount,
                category: selectedCategory,
                amount: amount,
                trasactionDate: selectedDate,
                comment: comment.isEmpty ? nil : comment,
                createdAt: Date(),
                updatedAt: Date()
            )
            
            try await transactionsService.addTransaction(transaction: newTransaction)
            
            // Update account balance
            let newBalance = selectedCategory.direction == .income ?
                bankAccount.balance + amount :
                bankAccount.balance - amount
            
            try await bankAccountsService.updateAccount(with: newBalance)
            
            print("Транзакция успешно создана")
            
        } catch {
            print("Ошибка создания транзакции: \(error)")
        }
    }
    
    func updateTransaction() async {
        guard let existingTransaction = existingTransaction,
              let selectedCategory = selectedCategory,
              canCreateTransaction else {
            print("Невозможно обновить транзакцию: недостаточно данных")
            return
        }
        
        do {
            let bankAccount = try await bankAccountsService.fetchAccount()
            
            // Revert the old transaction's effect on balance
            let oldAmount = existingTransaction.amount
            let oldDirection = existingTransaction.category.direction
            let revertedBalance = oldDirection == .income ?
                bankAccount.balance - oldAmount :
                bankAccount.balance + oldAmount
            
            // Apply the new transaction's effect on balance
            let newBalance = selectedCategory.direction == .income ?
                revertedBalance + amount :
                revertedBalance - amount
            
            let updatedTransaction = Transaction(
                id: existingTransaction.id,
                account: bankAccount,
                category: selectedCategory,
                amount: amount,
                trasactionDate: selectedDate,
                comment: comment.isEmpty ? nil : comment,
                createdAt: existingTransaction.createdAt,
                updatedAt: Date()
            )
            
            try await transactionsService.updateTransaction(transaction: updatedTransaction)
            try await bankAccountsService.updateAccount(with: newBalance)
            
            print("Транзакция успешно обновлена")
            
        } catch {
            print("Ошибка обновления транзакции: \(error)")
        }
    }
    
    func deleteTransaction() async {
        guard let existingTransaction = existingTransaction else {
            print("Нет транзакции для удаления")
            return
        }
        
        do {
            let bankAccount = try await bankAccountsService.fetchAccount()
            
            // Revert the transaction's effect on balance
            let amount = existingTransaction.amount
            let direction = existingTransaction.category.direction
            let newBalance = direction == .income ?
                bankAccount.balance - amount :
                bankAccount.balance + amount
            
            try await transactionsService.removeTransaction(transaction: existingTransaction)
            try await bankAccountsService.updateAccount(with: newBalance)
            
            print("Транзакция успешно удалена")
            
        } catch {
            print("Ошибка удаления транзакции: \(error)")
        }
    }
}
