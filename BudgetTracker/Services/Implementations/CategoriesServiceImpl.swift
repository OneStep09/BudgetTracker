//
//  CategoriesServiceImpl.swift
//  BudgetTracker
//
//  Created by Самат Танкеев on 18.07.2025.
//

import Foundation

final class CategoriesServiceImpl: CategoriesService {
    func fetchAllCategoires() async throws -> [Category] {
        let endpoint = "categories"
        let categories: [CategoryDTO] = try await NetworkClient.shared.request(endpoint: endpoint)
        return categories.map { $0.toCategory() }
    }
    
    func fetchCategoires(direction: Direction) async throws -> [Category] {
        let isIncome = direction == .income
        let endpoint = "categories/type/\(isIncome)"
        print("Fetch catrgories by type endpoint: ", endpoint)
        let categories: [CategoryDTO] = try await NetworkClient.shared.request(endpoint: endpoint)
        return categories.map { $0.toCategory() }
    }
}
