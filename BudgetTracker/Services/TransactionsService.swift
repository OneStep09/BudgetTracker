//
//  TransactionsService.swift
//  BudgetTracker
//
//  Created by Самат Танкеев on 11.06.2025.
//
import Foundation

final class TransactionsService {
    private lazy var bankAccount = BankAccount(id: 0,
                                           userId: 0,
                                           name: "Самат",
                                           balance: 20000,
                                           currency: "RUB",
                                           createdAt: DateStringConverter.getDate(from: "2025-06-10T12:34:56.789Z") ?? Date(),
                                           updatedAt: DateStringConverter.getDate(from: "2025-06-11T15:12:32.789Z") ?? Date())
    private lazy var categories = [
        Category(id: 0, name: "Аренда квартиры", emoji: "🏠", direction: .outcome),
        Category(id: 1, name: "Одежда", emoji: "👗", direction: .outcome),
        Category(id: 2, name: "На собачку", emoji: "🐕", direction: .outcome),
        Category(id: 3, name: "Ремонт квартиры", emoji: "🔨", direction: .outcome),
        Category(id: 4, name: "Продукты", emoji: "🍬", direction: .outcome),
        Category(id: 5, name: "Спортзал", emoji: "🏋️", direction: .outcome),
        Category(id: 6, name: "Медицина", emoji: "💊", direction: .outcome),
        Category(id: 7, name: "Аптека", emoji: "💜", direction: .outcome),
        Category(id: 8, name: "Машина", emoji: "🚗", direction: .outcome),
        Category(id: 9, name: "Зарплата", emoji: "💼", direction: .income),
        Category(id: 10, name: "Премия", emoji: "🎉", direction: .income),
        Category(id: 11, name: "Стипендия", emoji: "🎓", direction: .income),
    ]
    
    private lazy var transactions = [
        Transaction(id: 0, account: bankAccount, category: categories[0],
                    amount: 20000,
                    trasactionDate: DateStringConverter.getDate(from: "2025-06-01T10:34:56.789Z") ?? Date(),
                    comment: "Плата за аренду",
                    createdAt: DateStringConverter.getDate(from: "2025-06-01T10:34:56.789Z") ?? Date(),
                    updatedAt: DateStringConverter.getDate(from: "2025-06-01T10:34:56.789Z") ?? Date()),

        Transaction(id: 1, account: bankAccount, category: categories[4],
                    amount: 3500,
                    trasactionDate: DateStringConverter.getDate(from: "2025-06-02T15:20:10.000Z") ?? Date(),
                    comment: "Купил кушатц",
                    createdAt: DateStringConverter.getDate(from: "2025-06-02T15:20:10.000Z") ?? Date(),
                    updatedAt: DateStringConverter.getDate(from: "2025-06-02T15:20:10.000Z") ?? Date()),

        Transaction(id: 2, account: bankAccount, category: categories[5],
                    amount: 2500,
                    trasactionDate: DateStringConverter.getDate(from: "2025-06-03T08:00:00.000Z") ?? Date(),
                    comment: "Абонемент в спортзал",
                    createdAt: DateStringConverter.getDate(from: "2025-06-03T08:00:00.000Z") ?? Date(),
                    updatedAt: DateStringConverter.getDate(from: "2025-06-03T08:00:00.000Z") ?? Date()),

        Transaction(id: 3, account: bankAccount, category: categories[9],
                    amount: 50000,
                    trasactionDate: DateStringConverter.getDate(from: "2025-06-05T09:00:00.000Z") ?? Date(),
                    comment: "Зарплата за май",
                    createdAt: DateStringConverter.getDate(from: "2025-06-05T09:00:00.000Z") ?? Date(),
                    updatedAt: DateStringConverter.getDate(from: "2025-06-05T09:00:00.000Z") ?? Date()),

        Transaction(id: 4, account: bankAccount, category: categories[2],
                    amount: 1200,
                    trasactionDate: DateStringConverter.getDate(from: "2025-06-06T14:15:00.000Z") ?? Date(),
                    comment: "Корм для собачки",
                    createdAt: DateStringConverter.getDate(from: "2025-06-06T14:15:00.000Z") ?? Date(),
                    updatedAt: DateStringConverter.getDate(from: "2025-06-06T14:15:00.000Z") ?? Date()),

        Transaction(id: 5, account: bankAccount, category: categories[10],
                    amount: 15000,
                    trasactionDate: DateStringConverter.getDate(from: "2025-06-07T11:11:00.000Z") ?? Date(),
                    comment: "Премия за хорошую работу",
                    createdAt: DateStringConverter.getDate(from: "2025-06-07T11:11:00.000Z") ?? Date(),
                    updatedAt: DateStringConverter.getDate(from: "2025-06-07T11:11:00.000Z") ?? Date()),

        Transaction(id: 6, account: bankAccount, category: categories[1],
                    amount: 4800,
                    trasactionDate: DateStringConverter.getDate(from: "2025-06-08T17:30:00.000Z") ?? Date(),
                    comment: "Купил футболку и джинсы",
                    createdAt: DateStringConverter.getDate(from: "2025-06-08T17:30:00.000Z") ?? Date(),
                    updatedAt: DateStringConverter.getDate(from: "2025-06-08T17:30:00.000Z") ?? Date()),

        Transaction(id: 7, account: bankAccount, category: categories[7],
                    amount: 900,
                    trasactionDate: DateStringConverter.getDate(from: "2025-06-09T12:00:00.000Z") ?? Date(),
                    comment: "Купил витамины в аптеке",
                    createdAt: DateStringConverter.getDate(from: "2025-06-09T12:00:00.000Z") ?? Date(),
                    updatedAt: DateStringConverter.getDate(from: "2025-06-09T12:00:00.000Z") ?? Date())
    ]
    
    
    func fetchTransactions(startDate: Date, endDate: Date) async throws -> [Transaction] {
        return transactions.filter { transaction in
            transaction.trasactionDate >= startDate && transaction.trasactionDate <= endDate
        }
    }
    
    func addTransaction(transaction: Transaction) async throws {
        guard  !transactions.contains(where: {$0.id == transaction.id}) else {
            throw NSError(domain: "TransactionsService", code: 1, userInfo: [NSLocalizedDescriptionKey: "Данная транзакция уже существет"])
        }
        
        transactions.append(transaction)
    }
    
    func removeTransaction(transaction: Transaction) async throws {
        guard transactions.contains(where: {$0.id == transaction.id}) else {
            throw NSError(domain: "TransactionsService", code: 1, userInfo: [NSLocalizedDescriptionKey: "Данной транзации нет"])
        }
        
        transactions.removeAll(where: {$0.id == transaction.id})
    }
    
    func updateTransaction(transaction: Transaction) async throws {
        guard let ind = transactions.firstIndex(where: {$0.id == transaction.id}) else {
            throw NSError(domain: "TransactionsService", code: 1, userInfo: [NSLocalizedDescriptionKey: "Данной транзации нет"])
        }
        
        transactions[ind] = transaction
    
        
    }


    
  
    
    
    
}
