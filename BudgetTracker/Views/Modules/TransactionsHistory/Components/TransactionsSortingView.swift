//
//  TransactionsSortingView.swift
//  BudgetTracker
//
//  Created by Самат Танкеев on 24.06.2025.
//

import SwiftUI

struct TransactionsSortingView: View {
    
    @Binding var sortOption: TransactionSortOption
    var sortTransactions: (() -> ())
    
    var body: some View {
        HStack {
            Text("Сортировать по")
            
            Spacer()
            
            Picker("Сортировка", selection: $sortOption) {
                ForEach(TransactionSortOption.allCases) { option in
                    Text(option.rawValue).tag(option)
                }
            }
            .pickerStyle(.menu)
            .frame(alignment: .leading)
            .onChange(of: sortOption) {
                sortTransactions()
            }
        }
    }
}


