//
//  BankAccountsServiceMock.swift
//  BudgetTracker
//
//  Created by Самат Танкеев on 18.07.2025.
//

import Foundation

final class BankAccountsServiceMock: BankAccountsService {
    
    private var bankAccount = BankAccount(id: 0,
                                          userId: 0,
                                          name: "Основной счет",
                                          balance: 20000,
                                          currency: Currency(rawValue: "RUB") ?? Currency.rub,
                                          createdAt: DateStringConverter.date(from: "2025-06-10T12:34:56.789Z") ?? Date(),
                                          updatedAt: DateStringConverter.date(from: "2025-06-11T15:12:32.789Z") ?? Date())
    
    func fetchAccount() async throws -> BankAccount {
        bankAccount
    }
    
    func updateAccount(account: BankAccount) async throws -> BankAccount {
        let newAccount = BankAccount(id: account.id,
                                     userId: account.userId,
                                     name: account.name,
                                     balance: account.balance,
                                     currency: account.currency,
                                     createdAt: account.createdAt,
                                     updatedAt: account.updatedAt)
        bankAccount = newAccount
        
        return bankAccount
    }
}
