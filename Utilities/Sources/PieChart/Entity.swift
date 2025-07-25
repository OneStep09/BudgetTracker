//
//  Enity.swift
//  Utilities
//
//  Created by Самат Танкеев on 21.07.2025.
//
import Foundation

public struct Entity: Equatable {
    public let value: Decimal
    public let label: String
    
    public init(value: Decimal, label: String) {
        self.value = value
        self.label = label
    }
}
