//
//  Decimal + ext.swift
//  BudgetTracker
//
//  Created by Самат Танкеев on 24.06.2025.
//

import Foundation

extension Decimal {
    func formatted(with currencyCode: String) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = " "
        formatter.maximumFractionDigits = 0

        let number = NSDecimalNumber(decimal: self)
        let amountStr = formatter.string(from: number) ?? "\(self)"

        let symbol: String
        switch currencyCode {
        case "RUB": symbol = "₽"
        case "USD": symbol = "$"
        case "EUR": symbol = "€"
        default: symbol = currencyCode
        }

        return "\(amountStr) \(symbol)"
    }
}
