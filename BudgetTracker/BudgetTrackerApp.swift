//
//  BudgetTrackerApp.swift
//  BudgetTracker
//
//  Created by Самат Танкеев on 06.06.2025.
//

import SwiftUI
import LaunchScreen
@main
struct BudgetTrackerApp: App {
    @StateObject private var launchState = LaunchState()
    var body: some Scene {
        WindowGroup {
            
            if launchState.isFinished {
                TabBarView(transactionsOutcomeModel: TransactionsListModel(direction: .outcome),
                           transactionsIncomeModel: TransactionsListModel(direction: .income),
                           accountModel: AccountModel(),
                           categoriesModel: CategoriesModel())
            } else {
                LaunchAnimationView()
                    .environmentObject(launchState)
            }
           
        }
    }
}



