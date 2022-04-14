//
//  SessionHelping.swift
//  bitrise-cli
//
//  Created by Dan Hart on 4/14/22.
//

import Foundation
import SwiftUI
protocol SessionHelping {
    var token: String? { get set }
    var selectedAppSlug: String? { get set }
    func startSession(with optionalToken: String?)
    
    // MARK: - Operations
    func getApps()
}
