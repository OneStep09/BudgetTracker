//
//  TransactionsSortOption.swift
//  BudgetTracker
//
//  Created by Самат Танкеев on 20.06.2025.
//

import Foundation

enum TransactionSortOption: String, CaseIterable, Identifiable {
    case date = "дате"
    case sum = "сумме"
    
    var id: String { self.rawValue }
    
    var label: String {
        switch self {
        case .date: return "по дате"
        case .sum: return "по сумме"
        }
    }
}
