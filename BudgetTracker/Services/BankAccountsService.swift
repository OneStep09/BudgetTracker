//
//  BankAccountsService.swift
//  BudgetTracker
//
//  Created by Самат Танкеев on 11.06.2025.
//

import Foundation

final class BankAccountsService {
    private var bankAccount = BankAccount(id: 0,
                              userId: 0,
                              name: "Основной счет",
                              balance: 20000,
                                          currency: Currency(rawValue: "RUB") ?? Currency.rub,
                              createdAt: DateStringConverter.getDate(from: "2025-06-10T12:34:56.789Z") ?? Date(),
                              updatedAt: DateStringConverter.getDate(from: "2025-06-11T15:12:32.789Z") ?? Date())
    
    func fetchAccount() async throws -> BankAccount {
        bankAccount
    }
    
    
    func updateAccount(with balance: Decimal) async throws {
        let newAccount = BankAccount(id: bankAccount.id,
                                 userId: bankAccount.userId,
                                 name: bankAccount.name,
                                 balance: balance,
                                 currency: bankAccount.currency,
                                 createdAt: bankAccount.createdAt,
                                 updatedAt: bankAccount.updatedAt)
        bankAccount = newAccount
        
        
    }
    
    
}
