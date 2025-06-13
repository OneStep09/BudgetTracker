//
//  TransactionsFileCache.swift
//  BudgetTracker
//
//  Created by Самат Танкеев on 07.06.2025.
//
import Foundation

class TransactionsFileCache {
    
    private(set) var transactions: [Transaction] = []
    
    func addTransaction(_ transaction: Transaction) {
        guard !transactions.contains(where: { $0.id == transaction.id }) else {
               return
           }
        transactions.append(transaction)
    }
    
    func deleteTransaction(with id: Int) {
        transactions.removeAll {$0.id == id}
    }
    
    
    


      func writeToFile(to filename: String) throws {
          let jsonArray = transactions.map { $0.jsonObject }
          let jsonData = try JSONSerialization.data(withJSONObject: jsonArray, options: [.prettyPrinted])
          let fileURL = try getFileURL(filename: filename)
          try jsonData.write(to: fileURL, options: .atomic)
      }
    
    func load(from filename: String) throws {
            let fileURL = try getFileURL(filename: filename)
            
            guard FileManager.default.fileExists(atPath: fileURL.path) else {
                return
            }
            
            let data = try Data(contentsOf: fileURL)
            let jsonArray = try JSONSerialization.jsonObject(with: data, options: []) as? [Any] ?? []
         
            for jsonObject in jsonArray {
                if let transaction = Transaction.parse(jsonObject: jsonObject) {
                    transactions.append(transaction)
                }
            }
        }
    
    
    private func getFileURL(filename: String) throws -> URL {
          let fm = FileManager.default
          guard let docs = fm.urls(for: .documentDirectory, in: .userDomainMask).first else {
              throw NSError(domain: "Файловая ошибка", code: 1, userInfo: [NSLocalizedDescriptionKey: "Ошибка при чтении"])
          }
          return docs.appendingPathComponent(filename).appendingPathExtension("json")
      }
    
    
    
}
