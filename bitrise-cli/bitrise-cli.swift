//
//  bitrise-cli.swift
//  bitrise-cli
//
//  Created by Dan Hart on 4/14/22.
//

import Foundation
import ArgumentParser

@main
struct bitrise_cli: ParsableCommand {
    static let _commandName: String = "bitrise-cli"
    static let configuration = CommandConfiguration(abstract: "Unofficial bitrise cli")
    
    @Option(name: [.short, .customLong("action")], help: "\(Action.allCases.map({$0.rawValue}).joined(separator: ", "))")
        var action: Action = .setup
    
    @Flag(name: .long, help: "Print verbose updates.")
    var verbose = false

    mutating func run() throws {
        switch action {
        case .setup:
            try setup()
        }
        
        print("Press Enter to exit \(bitrise_cli.self)...")
        _ = readLine()
    }
    
    // MARK: - Setup
    func setup() throws {
        if let token = SessionHelper.shared.token {
            SessionHelper.shared.startSession(with: token)
        } else {
            print("Please enter a token: ")
            let enteredToken = readLine()
            SessionHelper.shared.startSession(with: enteredToken)
        }
        print("Press Enter to continue...")
        _ = readLine()
        
        if let slug = SessionHelper.shared.selectedAppSlug {
            print("App Slug: \(slug)")
        } else {
            print("Apps: ")
            SessionHelper.shared.getApps()
            print("Type app slug: ")
            SessionHelper.shared.selectedAppSlug = readLine()
        }
        
        print("Press Enter to exit setup...")
        _ = readLine()
    }
    
    // MARK: - Helpers
    func log(_ message: String?) {
        if let logMessage = message {
            if verbose { print(logMessage) }
        }
    }
}

struct RuntimeError: Error, CustomStringConvertible {
    var description: String
    
    init(_ description: String) {
        self.description = description
    }
}
