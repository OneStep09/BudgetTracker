//
//  TransactionModel.swift
//  BudgetTracker
//
//  Created by Самат Танкеев on 06.06.2025.
//


import Foundation

struct Transaction: Identifiable {
    let id: Int
    let account: BankAccount
    let category: Category
    let amount: Decimal
    let trasactionDate: Date
    let comment: String?
    let createdAt: Date
    let updatedAt: Date
    
}

extension Transaction {
    
    var jsonObject: Any {
           var dict: [String: Any] = [
               "id": id,
               "account": [
                   "id": account.id,
                   "userId": account.userId,
                   "name": account.name,
                   "balance": NSDecimalNumber(decimal: account.balance).intValue,
                   "currency": account.currency,
                   "createdAt": DateStringConverter.getStringUTC(from: account.createdAt),
                   "updatedAt": DateStringConverter.getStringUTC(from: account.updatedAt)
               ],
               "category": [
                   "id": category.id,
                   "name": category.name,
                   "emoji": String(category.emoji),
                   "isIncome": category.direction == .income
               ],
               "amount":  NSDecimalNumber(decimal: amount).intValue,
               "trasactionDate": DateStringConverter.getStringUTC(from: trasactionDate),
               "createdAt": DateStringConverter.getStringUTC(from: createdAt),
               "updatedAt": DateStringConverter.getStringUTC(from: updatedAt)
           ]
        
        if let comment {
            dict["comment"] = comment
        }
           
           return dict
       }
    
 
    static func parse(jsonObject: Any) -> Transaction? {
        
        
        guard let transactionDict = jsonObject as? [String: Any],
              let accountDict = transactionDict["account"] as? [String: Any],
              let categoryDict = transactionDict["category"] as? [String: Any],
              let account = parseAccount(accountDict: accountDict),
              let category = parseCategory(categoryDict: categoryDict),
              let id = transactionDict["id"] as? Int,
              let amount =  transactionDict["amount"] as? Int,
              let transactionDateStr = transactionDict["trasactionDate"] as? String,
              let transactionDate = DateStringConverter.getDate(from: transactionDateStr),
              let comment = transactionDict["comment"] as? String,
              let createdAtStr = transactionDict["createdAt"] as? String,
              let createdAt = DateStringConverter.getDate(from: createdAtStr),
              let updatedAtStr = transactionDict["updatedAt"] as? String,
              let updatedAt = DateStringConverter.getDate(from: updatedAtStr) else  {
            
            return nil
            
        }
        
        return Transaction(id: id, account: account, category: category, amount: Decimal(amount), trasactionDate: transactionDate, comment: comment, createdAt: createdAt, updatedAt: updatedAt)
    }
    
    
    static func parseCategory(categoryDict: [String: Any]) -> Category? {
        guard let id = categoryDict["id"] as? Int,
              let name = categoryDict["name"] as? String,
              let emoji = categoryDict["emoji"] as? String,
              let isIncome = categoryDict["isIncome"] as? Bool else {
            return nil
        }
        
        let direction: Direction = isIncome ? .income : .outcome
        
        return Category(id: id,
                        name: name,
                        emoji: Character(emoji),
                        direction: direction)
    }


    static func parseAccount(accountDict: [String: Any]) -> BankAccount? {
        guard let id = accountDict["id"] as? Int,
              let userId = accountDict["userId"] as? Int,
              let name = accountDict["name"] as? String,
              let balance = accountDict["balance"] as? Int,
              let currency = accountDict["currency"] as? String,
              let createdAtStr = accountDict["createdAt"] as? String,
              let createdAt = DateStringConverter.getDate(from: createdAtStr),
              let updatedAtStr = accountDict["updatedAt"] as? String,
              let updatedAt = DateStringConverter.getDate(from: updatedAtStr) else {
            return nil
        }
        
        return BankAccount(id: id, userId: userId, name: name, balance: Decimal(balance), currency: currency, createdAt: createdAt, updatedAt: updatedAt)
    }
    
    
    static func parse(csvLine: String) -> Transaction? {
        let csvRow = csvLine.components(separatedBy: ",")
        
        guard csvRow.count == 17 else { return nil }
        
        guard
            let id = Int(csvRow[0]),
            let amount = Decimal(string: csvRow[1]),
            let trasactionDate = DateStringConverter.getDate(from: csvRow[3]),
            let createdAt = DateStringConverter.getDate(from: csvRow[4]),
            let updatedAt = DateStringConverter.getDate(from: csvRow[5]),
            let accountId = Int(csvRow[6]),
            let accountUserId = Int(csvRow[7]),
            let accountBalance = Decimal(string: csvRow[9]),
            let categoryId = Int(csvRow[13]),
            let categoryIsIncome = Bool(csvRow[16])
        else {
            return nil
        }
        
        let account = BankAccount(
            id: accountId,
            userId: accountUserId,
            name: csvRow[8],
            balance: accountBalance,
            currency: csvRow[10],
            createdAt: DateStringConverter.getDate(from: csvRow[11]) ?? createdAt,
            updatedAt: DateStringConverter.getDate(from: csvRow[12]) ?? updatedAt
        )
        
        let direction: Direction = categoryIsIncome ? .income : .outcome
        let category = Category(
            id: categoryId,
            name: csvRow[14],
            emoji: Character(csvRow[15]),
            direction: direction
        )
        
        return Transaction(
            id: id,
            account: account,
            category: category,
            amount: amount,
            trasactionDate: trasactionDate,
            comment: csvRow[2],
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }
    
    

}





