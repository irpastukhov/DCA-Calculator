//
//  StringExtension.swift
//  dca-calculator
//
//  Created by Ivan Pastukhov on 22.07.2021.
//

import Foundation

extension String {
    
    func addBrackets () -> String {
        return "(\(self))"
    }
    
    func prefix(with text: String) -> String {
        return text + self
    }
    
    func toDouble() -> Double? {
        return Double(self)
    }
    
}
