//
//  BankAccountDTO.swift
//  BudgetTracker
//
//  Created by Самат Танкеев on 17.07.2025.
//

import Foundation

struct BankAccountDTO: Decodable {
    let id: Int
    let userId: Int?
    let name: String
    let balance: String
    var currency: String
    let createdAt: String?
    let updatedAt: String?
    
    
    func toBankAccount() -> BankAccount {
        return BankAccount(id: id,
                           userId: userId,
                           name: name,
                           balance: Decimal(string: balance) ?? 0,
                           currency: Currency(rawValue: currency) ?? .rub,
                           createdAt: DateStringConverter.date(from: createdAt ?? "") ?? Date(),
                           updatedAt: DateStringConverter.date(from: updatedAt ?? "") ?? Date())
    }
}
