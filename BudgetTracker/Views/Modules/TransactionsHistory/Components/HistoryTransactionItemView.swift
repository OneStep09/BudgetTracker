//
//  Transaction.swift
//  BudgetTracker
//
//  Created by Самат Танкеев on 20.06.2025.
//

import SwiftUI

struct HistoryTransactionItemView: View {
    let transaction: Transaction
    var body: some View {
        HStack {
            Text(String(transaction.category.emoji))
                .font(.title2)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(transaction.category.name)
                    .font(.body)
                    .lineLimit(1)
                
                Text(transaction.category.name)
                    .font(.footnote)
                    .foregroundStyle(Color.secondary)
                    .lineLimit(1)
            }
            
            Spacer()
            
            VStack(spacing: 4) {
                Text("\(transaction.amount) ₽")
                    .font(.body)
                
                Text("\(DateStringConverter.getString(from: transaction.trasactionDate, formatType: .time))")
                    .font(.body)
            }
            
            Image(systemName: "chevron.right")
                .foregroundStyle(Color.secondary)
        }
        .padding(8)
    }
}
