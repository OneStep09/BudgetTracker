//
//  TransactionsService.swift
//  BudgetTracker
//
//  Created by Самат Танкеев on 11.06.2025.
//
import Foundation

protocol TransactionsService {
    func fetchTransactions(accountId: Int, startDate: Date, endDate: Date) async throws -> [Transaction]
    func createTransaction(request: CreateTransactionRequest) async throws -> Transaction
    func removeTransaction(transactionId: Int) async throws -> Transaction
    func updateTransaction(request: UpdateTransactionRequest) async throws -> Transaction
}
