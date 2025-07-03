//
//  CategoryItemView.swift
//  BudgetTracker
//
//  Created by Самат Танкеев on 03.07.2025.
//


import SwiftUI

struct CategoryItemView: View {
    let category: Category
    var body: some View {
        HStack(spacing: 16) {
            Text(String(category.emoji))
                .font(.system(size: 16))
                .padding(4)
                .background(Color.accent.opacity(0.2))
                .clipShape(Circle())

                Text(category.name)
                    .font(.body)
                    .lineLimit(1)
            Spacer()
        }
        .padding(8)
    }
}
