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
    @Environment(SessionStore.self) private var session
    @Environment(SignUpFlowStore.self) private var flowStore
    
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
        .onAppear {
            // 프로필 단계에서 최종 회원가입을 수행하기 위해 공유 스토어를 주입
            vm.bindFlowStore(flowStore)
        }
        .onChange(of: vm.isProfileSaved) { _, isSaved in
            if isSaved {
                // 회원가입 완료 시 로그인 이력 저장 (백엔드 정책에 따라 조정 가능)
                session.markLoggedIn()
                flowStore.reset()
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
    @State private var flowStore = SignUpFlowStore()
    
    var body: some View {
        NavigationStack(path: $router.path) {
            ProfileView()
                .environment(router)
                .environment(session)
                .environment(flowStore)
        }
    }
}
