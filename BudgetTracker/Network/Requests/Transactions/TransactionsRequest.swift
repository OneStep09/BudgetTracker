//
//  TransactionsRequest.swift
//  BudgetTracker
//
//  Created by Самат Танкеев on 17.07.2025.
//

import Foundation

struct TransactionsRequest: Encodable {
    let startDate: String
    let endDate: String
    
    enum CodingKeys: CodingKey {
        case startDate
        case endDate
    }
}
