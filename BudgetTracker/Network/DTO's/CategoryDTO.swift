//
//  CategoryDTO.swift
//  BudgetTracker
//
//  Created by Самат Танкеев on 17.07.2025.
//



struct CategoryDTO: Decodable {
    let id: Int
    let name: String
    let emoji: String
    let isIncome: Bool
    
    func toCategory()  -> Category {
        
        return Category(id: id,
                        name: name,
                        emoji: Character(emoji),
                        direction: isIncome ? .income : .outcome)
    }
}
