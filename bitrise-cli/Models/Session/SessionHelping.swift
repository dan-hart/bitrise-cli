//
//  SessionHelping.swift
//  bitrise-cli
//
//  Created by Dan Hart on 4/14/22.
//

import Foundation
import SwiftUI
import BitriseSwift

protocol SessionHelping {
    var verbose: Bool { get set }
    var token: String? { get set }
    var selectedAppSlug: String? { get set }
    var isAuthenticated: Bool { get set }
    
    func startSession(with optionalToken: String?) async
    func clearStoredData()
    
    // MARK: - Operations
    func fetch<T>(_ apiRequest: APIRequest<T>) async -> T.SuccessType?
}
