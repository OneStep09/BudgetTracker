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
              return categories.filter { category in
                  category.name.localizedCaseInsensitiveContains(searchText)
              }
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
}

#Preview {
    NavigationView {
        CategoriesView()
    }
}
