//
//  BudgetTrackerTests.swift
//  BudgetTrackerTests
//
//  Created by Самат Танкеев on 06.06.2025.
//

import Testing
import Foundation
@testable import BudgetTracker


struct BudgetTrackerTests {
    
    
    @Test
    func testParseValidTransaction() throws {
        let jsonObject: Any = [
            "id": 0,
            "amount": 1000,
            "comment": "Покупка продуктов",
            "trasactionDate": "2025-06-01T10:34:56.789Z",
            "createdAt": "2025-06-01T10:34:56.789Z",
            "updatedAt": "2025-06-01T10:34:56.789Z",
            "account": [
                "id": 0,
                "userId": 0,
                "name": "Самат",
                "balance": 20000,
                "currency": "RUB",
                "createdAt": "2025-06-10T12:34:56.789Z",
                "updatedAt": "2025-06-11T15:12:32.789Z"
            ],
            "category": [
                "id": 4,
                "name": "Продукты",
                "emoji": "🍬",
                "isIncome": false
            ]
        ]
        
        
        guard let transaction = Transaction.parse(jsonObject: jsonObject) else {
            #expect(Bool(false))
            return
        }
        
        // Проверка Transaction
        #expect(transaction.id == 0)
        #expect(transaction.amount == 1000)
        #expect(transaction.comment == "Покупка продуктов")
        
        // Проверка Account
        #expect(transaction.account.id == 0)
        #expect(transaction.account.userId == 0)
        #expect(transaction.account.name == "Самат")
        #expect(transaction.account.balance == 20000)
        #expect(transaction.account.currency == "RUB")
        
        // Проверка Category
        #expect(transaction.category.id == 4)
        #expect(transaction.category.name == "Продукты")
        #expect(transaction.category.emoji == "🍬")
        #expect(transaction.category.direction == .outcome)
    }
    
    
    @Test
    func testTransactionToJsonObject() throws {
        
        let transaction = createTransaction()
        guard let json = transaction.jsonObject as? [String: Any] else {
            #expect(Bool(false), "Не валидный формат для transaction")
            return
        }
        

        
        // Проверка Transaction
        #expect(json["id"] as? Int == 1)
        #expect(json["amount"] as? Int == 3500)
        #expect(json["comment"] as? String == "Купил кушатц")
        #expect(json["trasactionDate"] as? String == "2025-06-02T15:20:10.000Z")
        #expect(json["createdAt"] as? String == "2025-06-02T15:20:10.000Z")
        #expect(json["updatedAt"] as? String == "2025-06-02T15:20:10.000Z")
        
        guard let accountJson = json["account"] as? [String: Any] else {
            #expect(Bool(false), "Не валидный формат для account")
            return
        }
        
        // Проверка Account
        #expect(accountJson["id"] as? Int == 0)
        #expect(accountJson["userId"] as? Int == 0)
        #expect(accountJson["name"] as? String == "Самат")
        #expect(accountJson["balance"] as? Int == 20000)
        #expect(accountJson["currency"] as? String == "RUB")
        #expect(accountJson["createdAt"] as? String == "2025-06-10T12:34:56.789Z")
        #expect(accountJson["updatedAt"] as? String == "2025-06-11T15:12:32.789Z")
        
        guard let categoryJson = json["category"] as? [String: Any] else {
            #expect(Bool(false), "category is missing or invalid")
            return
        }
        
        // Проверка Category
        #expect(categoryJson["id"] as? Int == 4)
        #expect(categoryJson["name"] as? String == "Продукты")
        #expect(categoryJson["emoji"] as? String == "🍬")
        #expect(categoryJson["isIncome"] as? Bool == false)
    }
    
    
    func createTransaction() -> Transaction {
        let account = BankAccount(id: 0,
                              userId: 0,
                              name: "Самат",
                              balance: 20000,
                              currency: "RUB",
                              createdAt: DateStringConverter.getDate(from: "2025-06-10T12:34:56.789Z") ?? Date(),
                              updatedAt: DateStringConverter.getDate(from: "2025-06-11T15:12:32.789Z") ?? Date())
        
        let category =  Category(id: 4, name: "Продукты", emoji: "🍬", direction: .outcome)
        
        return Transaction(id: 1, account: account, category: category,
                           amount: 3500,
                           trasactionDate: DateStringConverter.getDate(from: "2025-06-02T15:20:10.000Z") ?? Date(),
                           comment: "Купил кушатц",
                           createdAt: DateStringConverter.getDate(from: "2025-06-02T15:20:10.000Z") ?? Date(),
                           updatedAt: DateStringConverter.getDate(from: "2025-06-02T15:20:10.000Z") ?? Date())
    }
    
    
    @Test
    func testParseValidCSVTransaction() throws {
        let csvLine = """
        0,1000,Покупка продуктов,2025-06-01T10:34:56.789Z,2025-06-01T10:34:56.789Z,2025-06-01T10:34:56.789Z,0,0,Самат,20000,RUB,2025-06-10T12:34:56.789Z,2025-06-11T15:12:32.789Z,4,Продукты,🍬,false
        """
        
        guard let transaction = Transaction.parse(csvLine: csvLine) else {
            #expect(Bool(false), "Не удалось распарсить CSV строку")
            return
        }
        
        // Проверка Transaction
        #expect(transaction.id == 0)
        #expect(transaction.amount == 1000)
        #expect(transaction.comment == "Покупка продуктов")
        #expect(DateStringConverter.getStringUTC(from: transaction.trasactionDate) == "2025-06-01T10:34:56.789Z")
        #expect(DateStringConverter.getStringUTC(from: transaction.createdAt) == "2025-06-01T10:34:56.789Z")
        #expect(DateStringConverter.getStringUTC(from: transaction.updatedAt) == "2025-06-01T10:34:56.789Z")

        // Проверка Account
        let account = transaction.account
        #expect(account.id == 0)
        #expect(account.userId == 0)
        #expect(account.name == "Самат")
        #expect(account.balance == 20000)
        #expect(account.currency == "RUB")
        #expect(DateStringConverter.getStringUTC(from: account.createdAt) == "2025-06-10T12:34:56.789Z")
        #expect(DateStringConverter.getStringUTC(from: account.updatedAt) == "2025-06-11T15:12:32.789Z")
        
        // Проверка Category
        let category = transaction.category
        #expect(category.id == 4)
        #expect(category.name == "Продукты")
        #expect(category.emoji == "🍬")
        #expect(category.direction == .outcome)
    }

    
    
    
    
    
    
    
}
