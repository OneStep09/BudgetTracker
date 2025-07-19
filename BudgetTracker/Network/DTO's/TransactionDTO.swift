//
//  TransactionDTO.swift
//  BudgetTracker
//
//  Created by Самат Танкеев on 17.07.2025.
//

import Foundation

struct TransactionDTO: Decodable {
    let id: Int
    let account: BankAccountDTO
    let category: CategoryDTO
    let amount: String
    let transactionDate: String
    let comment: String?
    let createdAt: String
    let updatedAt: String
    
    
    func toTransaction() -> Transaction {
        Transaction(id: id,
                    account: account.toBankAccount(),
                    category: category.toCategory(),
                    amount: Decimal(string: amount) ?? 0,
                    trasactionDate: DateStringConverter.date(from: transactionDate) ?? Date(),
                    comment: comment,
                    createdAt: DateStringConverter.date(from: createdAt) ?? Date(),
                    updatedAt: DateStringConverter.date(from: updatedAt) ?? Date())
    }
}


