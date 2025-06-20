//
//  TransactionItemView.swift
//  BudgetTracker
//
//  Created by Самат Танкеев on 20.06.2025.
//

import SwiftUI

struct TransactionItemView: View {
    let transaction: Transaction
    var body: some View {
        HStack {
            Text(String(transaction.category.emoji))
                .font(.title2)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(transaction.category.name)
                    .font(.body)
                
                Text(transaction.category.name)
                    .font(.footnote)
                    .foregroundStyle(Color.secondary)
            }
            
            Spacer()
            
            Text("\(transaction.amount) ₽")
                .font(.body)
            
            Image(systemName: "chevron.right")
                .foregroundStyle(Color.secondary)
        }
        .padding(8)
    }
}
