//
//  CategoriesServiceMock.swift
//  BudgetTracker
//
//  Created by Самат Танкеев on 18.07.2025.
//
import Foundation

final class CategoriesServiceMock: CategoriesService {
    
    private let categories = [
        Category(id: 0, name: "Аренда квартиры", emoji: "🏠", direction: .outcome),
        Category(id: 1, name: "Одежда", emoji: "👗", direction: .outcome),
        Category(id: 2, name: "На собачку", emoji: "🐕", direction: .outcome),
        Category(id: 3, name: "Ремонт квартиры", emoji: "🔨", direction: .outcome),
        Category(id: 4, name: "Продукты", emoji: "🍬", direction: .outcome),
        Category(id: 5, name: "Спортзал", emoji: "🏋️", direction: .outcome),
        Category(id: 6, name: "Медицина", emoji: "💊", direction: .outcome),
        Category(id: 7, name: "Аптека", emoji: "💜", direction: .outcome),
        Category(id: 8, name: "Машина", emoji: "🚗", direction: .outcome),
        Category(id: 9, name: "Зарплата", emoji: "💼", direction: .income),
        Category(id: 10, name: "Премия", emoji: "🎉", direction: .income),
        Category(id: 11, name: "Стипендия", emoji: "🎓", direction: .income),
    ]
    
    func fetchAllCategoires() async throws -> [Category] {
        return categories
    }
    
    func fetchCategoires(direction: Direction) async throws -> [Category] {
        return categories.filter{$0.direction == direction}
    }
}
