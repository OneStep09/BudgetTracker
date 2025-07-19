//
//  Untitled.swift
//  BudgetTracker
//
//  Created by Самат Танкеев on 18.07.2025.
//

import Foundation

struct UpdateAccountRequest: Encodable {
    let name: String
    let balance: String
    let currency: String
}
