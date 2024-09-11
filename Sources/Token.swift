//
//  File.swift
//  slox
//
//  Created by Wataru Miyakoshi on 2024/09/08.
//

import Foundation

final class Token: CustomStringConvertible {
    let type: TokenType
    let lexeme: String
    let literal: Any?
    let line: Int
    
    init(type: TokenType, lexeme: String, literal: Any?, line: Int) {
        self.type = type
        self.lexeme = lexeme
        self.literal = literal
        self.line = line
    }
    
    var description: String {
        "\(type) \(lexeme) \(literal ?? "")"
    }
}
