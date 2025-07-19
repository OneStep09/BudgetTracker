//
//  CategoriesModel.swift
//  BudgetTracker
//
//  Created by Самат Танкеев on 18.07.2025.
//

import SwiftUI

@Observable
final class CategoriesModel {
    var categories: [Category] = []
    var isLoading: Bool = false
    var errorMessage: String?
    var searchText: String = ""
    
    private let service: CategoriesService
    private let direction: Direction
    
    var filteredCategories: [Category] {
        if searchText.isEmpty {
            return categories
        } else {
            return categories
                .compactMap { category in
                    let score = fuzzySearchScore(for: category.name, searchText: searchText)
                    return score > 0 ? (category, score) : nil
                }
                .sorted { $0.1 > $1.1 }
                .map { $0.0 }
        }
    }
    
    var hasCategories: Bool {
        !categories.isEmpty
    }
    
    var shouldShowEmptyState: Bool {
        !isLoading && !hasCategories && errorMessage == nil
    }
    
    var shouldShowError: Bool {
        !isLoading && errorMessage != nil
    }
    
    var shouldShowContent: Bool {
        !isLoading && hasCategories && errorMessage == nil
    }
    
    // MARK: - Initialization
    
    init(service: CategoriesService = CategoriesServiceImpl(), direction: Direction = .outcome) {
        self.service = service
        self.direction = direction
    }
    
    // MARK: - Public Methods
    
    func onViewAppear() {
        Task {
            await fetchCategories()
        }
    }
    
    func refreshCategories() async {
        await fetchCategories()
    }
    
    func retryFetchCategories() {
        Task {
            await fetchCategories()
        }
    }
    
    // MARK: - Private Methods
    
    private func fetchCategories() async {
        await MainActor.run {
            self.isLoading = true
            self.errorMessage = nil
        }
        
        do {
            let fetchedCategories = try await service.fetchCategoires(direction: direction)
            await MainActor.run {
                self.categories = fetchedCategories.filter{$0.direction == direction}
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.errorMessage = error.localizedDescription
                self.isLoading = false
            }
        }
    }
    
    // MARK: - Search Logic
    
    /// Вычисляет насколько две строки похожи
    private func fuzzySearchScore(for text: String, searchText: String) -> Double {
        let text = text.lowercased()
        let search = searchText.lowercased()
        
        // Если одинаковые возвращает максимум
        if text == search {
            return 4
        }
        
        // Если одинаковое начало
        if text.hasPrefix(search) {
            return 3
        }
        
        // Если содержит
        if text.contains(search) {
            return 2
        }
        
        // Вычисление дистанции
        let distance = levenshteinDistance(text, search)
        let maxLength = max(text.count, search.count)
        
        // Если дистанция слишком большая
        if distance > maxLength / 2 {
            return 0.0
        }
        
        let similarity = 1.0 - (Double(distance) / Double(maxLength))
        return similarity
    }
    
    /// Вычисляет расстояние Левенштейна между двумя строками
    private func levenshteinDistance(_ s1: String, _ s2: String) -> Int {
        let s1Array = Array(s1)
        let s2Array = Array(s2)
        let s1Count = s1Array.count
        let s2Count = s2Array.count
        
        var matrix = Array(repeating: Array(repeating: 0, count: s2Count + 1), count: s1Count + 1)
        
        for i in 0...s1Count {
            matrix[i][0] = i
        }
        for j in 0...s2Count {
            matrix[0][j] = j
        }
        
        for i in 1...s1Count {
            for j in 1...s2Count {
                let cost = s1Array[i - 1] == s2Array[j - 1] ? 0 : 1
                matrix[i][j] = min(
                    matrix[i - 1][j] + 1,
                    matrix[i][j - 1] + 1,
                    matrix[i - 1][j - 1] + cost
                )
            }
        }
        
        return matrix[s1Count][s2Count]
    }
}
