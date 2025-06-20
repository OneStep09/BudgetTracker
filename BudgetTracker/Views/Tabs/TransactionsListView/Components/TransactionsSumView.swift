//
//  TransactionsSumView.swift
//  BudgetTracker
//
//  Created by Самат Танкеев on 20.06.2025.
//

import SwiftUI

struct TransactionsSumView: View {
    let sum: Decimal
    var body: some View {
        HStack(alignment: .center) {
            Text("Всего")
                .font(.body)
                .foregroundStyle(Color.primary)
            
            Spacer()
            
            Text("\(sum) ₽")
                .font(.body)
                .foregroundStyle(Color.primary)
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .padding()
    }
}
