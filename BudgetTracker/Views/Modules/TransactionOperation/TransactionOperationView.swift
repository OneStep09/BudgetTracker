//
//  TransactionOperationView.swift
//  BudgetTracker
//
//  Created by Самат Танкеев on 11.07.2025.
//


import SwiftUI

struct TransactionOperationView: View {
    @State var model: TransactionOperationModel
    @Environment(\.dismiss) private var dismiss
    @State private var showValidationAlert = false
    
    init(model: TransactionOperationModel) {
        self.model = model
    }
    
    var body: some View {
        VStack(spacing: 0) {
            headerView
            List {
                Section {
                    categoryRow
                    amountRow
                    dateRow
                    timeRow
                    commentRow
                }
                
                if model.type == .edit {
                    Section {
                        deleteButton
                    }
                }
            }
            .padding(.top, -20)
        }
        .navigationBarBackButtonHidden()
        .background(Color(.systemGray6))
        .task {
            await model.loadCategories()
        }
        .alert("Удалить транзакцию?", isPresented: $model.showDeleteAlert) {
            Button("Отмена", role: .cancel) { }
            Button("Удалить", role: .destructive) {
                model.deleteTransaction()
                dismiss()
            }
        } message: {
            Text("Это действие нельзя отменить")
        }
        .alert("Не все поля заполены", isPresented: $showValidationAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Нужно заполнить все обязательные поля")
        }
    }
    
    var headerView: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                cancelButton
                Spacer()
                actionButton
            }
            
            Text(title)
                .font(.largeTitle)
                .fontWeight(.bold)
        }
        .padding()
    }

    private var categoryRow: some View {
        Menu {
            ForEach(model.categories) { category in
                Button(action: {
                    model.selectedCategoryId = category.id
                }) {
                    HStack {
                        Text(category.name)
                    }
                }
            }
        } label: {
            HStack {
                Text("Статья")
                
                Spacer()
                
                if let selectedCategory = model.selectedCategory {
                    Text(selectedCategory.name)
                } else {
                   Text("Выберете")
                        .foregroundStyle(Color.secondary)
                        .font(.callout)
                }
                Image(systemName: "chevron.right")
                    .font(.caption)
            }
            .foregroundColor(.primary)
            .padding(.vertical, 4)
        }
    }
    
    private var amountRow: some View {
        HStack {
            Text("Сумма")
                .foregroundColor(.primary)
            Spacer()
            
            TextField("0", text: $model.amountText)
                .keyboardType(.decimalPad)
                .multilineTextAlignment(.trailing)
                .frame(minWidth: 100)
                .onChange(of: model.amountText) { oldValue, newValue in
                    model.amountText = model.formatAmountInput(newValue)
                }
            
            Text("₽")
                .foregroundColor(.secondary)
        }
    }
    
    private var dateRow: some View {
        HStack {
            Text("Дата")
                .foregroundColor(.primary)
            Spacer()
            
            DatePicker("", selection: $model.selectedDate, in: ...Date(), displayedComponents: .date)
                .labelsHidden()
                .background(.accent.opacity(0.2))
                .clipShape(RoundedRectangle(cornerRadius: 8))
        }
    }
    
    private var timeRow: some View {
        HStack {
            Text("Время")
                .foregroundColor(.primary)
            Spacer()
            
            DatePicker("", selection: $model.selectedDate, displayedComponents: .hourAndMinute)
                .labelsHidden()
                .background(.accent.opacity(0.2))
                .clipShape(RoundedRectangle(cornerRadius: 8))
        }
    }
    
    private var commentRow: some View {
        HStack {
            TextField("Комментарий", text: $model.comment)
        }
    }
    
    private var deleteButton: some View {
        Button(action: {
            model.showDeleteAlert = true
        }) {
            Text("Удалить")
                .foregroundColor(.red)
        }
    }
    
    // MARK: - Navigation Bar Items
    
    private var cancelButton: some View {
        Button("Отмена") {
            dismiss()
        }
    }
    
    private var actionButton: some View {
        Button(actionButtonTitle) {
            // Check validation first
            guard model.canCreateTransaction else {
                showValidationAlert = true
                return
            }
            
            switch model.type {
            case .create:
                model.createTransaction()
            case .edit:
                model.updateTransaction()
            }
            
            dismiss()
        }
    }
    
    // MARK: - Computed Properties

    private var title: String {
        switch model.direction {
        case .income:
            "Мои доходы"
        case .outcome:
            "Мои расходы"
        }
    }
    
    private var actionButtonTitle: String {
        switch model.type {
        case .create:
            return "Создать"
        case .edit:
            return "Сохранить"
        }
    }
}

// MARK: - Helper Methods

enum TransactionOperation {
    case create
    case edit
}


#Preview {
    let model = TransactionOperationModel(direction: .outcome)
    TransactionOperationView(model: model)
}
