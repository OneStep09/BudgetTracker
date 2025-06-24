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
            if transaction.category.direction == .outcome {
                    Text(String(transaction.category.emoji))
                        .font(.system(size: 16))
                        .padding(4)
                        .background(Color.accent.opacity(0.2))
                        .clipShape(Circle())
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(transaction.category.name)
                    .font(.body)
                    .lineLimit(1)
                
                if let comment = transaction.comment {
                    Text(comment)
                        .font(.footnote)
                        .foregroundStyle(Color.secondary)
                        .lineLimit(1)
                }
            }
            
            Spacer()
            
            Text(transaction.amount.formatted(with: transaction.account.currency))
                .font(.body)
            
            Image(systemName: "chevron.right")
                .foregroundStyle(Color.secondary)
        }
        .padding(8)
    }
}
