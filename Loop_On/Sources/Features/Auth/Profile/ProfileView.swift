//
//  ProfileView.swift
//  Loop_On
//
//  Created by Auto on 1/14/26.
//

import SwiftUI

struct ProfileView: View {
    @StateObject private var vm = ProfileViewModel()
    @Environment(NavigationRouter.self) private var router
    
    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                ProfileHeaderSection(vm: vm)
                
                ProfileFormSection(vm: vm)
            }
            .padding(.horizontal, 26)
            .padding(.bottom, 28)
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .background(Color.white)
        .onChange(of: vm.isProfileSaved) { _, isSaved in
            if isSaved {
                // 프로필 저장 성공 후 홈 화면으로 이동
                router.reset()
                router.push(.app(.home))
            }
        }
    }
}

#Preview("ProfileView - Wrapped") {
    ProfilePreviewContainer()
}

private struct ProfilePreviewContainer: View {
    @State private var router = NavigationRouter()
    @State private var session = SessionStore()
    
    var body: some View {
        NavigationStack(path: $router.path) {
            ProfileView()
                .environment(router)
                .environment(session)
        }
    }
}
