//
//  BalanceChartView.swift
//  BudgetTracker
//
//  Created by Самат Танкеев on 24.07.2025.
//

import SwiftUI
import Charts

struct BalanceChartView: View {
    let dailyBalances: [DailyBalance]
    let currency: String
    @State private var selectedDate: Date?
    
    var body: some View {
        Chart(dailyBalances) { balance in
            BarMark(x: .value("Date", balance.date),
                    y: .value("Balance", abs(balance.balanceDouble)))
                .foregroundStyle(balance.isPositive ? .green : .red)
                .opacity(selectedDate == nil || Calendar.current.isDate(balance.date, inSameDayAs: selectedDate!) ? 1.0 : 0.5)
        }
        .chartXAxis {
            AxisMarks() { value in
                AxisGridLine()
                AxisValueLabel()
            }
        }
        .chartYAxis(.hidden)
        .chartXSelection(value: $selectedDate)
        .chartBackground { chartProxy in
            GeometryReader { geometry in
                Rectangle()
                    .fill(Color.clear)
                    .contentShape(Rectangle())
                    .onTapGesture { location in
                        selectedDate = nil
                    }
            }
        }
        .overlay(alignment: .top) {
            if let selectedDate = selectedDate,
               let selectedBalance = dailyBalances.first(where: { Calendar.current.isDate($0.date, inSameDayAs: selectedDate) })
            {
                VStack(spacing: 4) {
                    Text(selectedDate, style: .date)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(formatBalance(selectedBalance.balance))
                        .font(.headline)
                        .foregroundColor(selectedBalance.isPositive ? .green : .red)
                }
                .padding(8)
                .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 8))
                .transition(.opacity.combined(with: .scale))
            }
        }
        .frame(height: 200)
        .padding()
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
    
 

    private func formatBalance(_ balance: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 2
        formatter.groupingSeparator = " "
        formatter.decimalSeparator = "."
        
        let formattedNumber = formatter.string(from: balance as NSDecimalNumber) ?? "0"
        return "\(formattedNumber) \(currency)"
    }
}


