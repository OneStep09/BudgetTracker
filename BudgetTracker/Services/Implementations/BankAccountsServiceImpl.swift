//
//  BankAccountsServiceImpl.swift
//  BudgetTracker
//
//  Created by Самат Танкеев on 18.07.2025.
//

import Foundation

final class BankAccountsServiceImpl: BankAccountsService {
    func fetchAccount() async throws -> BankAccount {
        let endpoint = "accounts"
        let account: [BankAccountDTO] = try await NetworkClient.shared.request(endpoint: endpoint)
        return account[0].toBankAccount()
    }
    
    func updateAccount(account: BankAccount) async throws -> BankAccount {
        let endpoint = "accounts/\(account.id)"
        let request = UpdateAccountRequest(name:account.name,
                                           balance: String(describing: account.balance),
                                           currency: account.currency.rawValue)
        let account : BankAccountDTO = try await NetworkClient.shared.request(endpoint: endpoint, method: .put, parameters: request)
        return account.toBankAccount()
    }
}
