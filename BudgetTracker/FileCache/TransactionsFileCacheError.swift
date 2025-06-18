//
//  TransactionsFileCacheError.swift
//  BudgetTracker
//
//  Created by Самат Танкеев on 18.06.2025.
//
import Foundation

enum TransactionsFileCacheError: LocalizedError {
    case fileNotFound
    case invalidData

    var localizedDescription: String {
        switch self {
        case .fileNotFound:
            return "File not found at the specified path."
        case .invalidData:
            return "The data in the file is invalid."
        }
    }
}
