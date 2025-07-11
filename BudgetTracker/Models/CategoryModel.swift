//
//  CategoryModel.swift
//  BudgetTracker
//
//  Created by Самат Танкеев on 06.06.2025.
//

import Foundation

enum Direction {
    case income
    case outcome
}



struct Category: Identifiable, Hashable {
    let id: Int
    let name: String
    let emoji: Character
    let direction: Direction

}





