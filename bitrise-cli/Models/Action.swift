//
//  Action.swift
//  bitrise-cli
//
//  Created by Dan Hart on 4/14/22.
//

import Foundation
import ArgumentParser

enum Action: String, ExpressibleByArgument, CaseIterable {
    init?(argument: String) {
        let value = argument.lowercased()
        for m in Action.allCases {
            if value == m.rawValue.lowercased() {
                self = m
                return
            }
        }
        return nil
    }
    
    case setup
    case clearStoredData
}
