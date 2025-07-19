//
//  CategoriesView.swift
//  BudgetTracker
//
//  Created by Самат Танкеев on 19.06.2025.
//

import SwiftUI

struct CategoriesView: View {
    @State private var model: CategoriesModel
    
//    init(service: CategoriesService = CategoriesServiceImpl(), direction: Direction = .outcome) {
//        self._model = State(initialValue: CategoriesModel(service: service, direction: direction))
//    }
    
    init(model: CategoriesModel) {
        self.model = model
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
        .searchable(text: $model.searchText)
        .task {
            model.onViewAppear()
        }
        .refreshable {
            await model.refreshCategories()
        }
    }

    @ViewBuilder
    private var categoriesSection: some View {
        Section("Статьи") {
            if model.isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity)
            } else if model.shouldShowError {
                errorView(message: model.errorMessage ?? "Неизвестная ошибка")
            } else if model.shouldShowEmptyState {
                emptyStateView
            } else if model.shouldShowContent {
                categoriesList
            }
        }
    }
    
    private var categoriesList: some View {
        LazyVStack(alignment: .leading, spacing: 0) {
            ForEach(model.filteredCategories) { category in
                CategoryItemView(category: category)
                
                if category.id != model.filteredCategories.last?.id {
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
    
    private var emptyStateView: some View {
        VStack(spacing: 12) {
            Image(systemName: "folder.badge.questionmark")
                .font(.system(size: 48))
                .foregroundStyle(Color.secondary)
            
            Text("Нет категорий")
                .font(.headline)
                .foregroundStyle(Color.primary)
            
            Text("Категории появятся здесь после загрузки")
                .font(.body)
                .foregroundStyle(Color.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
        
    private func errorView(message: String) -> some View {
        VStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 48))
                .foregroundStyle(Color.orange)
            
            Text("Ошибка")
                .font(.headline)
                .foregroundStyle(Color.primary)
            
            Text(message)
                .font(.body)
                .foregroundStyle(Color.secondary)
                .multilineTextAlignment(.center)
            
            Button("Повторить") {
                model.retryFetchCategories()
            }
            .buttonStyle(.bordered)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

#Preview {
    NavigationView {
        CategoriesView(model: CategoriesModel())
    }
}
