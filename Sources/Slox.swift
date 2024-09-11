// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation

@main
@MainActor
struct Slox {
    static let arguments = CommandLine.arguments
    static var hadError: Bool = false
    
    static func main() throws {
        if (arguments.count > 2) {
            print("Usage: slox [script]")
            return
        } else if (arguments.count == 2) {
            try runFile(arguments[1])
        } else {
            try runPrompt()
        }
        
        exit(0)
    }
    
    private static func runFile(_ path: String) throws {
        let fileManager = FileManager.default
        
        guard fileManager.fileExists(atPath: path)
        else {
            print("File does not exists")
            exit(1)
        }
        
        let fileContents = try String(contentsOfFile: path)
        run(fileContents)
        
        if (hadError) {
            exit(1)
        } else {
            exit(0)
        }
    }
    
    private static func runPrompt() throws {
        while true {
            print("> ", terminator: "") // プロンプトを表示する
            
            guard let line = readLine() // Ctrl-Dを入力すると、EOF状態のシグナルが送信される。そうするとreadLineはnilを返却し、breakする。
            else {
                break
            }
            
            run(line)
            hadError = false
        }
    }
    
    private static func run(_ source: String) {
        let scanner: Scanner = Scanner(source: source)
        let tokens: [Token] = scanner.scanTokens()
        
        for token in tokens {
            print(token)
        }
    }
    
    static func error(line: Int, message: String) {
        report(line: line, place: "", message: message)
    }
    
    private static func report(line: Int, place: String, message: String) {
        print("[line \(line)] Error \(place): \(message)")
        hadError = true
    }
}
