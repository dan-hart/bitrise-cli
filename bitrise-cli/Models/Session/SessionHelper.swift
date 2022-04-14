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
    
    var keychainKeyIdentifier = "BITRISE_API_TOKEN"
    var isAuthenticated = false
    
    var client: APIClient?
    var user: V0UserProfileDataModel?
    
    // MARK: - App Storage
    @AppStorage("selectedAppSlug") var selectedAppSlug: String?
    
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
        keychain[keychainKeyIdentifier] = nil
        isAuthenticated = false
    }

    func startSession(with optionalToken: String? = nil) {
        if let token = optionalToken {
            // Continue existing session
            authenticate(using: token)
        } else {
            authenticate(using: token)
        }
    }

    // MARK: - Authentication
    private func authenticate(using token: String?) {
        guard let token = token, !token.isEmpty else {
            return
        }

        let getUserRequest = BitriseSwift.User.UserProfile.Request()
        client = APIClient.default
        client?.defaultHeaders["Authorization"] = token
        BitriseSwift.safeArrayDecoding = true
        BitriseSwift.safeOptionalDecoding = true
        
        client?.makeRequest(getUserRequest) { apiResponse in
            switch apiResponse.result {
            case .success(let response):
                self.isAuthenticated = true
                self.user = response.success?.data
                print("Authenticated as: \(self.user?.username ?? "Unknown Username")")
            case .failure(let error):
                print(error.localizedDescription)
                self.isAuthenticated = false
            }
        }
    }
    
    // MARK: - Operations
    func getApps() {
        if !isAuthenticated { return }
        let request = BitriseSwift.Application.AppList.Request()
        client?.makeRequest(request, complete: { apiResponse in
            let value = self.handle(apiResponse)
            for app in value?.data ?? [] {
                print((app.title ?? "Title") + ": " + (app.slug ?? "Slug"))
            }
        })
    }
    
    // MARK: - Helper Methods
    func handle<T>(_ response: APIResponse<T>) -> T.SuccessType? {
        switch response.result {
        case .success(let value):
            return value.success
        case .failure(let error):
            let stringData = String(data: response.data ?? Data(), encoding: .utf8)
            let responseCode = response.urlResponse?.statusCode ?? -1
            print("Error")
            print("Data: \(stringData ?? "Empty")")
            print("Response Code: \(responseCode)")
            print("Error: \(error)")
            print(error.localizedDescription)
        }
        
        return nil
    }
}
