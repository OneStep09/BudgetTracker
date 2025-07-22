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
    var errorMessage: String?
    
    var existingTransaction: Transaction?
    var direction: Direction
    var type: TransactionOperation = .create
    var bankAccount: BankAccount?
    
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
         cateogiresService: CategoriesService = CategoriesServiceImpl(),
         transactionsService: TransactionsService = TransactionsServiceImpl(),
         bankAccountService: BankAccountsService = BankAccountsServiceImpl()
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
    
    func onAppear() {
        Task {
            await loadBankAccount()
            await loadCategories()
        }
    }
    
    func loadCategories() async {
        do {
            let loadedCategories = try await categoriesService.fetchAllCategoires()
            self.categories = loadedCategories.filter{$0.direction == direction}
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func loadBankAccount() async {
        do {
            bankAccount = try await bankAccountsService.fetchAccount()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
 
    
    func createTransaction() {
        guard let bankAccount, let selectedCategory,
              canCreateTransaction else {
            return
        }
        
        let selectedDateStr = DateStringConverter.string(from: selectedDate)
        let request = CreateTransactionRequest(accountId: bankAccount.id, categoryId: selectedCategory.id, amount: String(describing: amount), transactionDate: selectedDateStr, comment: comment)
    
        Task {
            do {
                try await transactionsService.createTransaction(request: request)
             
                
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }
    
    func updateTransaction() {
        guard let bankAccount,
              let existingTransaction,
              let selectedCategory,
              canCreateTransaction else {
            return
        }
        
        Task {
            do {
                let selectedDateStr = DateStringConverter.string(from: selectedDate)
                let request = UpdateTransactionRequest(id: existingTransaction.id, accountId: bankAccount.id, categoryId: selectedCategory.id, amount: String(describing: amount), transactionDate: selectedDateStr, comment: comment)
                try await transactionsService.updateTransaction(request: request)
                
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }
    
    func deleteTransaction() {
       guard let existingTransaction else {
            return
        }
        
        Task {
            do {
                try await transactionsService.removeTransaction(transactionId: existingTransaction.id)
                
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }
    
    
    
    func formatAmountInput(_ input: String) -> String {
        let decimalSeparator = Locale.current.decimalSeparator ?? "."
        let allowedChars = "0123456789" + decimalSeparator
        
        let filtered = input.filter { allowedChars.contains($0) }
        let separators = filtered.filter { String($0) == decimalSeparator }
        
        if separators.count <= 1 {
            // разделитель может быть только один
            if let separatorIndex = filtered.firstIndex(of: Character(decimalSeparator)) {
                let beforeSeparator = String(filtered[..<separatorIndex])
                let afterSeparator = String(filtered[filtered.index(after: separatorIndex)...])
                
                if afterSeparator.count > 2 {
                    // Ограничиваем количество цифр после разделителя до 2
                    return beforeSeparator + decimalSeparator + String(afterSeparator.prefix(2))
                }
            }
            return filtered
        }
        
        return amountText // если введено больше одного разделителя, возвращаем старое значение
    }
    
    // MARK: - Error Types
    
    enum TransactionError: LocalizedError {
        case missingRequiredFields
        case creationFailed(String)
        case updateFailed(String)
        case deletionFailed(String)
        case noTransactionToDelete
        
        var errorDescription: String? {
            switch self {
            case .missingRequiredFields:
                return "Нужно заполнить все обязательные поля"
            case .creationFailed(let message):
                return "Ошибка создания транзакции: \(message)"
            case .updateFailed(let message):
                return "Ошибка обновления транзакции: \(message)"
            case .deletionFailed(let message):
                return "Ошибка удаления транзакции: \(message)"
            case .noTransactionToDelete:
                return "Нет транзакции для удаления"
            }
        }
    }
}
