//
//  CategoriesService.swift
//  BudgetTracker
//
//  Created by Самат Танкеев on 11.06.2025.
//

import Foundation

protocol CategoriesService {
    func fetchAllCategoires() async throws -> [Category]
    func fetchCategoires(direction: Direction) async throws -> [Category]
}





