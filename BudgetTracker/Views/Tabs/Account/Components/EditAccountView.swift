//
//  EditAccountView.swift
//  BudgetTracker
//
//  Created by Самат Танкеев on 26.06.2025.
//

import SwiftUI

struct EditAccountView: View {
    @Binding var balanceText: String
    @Binding var selectedCurrency: Currency
    

    @State private var showCurrencySelection = false
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("💰")
                    .frame(width: 22, height: 22)
                
                Text("Баланс")
                
                Spacer()
                
                TextField("", text: $balanceText)
                    .frame(minWidth: 100)
                    .multilineTextAlignment(.trailing)
                    .keyboardType(.numberPad)
                    .scrollDismissesKeyboard(.immediately)
            }
            .padding()
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .padding(.horizontal)
            
            HStack {
                Text("Валюта")
                
                Spacer()
                
               
                HStack {
                    Text(selectedCurrency.symbol)
                    Image(systemName: "chevron.right")
                        .font(.body)
                }
                .foregroundColor(.secondary)
                .onTapGesture {
                    showCurrencySelection = true
                }
            }
            .padding()
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .padding(.horizontal)
            
            Spacer()
        }
        
        .confirmationDialog(
            "Валюта",
            isPresented: $showCurrencySelection,
            titleVisibility: .visible
        ) {
            ForEach(Currency.allCases, id: \.self) { currency in
                Button(currency.name) {
                    if selectedCurrency != currency {
                        selectedCurrency = currency
                    }
                }
            
            }
        }
    }
}

