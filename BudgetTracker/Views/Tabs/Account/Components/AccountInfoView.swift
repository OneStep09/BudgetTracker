//
//  AccountInfoView.swift
//  BudgetTracker
//
//  Created by Самат Танкеев on 26.06.2025.
//

import SwiftUI

struct AccountInfoView: View {
    var balance: Decimal
    var currency: Currency
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("💰")
                    .frame(width: 22, height: 22)
                
                Text("Баланс")
                
                Spacer()
                
                Text(balance.formatted())
                    .foregroundStyle(Color.graylish)
            }
            .padding()
            .background(Color.accentColor)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .padding(.horizontal)
            
            HStack {
                Text("Валюта")
                
                Spacer()
                
                Text(currency.symbol)
                    .foregroundStyle(Color.graylish)
                
            }
            .padding()
            .background(Color.accentColor.opacity(0.2))
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .padding(.horizontal)
        }
    }
}


