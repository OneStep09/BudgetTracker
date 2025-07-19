//
//  MainView.swift
//  BudgetTracker
//
//  Created by Самат Танкеев on 19.06.2025.
//

import SwiftUI

struct TabBarView: View {
    
    
    var transactionsOutcomeModel: TransactionsListModel
    var transactionsIncomeModel: TransactionsListModel
    var accountModel: AccountModel
    var categoriesModel: CategoriesModel
    
    var body: some View {
        TabView {
            NavigationStack {
                TransactionsListView(model: transactionsOutcomeModel)
            }
            .tabItem {
                Label("Расходы", image: "expensesTab")
            }
            .tint(Color(.secondary))
            
            NavigationStack {
                TransactionsListView(model: transactionsIncomeModel)
            }
            .tabItem {
                Label("Доходы", image: "incomeTab")
            }
            .tint(Color(.secondary))
            
            
            NavigationStack {
                AccountView(model: accountModel)
            }
            .tabItem {
                Label("Счет", image: "accountTab")
            }
            
            NavigationStack {
                CategoriesView(model: categoriesModel)
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
    TabBarView(transactionsOutcomeModel: TransactionsListModel(direction: .outcome),
               transactionsIncomeModel: TransactionsListModel(direction: .income),
               accountModel: AccountModel(),
               categoriesModel: CategoriesModel())
}
