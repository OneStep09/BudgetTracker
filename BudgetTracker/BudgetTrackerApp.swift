//
//  BudgetTrackerApp.swift
//  BudgetTracker
//
//  Created by Самат Танкеев on 06.06.2025.
//

import SwiftUI

@main
struct BudgetTrackerApp: App {
    var body: some Scene {
        WindowGroup {
            TabBarView(transactionsOutcomeModel: TransactionsListModel(direction: .outcome),
                       transactionsIncomeModel: TransactionsListModel(direction: .income),
                       accountModel: AccountModel(),
                       categoriesModel: CategoriesModel())
        }
    }
}
