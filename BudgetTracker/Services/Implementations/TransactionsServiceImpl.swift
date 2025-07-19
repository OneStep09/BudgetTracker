//
//  TransactionsServiceImpl.swift
//  BudgetTracker
//
//  Created by Самат Танкеев on 18.07.2025.
//

import Foundation

final class TransactionsServiceImpl: TransactionsService {
    
    
    func fetchTransactions(accountId: Int, startDate: Date, endDate: Date) async throws -> [Transaction] {
        let endpoint = "transactions/account/\(accountId)/period"
        let startDateStr = DateStringConverter.getString(from: startDate, formatType: .yearMonthDate)
        let endDateStr = DateStringConverter.getString(from: endDate, formatType: .yearMonthDate)
        let request = TransactionsRequest(startDate: startDateStr, endDate: endDateStr)
        
        
        
        let transactionsDTO: [TransactionDTO] = try await NetworkClient.shared.request(endpoint: endpoint,
                                                                                       method: .get,
                                                                                       parameters: request)
        
        return transactionsDTO.map { $0.toTransaction() }
    }
    
    func createTransaction(request: CreateTransactionRequest) async throws -> Transaction {
        let endpoint = "transactions"
        let transactionDTO: TransactionDTO = try await NetworkClient.shared.request(endpoint: endpoint,
                                                                      method: .post,
                                                                      parameters: request)
        return transactionDTO.toTransaction()
    }
    
    func removeTransaction(transactionId: Int) async throws -> Transaction {
        let endpoint = "transactions/\(transactionId)"
        let transactionDTO: TransactionDTO = try await NetworkClient.shared.request(endpoint: endpoint,
                                                                      method: .delete,
                                                                      parameters: nil as String?)
        return transactionDTO.toTransaction()
    }
    
    func updateTransaction(request : UpdateTransactionRequest) async throws -> Transaction {
        let endpoint = "transactions/\(request.id)"
        let transactionDTO: TransactionDTO = try await NetworkClient.shared.request(endpoint: endpoint,
                                                                      method: .put,
                                                                      parameters: request)
        return transactionDTO.toTransaction()
    }
}
