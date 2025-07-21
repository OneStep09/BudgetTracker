//
//  TransactionsSumView.swift
//  BudgetTracker
//
//  Created by Самат Танкеев on 20.06.2025.
//

import SwiftUI

struct TransactionsSumView: View {
    let sum: Decimal
    let currencySymbol : String
    var body: some View {
        HStack(alignment: .center) {
            Text("Всего")
                .font(.body)
                .foregroundStyle(Color.primary)
            
            Spacer()
            
            Text("\(sum) \(currencySymbol)")
                .font(.body)
                .foregroundStyle(Color.primary)
        }
    }
}
