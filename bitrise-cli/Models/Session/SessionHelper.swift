//
//  SessionHelper.swift
//  bitrise-cli
//
//  Created by Dan Hart on 4/14/22.
//

import Foundation
import KeychainAccess
import BitriseSwift
import SwiftUI

class SessionHelper: SessionHelping {
    static var shared: SessionHelping = SessionHelper()
    
    var verbose = false
    var keychainKeyIdentifier = "BITRISE_API_TOKEN"
    var isAuthenticated = false {
        didSet {
            log("Set Authenticated: \(isAuthenticated)")
        }
    }
    
    var client: APIClient? {
        didSet {
            log("Set Client: \(client?.baseURL ?? "nil")")
        }
    }
    var user: V0UserProfileDataModel? {
        didSet {
            log("Set User: \(user?.username ?? "nil")")
        }
    }
    
    // MARK: - App Storage
    @AppStorage("selectedAppSlug") var selectedAppSlug: String? {
        didSet {
            log("Set selectedAppSlug: \(selectedAppSlug ?? "nil")")
        }
    }
    
    // MARK: - Computed
    var bundleID: String {
        Bundle.main.bundleIdentifier ?? ""
    }

    private var keychain: Keychain {
        Keychain(service: bundleID)
    }

    var token: String? {
        get {
            return keychain[keychainKeyIdentifier]
        }
        
        set {
            keychain[keychainKeyIdentifier] = newValue
        }
    }
    
    // MARK: - Methods
    func invalidateSession() {
        log("Invalidating session...")
        keychain[keychainKeyIdentifier] = nil
        log("Cleared keychain")
        isAuthenticated = false
        client = nil
        user = nil
    }
    
    func clearStoredData() {
        log("Clearing stored data...")
        selectedAppSlug = nil
        token = nil
    }

    func startSession(with optionalToken: String? = nil) async {
        log("Starting session")
        await authenticate(using: optionalToken ?? token ?? "")
    }

    // MARK: - Authentication
    private func authenticate(using token: String?) async {
        guard let token = token, !token.isEmpty else {
            isAuthenticated = false
            log("token is nil or empty, skipping authentication")
            return
        }

        let getUserRequest = BitriseSwift.User.UserProfile.Request()
        client = APIClient.default
        client?.defaultHeaders["Authorization"] = token
        BitriseSwift.safeArrayDecoding = true
        BitriseSwift.safeOptionalDecoding = true
        
        let response = await make(request: getUserRequest)
        switch response.result {
        case .success(let response):
            self.isAuthenticated = true
            self.token = token
            self.user = response.success?.data
            print("🛰 Authenticated as: \(self.user?.username ?? "Unknown Username")")
        case .failure(let error):
            print(error.localizedDescription)
            log("\(error)")
            self.isAuthenticated = false
            self.token = nil
        }
    }
    
    // MARK: - Helper Methods
    func fetch<T>(_ apiRequest: APIRequest<T>) async -> T.SuccessType? {
        if !isAuthenticated { return nil }
        let response = await make(request: apiRequest)
        return handle(response)
    }
    
    func make<T>(request: APIRequest<T>) async -> APIResponse<T> {
        return await withCheckedContinuation { continuation in
            self.client?.makeRequest(request) { response in
                continuation.resume(returning: response)
            }
        }
    }
    
    func handle<T>(_ response: APIResponse<T>) -> T.SuccessType? {
        switch response.result {
        case .success(let value):
            return value.success
        case .failure(let error):
            let stringData = String(data: response.data ?? Data(), encoding: .utf8)
            let responseCode = response.urlResponse?.statusCode ?? -1
            log("Error")
            log("Data: \(stringData ?? "Empty")")
            log("Response Code: \(responseCode)")
            log("Error: \(error)")
            print(error.localizedDescription)
        }
        
        return nil
    }
    
    func log(_ message: String?) {
        if let logMessage = message {
            if verbose { print("\(SessionHelper.self)" + ": " + logMessage) }
        }
    }
}
