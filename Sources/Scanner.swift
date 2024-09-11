//
//  File.swift
//  slox
//
//  Created by Wataru Miyakoshi on 2024/09/08.
//

import Foundation

@MainActor
final class Scanner {
    private let source: String
    private var tokens: [Token] = []
    private var startIndex: String.Index
    private var currentIndex: String.Index
    private var line: Int = 1
    
    static private let keywords: [String: TokenType] = [
        "and": .and,
        "class": .class,
        "else": .else,
        "false": .false,
        "for": .for,
        "fun": .fun,
        "if": .if,
        "nil": .nil,
        "or": .or,
        "print": .print,
        "return": .return,
        "super": .super,
        "this": .this,
        "true": .true,
        "var": .var,
        "while": .while
    ]
    

    init(source: String) {
        self.source = source
        self.startIndex = source.startIndex
        self.currentIndex = startIndex
    }
    
    func scanTokens() -> [Token] {
        while (!isAtEnd) {
            startIndex = currentIndex
            scanToken()
        }
        
        tokens.append(Token(type: .eof, lexeme: "", literal: nil, line: line))
        return tokens
    }
}

private extension Scanner {
    func incrementCurrentIndex() {
        currentIndex = source.index(after: currentIndex)
    }

    var isAtEnd: Bool {
        return currentIndex >= source.endIndex
    }
    
    func scanToken() {
        guard let c: Character = advance() // これを実行した時点で、currentIndexは進んでいる
        else { return }
        
        switch c {
        case "(": addToken(type: .leftParenthesis); break
        case ")": addToken(type: .rightParenthesis); break
        case "{": addToken(type: .leftBrace); break
        case "}": addToken(type: .rightBrace); break
        case ",": addToken(type: .comma); break
        case ".": addToken(type: .dot); break
        case "-": addToken(type: .minus); break
        case "+": addToken(type: .plus); break
        case ";": addToken(type: .semicolon); break
        case "*": addToken(type: .star); break
            
        // NOTE: 次に文字が存在するかもしれない場合の文字の判定方法。
        // 次の文字を返却せずに見る。
        // トークンを、
        case "!":
            addToken(type: match("=") ? .bangEqual : .bang)
            break
        case "=":
            addToken(type: match("=") ? .equalEqual : .equal)
            break
        case "<":
            addToken(type: match("=") ? .lessEqual : .less)
            break
        case ">":
            addToken(type: match("=") ? .greaterEqual : .greater)
            break
            
        // コメント
        case "/":
            if (match("/")) {
                // コメントの場合は、意味を持たせたくない。
                // つまり「トークンとして扱わない」ことが「意味を持たせない」ことになる。
                while (peek != "\n" && !isAtEnd) {
                    advance() // 行末まで文字を進めるだけ
                }
            } else {
                addToken(type: .slash) // 1文字の場合のみスラッシュと判断する
            }
            break
        
        // エスケープしたいキャラクタは、何もアクションを起こさない
        case " ", "\r", "\t": break
        
        // 改行は、行数をインクリメントする
        case "\n":
            line += 1
            break
            
        // リテラル
        case "\"":
            string()
            break
        default:
            if c.isNumber {
                number()
            } else if isAlpha(c) {
                identifier()
            } else {
                Slox.error(line: line, message: "Unexpected character.")
            }
            
            break
        }
    }
    
    /// 現在の文字を返却した後、インデックスを進める
    @discardableResult///
    func advance() -> Character? {
        guard !isAtEnd
        else { return nil }
        
        let char = source[currentIndex]
        incrementCurrentIndex()
        return char
    }
    
    func addToken(type: TokenType) {
        addToken(type: type, literal: nil)
    }
    
    func addToken(type: TokenType, literal: Any?) {
        let text: String = String(source[startIndex..<currentIndex])
        tokens.append(Token(type: type, lexeme: text, literal: nil, line: line))
    }
    
    /// 期待した文字の場合に限り、インデックスを進める(文字を消費する)
    func match(_ expected: Character) -> Bool {
        guard !isAtEnd,
              source[currentIndex] == expected
        else { return false }
        
        incrementCurrentIndex()
        return true
    }
    
    var peek: Character {
        if (isAtEnd) {
            return "\0"
        }
        
        return source[currentIndex]
    }
    
    var peekNext: Character {
        if (source.index(after: currentIndex) >= source.endIndex) {
            return "\0"
        }
        
        let currentChar = source[currentIndex]
        incrementCurrentIndex()
        return currentChar
    }
    
    func string() {
        while (peek != "\"" && !isAtEnd) {
            if (peek == "\n") {
                line += 1
            }
            advance()
        }
        
        if isAtEnd {
            Slox.error(line: line, message: "Unterminated string.")
            return
        }
        
        advance() // 右のダブルクォーテーションを消費する
        // 左右の1文字(ダブルクォーテーション)を削除する
        let value = String(source[source.index(after: startIndex)..<source.index(before: currentIndex)])
        addToken(type: .string, literal: value) // リテラルのバリューの使い方は、こうか。
    }
    
    func number() {
        while (peek.isNumber) {
            advance()
        }
        
        if (peek == "." && peekNext.isNumber) {
            advance()
            
            while (peek.isNumber) {
                advance()
            }
        }
        
        addToken(
            type: .number,
            literal: Double(String(source[startIndex..<currentIndex]))
        )
    }
    
    func isAlpha(_ char: Character) -> Bool {
        char.isLetter || char == "_"
    }
    
    func isAlphaNumeric(_ char: Character) -> Bool {
        isAlpha(char) || char.isNumber
    }
    
    func identifier() {
        while (isAlphaNumeric(peek)) {
            advance()
        }
        
        let text: String = String(source[startIndex..<currentIndex])
        if let type: TokenType = Self.keywords[text] {
            addToken(type: type)
        } else {
            addToken(type: .identifier)
        }
    }
}
