import Foundation

class TransactionsFileCache {
    
    private(set) var transactions: [Transaction] = []
    private let filename: String
    private let fileURL: URL
    
    init(filename: String) throws {
        self.filename = filename
        self.fileURL = try Self.getFileURL(filename: filename)
    }
    
    func addTransaction(_ transaction: Transaction) {
        guard !transactions.contains(where: { $0.id == transaction.id }) else {
            return
        }
        transactions.append(transaction)
    }
    
    func deleteTransaction(with id: Int) {
        transactions.removeAll { $0.id == id }
    }
    
    func writeToFile() throws {
        let jsonArray = transactions.map { $0.jsonObject }
        let jsonData = try JSONSerialization.data(withJSONObject: jsonArray, options: [.prettyPrinted])
        try jsonData.write(to: fileURL, options: .atomic)
    }
    
    func load() throws {
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            return
        }
        
        let data = try Data(contentsOf: fileURL)
        let jsonArray = try JSONSerialization.jsonObject(with: data, options: []) as? [Any] ?? []
        
        transactions.removeAll()
        
        for jsonObject in jsonArray {
            if let transaction = Transaction.parse(jsonObject: jsonObject) {
                transactions.append(transaction)
            }
        }
    }
    
    private static func getFileURL(filename: String) throws -> URL {
        let fm = FileManager.default
        guard let docs = fm.urls(for: .documentDirectory, in: .userDomainMask).first else {
            throw TransactionsFileCacheError.fileNotFound
        }
        return docs.appendingPathComponent(filename).appendingPathExtension("json")
    }
}
