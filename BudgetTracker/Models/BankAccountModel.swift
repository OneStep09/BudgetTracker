//
//  BankModel.swift
//  BudgetTracker
//
//  Created by Самат Танкеев on 06.06.2025.
//

import Foundation

struct BankAccount {
    let id: Int
    let userId: Int?
    let name: String
    let balance: Decimal
    var currency: Currency
    let createdAt: Date?
    let updatedAt: Date?
}


enum Currency: String, CaseIterable {
    case rub = "RUB"
    case usd = "USD"
    case eur = "EUR"
    
    var name: String {
        switch self {
        case .rub:
            "Российский рубль ₽"
        case .usd:
            "Американский доллар $"
        case .eur:
            "Евро €"
        }
    }
    
    var symbol: String {
        switch self {
        case .rub:
            "₽"
        case .usd:
            "$"
        case .eur:
            "€"
        }
    }
    
}


