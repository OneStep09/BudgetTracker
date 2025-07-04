//
//  CategoriesView.swift
//  BudgetTracker
//
//  Created by Самат Танкеев on 19.06.2025.
//

import SwiftUI

struct CategoriesView: View {
    
    
    @State private var categories: [Category] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var searchText = ""
    
    
    private var filteredCategories: [Category] {
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
    
    private let service: CategoriesService
    private let direction: Direction
    
    init(
        service: CategoriesService = CategoriesService(),
        direction: Direction = .outcome
    ) {
        self.service = service
        self.direction = direction
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                categoriesSection
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
        }
        .background(Color(.systemGray6))
        .navigationTitle("Мои статьи")
        .searchable(text: $searchText)
        .task {
            await fetchCategories()
        }
        .refreshable {
            await fetchCategories()
        }
    }
  

    @ViewBuilder
    private var categoriesSection: some View {
        Section("Статьи") {
            if isLoading {
                ProgressView("Загрузка...")
            } else if let errorMessage = errorMessage {
                errorView(message: errorMessage)
            } else if categories.isEmpty {
                EmptyView()
            } else {
                categoriesList
            }
        }
        .foregroundStyle(Color.secondary)
    }
    
    private var categoriesList: some View {
        LazyVStack(alignment: .leading, spacing: 0) {
            ForEach(filteredCategories) { category in
                CategoryItemView(category: category)
                
                if category.id != categories.last?.id {
                    Divider()
                        .padding(.leading, 48)
                        .padding(.bottom, 8)
                }
            }
        }
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .foregroundStyle(Color.primary)
        
    }
        
    private func errorView(message: String) -> some View {
        VStack(spacing: 12) {
            Text("Ошибка")
                .font(.headline)
                .foregroundStyle(Color.primary)
            
            Text(message)
                .font(.body)
                .foregroundStyle(Color.secondary)
                .multilineTextAlignment(.center)
            
            Button("Повторить") {
                Task {
                    await fetchCategories()
                }
            }
            .buttonStyle(.bordered)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
    
  
    
  
    
    private func fetchCategories() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let fetchedCategories = try await service.fetchCategoires(direction: direction)
            categories = fetchedCategories
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    
    // Вычисляет наколько две строки похожи
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
                      matrix[i - 1][j] + 1,      // Удаление символа
                      matrix[i][j - 1] + 1,      // Добавление
                      matrix[i - 1][j - 1] + cost // Замена
                  )
              }
          }
          
          return matrix[s1Count][s2Count]
      }
}

#Preview {
    NavigationView {
        CategoriesView()
    }
}
