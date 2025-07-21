//
//  NetworkClient.swift
//  BudgetTracker
//
//  Created by Самат Танкеев on 17.07.2025.
//

import Foundation


// MARK: - Network Client
class NetworkClient {
    
    private let baseURL: URL = URL(string: "https://shmr-finance.ru")!
    private let apiPrefix = "/api/v1/"
    private let session = URLSession.shared
    private let token = "hxJAcmx39VoC5qyGgrViLT3p" // Сюда свой токен
    
    static let shared = NetworkClient()
   
    
    
    // MARK: - Request
    func request<T: Encodable, U: Decodable>(
        endpoint: String,
        method: HTTPMethod = .get,
        parameters: T? = nil as String?
    ) async throws -> U {
        
        guard let url = URL(string: apiPrefix + endpoint, relativeTo: baseURL) else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        try configureRequest(&request, with: parameters, for: method)
        print("➡️ Request: \(request.httpMethod ?? "") \(request.url?.absoluteString ?? "")")
        
        if let body = request.httpBody,
           let bodyString = String(data: body, encoding: .utf8) {
            print("Request Body:\n\(bodyString)")
        }
        do {
            let (data, response) = try await session.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkError.invalidResponse
            }
            
            print("⬅️ Response: \(httpResponse.statusCode)")
            
            if let responseString = String(data: data, encoding: .utf8) {
                print("Response Data:\n\(responseString)")
            }

            
            try validateHTTPResponse(httpResponse, data: data)
            
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            return try decoder.decode(U.self, from: data)
          
            
        } catch let error as NetworkError {
            throw error
        } catch {
            throw NetworkError.deserializationError(error.localizedDescription)
        }
    }
    
    
    
   
    private func configureRequest<T: Encodable>(
        _ request: inout URLRequest,
        with parameters: T?,
        for method: HTTPMethod
    ) throws {
        
        guard let parameters = parameters else { return }
        switch method {
        case .get, .delete:
            try addQueryParameters(to: &request, parameters: parameters)
            
        case .post, .put, .patch:
            try addBodyParameters(to: &request, parameters: parameters)
        }
    }
    
    private func addQueryParameters<T: Encodable>(
        to request: inout URLRequest,
        parameters: T
    ) throws {
        guard let url = request.url else { return }
        
        let encoder = JSONEncoder()
        let data = try encoder.encode(parameters)
        
        guard let dictionary = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            return
        }
        
        var components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        components?.queryItems = dictionary.compactMap { key, value in
            URLQueryItem(name: key, value: "\(value)")
        }
        
        request.url = components?.url
    }
    
    private func addBodyParameters<T: Encodable>(
        to request: inout URLRequest,
        parameters: T
    ) throws {
        let encoder = JSONEncoder()
        request.httpBody = try encoder.encode(parameters)
    }
    
    
    private func validateHTTPResponse(_ response: HTTPURLResponse, data: Data) throws {
        switch response.statusCode {
        case 200...299:
            return // Запрос выполнился успешно
        case 400:
            throw NetworkError.badRequest
        case 401:
            throw NetworkError.unauthorized
        case 403:
            throw NetworkError.forbidden
        case 404:
            throw NetworkError.notFound
        case 415:
            throw NetworkError.unsupportedMediaType
        case 500:
            throw NetworkError.internalServerError
        case 502:
            throw NetworkError.badGateway
        default:
            throw NetworkError.httpError(code: response.statusCode)
        }
    }
}

// MARK: - HTTP Methods
enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case patch = "PATCH"
    case delete = "DELETE"
}



// MARK: - Network Errors
enum NetworkError: Error, LocalizedError {
    case invalidURL
    case invalidResponse
    case networkError
    case serializationError(String)
    case deserializationError(String)
    
    // Ошибки HTTP
    case badRequest
    case unauthorized
    case forbidden
    case notFound
    case unsupportedMediaType
    case internalServerError
    case badGateway
    case httpError(code: Int)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Недопустимый URL"
        case .invalidResponse:
            return "Недопустимый ответ"
        case .networkError:
            return "Сетевая ошибка"
        case .serializationError(let message):
            return "Ошибка сериализации: \(message)"
        case .deserializationError(let message):
            return "Ошибка десериализации: \(message)"
        case .badRequest:
            return "Некорректный запрос"
        case .unauthorized:
            return "Неавторизованный доступ"
        case .forbidden:
            return "Доступ запрещён"
        case .notFound:
            return "Не найдено"
        case .unsupportedMediaType:
            return "Неподдерживаемый контент"
        case .internalServerError:
            return "Внутренняя ошибка сервера"
        case .badGateway:
            return "Проблемы с сервером"
        case .httpError(let code):
            return "Ошибка HTTP (\(code))"
        }
    }
    
    var statusCode: Int? {
        switch self {
        case .badRequest: return 400
        case .unauthorized: return 401
        case .forbidden: return 403
        case .notFound: return 404
        case .internalServerError: return 500
        case .badGateway: return 502
        case .httpError(let code): return code
        default: return nil
        }
    }
}



