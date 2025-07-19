//
//  CreateTransactionRequest 2.swift
//  BudgetTracker
//
//  Created by Самат Танкеев on 17.07.2025.
//


struct UpdateTransactionRequest: Encodable {
    let id: Int
    let accountId: Int
    let categoryId: Int
    let amount: String
    let transactionDate: String
    let comment: String?
    
    enum CodingKeys: CodingKey {
        case accountId
        case categoryId
        case amount
        case transactionDate
        case comment
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.accountId, forKey: .accountId)
        try container.encode(self.categoryId, forKey: .categoryId)
        try container.encode(self.amount, forKey: .amount)
        try container.encode(self.transactionDate, forKey: .transactionDate)
        try container.encodeIfPresent(self.comment, forKey: .comment)
    }
}
