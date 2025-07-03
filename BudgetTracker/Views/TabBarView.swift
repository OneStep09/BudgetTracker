//
//  MainView.swift
//  BudgetTracker
//
//  Created by Самат Танкеев on 19.06.2025.
//

import SwiftUI

struct TabBarView: View {
    var body: some View {
        TabView {
            NavigationStack {
                TransactionsListView(direction: .outcome)
            }
            .tabItem {
                Label("Расходы", image: "expensesTab")
            }
            .tint(Color(.secondary))
            
            NavigationStack {
                TransactionsListView(direction: .income)
            }
            .tabItem {
                Label("Доходы", image: "incomeTab")
            }
            .tint(Color(.secondary))
            
            
            NavigationStack {
                AccountView()
            }
            .tabItem {
                Label("Счет", image: "accountTab")
            }
            
            NavigationStack {
                CategoriesView()
            }
            .tabItem {
                Label("Статьи", image: "categoriesTab")
            }
            
            NavigationStack {
                SettingsView()
            }
            .tabItem {
                Label("Настройки", image: "settigsTab")
            }
        }
    }
}

#Preview {
    TabBarView()
}
