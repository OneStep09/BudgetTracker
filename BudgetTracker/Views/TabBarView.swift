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
            TransactionsListView(direction: .outcome)
                .tabItem {
                    Label("Расходы", image: "expensesTab")
                }
            
            TransactionsListView(direction: .income)
                .tabItem {
                    Label("Доходы", image: "incomeTab")
                }
            
            AccountView()
                .tabItem {
                    Label("Счет", image: "accountTab")
                }
            
            CategoriesView()
                .tabItem {
                    Label("Статьи", image: "categoriesTab")
                }
            
            SettingsView()
                .tabItem {
                    Label("Настройки", image: "settigsTab")
                }
        }
    }
}

#Preview {
    TabBarView()
}
