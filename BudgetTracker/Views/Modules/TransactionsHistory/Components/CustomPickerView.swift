//
//  CustomPickerView.swift
//  BudgetTracker
//
//  Created by Самат Танкеев on 24.06.2025.
//

import SwiftUI

struct CustomPickerView: View {
    let label: String
    @Binding var selectedDate: Date
    
    var body: some View {
        HStack {
            Text(label)
            
            Spacer()
            
            DatePicker("", selection: $selectedDate, displayedComponents: .date)
                .labelsHidden()
                .background(Color.accent.opacity(0.2))
                .clipShape(RoundedRectangle(cornerRadius: 4))
        }
       
    }
}


