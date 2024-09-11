//
//  File.swift
//  slox
//
//  Created by Wataru Miyakoshi on 2024/09/08.
//

import Foundation

enum TokenType {
    // MARK: - 記号1個のトークン
    case leftParenthesis
    case rightParenthesis
    case leftBrace
    case rightBrace
    case comma
    case dot
    case minus
    case plus
    case semicolon
    case slash
    case star
    
    // MARK: - 記号1個または2個によるトークン
    case bang
    case bangEqual
    case equal
    case equalEqual
    case greater
    case greaterEqual
    case less
    case lessEqual
    
    // MARK: - リテラル
    case identifier
    case string
    case number
    
    // MARK: - keyword
    case `and`
    case `class`
    case `else`
    case `false`
    case fun
    case `for`
    case `if`
    case `nil`
    case `or`
    case print
    case `return`
    case `super`
    case this
    case `true`
    case `var`
    case `while`
    
    // MARK: - EOF
    case eof
}
