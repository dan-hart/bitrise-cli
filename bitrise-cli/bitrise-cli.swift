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
    static let configuration = CommandConfiguration(abstract: "Manage Bitrise.io operations")

    enum Action: String, ExpressibleByArgument, CaseIterable {
        init?(argument: String) {
            let value = argument.lowercased()
            for m in bitrise_cli.Action.allCases {
                if value == m.rawValue.lowercased() {
                    self = m
                    return
                }
            }
            
            return nil
        }
        
        case setup
    }
    
    @Option(name: [.short, .customLong("action")], help: "\(bitrise_cli.Action.allCases.map({$0.rawValue}).joined(separator: ", "))")
        var action: Action = .setup
    
    @Flag(name: .long, help: "Print verbose updates.")
    var verbose = true

    mutating func run() throws {
        switch action {
        case .setup:
            try setup()
        }
    }
    
    // MARK: - Setup
    func setup() throws {
        
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
