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
            ExpensesView()
                .tabItem {
                    Label("Расходы", image: "expensesTab")
                }
            
            IncomeView()
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
