//
//  SystemViewModel.swift
//  Loop_On
//
//  Created by Auto on 1/15/26.
//

import Foundation
import SwiftUI

@MainActor
final class SystemViewModel: ObservableObject {
    @Published var isNotificationPermissionOn = true
    @Published var isCameraPermissionOn = true
    @Published var isPhotoPermissionOn = true

    var appVersion: String {
        (Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String) ?? "0.00.0"
    }

    func clearCache() {
        // TODO: 캐시 정리 로직
    }
}
