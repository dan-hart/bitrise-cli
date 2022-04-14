//
//  bitrise-cli.swift
//  bitrise-cli
//
//  Created by Dan Hart on 4/14/22.
//

import Foundation
import ArgumentParser
import BitriseSwift

@main
struct bitrise_cli: ParsableCommand {
    static let _commandName: String = "bitrise-cli"
    static let configuration = CommandConfiguration(abstract: "Unofficial bitrise cli")
    
    @Option(name: [.short, .customLong("action")], help: "\(Action.allCases.map({$0.rawValue}).joined(separator: ", "))")
    var action: Action = .setup
    
    @Flag(name: .long, help: "Print verbose updates.")
    var verbose = false
    
    mutating func run() throws {
        print("🎉 Welcome to \(bitrise_cli.self)!")
        
        SessionHelper.shared.verbose = verbose
        
        switch self.action {
        case .setup:
            try setup()
        case .clearStoredData:
            SessionHelper.shared.clearStoredData()
            print("🫧 Cleared stored data")
        }
        
        print("❌ Press enter to exit...")
        _ = readLine()
    }
    
    // MARK: - Setup
    func authenticate() {
        let group = DispatchGroup()
        group.enter()
        Task {
            if let token = SessionHelper.shared.token {
                await SessionHelper.shared.startSession(with: token)
            } else {
                print("🔐 Please enter a Bitrise Personal Access Key: ")
                let enteredToken = readLine(strippingNewline: true)
                await SessionHelper.shared.startSession(with: enteredToken)
                if SessionHelper.shared.isAuthenticated {
                    SessionHelper.shared.token = enteredToken
                }
            }
            group.leave()
        }
        group.wait()
    }
    
    func setup() throws {
        authenticate()

        let group = DispatchGroup()
        if SessionHelper.shared.selectedAppSlug == nil {
            group.enter()
            Task {
                let result = await SessionHelper.shared.fetch(BitriseSwift.Application.AppList.Request())
                print("📲 Apps: ")
                for app in result?.data ?? [] {
                    print((app.title ?? "") + ": " + (app.slug ?? ""))
                }
                print("⌨️ Type app slug: ")
                SessionHelper.shared.selectedAppSlug = readLine()
                group.leave()
            }
        }
        
        group.wait()
        
        print("✅ Setup complete, selected app slug: \(SessionHelper.shared.selectedAppSlug ?? "ERROR")")
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
