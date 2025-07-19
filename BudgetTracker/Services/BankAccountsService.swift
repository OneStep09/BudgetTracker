//
//  BankAccountsService.swift
//  BudgetTracker
//
//  Created by Самат Танкеев on 11.06.2025.
//

import Foundation

protocol BankAccountsService {
    func fetchAccount() async throws -> BankAccount
    func updateAccount(account: BankAccount) async throws -> BankAccount
}





