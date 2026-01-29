//
//  PersonalProfileViewModel.swift
//  Loop_On
//
//  Created by Auto on 1/15/26.
//

import Foundation
import SwiftUI

@MainActor
final class PersonalProfileViewModel: ObservableObject {
    @Published var user: UserModel?
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    // 챌린지 이미지들
    @Published var challengeImages: [String?] = []
    
    init() {
        // TODO: Load user profile data
        loadProfile()
    }
    
    func loadProfile() {
        isLoading = true
        // TODO: Fetch user profile from API
        // For now, use mock data
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.user = UserModel(
                id: "1",
                name: "서리",
                profileImageURL: nil,
                bio: "LOOP:ON 디자이너 서리/최서정\n룸온팀 파이팅!!"
            )
            // Mock challenge images (6개)
            self.challengeImages = Array(repeating: nil, count: 6)
            self.isLoading = false
        }
    }
    
    func refreshProfile() {
        loadProfile()
    }
}
