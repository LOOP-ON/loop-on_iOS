//
//  SessionStore.swift
//  Loop_On
//
//  Created by 이경민 on 1/1/26.
//

import Foundation
import Observation

@Observable
final class SessionStore {
    private let key = "hasLoggedInBefore"

    var hasLoggedInBefore: Bool {
        get { UserDefaults.standard.bool(forKey: key) }
        set { UserDefaults.standard.set(newValue, forKey: key) }
    }

    func markLoggedIn() {
        hasLoggedInBefore = true
    }

    func logout() {
        KeychainService.shared.deleteToken()
        hasLoggedInBefore = false
    }
}
